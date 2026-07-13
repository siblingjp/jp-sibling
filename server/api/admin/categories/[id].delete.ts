export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const existing = await prisma.category.findUnique({
      where: { id },
      include: {
        products: {
          select: { id: true, _count: { select: { orderItems: true } } },
        },
      },
    })
    if (!existing) throw notFound('Category')

    const hasOrders = existing.products.some(p => p._count.orderItems > 0)

    if (hasOrders) {
      // soft delete category + all products
      await prisma.category.update({ where: { id }, data: { isActive: false } })
      await prisma.product.updateMany({ where: { categoryId: id }, data: { isActive: false } })
    } else {
      // hard delete products first (FK), then category
      await prisma.product.deleteMany({ where: { categoryId: id } })
      await prisma.category.delete({ where: { id } })
    }

    invalidateCache('pos:products')
    invalidateCache('member:products')
    return okResponse(null, 'Category deleted')
  } catch (e) {
    handleError(e)
  }
})
