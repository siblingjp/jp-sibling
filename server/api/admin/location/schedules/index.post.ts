import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  description: z.string().optional().nullable(),
  mapUrl: z.string().optional().nullable(),
  openTime: z.string().min(1),
  closeTime: z.string().min(1),
  daysOfWeek: z.string().min(1),
  sortOrder: z.number().int().optional().default(0),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const body = validate(schema, await readBody(event))

    const truck = await prisma.truckLocation.findFirst({ where: { isActive: true } })
    if (!truck) throw createError({ statusCode: 404, message: 'ไม่พบข้อมูลร้าน' })

    const schedule = await prisma.locationSchedule.create({
      data: { ...body, truckLocationId: truck.id },
    })

    return okResponse(schedule)
  } catch (e) {
    handleError(e)
  }
})
