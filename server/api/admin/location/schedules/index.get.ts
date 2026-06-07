export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const truck = await prisma.truckLocation.findFirst({ where: { isActive: true } })
    if (!truck) return okResponse({ schedules: [] })

    const schedules = await prisma.locationSchedule.findMany({
      where: { truckLocationId: truck.id },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    })

    return okResponse({ schedules, truckLocationId: truck.id })
  } catch (e) {
    handleError(e)
  }
})
