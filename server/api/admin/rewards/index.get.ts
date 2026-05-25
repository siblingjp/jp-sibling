export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const rewards = await prisma.reward.findMany({
      orderBy: { pointCost: 'asc' },
    })

    return okResponse(rewards)
  } catch (e) {
    handleError(e)
  }
})
