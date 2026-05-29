import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1).optional(),
  description: z.string().optional().nullable(),
  type: z.enum(['POINT_REDEEM', 'PROMOTION', 'DISCOUNT']).optional(),
  benefitType: z.enum(['DISCOUNT', 'FREE_ITEM']).optional(),
  freeItemDescription: z.string().optional().nullable(),
  discountKind: z.enum(['PERCENT', 'AMOUNT']).optional(),
  discountValue: z.number().min(0).optional(),
  minOrderAmount: z.number().min(0).optional().nullable(),
  minQuantity: z.number().int().positive().optional().nullable(),
  maxUses: z.number().int().positive().optional().nullable(),
  startAt: z.string().datetime().optional().nullable(),
  expiredAt: z.string().datetime().optional().nullable(),
  isActive: z.boolean().optional(),
  memberOnly: z.boolean().optional(),
  minTier: z.enum(['SILVER', 'GOLD', 'VIP']).optional().nullable(),
  pointCost: z.number().int().positive().optional().nullable(),
  perMemberLimit: z.number().int().positive().optional().nullable(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    const body = validate(schema, await readBody(event))

    const coupon = await prisma.coupon.update({
      where: { id },
      data: {
        ...body,
        startAt: body.startAt !== undefined ? (body.startAt ? new Date(body.startAt) : null) : undefined,
        expiredAt: body.expiredAt !== undefined ? (body.expiredAt ? new Date(body.expiredAt) : null) : undefined,
      },
    })

    return okResponse(coupon)
  } catch (e) {
    handleError(e)
  }
})
