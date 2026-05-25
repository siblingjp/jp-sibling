export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!

    const group = await prisma.optionGroup.findUnique({
      where: { id },
      include: {
        options: { orderBy: [{ sortOrder: 'asc' }] },
      },
    })

    if (!group) throw notFound('Option Group')

    return okResponse(group)
  } catch (e) {
    handleError(e)
  }
})
