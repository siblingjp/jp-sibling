export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const parsed = parseListQuery(getQuery(event))
    const where = buildWhere(parsed, {
      searchFields: ['name', 'slug'],
      booleanFields: ['isActive'],
      exactFields: ['categoryId'],
    })

    const [data, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip: parsed.skip,
        take: parsed.limit,
        orderBy: { createdAt: 'desc' },
        include: { category: { select: { id: true, name: true } } },
      }),
      prisma.product.count({ where }),
    ])

    return paginatedResponse(data, { page: parsed.page, limit: parsed.limit, total })
  } catch (e) {
    handleError(e)
  }
})
