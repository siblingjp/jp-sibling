import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  description: z.string().optional().nullable(),
  mapUrl: z.string().optional().nullable(),
  openTime: z.string().min(1),
  closeTime: z.string().min(1),
  daysOfWeek: z.string().min(1),
  isActive: z.boolean().optional(),
  sortOrder: z.number().int().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const body = validate(schema, await readBody(event))

    const schedule = await prisma.locationSchedule.update({
      where: { id },
      data: body,
    })

    return okResponse(schedule)
  } catch (e) {
    handleError(e)
  }
})
