export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    const memberId = session.member?.id ?? null
    const memberTier = session.member?.tier ?? null
    const id = getRouterParam(event, 'id')!
    const now = new Date()

    const campaign = await prisma.campaign.findFirst({
      where: {
        id,
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
    })

    if (!campaign) throw notFound('ไม่พบแคมเปญนี้')

    const tierOrder: Record<string, number> = { SILVER: 0, GOLD: 1, VIP: 2 }
    const memberTierRank = memberTier ? (tierOrder[memberTier] ?? 0) : -1

    const result = {
      id: campaign.id,
      name: campaign.name,
      description: campaign.description,
      imageUrl: campaign.imageUrl,
      imageOrientation: campaign.imageOrientation,
      displayMode: campaign.displayMode,
      bannerColor: campaign.bannerColor,
      startAt: campaign.startAt,
      expiredAt: campaign.expiredAt,
      memberOnly: campaign.memberOnly,
      minTier: campaign.minTier,
      coupons: campaign.coupons
        .map((cc) => cc.coupon)
        .filter((coupon) => {
          if (!coupon.isActive) return false
          if (coupon.minTier && memberTierRank < (tierOrder[coupon.minTier] ?? 0)) return false
          return true
        }),
    }

    return okResponse(result)
  } catch (e) {
    handleError(e)
  }
})
