import { z } from 'zod'

const schema = z.object({
  status: z.enum(['PREPARING', 'READY', 'COMPLETED', 'CANCELLED']),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const order = await prisma.order.findUnique({
      where: { id },
      include: { payment: true },
    })
    if (!order) throw notFound('Order')
    if (order.status === 'COMPLETED' || order.status === 'CANCELLED') {
      throw badRequest('Order is already finalized')
    }
    if (data.status === 'CANCELLED' && order.payment) {
      throw badRequest('Cannot cancel a paid order')
    }

    const updated = await prisma.$transaction(async (tx) => {
      const result = await tx.order.update({
        where: { id },
        data: { status: data.status },
        include: {
          items: { include: { options: true, product: { select: { id: true, name: true } } } },
          member: { select: { id: true, name: true } },
          payment: true,
        },
      })

      // earn points เมื่อ COMPLETED และมี member และมี payment
      if (data.status === 'COMPLETED' && result.memberId && result.pointsEarned > 0 && result.payment) {
        const expiredAt = new Date()
        expiredAt.setFullYear(expiredAt.getFullYear() + 2)

        const updatedMember = await tx.member.update({
          where: { id: result.memberId },
          data: {
            points: { increment: result.pointsEarned },
            totalSpent: { increment: Number(result.total) },
          },
        })

        // tier upgrade ในคำสั่งเดียว ไม่ต้อง findUnique แยก
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
            note: `Earned from POS #${result.queueNo}`,
            orderId: id,
            expiredAt,
          },
        })
      }

      return result
    }, { timeout: 15000, maxWait: 5000 })

    return okResponse(updated)
  } catch (e: any) {
    console.error('[PATCH /pos/orders/:id] ERROR:', e?.message, e?.code, e?.meta)
    handleError(e)
  }
})
