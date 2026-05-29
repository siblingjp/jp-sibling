const COUPON_SELECT = {
  id: true, code: true, name: true,
  type: true, benefitType: true, freeItemDescription: true,
  discountKind: true, discountValue: true,
  maxUses: true, usedCount: true,
  startAt: true, expiredAt: true,
  pointCost: true, minOrderAmount: true, minQuantity: true,
} as const

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const query = getQuery(event)
    const page = Math.max(1, Number(query.page) || 1)
    const size = Math.min(100, Math.max(1, Number(query.size) || 20))
    const skip = (page - 1) * size

    const [campaigns, total] = await Promise.all([
      prisma.campaign.findMany({
        orderBy: { createdAt: 'desc' },
        include: {
          coupons: { include: { coupon: { select: COUPON_SELECT } } },
        },
        skip,
        take: size,
      }),
      prisma.campaign.count(),
    ])

    return okResponse({ data: campaigns, total, page, size })
  } catch (e) {
    handleError(e)
  }
})
