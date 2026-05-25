export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const discounts = await prisma.discount.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
    })

    return okResponse(discounts)
  } catch (e) {
    handleError(e)
  }
})
