export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const uses = await prisma.couponUse.findMany({
      where: { memberId: session.member.id },
      include: { coupon: true },
      orderBy: { createdAt: 'desc' },
    })

    return okResponse(uses)
  } catch (e) {
    handleError(e)
  }
})
