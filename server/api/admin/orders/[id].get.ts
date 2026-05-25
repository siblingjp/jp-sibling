export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        items: {
          include: {
            product: { select: { id: true, name: true, imageUrl: true } },
            options: true,
          },
        },
        payment: true,
        member: { select: { id: true, name: true, phone: true, email: true, tier: true, points: true } },
        user: { select: { id: true, name: true } },
        discountBadge: { select: { id: true, name: true } },
      },
    })

    if (!order) throw notFound('Order')

    return okResponse(order)
  } catch (e) {
    handleError(e)
  }
})
