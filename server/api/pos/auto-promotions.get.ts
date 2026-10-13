export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const cached = getCache('pos:autoPromotions')
    if (cached) return okResponse(cached)

    const now = new Date()
    const coupons = await prisma.coupon.findMany({
      where: {
        autoApply: true,
        isActive: true,
        type: 'PROMOTION',
        bundleQty: { not: null },
        bundleDiscount: { not: null },
        OR: [{ startAt: null }, { startAt: { lte: now } }],
        AND: [{ OR: [{ expiredAt: null }, { expiredAt: { gte: now } }] }],
      },
      select: { id: true, name: true, categoryId: true, bundleQty: true, bundleDiscount: true },
    })

    setCache('pos:autoPromotions', coupons, 60)
    return okResponse(coupons)
  } catch (e) {
    handleError(e)
  }
})
