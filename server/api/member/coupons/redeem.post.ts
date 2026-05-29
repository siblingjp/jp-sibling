import { z } from 'zod'

const schema = z.object({ couponId: z.string() })

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const { couponId } = validate(schema, await readBody(event))
    const now = new Date()

    const coupon = await prisma.coupon.findUnique({ where: { id: couponId } })
    if (!coupon) throw notFound('ไม่พบ coupon')
    if (!coupon.isActive) throw badRequest('Coupon นี้ถูกปิดใช้งาน')
    if (!coupon.pointCost) throw badRequest('Coupon นี้ไม่ได้เปิดให้แลกด้วยแต้ม')
    if (coupon.startAt && coupon.startAt > now) throw badRequest('Coupon ยังไม่เริ่มใช้งาน')
    if (coupon.expiredAt && coupon.expiredAt < now) throw badRequest('Coupon หมดอายุแล้ว')
    if (coupon.maxUses !== null && coupon.usedCount >= coupon.maxUses) throw badRequest('Coupon ถูกใช้ครบจำนวนแล้ว')

    const member = await prisma.member.findUnique({ where: { id: session.member.id } })
    if (!member) throw unauthorized()

    if (member.points < coupon.pointCost) throw badRequest(`แต้มไม่พอ ต้องการ ${coupon.pointCost} แต้ม`)

    if (coupon.perMemberLimit !== null) {
      const existing = await prisma.couponUse.count({
        where: { couponId, memberId: member.id },
      })
      if (existing >= coupon.perMemberLimit) throw badRequest('คุณแลก coupon นี้ครบจำนวนแล้ว')
    }

    if (coupon.minTier) {
      const tierOrder = { SILVER: 0, GOLD: 1, VIP: 2 }
      if (tierOrder[member.tier] < tierOrder[coupon.minTier]) {
        throw badRequest(`ต้องเป็นสมาชิกระดับ ${coupon.minTier} ขึ้นไป`)
      }
    }

    const use = await prisma.$transaction(async (tx) => {
      await tx.member.update({
        where: { id: member.id },
        data: { points: { decrement: coupon.pointCost! } },
      })
      await tx.pointLog.create({
        data: { memberId: member.id, action: 'REDEEM', amount: -coupon.pointCost!, note: `แลก coupon ${coupon.code}` },
      })
      return tx.couponUse.create({
        data: { couponId, memberId: member.id, isUsed: false },
        include: { coupon: true },
      })
    }, { timeout: 10000 })

    return okResponse(use)
  } catch (e) {
    handleError(e)
  }
})
