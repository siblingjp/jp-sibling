export default defineEventHandler(async (event) => {
  try {
    const { phone } = getQuery(event) as { phone?: string }
    const normalized = phone?.trim()
    if (!normalized || normalized.length < 9) throw badRequest('กรุณาระบุเบอร์โทรศัพท์ให้ถูกต้อง')

    const member = await prisma.member.findFirst({
      where: { isActive: true, phone: normalized },
      select: {
        id: true,
        name: true,
        phone: true,
        tier: true,
        stampCount: true,
      },
    })

    if (!member) throw notFound('ไม่พบสมาชิก')

    return okResponse({ ...member, hasPendingStampRedemption: await checkHasPendingStampRedemption(member.id) })
  } catch (e) {
    handleError(e)
  }
})
