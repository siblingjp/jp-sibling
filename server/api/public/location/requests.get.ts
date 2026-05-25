export default defineEventHandler(async () => {
  try {
    const weekYear = getWeekYear()
    const requests = await prisma.locationRequest.findMany({
      where: { isActive: true, weekYear },
      orderBy: { voteCount: 'desc' },
      select: {
        id: true, name: true, description: true, voteCount: true, createdAt: true,
        member: { select: { name: true } },
      },
    })
    return okResponse({ requests, weekYear })
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
