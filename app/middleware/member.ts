export default defineNuxtRouteMiddleware(async () => {
  const store = useMemberStore()

  if (!store.initialized) {
    await store.fetchMe()
  }

  if (!store.member) {
    return navigateTo('/member/login')
  }
})
