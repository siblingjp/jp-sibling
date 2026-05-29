import { z } from 'zod'
import { verify } from 'argon2'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
})

export default defineEventHandler(async (event) => {
  try {
    const data = validate(schema, await readBody(event))

    const member = await prisma.member.findUnique({
      where: { email: data.email, isActive: true },
    })
    if (!member || !member.passwordHash) throw notFound('EMAIL_NOT_FOUND')

    const valid = await verify(member.passwordHash, data.password)
    if (!valid) throw unauthorized('Invalid email or password')

    await setUserSession(event, {
      member: {
        id: member.id,
        name: member.name,
        email: member.email,
        tier: member.tier,
        points: member.points,
      },
    })

    return okResponse({ id: member.id, name: member.name, tier: member.tier })
  } catch (e) {
    handleError(e)
  }
})
