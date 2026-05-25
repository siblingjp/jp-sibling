import { z } from 'zod'
import { Decimal } from '@prisma/client/runtime/library'

const itemSchema = z.object({
  productId: z.string(),
  quantity: z.number().int().positive(),
  options: z.array(z.object({
    optionId: z.string(),
    name: z.string(),
    extraPrice: z.number(),
  })).optional().default([]),
  note: z.string().optional(),
})

const schema = z.object({
  items: z.array(itemSchema).min(1),
  note: z.string().optional(),
  pointsToRedeem: z.number().int().min(0).optional().default(0),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const body = validate(schema, await readBody(event))

    const productIds = body.items.map(i => i.productId)
    const products = await prisma.product.findMany({
      where: { id: { in: productIds }, isActive: true },
    })

    const productMap = new Map(products.map(p => [p.id, p]))

    let subtotal = 0
    const itemsData = body.items.map(item => {
      const product = productMap.get(item.productId)
      if (!product) throw badRequest(`Product ${item.productId} not found`)
      const optionExtra = item.options.reduce((sum, o) => sum + o.extraPrice, 0)
      const unitPrice = Number(product.price) + optionExtra
      const itemSubtotal = unitPrice * item.quantity
      subtotal += itemSubtotal
      return { ...item, unitPrice, subtotal: itemSubtotal }
    })

    const member = await prisma.member.findUnique({ where: { id: session.member.id } })
    if (!member) throw unauthorized()

    const pointsToRedeem = Math.min(body.pointsToRedeem, member.points, Math.floor(subtotal))
    const discount = pointsToRedeem
    const total = subtotal - discount

    const tierMultiplier = member.tier === 'VIP' ? 1.5 : member.tier === 'GOLD' ? 1.25 : 1.0
    const pointsEarned = Math.floor((total / 10) * tierMultiplier)

    const order = await prisma.$transaction(async (tx) => {
      const newOrder = await tx.memberOrder.create({
        data: {
          memberId: member.id,
          source: 'ONLINE',
          note: body.note,
          subtotal,
          discountKind: pointsToRedeem > 0 ? 'AMOUNT' : undefined,
          discountValue: pointsToRedeem > 0 ? pointsToRedeem : undefined,
          discount,
          total,
          pointsEarned,
          pointsRedeemed: pointsToRedeem,
          items: {
            create: itemsData.map(item => ({
              productId: item.productId,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              subtotal: item.subtotal,
              note: item.note,
              options: {
                create: item.options.map(o => ({
                  optionId: o.optionId,
                  name: o.name,
                  extraPrice: o.extraPrice,
                })),
              },
            })),
          },
        },
      })

      if (pointsToRedeem > 0) {
        await tx.member.update({
          where: { id: member.id },
          data: { points: { decrement: pointsToRedeem } },
        })
        await tx.pointLog.create({
          data: {
            memberId: member.id,
            action: 'REDEEM',
            amount: -pointsToRedeem,
            memberOrderId: newOrder.id,
            note: `Redeemed for order`,
          },
        })
      }

      return newOrder
    })

    return okResponse({ id: order.id, queueStatus: order.status, total, pointsEarned, pointsRedeemed: pointsToRedeem })
  } catch (e) {
    handleError(e)
  }
})
