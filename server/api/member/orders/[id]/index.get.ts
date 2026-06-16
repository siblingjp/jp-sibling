export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

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
        payment: { select: { method: true, amount: true } },
        couponUses: { include: { coupon: { select: { code: true, name: true } } } },
      },
    })
    if (!order || order.memberId !== session.member.id) throw notFound()

    return okResponse(order)
  } catch (e) {
    handleError(e)
  }
})
