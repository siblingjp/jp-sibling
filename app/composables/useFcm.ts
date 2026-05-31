import { initializeApp, getApps, type FirebaseApp } from 'firebase/app'
import { getMessaging, getToken, onMessage, type Messaging } from 'firebase/messaging'

let firebaseApp: FirebaseApp | null = null
let messaging: Messaging | null = null

export function useFcm() {
  const config = useRuntimeConfig()
  const http = useHttpClient()

  function initFirebase() {
    if (getApps().length > 0) {
      firebaseApp = getApps()[0]!
    } else {
      firebaseApp = initializeApp({
        apiKey: config.public.firebaseApiKey,
        authDomain: config.public.firebaseAuthDomain,
        projectId: config.public.firebaseProjectId,
        messagingSenderId: config.public.firebaseMessagingSenderId,
        appId: config.public.firebaseAppId,
      })
    }
    messaging = getMessaging(firebaseApp)
  }

  async function registerServiceWorker() {
    const registration = await navigator.serviceWorker.register('/firebase-messaging-sw.js', { scope: '/' })
    // ส่ง config ให้ sw
    const sw = registration.installing ?? registration.waiting ?? registration.active
    if (sw) {
      sw.postMessage({
        type: 'FIREBASE_CONFIG',
        config: {
          apiKey: config.public.firebaseApiKey,
          authDomain: config.public.firebaseAuthDomain,
          projectId: config.public.firebaseProjectId,
          messagingSenderId: config.public.firebaseMessagingSenderId,
          appId: config.public.firebaseAppId,
        },
      })
    }
    return registration
  }

  async function requestAndRegister() {
    if (!import.meta.client) return
    if (!('Notification' in window) || !('serviceWorker' in navigator)) {
      console.warn('[FCM] Notification or serviceWorker not supported')
      return
    }
    if (!config.public.firebaseVapidKey) {
      console.warn('[FCM] VAPID key missing')
      return
    }

    try {
      initFirebase()
      const registration = await registerServiceWorker()
      console.log('[FCM] SW registered, requesting permission...')
      const permission = await Notification.requestPermission()
      console.log('[FCM] Permission:', permission)
      if (permission !== 'granted') return

      const token = await getToken(messaging!, {
        vapidKey: config.public.firebaseVapidKey,
        serviceWorkerRegistration: registration,
      })

      if (!token) return

      const platform = /android/i.test(navigator.userAgent)
        ? 'android'
        : /iphone|ipad/i.test(navigator.userAgent)
          ? 'ios'
          : 'web'

      await http.post('/api/member/fcm/token', { token, platform })

      // รับ foreground message
      onMessage(messaging!, (payload) => {
        const { title, body } = payload.notification ?? {}
        if (title) new Notification(title, { body: body ?? '', icon: '/icons/icon-192x192.png' })
      })
    } catch (e) {
      console.error('[FCM] Error:', e)
    }
  }

  return { requestAndRegister }
}
