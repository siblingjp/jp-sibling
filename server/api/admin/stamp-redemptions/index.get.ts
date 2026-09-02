export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const redemptions = await prisma.stampRedemption.findMany({
      where: { status: 'PENDING' },
      include: { member: { select: { id: true, name: true, phone: true } } },
      orderBy: { requestedAt: 'asc' },
    })

    return okResponse(redemptions)
  } catch (e) {
    handleError(e)
  }
})
