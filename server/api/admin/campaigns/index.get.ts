export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const campaigns = await prisma.campaign.findMany({ orderBy: { createdAt: 'desc' } })
    return okResponse(campaigns)
  } catch (e) {
    handleError(e)
  }
})
