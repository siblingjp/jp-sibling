export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const query = getQuery(event)
    const page = Math.max(1, Number(query.page) || 1)
    const size = Math.min(100, Math.max(1, Number(query.size) || 20))
    const skip = (page - 1) * size

    const [coupons, total] = await Promise.all([
      prisma.coupon.findMany({
        orderBy: { createdAt: 'desc' },
        include: { _count: { select: { uses: true } } },
        skip,
        take: size,
      }),
      prisma.coupon.count(),
    ])

    return okResponse({ data: coupons, total, page, size })
  } catch (e) {
    handleError(e)
  }
})
