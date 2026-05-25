import { z } from 'zod'

const schema = z.object({
  points: z.number().int().positive(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const { points } = validate(schema, await readBody(event))

    const member = await prisma.member.findUnique({
      where: { id: session.member.id, isActive: true },
    })
    if (!member) throw unauthorized()
    if (member.points < points) throw badRequest('Insufficient points')

    const discount = points // 1pt = 1฿

    const updatedMember = await prisma.$transaction(async (tx) => {
      const updated = await tx.member.update({
        where: { id: member.id },
        data: { points: { decrement: points } },
        select: { points: true, tier: true },
      })

      await tx.pointLog.create({
        data: {
          memberId: member.id,
          action: 'REDEEM',
          amount: -points,
          note: `Redeemed ${points}pt = ${discount}฿ discount`,
        },
      })

      return updated
    })

    await setUserSession(event, {
      ...session,
      member: { ...session.member, points: updatedMember.points, tier: updatedMember.tier },
    })

    return okResponse({ pointsUsed: points, discount, remainingPoints: updatedMember.points })
  } catch (e) {
    handleError(e)
  }
})
