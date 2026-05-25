import { defineStore } from 'pinia'
import { ApiError, initState, loadingState, successState, errorState } from '~/composables/store_models/base'
import { API_ENDPOINTS } from '~/composables/constants/api'
import type { BaseResponse } from '~/composables/store_models/base'

export interface MemberUser {
  id: string
  name: string
  email: string | null
  phone: string | null
  profileImage: string | null
  tier: 'SILVER' | 'GOLD' | 'VIP'
  points: number
  totalSpent: number
  lineUserId: string | null
  googleId: string | null
  createdAt: string
}

interface LoginBody {
  email: string
  password: string
}

interface RegisterBody {
  name: string
  email: string
  password: string
  phone?: string
}

export const useMemberStore = defineStore('member', () => {
  const state = ref(initState<MemberUser>())
  const member = ref<MemberUser | null>(null)

  const isMemberAuthenticated = computed(() => !!member.value)

  async function login(body: LoginBody) {
    const http = useHttpClient()
    state.value = loadingState()
    try {
      const res = await http.post<BaseResponse<{ id: string; name: string; tier: string }>>(API_ENDPOINTS.MEMBER.AUTH.LOGIN, body)
      state.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      state.value = errorState({ message: err.message, statusCode: err.statusCode })
      throw err
    }
  }

  async function register(body: RegisterBody) {
    const http = useHttpClient()
    state.value = loadingState()
    try {
      const res = await http.post<BaseResponse<{ id: string; name: string }>>(API_ENDPOINTS.MEMBER.AUTH.REGISTER, body)
      state.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      state.value = errorState({ message: err.message, statusCode: err.statusCode })
      throw err
    }
  }

  async function logout() {
    const http = useHttpClient()
    await http.post(API_ENDPOINTS.MEMBER.AUTH.LOGOUT).catch(() => {})
    member.value = null
    state.value = initState()
    await navigateTo('/member/login')
  }

  async function fetchMe() {
    const http = useHttpClient()
    try {
      const res = await http.get<BaseResponse<MemberUser>>(API_ENDPOINTS.MEMBER.AUTH.ME)
      member.value = res.data ?? null
    } catch {
      member.value = null
    }
  }

  async function updateProfile(body: { name: string; phone?: string }) {
    const http = useHttpClient()
    state.value = loadingState()
    try {
      const res = await http.put<BaseResponse<MemberUser>>(API_ENDPOINTS.MEMBER.PROFILE, body)
      if (res.data) member.value = res.data
      state.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      state.value = errorState({ message: err.message, statusCode: err.statusCode })
      throw err
    }
  }

  function addPoints(amount: number) {
    if (member.value) member.value.points += amount
  }

  return {
    state: readonly(state),
    member,
    isMemberAuthenticated,
    login,
    register,
    logout,
    fetchMe,
    updateProfile,
    addPoints,
  }
})
