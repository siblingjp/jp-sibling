export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const parsed = parseListQuery(getQuery(event))
    const where = buildWhere(parsed, {
      searchFields: ['name', 'slug'],
      booleanFields: ['isActive'],
    })

    const [data, total] = await Promise.all([
      prisma.category.findMany({
        where,
        skip: parsed.skip,
        take: parsed.limit,
        orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        include: { _count: { select: { products: true } } },
      }),
      prisma.category.count({ where }),
    ])

    return paginatedResponse(data, { page: parsed.page, limit: parsed.limit, total })
  } catch (e) {
    handleError(e)
  }
})
