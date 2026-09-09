export default defineNuxtRouteMiddleware(async (to) => {
  // SSR — ข้ามไป ให้ client-side จัดการ
  if (import.meta.server) return

  const store = useMemberStore()

  if (!store.initialized) {
    await store.fetchMe()
  }

  if (!store.member) {
    let everLoggedIn = false
    try { everLoggedIn = !!localStorage.getItem('member_ever_logged_in') } catch { /* private mode */ }
    return navigateTo(everLoggedIn ? '/member/login?expired=1' : '/member/login')
  }

  if (!store.member.phone && to.path !== '/member/complete-profile') {
    return navigateTo('/member/complete-profile')
  }
})
