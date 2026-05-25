export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!

    const group = await prisma.optionGroup.findUnique({
      where: { id },
      include: { _count: { select: { products: true } } },
    })
    if (!group) throw notFound('Option Group')
    if (group._count.products > 0) throw badRequest('Cannot delete group that is linked to products')

    await prisma.optionGroup.delete({ where: { id } })

    return okResponse({ id })
  } catch (e) {
    handleError(e)
  }
})
