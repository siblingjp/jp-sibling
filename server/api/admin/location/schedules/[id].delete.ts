export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    await prisma.locationSchedule.delete({ where: { id } })

    return okResponse({ deleted: true })
  } catch (e) {
    handleError(e)
  }
})
