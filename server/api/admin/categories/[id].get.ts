export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const category = await prisma.category.findUnique({
      where: { id },
      include: { _count: { select: { products: true } } },
    })

    if (!category) throw notFound('Category')

    return okResponse(category)
  } catch (e) {
    handleError(e)
  }
})
