export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const existing = await prisma.truckLocation.findFirst({ where: { isActive: true } })
    if (!existing) throw createError({ statusCode: 404, message: 'ไม่พบข้อมูลร้าน' })

    const updated = await prisma.truckLocation.update({
      where: { id: existing.id },
      data: { isOpen: !existing.isOpen },
    })

    return okResponse({ isOpen: updated.isOpen })
  } catch (e) {
    handleError(e)
  }
})
