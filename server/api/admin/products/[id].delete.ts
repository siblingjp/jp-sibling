export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const existing = await prisma.product.findUnique({ where: { id } })
    if (!existing) throw notFound('Product')

    await prisma.product.update({ where: { id }, data: { isActive: false } })

    invalidateCache('pos:products')
    invalidateCache('member:products')
    return okResponse(null, 'Product deleted')
  } catch (e) {
    handleError(e)
  }
})
