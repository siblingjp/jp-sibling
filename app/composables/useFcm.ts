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
    const registration = await navigator.serviceWorker.register('/sw.js', { scope: '/' })

    // รอจนกว่า SW จะ active
    await new Promise<void>((resolve) => {
      if (registration.active) return resolve()
      const sw = registration.installing ?? registration.waiting
      if (!sw) return resolve()
      sw.addEventListener('statechange', function handler() {
        if (sw.state === 'activated') {
          sw.removeEventListener('statechange', handler)
          resolve()
        }
      })
    })

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
      console.log('[FCM] SW registered:', registration.scope, registration.active?.state)
      const permission = await Notification.requestPermission()
      console.log('[FCM] Permission:', permission)
      if (permission !== 'granted') return

      console.log('[FCM] Getting token...')
      const token = await getToken(messaging!, {
        vapidKey: config.public.firebaseVapidKey,
        serviceWorkerRegistration: registration,
      })
      console.log('[FCM] Token:', token ? token.slice(0, 20) + '...' : 'EMPTY')

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
