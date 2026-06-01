export default defineNuxtRouteMiddleware(async () => {
  // SSR — ข้ามไป ให้ client-side จัดการ
  if (import.meta.server) return

  const store = useMemberStore()

  if (!store.initialized) {
    await store.fetchMe()
  }

  if (!store.member) {
    return navigateTo('/member/login')
  }
})
