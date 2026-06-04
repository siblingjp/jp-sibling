export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const existing = await prisma.product.findUnique({ where: { id }, select: { id: true, isFeatured: true } })
    if (!existing) throw notFound('Product')

    const product = await prisma.product.update({
      where: { id },
      data: { isFeatured: !existing.isFeatured },
      select: { id: true, isFeatured: true },
    })

    invalidateCache('pos:products')
    invalidateCache('member:products')
    return okResponse(product)
  } catch (e) {
    handleError(e)
  }
})
