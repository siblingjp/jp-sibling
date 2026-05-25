export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const product = await prisma.product.findUnique({
      where: { id },
      include: {
        category: { select: { id: true, name: true } },
        optionGroups: {
          orderBy: { sortOrder: 'asc' },
          include: {
            optionGroup: {
              include: {
                options: { orderBy: [{ sortOrder: 'asc' }] },
              },
            },
          },
        },
      },
    })

    if (!product) throw notFound('Product')

    return okResponse(product)
  } catch (e) {
    handleError(e)
  }
})
