import { z } from 'zod'

const schema = z.object({
  isActive: z.boolean(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const member = await prisma.member.findUnique({ where: { id } })
    if (!member) throw notFound('Member')

    const updated = await prisma.member.update({
      where: { id },
      data: { isActive: data.isActive },
      select: { id: true, email: true, name: true, isActive: true },
    })

    return okResponse(updated)
  } catch (e) {
    handleError(e)
  }
})
