export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const logs = await prisma.pointLog.findMany({
      where: { memberId: session.member.id },
      orderBy: { createdAt: 'desc' },
      take: 50,
      include: {
        order: { select: { queueNo: true } },
      },
    })

    const member = await prisma.member.findUnique({
      where: { id: session.member.id },
      select: { points: true, tier: true, totalSpent: true },
    })

    return okResponse({ points: member?.points ?? 0, tier: member?.tier ?? 'SILVER', logs })
  } catch (e) {
    handleError(e)
  }
})
