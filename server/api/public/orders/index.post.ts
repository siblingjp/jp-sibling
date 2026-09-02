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
  guestName: z.string().min(1, 'กรุณาระบุชื่อ').max(100),
  items: z.array(itemSchema).min(1),
  note: z.string().optional(),
  pickupTime: z.string().optional(),
  paymentMethod: z.enum(['CASH', 'CARD', 'QR', 'THAI_HELP']).default('QR'),
  memberId: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const body = validate(schema, await readBody(event))

    // ตรวจสอบ blockOnlineOrder
    const truck = await prisma.truckLocation.findFirst({ where: { isActive: true } })
    if (truck?.blockOnlineOrder) {
      throw createError({ statusCode: 403, message: 'ขณะนี้ไม่รับออเดอร์ออนไลน์' })
    }

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

    const total = subtotal

    // สมาชิกที่ผูกจากเบอร์โทร (ถ้ามี) — ต้อง active จริงเท่านั้น
    const member = body.memberId
      ? await prisma.member.findUnique({ where: { id: body.memberId, isActive: true } })
      : null

    const loyaltyMode = await getLoyaltyMode()
    const pointsEarned = member && loyaltyMode === 'POINTS' ? calcPointsEarned(total, member.tier) : 0
    const stampsEligible = member && loyaltyMode === 'STAMPS'
      ? calcEligibleCupCount(itemsData.map(item => ({ quantity: item.quantity, product: productMap.get(item.productId)! })))
      : 0

    // Queue number for today
    const { start: todayStart, end: todayEnd } = getTodayRangeBKK()
    const lastOrder = await prisma.order.findFirst({
      where: { createdAt: { gte: todayStart, lte: todayEnd } },
      orderBy: { queueNo: 'desc' },
      select: { queueNo: true },
    })
    const queueNo = (lastOrder?.queueNo ?? 0) + 1

    const order = await prisma.order.create({
      data: {
        queueNo,
        source: 'WEBAPP',
        guestName: body.guestName.trim(),
        member: member ? { connect: { id: member.id } } : undefined,
        note: body.note,
        pickupTime: body.pickupTime,
        subtotal,
        discount: 0,
        total,
        pointsEarned,
        pointsRedeemed: 0,
        stampsEligible,
        status: 'PENDING',
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
        payment: {
          create: {
            method: body.paymentMethod,
            amount: total,
            change: 0,
          },
        },
      },
    })

    // หมายเหตุ: แต้ม/แสตมป์ (pointsEarned/stampsEligible) จะถูกให้จริงตอนออเดอร์ COMPLETED
    // + มี payment เท่านั้น (ดู pos/orders/[id].patch.ts, admin/orders/[id]/status.patch.ts)
    // ไม่ใช่ตอนสร้างออเดอร์ — เพื่อให้สอดคล้องกับออเดอร์ POS/ONLINE และไม่ต้องคืนแต้มเมื่อยกเลิก

    sendPushToAllStaff({
      title: '🌐 ออเดอร์ WEBAPP ใหม่',
      body: `#${queueNo} · ${body.guestName} · ฿${total.toFixed(0)}`,
      data: { url: '/pos/orders' },
    }).catch(() => {})

    return okResponse({ id: order.id, queueNo, total })
  } catch (e: any) {
    console.error('[public/orders POST]', e)
    if (process.env.NODE_ENV !== 'production') {
      throw createError({ statusCode: 500, message: e?.message ?? String(e) })
    }
    handleError(e)
  }
})
