export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!

    const usedCount = await prisma.couponUse.count({ where: { couponId: id, isUsed: true } })
    if (usedCount > 0) throw badRequest('ไม่สามารถลบ coupon ที่มีการใช้งานแล้ว')

    await prisma.coupon.delete({ where: { id } })

    return okResponse({ id })
  } catch (e) {
    handleError(e)
  }
})
