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
    const weekYear = getMonthYear()

    const existing = await prisma.locationRequest.findFirst({
      where: { memberId: session.member.id, weekYear },
    })
    if (existing) throw conflict('คุณได้เสนอสถานที่เดือนนี้แล้ว')

    const request = await prisma.locationRequest.create({
      data: { name: data.name, description: data.description, weekYear, memberId: session.member.id },
    })

    return okResponse(request)
  } catch (e) {
    handleError(e)
  }
})

function getMonthYear() {
  const bkk = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  return `${bkk.getFullYear()}-${String(bkk.getMonth() + 1).padStart(2, '0')}`
}
