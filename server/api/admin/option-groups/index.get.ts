export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const groups = await prisma.optionGroup.findMany({
      orderBy: [{ sortOrder: 'asc' }],
      include: {
        options: {
          where: { isActive: true },
          orderBy: [{ sortOrder: 'asc' }],
        },
        _count: { select: { products: true } },
      },
    })

    return okResponse(groups)
  } catch (e) {
    handleError(e)
  }
})
