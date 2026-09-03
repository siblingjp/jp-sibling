export default defineEventHandler(async (event) => {
  try {
    const id = getRouterParam(event, 'id')!
    const now = new Date()

    const campaign = await prisma.campaign.findFirst({
      where: {
        id,
        isActive: true,
        showOnPublic: true,
        OR: [{ startAt: null }, { startAt: { lte: now } }],
        AND: [{ OR: [{ expiredAt: null }, { expiredAt: { gte: now } }] }],
      },
      select: {
        id: true,
        name: true,
        description: true,
        imageUrl: true,
        imageOrientation: true,
        displayMode: true,
        bannerColor: true,
        expiredAt: true,
        memberOnly: true,
      },
    })

    if (!campaign) throw notFound('ไม่พบแคมเปญนี้')

    return okResponse(campaign)
  } catch (e) {
    handleError(e)
  }
})
