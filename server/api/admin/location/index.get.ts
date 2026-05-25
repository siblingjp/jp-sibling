export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { weekYear } = getQuery(event) as { weekYear?: string }
    const week = weekYear || getWeekYear()

    const [truckLocation, requests] = await Promise.all([
      prisma.truckLocation.findFirst({ where: { isActive: true } }),
      prisma.locationRequest.findMany({
        where: { weekYear: week },
        orderBy: { voteCount: 'desc' },
        include: { member: { select: { id: true, name: true } }, _count: { select: { votes: true } } },
      }),
    ])

    return okResponse({ truckLocation, requests, weekYear: week })
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
