import { z } from 'zod'

const schema = z.object({
  mode: z.enum(['close', 'closeBlock', 'reset', 'openNow']),
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
        ? { manualClose: false, manualOpen: false, blockOnlineOrder: false }
        : mode === 'openNow'
          ? { manualClose: false, manualOpen: true, blockOnlineOrder: false }
          : mode === 'closeBlock'
            ? { manualClose: true, manualOpen: false, blockOnlineOrder: true }
            : { manualClose: true, manualOpen: false, blockOnlineOrder: false }

    const updated = await prisma.truckLocation.update({
      where: { id: truck.id },
      data,
    })

    return okResponse({
      manualClose: updated.manualClose,
      manualOpen: updated.manualOpen,
      blockOnlineOrder: updated.blockOnlineOrder,
    })
  } catch (e) {
    handleError(e)
  }
})
