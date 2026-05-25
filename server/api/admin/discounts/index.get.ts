export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const discounts = await prisma.discount.findMany({
      orderBy: { name: 'asc' },
      include: { _count: { select: { orders: true } } },
    })

    return okResponse(discounts)
  } catch (e) {
    handleError(e)
  }
})
