export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const orders = await prisma.order.findMany({
      where: { memberId: session.member.id },
      orderBy: { createdAt: 'desc' },
      include: {
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
