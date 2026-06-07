export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const weekYear = getMonthYear()

    await prisma.$transaction([
      prisma.locationVote.deleteMany({ where: { weekYear } }),
      prisma.locationRequest.updateMany({
        where: { weekYear },
        data: { voteCount: 0, isActive: false },
      }),
    ])

    return okResponse({ reset: true, weekYear })
  } catch (e) {
    handleError(e)
  }
})

function getMonthYear() {
  const bkk = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  return `${bkk.getFullYear()}-${String(bkk.getMonth() + 1).padStart(2, '0')}`
}
