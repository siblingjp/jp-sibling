export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const parsed = parseListQuery(getQuery(event))
    const where = buildWhere(parsed, {
      searchFields: ['name', 'email'],
      booleanFields: ['isActive'],
      exactFields: ['role'],
    })

    const [data, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip: parsed.skip,
        take: parsed.limit,
        orderBy: { createdAt: 'desc' },
        select: { id: true, email: true, name: true, role: true, isActive: true, createdAt: true },
      }),
      prisma.user.count({ where }),
    ])

    return paginatedResponse(data, { page: parsed.page, limit: parsed.limit, total })
  } catch (e) {
    handleError(e)
  }
})
