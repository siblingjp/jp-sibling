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
  note: z.string().optional(),
  memberId: z.string().optional(),
  discountKind: z.enum(['PERCENT', 'AMOUNT']).optional(),
  discountValue: z.number().min(0).optional(),
  discountId: z.string().optional(),
  couponCode: z.string().optional(),
  pointsRedeemed: z.number().int().min(0).default(0),
  items: z.array(itemSchema).min(1),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const data = validate(schema, await readBody(event))

    const productIds = [...new Set(data.items.map((i) => i.productId))]
    const optionIds = [...new Set(data.items.flatMap((i) => i.options.map((o) => o.optionId)))]

    const [products, options, member] = await Promise.all([
      prisma.product.findMany({ where: { id: { in: productIds }, isActive: true } }),
      optionIds.length > 0 ? prisma.option.findMany({ where: { id: { in: optionIds }, isActive: true } }) : [],
      data.memberId ? prisma.member.findUnique({ where: { id: data.memberId, isActive: true } }) : null,
    ])

    if (products.length !== productIds.length) throw badRequest('Some products are unavailable')
    if (data.memberId && !member) throw badRequest('Member not found')

    const productMap = new Map(products.map((p) => [p.id, p]))
    const optionMap = new Map(options.map((o) => [o.id, o]))

    const itemsCalc = data.items.map((item) => {
      const product = productMap.get(item.productId)!
      const itemOptions = item.options.map((o) => {
        const opt = optionMap.get(o.optionId)
        if (!opt) throw badRequest(`Option ${o.optionId} not found`)
        return opt
      })
      const unitPrice = Number(product.price) + itemOptions.reduce((sum, o) => sum + Number(o.extraPrice), 0)
      const subtotal = unitPrice * item.quantity
      return { item, product, itemOptions, unitPrice, subtotal }
    })

    const subtotal = itemsCalc.reduce((sum, i) => sum + i.subtotal, 0)

    // discount badge
    let discountAmount = 0
    if (data.discountKind && data.discountValue != null) {
      discountAmount = data.discountKind === 'PERCENT'
        ? Math.round((subtotal * data.discountValue) / 100 * 100) / 100
        : Math.min(data.discountValue, subtotal)
    }

    // coupon
    let coupon = null
    let couponDiscountAmount = 0
    if (data.couponCode) {
      const now = new Date()
      coupon = await prisma.coupon.findUnique({ where: { code: data.couponCode.toUpperCase() } })
      if (!coupon || !coupon.isActive) throw badRequest('Coupon ไม่ถูกต้อง')
      if (coupon.startAt && coupon.startAt > now) throw badRequest('Coupon ยังไม่เริ่มใช้งาน')
      if (coupon.expiredAt && coupon.expiredAt < now) throw badRequest('Coupon หมดอายุแล้ว')
      if (coupon.maxUses !== null && coupon.usedCount >= coupon.maxUses) throw badRequest('Coupon ถูกใช้ครบแล้ว')
      if (coupon.minOrderAmount && subtotal < Number(coupon.minOrderAmount)) throw badRequest(`ยอดขั้นต่ำ ฿${coupon.minOrderAmount}`)
      if (coupon.memberOnly && !member) throw badRequest('Coupon นี้สำหรับสมาชิกเท่านั้น')

      couponDiscountAmount = coupon.discountKind === 'PERCENT'
        ? Math.min((subtotal * Number(coupon.discountValue)) / 100, subtotal)
        : Math.min(Number(coupon.discountValue), subtotal)
    }

    const afterDiscount = subtotal - discountAmount - couponDiscountAmount
    const maxRedeemable = Math.floor(afterDiscount)
    const pointsRedeemed = Math.min(data.pointsRedeemed, member?.points ?? 0, maxRedeemable)
    const total = Math.max(0, afterDiscount - pointsRedeemed)

    const tierMultiplier = member?.tier === 'VIP' ? 1.5 : member?.tier === 'GOLD' ? 1.25 : 1.0
    const pointsEarned = member ? Math.floor((total / 10) * tierMultiplier) : 0

    const todayStart = new Date()
    todayStart.setHours(0, 0, 0, 0)
    const todayEnd = new Date()
    todayEnd.setHours(23, 59, 59, 999)

    const lastOrder = await prisma.order.findFirst({
      where: { createdAt: { gte: todayStart, lte: todayEnd } },
      orderBy: { queueNo: 'desc' },
    })
    const queueNo = (lastOrder?.queueNo ?? 0) + 1

    const order = await prisma.$transaction(async (tx) => {
      const created = await tx.order.create({
        data: {
          queueNo,
          note: data.note,
          subtotal,
          discountKind: data.discountKind ?? null,
          discountValue: data.discountValue ?? null,
          discount: discountAmount + couponDiscountAmount,
          couponCode: coupon?.code ?? null,
          total,
          pointsEarned,
          pointsRedeemed,
          userId: session.user!.id,
          memberId: data.memberId ?? null,
          discountId: data.discountId ?? null,
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
        },
      })

      // mark coupon used
      if (coupon) {
        await tx.coupon.update({ where: { id: coupon.id }, data: { usedCount: { increment: 1 } } })
        await tx.couponUse.create({
          data: {
            couponId: coupon.id,
            memberId: member?.id ?? null,
            orderId: created.id,
            isUsed: true,
            usedAt: new Date(),
          },
        })
      }

      if (member && pointsRedeemed > 0) {
        await tx.member.update({ where: { id: member.id }, data: { points: { decrement: pointsRedeemed } } })
        await tx.pointLog.create({
          data: { memberId: member.id, action: 'REDEEM', amount: pointsRedeemed, note: `Redeem at POS #${queueNo}`, orderId: created.id },
        })
      }

      return created
    }, { timeout: 15000 })

    return okResponse(order)
  } catch (e) {
    handleError(e)
  }
})
