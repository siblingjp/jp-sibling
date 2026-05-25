export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const parsed = parseListQuery(getQuery(event))
    const where = buildWhere(parsed, {
      exactFields: ['status'],
    })

    // filter by date range
    const raw = getQuery(event) as Record<string, string>
    if (raw.dateFrom || raw.dateTo) {
      const dateFilter: any = {}
      if (raw.dateFrom) dateFilter.gte = new Date(raw.dateFrom)
      if (raw.dateTo) {
        const to = new Date(raw.dateTo)
        to.setHours(23, 59, 59, 999)
        dateFilter.lte = to
      }
      ;(where as any).createdAt = dateFilter
    }

    const [data, total] = await Promise.all([
      prisma.order.findMany({
        where,
        skip: parsed.skip,
        take: parsed.limit,
        orderBy: { createdAt: 'desc' },
        include: {
          items: {
            include: {
              product: { select: { id: true, name: true } },
              options: true,
            },
          },
          payment: true,
          member: { select: { id: true, name: true, phone: true, tier: true } },
          user: { select: { id: true, name: true } },
          discountBadge: { select: { id: true, name: true } },
        },
      }),
      prisma.order.count({ where }),
    ])

    return paginatedResponse(data, { page: parsed.page, limit: parsed.limit, total })
  } catch (e) {
    handleError(e)
  }
})
