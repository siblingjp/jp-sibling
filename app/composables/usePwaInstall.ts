export type PwaInstallPlatform =
  | 'android-chrome'   // มี native prompt
  | 'ios-safari'       // ต้องแนะนำ manual
  | 'ios-other'        // Chrome/Firefox บน iOS — ต้องเปิดด้วย Safari
  | 'desktop'          // desktop browser ที่รองรับ PWA
  | 'unsupported'

export function usePwaInstall() {
  const { $pwa } = useNuxtApp()

  const platform = computed<PwaInstallPlatform>(() => {
    if (!import.meta.client) return 'unsupported'
    const ua = navigator.userAgent

    const isIOS = /iPad|iPhone|iPod/.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)
    const isSafari = /Safari/.test(ua) && !/Chrome|CriOS|FxiOS|OPiOS/.test(ua)
    const isAndroid = /Android/.test(ua)
    const isChrome = /Chrome/.test(ua) && !/Edg/.test(ua)

    if (isIOS && isSafari) return 'ios-safari'
    if (isIOS && !isSafari) return 'ios-other'
    if (isAndroid && isChrome) return 'android-chrome'
    if ($pwa?.showInstallPrompt) return 'desktop'
    return 'unsupported'
  })

  // แสดง banner ถ้ายังไม่ได้ install และ platform รองรับ
  const isInStandaloneMode = computed(() => {
    if (!import.meta.client) return false
    return window.matchMedia('(display-mode: standalone)').matches
      || ('standalone' in navigator && (navigator as any).standalone === true)
  })

  const canInstall = computed(() =>
    !isInStandaloneMode.value && platform.value !== 'unsupported'
  )

  const isIOS = computed(() => {
    if (!import.meta.client) return false
    const ua = navigator.userAgent
    return /iPad|iPhone|iPod/.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)
  })

  // native prompt ใช้ได้จริงเฉพาะ non-iOS เท่านั้น
  const hasNativePrompt = computed(() => !isIOS.value && !!$pwa?.showInstallPrompt)

  async function install() {
    if (hasNativePrompt.value) await $pwa?.install()
  }

  function dismiss() {
    $pwa?.cancelInstall()
  }

  return { canInstall, platform, hasNativePrompt, isInStandaloneMode, install, dismiss }
}
