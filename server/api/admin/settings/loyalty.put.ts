import { z } from 'zod'

const schema = z.object({
  loyaltyMode: z.enum(['POINTS', 'STAMPS']),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const { loyaltyMode } = validate(schema, await readBody(event))

    // ต้องแก้เฉพาะ Settings.loyaltyMode เท่านั้น ห้ามแตะ Member.points / Member.stampCount ที่นี่เด็ดขาด
    const settings = await prisma.settings.upsert({
      where: { id: SETTINGS_SINGLETON_ID },
      create: { id: SETTINGS_SINGLETON_ID, loyaltyMode },
      update: { loyaltyMode },
    })

    invalidateLoyaltyModeCache()

    return okResponse({ loyaltyMode: settings.loyaltyMode })
  } catch (e) {
    handleError(e)
  }
})
