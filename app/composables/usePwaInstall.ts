export function usePwaInstall() {
  const { $pwa } = useNuxtApp()

  const canInstall = computed(() => !!$pwa?.showInstallPrompt)

  async function install() {
    await $pwa?.install()
  }

  function dismiss() {
    $pwa?.cancelInstall()
  }

  return { canInstall, install, dismiss }
}
