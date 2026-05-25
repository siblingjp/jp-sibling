export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    const discount = await prisma.discount.findUnique({
      where: { id },
      include: { _count: { select: { orders: true } } },
    })
    if (!discount) throw notFound('Discount')
    if (discount._count.orders > 0) throw badRequest('Cannot delete discount that has been used in orders')

    await prisma.discount.delete({ where: { id } })
    return okResponse({ id })
  } catch (e) {
    handleError(e)
  }
})
