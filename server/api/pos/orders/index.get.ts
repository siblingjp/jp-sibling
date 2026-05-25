export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { status } = getQuery(event) as { status?: string }

    const where = status && status !== 'ALL'
      ? { status: status as any }
      : { status: { notIn: ['COMPLETED', 'CANCELLED'] as any[] } }

    const orders = await prisma.order.findMany({
      where,
      orderBy: { createdAt: 'asc' },
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

    return okResponse(orders)
  } catch (e) {
    handleError(e)
  }
})
