import { z } from 'zod'

const schema = z.object({
  mode: z.enum(['close', 'closeBlock', 'reset']),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { mode } = validate(schema, await readBody(event))

    const truck = await prisma.truckLocation.findFirst({ where: { isActive: true } })
    if (!truck) throw createError({ statusCode: 404, message: 'ไม่พบข้อมูลร้าน' })

    const data =
      mode === 'reset'
        ? { manualClose: false, blockOnlineOrder: false }
        : mode === 'closeBlock'
          ? { manualClose: true, blockOnlineOrder: true }
          : { manualClose: true, blockOnlineOrder: false }

    const updated = await prisma.truckLocation.update({
      where: { id: truck.id },
      data,
    })

    return okResponse({
      manualClose: updated.manualClose,
      blockOnlineOrder: updated.blockOnlineOrder,
    })
  } catch (e) {
    handleError(e)
  }
})
