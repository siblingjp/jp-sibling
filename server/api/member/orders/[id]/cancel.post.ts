export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const order = await prisma.order.findUnique({ where: { id } })
    if (!order || order.memberId !== session.member.id) throw notFound()

    if (!['PENDING', 'PREPARING'].includes(order.status)) {
      throw badRequest('ไม่สามารถยกเลิกออเดอร์ที่อยู่ในสถานะนี้ได้')
    }

    const updated = await prisma.$transaction(async (tx) => {
      // คืนแต้มที่เคยหักไปตอนแลก
      await reverseRedeemedPoints(tx, order.id, session.member!.id, order.pointsRedeemed)

      return tx.order.update({
        where: { id },
        data: { status: 'CANCELLED' },
      })
    })

    return okResponse(updated)
  } catch (e) {
    handleError(e)
  }
})
