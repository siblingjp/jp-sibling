export async function sendLineMessageToAdmin(text: string) {
  const config = useRuntimeConfig()
  const { channelAccessToken, adminUserId } = config.lineMessaging
  if (!channelAccessToken || !adminUserId) return

  await $fetch('https://api.line.me/v2/bot/message/push', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${channelAccessToken}`,
    },
    body: {
      to: adminUserId,
      messages: [{ type: 'text', text }],
    },
  })
}
