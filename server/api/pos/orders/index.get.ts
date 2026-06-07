export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { status } = getQuery(event) as { status?: string }

    const { start, end } = getTodayRangeBKK()

    const statusFilter = status && status !== 'ALL'
      ? { status: status as any }
      : { status: { notIn: ['COMPLETED', 'CANCELLED'] as any[] } }

    const where = { ...statusFilter, createdAt: { gte: start, lte: end } }

    const orders = await prisma.order.findMany({
      where,
      orderBy: [
        { pickupTime: { sort: 'asc', nulls: 'last' } },
        { queueNo: 'asc' },
      ],
      include: {
        items: {
          include: {
            options: true,
            product: { select: { id: true, name: true } },
          },
        },
        member: { select: { id: true, name: true, phone: true } },
        payment: true,
      },
    })

    return okResponse(orders)
  } catch (e) {
    handleError(e)
  }
})
