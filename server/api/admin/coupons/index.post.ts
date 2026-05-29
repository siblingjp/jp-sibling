import { z } from 'zod'
import { randomBytes } from 'crypto'

const schema = z.object({
  name: z.string().min(1),
  description: z.string().optional().nullable(),
  type: z.enum(['POINT_REDEEM', 'PROMOTION', 'DISCOUNT']).default('DISCOUNT'),
  benefitType: z.enum(['DISCOUNT', 'FREE_ITEM']).default('DISCOUNT'),
  freeItemDescription: z.string().optional().nullable(),
  discountKind: z.enum(['PERCENT', 'AMOUNT']),
  discountValue: z.number().min(0),
  minOrderAmount: z.number().min(0).optional().nullable(),
  minQuantity: z.number().int().positive().optional().nullable(),
  maxUses: z.number().int().positive().optional().nullable(),
  startAt: z.string().datetime().optional().nullable(),
  expiredAt: z.string().datetime().optional().nullable(),
  isActive: z.boolean().default(true),
  memberOnly: z.boolean().default(false),
  minTier: z.enum(['SILVER', 'GOLD', 'VIP']).optional().nullable(),
  pointCost: z.number().int().positive().optional().nullable(),
  perMemberLimit: z.number().int().positive().optional().nullable(),
  code: z.string().min(6).optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const body = validate(schema, await readBody(event))

    if (body.type === 'POINT_REDEEM' && !body.pointCost) throw badRequest('แลกแต้มต้องระบุต้นทุนแต้ม')
    if (body.benefitType === 'FREE_ITEM' && !body.freeItemDescription) throw badRequest('กรุณาระบุรายละเอียดของแถม')
    if (body.benefitType === 'FREE_ITEM') {
      body.discountValue = 0
    }

    const code = body.code
      ? body.code.toUpperCase()
      : randomBytes(8).toString('hex').toUpperCase()

    const existing = await prisma.coupon.findUnique({ where: { code } })
    if (existing) throw badRequest('Code นี้มีอยู่แล้ว')

    const coupon = await prisma.coupon.create({
      data: {
        code,
        name: body.name,
        description: body.description ?? null,
        type: body.type,
        benefitType: body.benefitType,
        freeItemDescription: body.freeItemDescription ?? null,
        discountKind: body.discountKind,
        discountValue: body.discountValue,
        minOrderAmount: body.minOrderAmount ?? null,
        minQuantity: body.minQuantity ?? null,
        maxUses: body.maxUses ?? null,
        startAt: body.startAt ? new Date(body.startAt) : null,
        expiredAt: body.expiredAt ? new Date(body.expiredAt) : null,
        isActive: body.isActive,
        memberOnly: body.memberOnly,
        minTier: body.minTier ?? null,
        pointCost: body.pointCost ?? null,
        perMemberLimit: body.perMemberLimit ?? null,
      },
    })

    return okResponse(coupon)
  } catch (e) {
    handleError(e)
  }
})
