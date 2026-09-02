export default defineEventHandler(async () => {
  try {
    const loyaltyMode = await getLoyaltyMode()
    return okResponse({ loyaltyMode })
  } catch (e) {
    handleError(e)
  }
})
