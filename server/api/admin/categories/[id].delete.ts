export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const existing = await prisma.category.findUnique({
      where: { id },
      include: { _count: { select: { products: true } } },
    })
    if (!existing) throw notFound('Category')
    if (existing._count.products > 0) throw badRequest('Cannot delete category with existing products')

    await prisma.category.update({ where: { id }, data: { isActive: false } })

    return okResponse(null, 'Category deleted')
  } catch (e) {
    handleError(e)
  }
})
