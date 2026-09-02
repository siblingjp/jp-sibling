export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const parsed = parseListQuery(getQuery(event))
    const where = buildWhere(parsed, {
      searchFields: ['name', 'email', 'phone'],
      booleanFields: ['isActive'],
    })

    const [data, total] = await Promise.all([
      prisma.member.findMany({
        where,
        skip: parsed.skip,
        take: parsed.limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          email: true,
          name: true,
          phone: true,
          points: true,
          stampCount: true,
          isActive: true,
          createdAt: true,
          _count: { select: { orders: true } },
        },
      }),
      prisma.member.count({ where }),
    ])

    return paginatedResponse(data, { page: parsed.page, limit: parsed.limit, total })
  } catch (e) {
    handleError(e)
  }
})
