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
            options: true,
            product: { select: { id: true, name: true } },
          },
        },
        member: { select: { id: true, name: true, phone: true } },
        payment: true,
      },
    })

    if (!order) throw notFound('Order')
    return okResponse(order)
  } catch (e) {
    handleError(e)
  }
})
