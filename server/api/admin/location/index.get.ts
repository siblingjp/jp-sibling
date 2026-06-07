export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { weekYear } = getQuery(event) as { weekYear?: string }
    const week = weekYear || getMonthYear()

    const [truckLocation, requests] = await Promise.all([
      prisma.truckLocation.findFirst({
        where: { isActive: true },
        include: {
          schedules: {
            where: { isActive: true },
            orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
          },
        },
      }),
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

function getMonthYear() {
  const bkk = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  return `${bkk.getFullYear()}-${String(bkk.getMonth() + 1).padStart(2, '0')}`
}
