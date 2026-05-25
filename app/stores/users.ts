import { defineStore } from 'pinia'
import { ApiError, initState, loadingState, successState, errorState } from '~/composables/store_models/base'
import { API_ENDPOINTS } from '~/composables/constants/api'
import type { ListQuery } from '~/composables/store_models/base'

export interface AdminUser {
  id: string
  email: string
  name: string
  role: 'ADMIN' | 'CASHIER' | 'STAFF'
  isActive: boolean
  createdAt: string
}

export interface UserForm {
  email: string
  name: string
  password: string
  role: 'ADMIN' | 'CASHIER' | 'STAFF'
  isActive: boolean
}

export const useUsersStore = defineStore('users', () => {
  const listState = ref(initState<AdminUser[]>())
  const formState = ref(initState<AdminUser>())

  async function fetchList(query?: ListQuery) {
    const http = useHttpClient()
    listState.value = loadingState()
    try {
      const res = await http.get(API_ENDPOINTS.ADMIN.USERS.LIST, query)
      listState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      listState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function create(body: UserForm) {
    const http = useHttpClient()
    formState.value = loadingState()
    try {
      const res = await http.post(API_ENDPOINTS.ADMIN.USERS.CREATE, body)
      formState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      formState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function update(id: string, body: Partial<UserForm>) {
    const http = useHttpClient()
    formState.value = loadingState()
    try {
      const res = await http.put(API_ENDPOINTS.ADMIN.USERS.UPDATE(id), body)
      formState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      formState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function deactivate(id: string) {
    const http = useHttpClient()
    try {
      await http.delete(API_ENDPOINTS.ADMIN.USERS.DELETE(id))
    } catch (error) {
      throw new ApiError(error)
    }
  }

  return {
    listState: readonly(listState),
    formState: readonly(formState),
    fetchList,
    create,
    update,
    deactivate,
  }
})
