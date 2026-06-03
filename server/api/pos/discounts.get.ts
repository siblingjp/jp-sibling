export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const cached = getCache('pos:discounts')
    if (cached) return okResponse(cached)

    const discounts = await prisma.discount.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
    })

    setCache('pos:discounts', discounts, 300)
    return okResponse(discounts)
  } catch (e) {
    handleError(e)
  }
})
