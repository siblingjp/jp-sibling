export default defineEventHandler(async (event) => {
  try {
    await clearUserSession(event)
    return okResponse(null)
  } catch (e) {
    handleError(e)
  }
})
