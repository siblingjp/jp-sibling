export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const order = await prisma.order.findUnique({ where: { id } })
    if (!order) throw notFound('Order')
    if (order.status !== 'PENDING') throw badRequest('รับทราบได้เฉพาะออเดอร์ที่รอดำเนินการเท่านั้น')
    if (order.acknowledgedAt) throw badRequest('รับทราบออเดอร์นี้ไปแล้ว')

    const updated = await prisma.order.update({
      where: { id },
      data: { acknowledgedAt: new Date() },
    })

    if (order.memberId) {
      sendPushToMember(order.memberId, {
        title: '✅ ร้านรับออเดอร์แล้ว',
        body: `ออเดอร์ #${order.queueNo} ได้รับการยืนยันแล้ว ร้านจะเริ่มทำเมื่อถึงเวลาเปิด`,
        data: { url: `/member/orders/${id}`, orderId: id },
      }).catch(() => {})
    }

    return okResponse({ acknowledgedAt: updated.acknowledgedAt })
  } catch (e) {
    handleError(e)
  }
})
