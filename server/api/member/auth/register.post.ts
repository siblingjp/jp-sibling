import { z } from 'zod'
import { hash } from 'argon2'

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  password: z.string().min(8),
  phone: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const data = validate(schema, await readBody(event))

    const existing = await prisma.member.findUnique({ where: { email: data.email } })
    if (existing) throw conflict('Email already registered')

    if (data.phone) {
      const phoneExists = await prisma.member.findFirst({ where: { phone: data.phone, isActive: true } })
      if (phoneExists) throw conflict('PHONE_EXISTS')
    }

    const passwordHash = await hash(data.password)
    const { password: _, ...rest } = data

    const member = await prisma.member.create({
      data: { ...rest, passwordHash },
    })

    await setUserSession(event, {
      member: {
        id: member.id,
        name: member.name,
        email: member.email,
        tier: member.tier,
        points: member.points,
      },
    })

    return okResponse({ id: member.id, name: member.name })
  } catch (e) {
    handleError(e)
  }
})
