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
  slipUrls: z.array(z.string()).min(1, 'กรุณาแนบสลิปอย่างน้อย 1 รูป'),
  couponCode: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const body = validate(schema, await readBody(event))

    // ตรวจสอบว่าสั่งออเดอร์ได้หรือไม่ (เปิดอยู่ หรือ ภายใน 12 ชม. ก่อนเปิดรอบถัดไป)
    await checkCanOrder()

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
      if (coupon.perMemberLimit !== null) {
        const memberUsedCount = await prisma.order.count({
          where: {
            memberId: member.id,
            couponCode: couponCode,
            status: { notIn: ['CANCELLED'] },
          },
        })
        if (memberUsedCount >= coupon.perMemberLimit) throw badRequest(`คูปองนี้ใช้ได้ ${coupon.perMemberLimit} ครั้งต่อคนเท่านั้น`)
      }
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
    const loyaltyMode = await getLoyaltyMode()
    const pointsEarned = loyaltyMode === 'POINTS' ? calcPointsEarned(total, member.tier) : 0
    const stampsEligible = loyaltyMode === 'STAMPS'
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

    // Create order (no long-running ops inside transaction)
    const order = await prisma.order.create({
      data: {
        queueNo,
        source: 'ONLINE',
        member: { connect: { id: member.id } },
        note: body.note,
        pickupTime: body.pickupTime,
        slipUrl: body.slipUrls[0],
        slipUrls: body.slipUrls,
        couponCode: couponCode ?? undefined,
        subtotal,
        discountKind: couponDiscountKind,
        discountValue: couponDiscountValue,
        discount: couponDiscount,
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
            method: 'QR',
            amount: total,
            change: 0,
            transactionRef: null,
          },
        },
      },
    })

    // Post-order updates (fire-and-forget style, outside transaction)
    // หมายเหตุ: แต้ม/แสตมป์ (pointsEarned/stampsEligible) จะถูกให้จริงตอนออเดอร์ COMPLETED
    // + มี payment เท่านั้น (ดู pos/orders/[id].patch.ts, admin/orders/[id]/status.patch.ts)
    // ไม่ใช่ตอนสร้างออเดอร์ — เพื่อให้สอดคล้องกับออเดอร์ POS และไม่ต้องคืนแต้มเมื่อยกเลิก
    const updates: Promise<unknown>[] = []

    if (couponCode) {
      updates.push(prisma.coupon.update({
        where: { code: couponCode },
        data: { usedCount: { increment: 1 } },
      }))
    }

    await Promise.all(updates)

    // แจ้งเตือน staff ทุกคนว่ามีออเดอร์ออนไลน์ใหม่ (fire-and-forget)
    sendPushToAllStaff({
      title: '🛒 ออเดอร์ออนไลน์ใหม่',
      body: `#${queueNo} · ${member.name ?? member.phone} · ฿${total.toFixed(0)}`,
      data: { url: '/pos/orders' },
    }).catch(() => {})

    return okResponse({
      id: order.id,
      queueStatus: order.status,
      total,
      pointsEarned,
      pointsRedeemed: 0,
      loyaltyMode,
      stampsEligible,
    })
  } catch (e: any) {
    console.error('[member/orders POST]', e)
    if (process.env.NODE_ENV !== 'production') {
      throw createError({ statusCode: 500, message: e?.message ?? String(e) })
    }
    handleError(e)
  }
})

async function checkCanOrder() {
  const now = new Date()
  const truck = await prisma.truckLocation.findFirst({
    where: { isActive: true },
    include: { schedules: { where: { isActive: true }, orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }] } },
  })
  if (!truck) return

  const timelineOpen = truck.schedules.length > 0 ? !!getActiveSchedule(truck.schedules, now) : truck.isOpen
  const isOpen = truck.manualOpen ? true : timelineOpen
  if (isOpen) return

  const next = getNextSlot(truck.schedules, now)
  if (next && next.minutesUntilOpen <= 12 * 60) return

  const msg = next
    ? `ร้านปิดอยู่ — จะเปิดอีกครั้ง${next.label} ที่ ${next.name}`
    : 'ร้านปิดอยู่ และยังไม่มีกำหนดเปิดในขณะนี้'
  throw createError({ statusCode: 403, message: msg })
}

type Schedule = { id: string; openTime: string; closeTime: string; daysOfWeek: string; name: string }

function toMinutes(t: string) {
  const [h, m] = t.split(':').map(Number)
  return h * 60 + m
}

function getActiveSchedule(schedules: Schedule[], now: Date) {
  const bkk = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  const dayNames = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์']
  const hhmm = bkk.getHours() * 60 + bkk.getMinutes()
  const todayName = dayNames[bkk.getDay()]
  for (const s of schedules) {
    if (!s.daysOfWeek.includes(todayName)) continue
    if (hhmm >= toMinutes(s.openTime) && hhmm < toMinutes(s.closeTime)) return s
  }
  return null
}

function getNextSlot(schedules: Schedule[], now: Date) {
  if (!schedules.length) return null
  const bkk = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  const dayNames = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์']
  const thMonths = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.']
  const hhmm = bkk.getHours() * 60 + bkk.getMinutes()

  for (let d = 0; d <= 7; d++) {
    const target = new Date(bkk)
    target.setDate(target.getDate() + d)
    const dayName = dayNames[target.getDay()]
    const candidates = schedules
      .filter(s => s.daysOfWeek.includes(dayName))
      .filter(s => d > 0 || toMinutes(s.openTime) > hhmm)
      .sort((a, b) => toMinutes(a.openTime) - toMinutes(b.openTime))
    if (!candidates.length) continue
    const slot = candidates[0]
    const buddhistYear = target.getFullYear() + 543
    const label = `วัน${dayNames[target.getDay()]} ที่ ${target.getDate()} ${thMonths[target.getMonth()]} ${buddhistYear} ${slot.openTime} น.`
    const minutesUntilOpen = d * 24 * 60 + toMinutes(slot.openTime) - hhmm
    return { label, name: slot.name, minutesUntilOpen }
  }
  return null
}
