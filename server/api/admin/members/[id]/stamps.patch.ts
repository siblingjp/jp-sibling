import { z } from 'zod'

const schema = z.object({
  stampCount: z.number().int().min(0).max(MAX_STAMPS),
  note: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const member = await prisma.member.findUnique({ where: { id }, select: { stampCount: true } })
    if (!member) throw notFound('Member')

    const diff = data.stampCount - member.stampCount
    if (diff === 0) return okResponse({ id, stampCount: member.stampCount })

    const updated = await prisma.$transaction(async (tx) => {
      const result = await tx.member.update({
        where: { id },
        data: { stampCount: data.stampCount },
        select: { id: true, stampCount: true },
      })
      await tx.stampLog.create({
        data: {
          memberId: id,
          action: 'ADJUST',
          amount: diff,
          note: data.note || `แอดมินปรับแสตมป์ด้วยตนเอง (${member.stampCount} → ${data.stampCount})`,
        },
      })
      return result
    })

    return okResponse(updated)
  } catch (e) {
    handleError(e)
  }
})
