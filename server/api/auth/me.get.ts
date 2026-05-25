export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const user = await prisma.user.findUnique({
      where: { id: session.user.id },
      select: { id: true, email: true, name: true, role: true, isActive: true },
    })

    if (!user || !user.isActive) {
      await clearUserSession(event)
      throw unauthorized()
    }

    return okResponse({ id: user.id, email: user.email, name: user.name, role: user.role })
  } catch (e) {
    handleError(e)
  }
})
