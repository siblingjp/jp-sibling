export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const orders = await prisma.order.findMany({
      where: { memberId: session.member.id },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        queueNo: true,
        status: true,
        total: true,
        pointsEarned: true,
        pointsRedeemed: true,
        createdAt: true,
        items: {
          include: {
            product: { select: { id: true, name: true, imageUrl: true } },
            options: true,
          },
        },
      },
    })

    return okResponse(orders)
  } catch (e) {
    handleError(e)
  }
})
