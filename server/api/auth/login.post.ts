import { z } from 'zod'
import { verify } from 'argon2'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
})

export default defineEventHandler(async (event) => {
  try {
    const data = validate(schema, await readBody(event))

    const user = await prisma.user.findUnique({ where: { email: data.email } })
    if (!user || !user.isActive) throw unauthorized('Invalid credentials')

    const valid = await verify(user.passwordHash, data.password)
    if (!valid) throw unauthorized('Invalid credentials')

    await setUserSession(event, {
      user: { id: user.id, email: user.email, name: user.name, role: user.role },
    })

    return okResponse(
      { id: user.id, email: user.email, name: user.name, role: user.role },
      'Login successful',
    )
  } catch (e) {
    handleError(e)
  }
})
