import { z } from 'zod'

const schema = z.object({
  code: z.string().min(1),
  subtotal: z.number().min(0),
  memberId: z.string().optional().nullable(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user && !session.member) throw unauthorized()

    const body = validate(schema, await readBody(event))
    const now = new Date()

    const coupon = await prisma.coupon.findUnique({ where: { code: body.code.toUpperCase() } })
    if (!coupon) throw notFound('ไม่พบ coupon')
    if (!coupon.isActive) throw badRequest('Coupon นี้ถูกปิดใช้งาน')
    if (coupon.startAt && coupon.startAt > now) throw badRequest('Coupon ยังไม่เริ่มใช้งาน')
    if (coupon.expiredAt && coupon.expiredAt < now) throw badRequest('Coupon หมดอายุแล้ว')
    if (coupon.maxUses !== null && coupon.usedCount >= coupon.maxUses) throw badRequest('Coupon ถูกใช้ครบจำนวนแล้ว')
    if (coupon.minOrderAmount && body.subtotal < Number(coupon.minOrderAmount)) {
      throw badRequest(`ยอดสั่งขั้นต่ำ ฿${coupon.minOrderAmount}`)
    }
    if (coupon.memberOnly && !body.memberId) throw badRequest('Coupon นี้สำหรับสมาชิกเท่านั้น')

    if (body.memberId) {
      if (coupon.minTier) {
        const member = await prisma.member.findUnique({ where: { id: body.memberId } })
        const tierOrder = { SILVER: 0, GOLD: 1, VIP: 2 }
        if (!member || tierOrder[member.tier] < tierOrder[coupon.minTier]) {
          throw badRequest(`ต้องเป็นสมาชิกระดับ ${coupon.minTier} ขึ้นไป`)
        }
      }
      if (coupon.perMemberLimit !== null) {
        const [usedInOrders, usedInCouponUses] = await Promise.all([
          prisma.order.count({
            where: { memberId: body.memberId, couponCode: coupon.code, status: { notIn: ['CANCELLED'] } },
          }),
          prisma.couponUse.count({
            where: { couponId: coupon.id, memberId: body.memberId, isUsed: true },
          }),
        ])
        if (usedInOrders + usedInCouponUses >= coupon.perMemberLimit)
          throw badRequest(`คูปองนี้ใช้ได้ ${coupon.perMemberLimit} ครั้งต่อคนเท่านั้น`)
      }
    }

    const discountAmt = coupon.discountKind === 'PERCENT'
      ? Math.min((body.subtotal * Number(coupon.discountValue)) / 100, body.subtotal)
      : Math.min(Number(coupon.discountValue), body.subtotal)

    return okResponse({
      coupon: { id: coupon.id, code: coupon.code, name: coupon.name, discountKind: coupon.discountKind, discountValue: Number(coupon.discountValue) },
      discountAmount: discountAmt,
    })
  } catch (e) {
    handleError(e)
  }
})
