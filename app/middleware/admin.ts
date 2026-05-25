export default defineNuxtRouteMiddleware(() => {
  const { loggedIn, user } = useUserSession()
  if (!loggedIn.value) {
    return navigateTo('/admin/login')
  }
  const role = (user.value as { role?: string })?.role
  if (!role || !['ADMIN', 'CASHIER', 'STAFF'].includes(role)) {
    return navigateTo('/')
  }
})
