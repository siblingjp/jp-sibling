export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    await prisma.campaign.delete({ where: { id } })

    return okResponse({ id })
  } catch (e) {
    handleError(e)
  }
})
