export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const existing = await prisma.product.findUnique({
      where: { id },
      include: { _count: { select: { orderItems: true } } },
    })
    if (!existing) throw notFound('Product')

    if (existing._count.orderItems === 0) {
      await prisma.product.delete({ where: { id } })
    } else {
      await prisma.product.update({ where: { id }, data: { isActive: false } })
    }

    invalidateCache('pos:products')
    invalidateCache('member:products')
    return okResponse(null, 'Product deleted')
  } catch (e) {
    handleError(e)
  }
})
