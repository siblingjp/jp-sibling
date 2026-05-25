export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!

    if (id === session.user.id) throw badRequest('Cannot deactivate your own account')

    const existing = await prisma.user.findUnique({ where: { id } })
    if (!existing) throw notFound('User')

    await prisma.user.update({ where: { id }, data: { isActive: false } })

    return okResponse(null, 'User deactivated')
  } catch (e) {
    handleError(e)
  }
})
