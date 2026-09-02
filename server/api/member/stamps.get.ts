export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const [member, logs, pendingRedemption] = await Promise.all([
      prisma.member.findUnique({
        where: { id: session.member.id },
        select: { stampCount: true },
      }),
      prisma.stampLog.findMany({
        where: { memberId: session.member.id },
        orderBy: { createdAt: 'desc' },
        take: 50,
        include: { order: { select: { queueNo: true } } },
      }),
      prisma.stampRedemption.findFirst({
        where: { memberId: session.member.id, status: 'PENDING' },
      }),
    ])

    return okResponse({
      stampCount: member?.stampCount ?? 0,
      maxStamps: MAX_STAMPS,
      logs,
      pendingRedemption,
    })
  } catch (e) {
    handleError(e)
  }
})
