import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  description: z.string().optional().nullable(),
  startAt: z.string().datetime().optional().nullable(),
  expiredAt: z.string().datetime().optional().nullable(),
  isActive: z.boolean().default(true),
  memberOnly: z.boolean().default(false),
  minTier: z.enum(['SILVER', 'GOLD', 'VIP']).optional().nullable(),
  couponIds: z.array(z.string()).default([]),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const body = validate(schema, await readBody(event))

    const campStart = body.startAt ? new Date(body.startAt) : null
    const campEnd = body.expiredAt ? new Date(body.expiredAt) : null

    if (campStart && campEnd && campStart >= campEnd) {
      throw badRequest('วันเริ่มต้นต้องอยู่ก่อนวันสิ้นสุด')
    }

    if (body.couponIds.length > 0 && (campStart || campEnd)) {
      const coupons = await prisma.coupon.findMany({
        where: { id: { in: body.couponIds } },
        select: { id: true, code: true, startAt: true, expiredAt: true },
      })
      for (const c of coupons) {
        if (campStart && c.expiredAt && c.expiredAt < campStart) {
          throw badRequest(`คูปอง ${c.code} หมดอายุก่อนแคมเปญเริ่ม`)
        }
        if (campEnd && c.startAt && c.startAt > campEnd) {
          throw badRequest(`คูปอง ${c.code} เริ่มใช้งานหลังแคมเปญสิ้นสุด`)
        }
      }
    }

    const campaign = await prisma.campaign.create({
      data: {
        name: body.name,
        description: body.description ?? null,
        startAt: campStart,
        expiredAt: campEnd,
        isActive: body.isActive,
        memberOnly: body.memberOnly,
        minTier: body.minTier ?? null,
        coupons: {
          create: body.couponIds.map((couponId) => ({ couponId })),
        },
      },
      include: { coupons: { include: { coupon: true } } },
    })

    return okResponse(campaign)
  } catch (e) {
    handleError(e)
  }
})
