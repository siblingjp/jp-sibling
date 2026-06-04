export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

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
        status: 'RESERVED',
        subtotal: 0,
        discount: 0,
        total: 0,
        pointsEarned: 0,
        pointsRedeemed: 0,
        userId: session.user.id,
      },
      select: { id: true, queueNo: true, status: true },
    })

    return okResponse(order)
  } catch (e) {
    handleError(e)
  }
})
