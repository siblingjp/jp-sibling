// ชั่วคราว: ใช้หา LINE userId ของ admin เท่านั้น — ลบไฟล์นี้ทิ้งได้หลังตั้งค่า LINE_ADMIN_USER_ID เสร็จ
export default defineEventHandler(async (event) => {
  const body = await readBody<{ events?: any[] }>(event)
  const config = useRuntimeConfig()

  for (const e of body.events ?? []) {
    const userId = e?.source?.userId
    if (!userId) continue

    console.log('[LINE webhook] userId:', userId)

    if (e.replyToken && config.lineMessaging.channelAccessToken) {
      await $fetch('https://api.line.me/v2/bot/message/reply', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${config.lineMessaging.channelAccessToken}`,
        },
        body: {
          replyToken: e.replyToken,
          messages: [{ type: 'text', text: `userId ของคุณคือ:\n${userId}` }],
        },
      }).catch(err => console.error('[LINE webhook] reply failed', err))
    }
  }

  return { ok: true }
})
