export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    const memberId = session.member?.id ?? null
    const memberTier = session.member?.tier ?? null
    const now = new Date()

    const campaigns = await prisma.campaign.findMany({
      where: {
        isActive: true,
        OR: [{ startAt: null }, { startAt: { lte: now } }],
        AND: [{ OR: [{ expiredAt: null }, { expiredAt: { gte: now } }] }],
        ...(memberId ? {} : { memberOnly: false }),
      },
      include: {
        coupons: {
          include: {
            coupon: {
              select: {
                id: true,
                code: true,
                name: true,
                description: true,
                type: true,
                discountKind: true,
                discountValue: true,
                pointCost: true,
                minTier: true,
                expiredAt: true,
                isActive: true,
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 10,
    })

    const tierOrder: Record<string, number> = { SILVER: 0, GOLD: 1, VIP: 2 }
    const memberTierRank = memberTier ? (tierOrder[memberTier] ?? 0) : -1

    const result = campaigns.map((c) => ({
      id: c.id,
      name: c.name,
      description: c.description,
      imageUrl: c.imageUrl,
      displayMode: c.displayMode,
      bannerColor: c.bannerColor,
      startAt: c.startAt,
      expiredAt: c.expiredAt,
      memberOnly: c.memberOnly,
      minTier: c.minTier,
      coupons: c.coupons
        .map((cc) => cc.coupon)
        .filter((coupon) => {
          if (!coupon.isActive) return false
          if (coupon.minTier && memberTierRank < (tierOrder[coupon.minTier] ?? 0)) return false
          return true
        }),
    }))

    return okResponse(result)
  } catch (e) {
    handleError(e)
  }
})
