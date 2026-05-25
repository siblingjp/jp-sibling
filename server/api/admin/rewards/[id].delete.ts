export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    await prisma.reward.delete({ where: { id } })

    return okResponse(null)
  } catch (e) {
    handleError(e)
  }
})
