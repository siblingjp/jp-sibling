import { z } from 'zod'

const optionSchema = z.object({
  name: z.string().min(1),
  extraPrice: z.number().min(0).default(0),
  sortOrder: z.number().int().default(0),
})

const schema = z.object({
  name: z.string().min(1),
  required: z.boolean().default(false),
  multiSelect: z.boolean().default(false),
  sortOrder: z.number().int().default(0),
  options: z.array(optionSchema).min(1),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const data = validate(schema, await readBody(event))

    const group = await prisma.optionGroup.create({
      data: {
        name: data.name,
        required: data.required,
        multiSelect: data.multiSelect,
        sortOrder: data.sortOrder,
        options: {
          create: data.options.map((o) => ({
            name: o.name,
            extraPrice: o.extraPrice,
            sortOrder: o.sortOrder,
          })),
        },
      },
      include: {
        options: { orderBy: [{ sortOrder: 'asc' }] },
      },
    })

    return okResponse(group)
  } catch (e) {
    handleError(e)
  }
})
