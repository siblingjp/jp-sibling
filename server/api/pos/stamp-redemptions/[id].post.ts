export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const redemption = await prisma.stampRedemption.findUnique({
      where: { id },
      include: { member: { select: { id: true, name: true } } },
    })

    if (!redemption) throw notFound('ไม่พบคำขอแลกแสตมป์')
    if (redemption.status !== 'PENDING') throw badRequest('คำขอนี้ถูกใช้ไปแล้วหรือถูกยกเลิก')

    const updated = await prisma.stampRedemption.update({
      where: { id },
      data: { status: 'CONFIRMED', confirmedAt: new Date(), confirmedById: session.user.id },
      include: { member: { select: { id: true, name: true } } },
    })

    return okResponse({
      id: updated.id,
      memberName: updated.member.name,
      confirmedAt: updated.confirmedAt,
    })
  } catch (e) {
    handleError(e)
  }
})
