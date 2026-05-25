import { defineStore } from 'pinia'
import { ApiError, initState, loadingState, successState, errorState } from '~/composables/store_models/base'
import { API_ENDPOINTS } from '~/composables/constants/api'

export interface AuthUser {
  id: string
  email: string
  name: string
  role: 'ADMIN' | 'CASHIER' | 'STAFF'
}

interface LoginBody {
  email: string
  password: string
}

export const useAuthStore = defineStore('auth', () => {
  const state = ref(initState<AuthUser>())

  const isLoading = computed(() => state.value.isLoading)
  const isError = computed(() => state.value.isError)
  const errorMessage = computed(() => state.value.response?.message)

  async function login(body: LoginBody) {
    const http = useHttpClient()
    state.value = loadingState()
    try {
      const res = await http.post<{ data: AuthUser }>(API_ENDPOINTS.AUTH.LOGIN, body)
      // refresh session cookie → useUserSession() จะ sync อัตโนมัติ
      const { fetch: fetchSession } = useUserSession()
      await fetchSession()
      state.value = successState({ data: res.data })
      return res
    } catch (error) {
      const err = new ApiError(error)
      state.value = errorState({ message: err.message, statusCode: err.statusCode })
      throw err
    }
  }

  async function logout() {
    const http = useHttpClient()
    const { clear: clearSession } = useUserSession()
    await http.post(API_ENDPOINTS.AUTH.LOGOUT).catch(() => {})
    await clearSession()
    state.value = initState()
    await navigateTo('/admin/login')
  }

  return { state, isLoading, isError, errorMessage, login, logout }
})
