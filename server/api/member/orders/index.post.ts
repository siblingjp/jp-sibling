import { z } from 'zod'

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
  pickupTime: z.string().optional(),
  slipUrl: z.string().optional(),
  couponCode: z.string().optional(),
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

    // Validate coupon & calculate discount
    let couponDiscount = 0
    let couponDiscountKind: 'PERCENT' | 'AMOUNT' | undefined
    let couponDiscountValue: number | undefined
    const couponCode = body.couponCode?.trim().toUpperCase()

    if (couponCode) {
      const coupon = await prisma.coupon.findUnique({ where: { code: couponCode } })
      if (!coupon || !coupon.isActive) throw badRequest('คูปองไม่ถูกต้องหรือถูกปิดใช้งาน')
      const now = new Date()
      if (coupon.startAt && coupon.startAt > now) throw badRequest('คูปองยังไม่เริ่มใช้งาน')
      if (coupon.expiredAt && coupon.expiredAt < now) throw badRequest('คูปองหมดอายุแล้ว')
      if (coupon.maxUses !== null && coupon.usedCount >= coupon.maxUses) throw badRequest('คูปองถูกใช้ครบจำนวนแล้ว')
      if (coupon.minOrderAmount && subtotal < Number(coupon.minOrderAmount))
        throw badRequest(`ยอดสั่งขั้นต่ำ ฿${coupon.minOrderAmount}`)
      if (coupon.minTier) {
        const tierOrder: Record<string, number> = { SILVER: 0, GOLD: 1, VIP: 2 }
        if ((tierOrder[member.tier] ?? 0) < (tierOrder[coupon.minTier] ?? 0))
          throw badRequest(`ต้องเป็นสมาชิกระดับ ${coupon.minTier} ขึ้นไป`)
      }
      couponDiscountKind = coupon.discountKind as 'PERCENT' | 'AMOUNT'
      couponDiscountValue = Number(coupon.discountValue)
      couponDiscount = coupon.discountKind === 'PERCENT'
        ? Math.min((subtotal * couponDiscountValue) / 100, subtotal)
        : Math.min(couponDiscountValue, subtotal)
    }

    const total = Math.max(subtotal - couponDiscount, 0)
    const tierMultiplier = member.tier === 'VIP' ? 1.5 : member.tier === 'GOLD' ? 1.25 : 1.0
    const pointsEarned = Math.floor((total / 10) * tierMultiplier)

    // Queue number for today
    const todayStart = new Date(); todayStart.setHours(0, 0, 0, 0)
    const todayEnd = new Date(); todayEnd.setHours(23, 59, 59, 999)
    const lastOrder = await prisma.order.findFirst({
      where: { createdAt: { gte: todayStart, lte: todayEnd } },
      orderBy: { queueNo: 'desc' },
      select: { queueNo: true },
    })
    const queueNo = (lastOrder?.queueNo ?? 0) + 1

    // Create order (no long-running ops inside transaction)
    const order = await prisma.order.create({
      data: {
        queueNo,
        source: 'ONLINE',
        member: { connect: { id: member.id } },
        note: body.note,
        pickupTime: body.pickupTime,
        slipUrl: body.slipUrl,
        couponCode: couponCode ?? undefined,
        subtotal,
        discountKind: couponDiscountKind,
        discountValue: couponDiscountValue,
        discount: couponDiscount,
        total,
        pointsEarned,
        pointsRedeemed: 0,
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

    // Post-order updates (fire-and-forget style, outside transaction)
    const updates: Promise<unknown>[] = []

    if (couponCode) {
      updates.push(prisma.coupon.update({
        where: { code: couponCode },
        data: { usedCount: { increment: 1 } },
      }))
    }

    updates.push(prisma.member.update({
      where: { id: member.id },
      data: {
        ...(pointsEarned > 0 && { points: { increment: pointsEarned } }),
        totalSpent: { increment: total },
      },
    }))

    if (pointsEarned > 0) {
      updates.push(prisma.pointLog.create({
        data: {
          memberId: member.id,
          action: 'EARN',
          amount: pointsEarned,
          orderId: order.id,
          note: `ได้รับแต้มจากออเดอร์ #${queueNo}`,
        },
      }))
    }

    await Promise.all(updates)

    return okResponse({ id: order.id, queueStatus: order.status, total, pointsEarned, pointsRedeemed: 0 })
  } catch (e: any) {
    console.error('[member/orders POST]', e)
    if (process.env.NODE_ENV !== 'production') {
      throw createError({ statusCode: 500, message: e?.message ?? String(e) })
    }
    handleError(e)
  }
})
