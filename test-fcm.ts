import admin from 'firebase-admin'

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID!,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL!,
    privateKey: process.env.FIREBASE_PRIVATE_KEY!.replace(/\\n/g, '\n'),
  }),
})

const tokens = [
  'cDemq6wFClIyRiqQAFeXp0:APA91bHFI_HDWK6MoHp2gIbTs2Gh-aLveTLX2tCvKItA4PWnr93Wl6PuNtsicbH1cZRFPcUBqXPmfiPhV0PhAOt8bOLwOgHpbbpngCrXG7AEyyo5MkKBczY',
]

for (const token of tokens) {
  console.log('Sending to:', token.slice(0, 20) + '...')
  try {
    const res = await admin.messaging().send({
      token,
      notification: { title: 'ทดสอบ FCM', body: 'ถ้าเห็นข้อความนี้แสดงว่าใช้งานได้แล้ว!' },
      webpush: {
        notification: { icon: '/icons/icon-192x192.png' },
        fcmOptions: { link: 'https://jp-sibling.com/member/orders' },
      },
    })
    console.log('SUCCESS:', res)
  } catch (e: any) {
    console.error('ERROR:', e.message, '\nCode:', e.code)
  }
}
