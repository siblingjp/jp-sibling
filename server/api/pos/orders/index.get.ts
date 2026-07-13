export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const query = getQuery(event) as { status?: string | string[]; allDays?: string }
    const statusRaw = query.status
    const allDays = query.allDays === 'true'

    const { start, end } = getTodayRangeBKK()

    const statuses = statusRaw
      ? (Array.isArray(statusRaw) ? statusRaw : [statusRaw]).filter(s => s !== 'ALL')
      : []

    const statusFilter = statuses.length > 0
      ? { status: { in: statuses as any[] } }
      : { status: { notIn: ['READY', 'COMPLETED', 'CANCELLED'] as any[] } }

    const dateFilter = allDays ? {} : { createdAt: { gte: start, lte: end } }
    const where = { ...statusFilter, ...dateFilter }

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
        couponUses: { include: { coupon: { select: { id: true, code: true, name: true, discountKind: true, discountValue: true } } } },
      },
    })

    return okResponse(orders)
  } catch (e) {
    handleError(e)
  }
})
