import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  description: z.string().optional().nullable(),
  mapUrl: z.string().optional().nullable(),
  openTime: z.string().optional().nullable(),
  closeTime: z.string().optional().nullable(),
  daysOfWeek: z.string().optional().nullable(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const data = validate(schema, await readBody(event))

    const existing = await prisma.truckLocation.findFirst({ where: { isActive: true } })

    const location = existing
      ? await prisma.truckLocation.update({ where: { id: existing.id }, data })
      : await prisma.truckLocation.create({ data })

    return okResponse(location)
  } catch (e) {
    handleError(e)
  }
})
