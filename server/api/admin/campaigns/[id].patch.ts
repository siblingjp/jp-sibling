import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1).optional(),
  description: z.string().optional().nullable(),
  startAt: z.string().datetime().optional().nullable(),
  expiredAt: z.string().datetime().optional().nullable(),
  isActive: z.boolean().optional(),
  memberOnly: z.boolean().optional(),
  minTier: z.enum(['SILVER', 'GOLD', 'VIP']).optional().nullable(),
  couponIds: z.array(z.string()).optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    const body = validate(schema, await readBody(event))

    const campStart = body.startAt !== undefined ? (body.startAt ? new Date(body.startAt) : null) : undefined
    const campEnd = body.expiredAt !== undefined ? (body.expiredAt ? new Date(body.expiredAt) : null) : undefined

    if (campStart && campEnd && campStart >= campEnd) {
      throw badRequest('วันเริ่มต้นต้องอยู่ก่อนวันสิ้นสุด')
    }

    if (body.couponIds !== undefined && body.couponIds.length > 0 && (campStart || campEnd)) {
      const existing = await prisma.campaign.findUnique({ where: { id }, select: { startAt: true, expiredAt: true } })
      const resolvedStart = campStart !== undefined ? campStart : existing?.startAt ?? null
      const resolvedEnd = campEnd !== undefined ? campEnd : existing?.expiredAt ?? null

      const coupons = await prisma.coupon.findMany({
        where: { id: { in: body.couponIds } },
        select: { id: true, code: true, startAt: true, expiredAt: true },
      })
      for (const c of coupons) {
        if (resolvedStart && c.expiredAt && c.expiredAt < resolvedStart) {
          throw badRequest(`คูปอง ${c.code} หมดอายุก่อนแคมเปญเริ่ม`)
        }
        if (resolvedEnd && c.startAt && c.startAt > resolvedEnd) {
          throw badRequest(`คูปอง ${c.code} เริ่มใช้งานหลังแคมเปญสิ้นสุด`)
        }
      }
    }

    const campaign = await prisma.$transaction(async (tx) => {
      if (body.couponIds !== undefined) {
        await tx.campaignCoupon.deleteMany({ where: { campaignId: id } })
        if (body.couponIds.length > 0) {
          await tx.campaignCoupon.createMany({
            data: body.couponIds.map((couponId) => ({ campaignId: id, couponId })),
          })
        }
      }

      return tx.campaign.update({
        where: { id },
        data: {
          ...(body.name !== undefined && { name: body.name }),
          ...(body.description !== undefined && { description: body.description }),
          ...(body.isActive !== undefined && { isActive: body.isActive }),
          ...(body.memberOnly !== undefined && { memberOnly: body.memberOnly }),
          ...(body.minTier !== undefined && { minTier: body.minTier }),
          ...(campStart !== undefined && { startAt: campStart }),
          ...(campEnd !== undefined && { expiredAt: campEnd }),
        },
        include: { coupons: { include: { coupon: true } } },
      })
    }, { timeout: 10000 })

    return okResponse(campaign)
  } catch (e) {
    handleError(e)
  }
})
