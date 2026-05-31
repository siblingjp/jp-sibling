import admin from 'firebase-admin'

let app: admin.app.App | null = null

export function getFirebaseAdmin(): admin.app.App {
  if (app) return app

  const config = useRuntimeConfig()
  const { projectId, clientEmail, privateKey } = config.firebase

  if (!projectId || !clientEmail || !privateKey) {
    throw new Error('Firebase Admin credentials are not configured')
  }

  if (admin.apps.length > 0) {
    app = admin.apps[0]!
    return app
  }

  app = admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey: privateKey.replace(/\\n/g, '\n'),
    }),
  })

  return app
}

export function getMessaging(): admin.messaging.Messaging {
  return getFirebaseAdmin().messaging()
}
