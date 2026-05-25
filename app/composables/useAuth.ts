export function useAuth() {
  const { user: sessionUser, loggedIn } = useUserSession()
  const store = useAuthStore()

  const user = computed(() => sessionUser.value as import('~/stores/auth').AuthUser | null ?? null)
  const isAuthenticated = computed(() => loggedIn.value)
  const isAdmin = computed(() => user.value?.role === 'ADMIN')
  const isCashier = computed(() => user.value?.role === 'CASHIER')

  return {
    user,
    isAuthenticated,
    isAdmin,
    isCashier,
    isLoading: store.isLoading,
    login: store.login,
    logout: store.logout,
  }
}
