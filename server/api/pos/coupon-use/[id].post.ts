export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const now = new Date()

    const use = await prisma.couponUse.findUnique({
      where: { id },
      include: { coupon: true, member: { select: { id: true, name: true } } },
    })

    if (!use) throw notFound('ไม่พบ coupon use')
    if (use.isUsed) throw badRequest('คูปองนี้ถูกใช้ไปแล้ว')

    // check 30-minute window
    const expiresAt = new Date(use.createdAt.getTime() + 30 * 60 * 1000)
    if (now > expiresAt) throw badRequest('คูปองหมดอายุแล้ว (เกิน 30 นาที)')

    const updated = await prisma.couponUse.update({
      where: { id },
      data: { isUsed: true, usedAt: now },
      include: { coupon: true, member: { select: { id: true, name: true } } },
    })

    return okResponse({
      id: updated.id,
      couponCode: updated.coupon.code,
      couponName: updated.coupon.name,
      discountKind: updated.coupon.discountKind,
      discountValue: Number(updated.coupon.discountValue),
      memberName: updated.member?.name ?? null,
      usedAt: updated.usedAt,
    })
  } catch (e) {
    handleError(e)
  }
})
