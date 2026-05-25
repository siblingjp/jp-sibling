export default defineEventHandler(async () => {
  try {
    const now = new Date()

    const [products, campaigns, truckLocation, topRequests] = await Promise.all([
      prisma.product.findMany({
        where: { isActive: true },
        select: { id: true, name: true, imageUrl: true, category: { select: { name: true } } },
        orderBy: { createdAt: 'asc' },
        take: 8,
      }),
      prisma.campaign.findMany({
        where: {
          status: 'PUBLISHED',
          OR: [
            { startsAt: null },
            { startsAt: { lte: now } },
          ],
          AND: [
            { OR: [{ endsAt: null }, { endsAt: { gte: now } }] },
          ],
        },
        orderBy: { createdAt: 'desc' },
        take: 4,
      }),
      prisma.truckLocation.findFirst({ where: { isActive: true } }),
      prisma.locationRequest.findMany({
        where: { isActive: true, weekYear: getWeekYear() },
        orderBy: { voteCount: 'desc' },
        take: 5,
        select: { id: true, name: true, description: true, voteCount: true },
      }),
    ])

    return okResponse({ products, campaigns, truckLocation, topRequests })
  } catch (e) {
    handleError(e)
  }
})

function getWeekYear() {
  const now = new Date()
  const d = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()))
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7))
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1))
  const week = Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7)
  return `${d.getUTCFullYear()}-W${String(week).padStart(2, '0')}`
}
