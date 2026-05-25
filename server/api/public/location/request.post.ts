import { z } from 'zod'

const schema = z.object({
  name: z.string().min(2).max(100),
  description: z.string().max(300).optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized('กรุณาเข้าสู่ระบบก่อนเสนอสถานที่')

    const data = validate(schema, await readBody(event))
    const weekYear = getWeekYear()

    const existing = await prisma.locationRequest.findFirst({
      where: { memberId: session.member.id, weekYear },
    })
    if (existing) throw conflict('คุณได้เสนอสถานที่สัปดาห์นี้แล้ว')

    const request = await prisma.locationRequest.create({
      data: { name: data.name, description: data.description, weekYear, memberId: session.member.id },
    })

    return okResponse(request)
  } catch (e) {
    handleError(e)
  }
})

function getWeekYear() {
  const now = new Date()
  const d = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()))
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7))
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1))
  const week = Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7)
  return `${d.getUTCFullYear()}-W${String(week).padStart(2, '0')}`
}
