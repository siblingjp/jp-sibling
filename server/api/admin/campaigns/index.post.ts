import { z } from 'zod'

const schema = z.object({
  title: z.string().min(1),
  description: z.string().optional().nullable(),
  imageUrl: z.string().url().optional().nullable(),
  status: z.enum(['DRAFT', 'PUBLISHED', 'ARCHIVED']).default('DRAFT'),
  startsAt: z.string().datetime().optional().nullable(),
  endsAt: z.string().datetime().optional().nullable(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const data = validate(schema, await readBody(event))
    const campaign = await prisma.campaign.create({
      data: {
        ...data,
        startsAt: data.startsAt ? new Date(data.startsAt) : null,
        endsAt: data.endsAt ? new Date(data.endsAt) : null,
      },
    })
    return okResponse(campaign)
  } catch (e) {
    handleError(e)
  }
})
