export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const now = new Date()

    const coupons = await prisma.coupon.findMany({
      where: {
        isActive: true,
        type: 'POINT_REDEEM',
        pointCost: { not: null },
        AND: [
          { OR: [{ startAt: null }, { startAt: { lte: now } }] },
          { OR: [{ expiredAt: null }, { expiredAt: { gte: now } }] },
        ],
      },
      orderBy: { pointCost: 'asc' },
    })

    return okResponse(coupons)
  } catch (e) {
    handleError(e)
  }
})
