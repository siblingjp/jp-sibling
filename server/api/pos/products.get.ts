export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const cached = getCache('pos:products')
    if (cached) return okResponse(cached)

    const products = await prisma.product.findMany({
      where: { isActive: true },
      orderBy: [{ isFeatured: 'desc' }, { category: { name: 'asc' } }, { name: 'asc' }],
      include: {
        category: { select: { id: true, name: true, slug: true } },
        optionGroups: {
          orderBy: { sortOrder: 'asc' },
          include: {
            optionGroup: {
              include: {
                options: {
                  where: { isActive: true },
                  orderBy: { sortOrder: 'asc' },
                },
              },
            },
          },
        },
      },
    })

    setCache('pos:products', products, 300)
    return okResponse(products)
  } catch (e) {
    handleError(e)
  }
})
