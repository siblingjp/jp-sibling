export default defineNuxtRouteMiddleware(async () => {
  const { member, fetchMe } = useMemberAuth()

  if (!member.value) {
    await fetchMe()
  }

  if (!member.value) {
    return navigateTo('/member/login')
  }
})
