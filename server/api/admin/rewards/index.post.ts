import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  pointCost: z.number().int().positive(),
  isActive: z.boolean().optional().default(true),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const data = validate(schema, await readBody(event))
    const reward = await prisma.reward.create({ data })

    return okResponse(reward)
  } catch (e) {
    handleError(e)
  }
})
