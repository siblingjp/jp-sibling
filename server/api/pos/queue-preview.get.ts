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
    const nextQueueNo = (lastOrder?.queueNo ?? 0) + 1

    return okResponse({ queueNo: nextQueueNo })
  } catch (e) {
    handleError(e)
  }
})
