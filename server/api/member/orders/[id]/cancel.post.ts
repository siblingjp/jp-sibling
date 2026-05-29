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

    // คืน points ที่ใช้ redeem
    if (order.pointsRedeemed > 0) {
      await prisma.member.update({
        where: { id: session.member.id },
        data: { points: { increment: order.pointsRedeemed } },
      })
    }

    const updated = await prisma.order.update({
      where: { id },
      data: { status: 'CANCELLED' },
    })

    return okResponse(updated)
  } catch (e) {
    handleError(e)
  }
})
