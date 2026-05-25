export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!

    const member = await prisma.member.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        points: true,
        isActive: true,
        createdAt: true,
        orders: {
          orderBy: { createdAt: 'desc' },
          take: 10,
          select: {
            id: true,
            status: true,
            total: true,
            createdAt: true,
          },
        },
        pointLogs: {
          orderBy: { createdAt: 'desc' },
          take: 20,
          select: {
            id: true,
            action: true,
            amount: true,
            note: true,
            createdAt: true,
          },
        },
        _count: { select: { orders: true } },
      },
    })

    if (!member) throw notFound('Member')

    return okResponse(member)
  } catch (e) {
    handleError(e)
  }
})
