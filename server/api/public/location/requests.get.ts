export default defineEventHandler(async () => {
  try {
    const weekYear = getMonthYear()
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

function getMonthYear() {
  const bkk = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  return `${bkk.getFullYear()}-${String(bkk.getMonth() + 1).padStart(2, '0')}`
}
