export default defineEventHandler(async () => {
  try {
    const products = await prisma.product.findMany({
      where: { isActive: true },
      include: {
        category: { select: { id: true, name: true } },
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
      orderBy: [{ category: { sortOrder: 'asc' } }, { sortOrder: 'asc' }],
    })
    return okResponse(products)
  } catch (e) {
    handleError(e)
  }
})
