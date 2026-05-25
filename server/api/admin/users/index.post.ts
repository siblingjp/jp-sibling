import { z } from 'zod'
import { hash } from 'argon2'

const schema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
  password: z.string().min(8),
  role: z.enum(['ADMIN', 'CASHIER', 'STAFF']).default('STAFF'),
  isActive: z.boolean().default(true),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const data = validate(schema, await readBody(event))

    const existing = await prisma.user.findUnique({ where: { email: data.email } })
    if (existing) throw conflict('Email already exists')

    const passwordHash = await hash(data.password)
    const { password: _, ...rest } = data
    const user = await prisma.user.create({
      data: { ...rest, passwordHash },
      select: { id: true, email: true, name: true, role: true, isActive: true, createdAt: true },
    })

    return okResponse(user, 'User created')
  } catch (e) {
    handleError(e)
  }
})
