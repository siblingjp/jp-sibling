import { defineStore } from 'pinia'
import { ApiError, initState, loadingState, successState, errorState } from '~/composables/store_models/base'
import { API_ENDPOINTS } from '~/composables/constants/api'
import type { ListQuery } from '~/composables/store_models/base'

export interface AdminMember {
  id: string
  email: string
  name: string
  phone: string | null
  points: number
  isActive: boolean
  createdAt: string
  _count?: { orders: number }
}

export interface AdminMemberDetail extends AdminMember {
  orders: {
    id: string
    status: string
    total: number
    createdAt: string
  }[]
  pointLogs: {
    id: string
    action: string
    amount: number
    note: string | null
    createdAt: string
  }[]
}

export const useMembersStore = defineStore('adminMembers', () => {
  const listState = ref(initState<AdminMember[]>())
  const detailState = ref(initState<AdminMemberDetail>())

  async function fetchList(query?: ListQuery) {
    const http = useHttpClient()
    listState.value = loadingState()
    try {
      const res = await http.get(API_ENDPOINTS.ADMIN.MEMBERS.LIST, query)
      listState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      listState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function fetchDetail(id: string) {
    const http = useHttpClient()
    detailState.value = loadingState()
    try {
      const res = await http.get(API_ENDPOINTS.ADMIN.MEMBERS.SHOW(id))
      detailState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      detailState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function toggleActive(id: string, isActive: boolean) {
    const http = useHttpClient()
    try {
      await http.patch(API_ENDPOINTS.ADMIN.MEMBERS.TOGGLE_ACTIVE(id), { isActive })
    } catch (error) {
      throw new ApiError(error)
    }
  }

  return {
    listState: readonly(listState),
    detailState: readonly(detailState),
    fetchList,
    fetchDetail,
    toggleActive,
  }
})
