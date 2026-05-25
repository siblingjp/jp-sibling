export default defineEventHandler(async (event) => {
  await clearUserSession(event)
  return okResponse(null, 'Logged out')
})
