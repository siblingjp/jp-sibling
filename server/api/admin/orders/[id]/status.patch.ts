import { z } from 'zod'

const schema = z.object({
  status: z.enum(['PENDING', 'PREPARING', 'READY', 'COMPLETED', 'CANCELLED']),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const { status } = validate(schema, await readBody(event))

    const order = await prisma.order.findUnique({
      where: { id },
      include: { payment: true },
    })
    if (!order) throw notFound('Order')
    if (order.status === 'COMPLETED' || order.status === 'CANCELLED') {
      throw badRequest('ออเดอร์นี้สิ้นสุดแล้ว ไม่สามารถเปลี่ยนสถานะได้')
    }

    const updated = await prisma.$transaction(async (tx) => {
      // ถ้าปิดออเดอร์แล้วยังไม่มี payment ให้สร้างแบบไม่ระบุช่องทางอัตโนมัติ
      if (status === 'COMPLETED' && !order.payment) {
        await tx.payment.create({
          data: {
            orderId: id,
            method: 'UNSPECIFIED',
            amount: Number(order.total),
            change: 0,
          },
        })
      }

      // ยกเลิกออเดอร์ → คืนแต้มที่เคยหักไปตอนแลก
      if (status === 'CANCELLED' && order.memberId) {
        await reverseRedeemedPoints(tx, order.id, order.memberId, order.pointsRedeemed)
      }

      const result = await tx.order.update({
        where: { id },
        data: { status },
        include: { payment: true },
      })

      // earn points เมื่อ COMPLETED และมี member และมี payment (ทุก source)
      if (status === 'COMPLETED' && result.memberId && result.pointsEarned > 0 && result.payment) {
        const expiredAt = new Date()
        expiredAt.setFullYear(expiredAt.getFullYear() + 2)

        const updatedMember = await tx.member.update({
          where: { id: result.memberId },
          data: {
            points: { increment: result.pointsEarned },
            totalSpent: { increment: Number(result.total) },
          },
        })

        const spent = Number(updatedMember.totalSpent)
        const newTier = spent >= 5000 ? 'VIP' : spent >= 2000 ? 'GOLD' : 'SILVER'
        if (newTier !== updatedMember.tier) {
          await tx.member.update({ where: { id: result.memberId }, data: { tier: newTier } })
        }

        await tx.pointLog.create({
          data: {
            memberId: result.memberId,
            action: 'EARN',
            amount: result.pointsEarned,
            note: `ได้จากหน้าร้าน #${result.queueNo}`,
            orderId: id,
            expiredAt,
          },
        })
      }

      // ให้แสตมป์เมื่อ COMPLETED และมี member และมี payment (ทุก source)
      if (status === 'COMPLETED' && result.memberId && result.stampsEligible > 0 && result.payment) {
        await awardOrderLoyaltyOnComplete(tx, id, result.memberId, result.stampsEligible, `ได้จากหน้าร้าน #${result.queueNo}`)
      }

      return result
    }, { timeout: 15000, maxWait: 5000 })

    if (updated.memberId) {
      const statusMessages: Record<string, { title: string; body: string }> = {
        PREPARING: { title: '☕ กำลังเตรียมออเดอร์', body: `ออเดอร์ #${updated.queueNo} กำลังถูกเตรียม` },
        READY:     { title: '✅ ออเดอร์พร้อมแล้ว!', body: `ออเดอร์ #${updated.queueNo} พร้อมรับได้เลยครับ` },
        COMPLETED: {
          title: '🎉 เสร็จสิ้น',
          body: updated.stampsEligible > 0
            ? `ออเดอร์ #${updated.queueNo} เสร็จสิ้น ได้รับ ${updated.stampsEligible} แสตมป์`
            : `ออเดอร์ #${updated.queueNo} เสร็จสิ้น ได้รับ ${updated.pointsEarned} แต้ม`,
        },
        CANCELLED: { title: '❌ ยกเลิกออเดอร์', body: `ออเดอร์ #${updated.queueNo} ถูกยกเลิก` },
      }
      const msg = statusMessages[status]
      if (msg) {
        sendPushToMember(updated.memberId, {
          ...msg,
          data: { url: `/member/orders/${id}`, orderId: id },
        }).catch(() => {})
      }
    }

    return okResponse(updated)
  } catch (e) {
    handleError(e)
  }
})
