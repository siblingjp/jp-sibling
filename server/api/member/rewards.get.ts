export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const rewards = await prisma.reward.findMany({
      where: { isActive: true },
      orderBy: { pointCost: 'asc' },
    })

    return okResponse(rewards)
  } catch (e) {
    handleError(e)
  }
})
