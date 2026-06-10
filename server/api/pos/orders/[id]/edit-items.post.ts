import { z } from 'zod'

const optionSchema = z.object({
  optionId: z.string(),
})

const itemSchema = z.object({
  productId: z.string(),
  quantity: z.number().int().positive(),
  note: z.string().optional(),
  options: z.array(optionSchema).default([]),
})

const schema = z.object({
  items: z.array(itemSchema).min(1),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const existing = await prisma.order.findUnique({
      where: { id },
      include: {
        items: { select: { id: true } },
        member: { select: { tier: true } },
      },
    })
    if (!existing) throw notFound('Order')
    if (!['PENDING', 'PREPARING'].includes(existing.status)) {
      throw badRequest('สามารถแก้ไขออเดอร์ได้เฉพาะสถานะ PENDING หรือ PREPARING เท่านั้น')
    }

    const productIds = [...new Set(data.items.map((i) => i.productId))]
    const optionIds = [...new Set(data.items.flatMap((i) => i.options.map((o) => o.optionId)))]

    const [products, options] = await Promise.all([
      prisma.product.findMany({ where: { id: { in: productIds }, isActive: true } }),
      optionIds.length > 0 ? prisma.option.findMany({ where: { id: { in: optionIds } } }) : [],
    ])

    if (products.length !== productIds.length) throw badRequest('Some products are unavailable')

    const productMap = new Map(products.map((p) => [p.id, p]))
    const optionMap = new Map(options.map((o) => [o.id, o]))

    const itemsCalc = data.items.map((item) => {
      const product = productMap.get(item.productId)!
      const itemOptions = item.options.map((o) => {
        const opt = optionMap.get(o.optionId)
        if (!opt) throw badRequest(`Option ${o.optionId} not found`)
        return opt
      })
      const optExtra = itemOptions.reduce((sum, o) => sum + Number(o.extraPrice), 0)
      const unitPrice = Number(product.price) + optExtra
      const subtotal = unitPrice * item.quantity
      return { item, itemOptions, unitPrice, subtotal }
    })

    const newSubtotal = itemsCalc.reduce((sum, i) => sum + i.subtotal, 0)

    let discountAmount = 0
    if (existing.discountKind && existing.discountValue != null) {
      discountAmount = existing.discountKind === 'PERCENT'
        ? Math.round((newSubtotal * Number(existing.discountValue)) / 100 * 100) / 100
        : Math.min(Number(existing.discountValue), newSubtotal)
    }
    const pointsRedeemed = Number(existing.pointsRedeemed ?? 0)
    const newTotal = Math.max(0, newSubtotal - discountAmount - pointsRedeemed)

    const tier = existing.member?.tier
    const tierMultiplier = tier === 'VIP' ? 1.5 : tier === 'GOLD' ? 1.25 : 1.0
    const pointsEarned = existing.memberId ? Math.floor((newTotal / 10) * tierMultiplier) : 0

    const existingItemIds = existing.items.map((i) => i.id)

    // ลบ items เดิม (cascade จะลบ options ตาม)
    if (existingItemIds.length > 0) {
      await prisma.orderItem.deleteMany({ where: { id: { in: existingItemIds } } })
    }

    // สร้าง items ใหม่ + อัปเดต totals
    const order = await prisma.order.update({
      where: { id },
      data: {
        subtotal: newSubtotal,
        discount: discountAmount,
        total: newTotal,
        pointsEarned,
        items: {
          create: itemsCalc.map(({ item, unitPrice, subtotal: itemSubtotal, itemOptions }) => ({
            productId: item.productId,
            quantity: item.quantity,
            unitPrice,
            subtotal: itemSubtotal,
            note: item.note,
            options: {
              create: itemOptions.map((opt) => ({
                optionId: opt.id,
                name: opt.name,
                extraPrice: opt.extraPrice,
              })),
            },
          })),
        },
      },
      include: {
        items: { include: { options: true, product: { select: { id: true, name: true } } } },
        member: { select: { id: true, name: true } },
        payment: true,
      },
    })

    return okResponse(order)
  } catch (e: any) {
    console.error('[edit-items] ERROR:', e?.message, e?.code, e?.meta)
    handleError(e)
  }
})
