import { defineStore } from 'pinia'
import { ApiError, initState, loadingState, successState, errorState } from '~/composables/store_models/base'
import { API_ENDPOINTS } from '~/composables/constants/api'

export interface OptionItem {
  id?: string
  name: string
  extraPrice: number
  isActive: boolean
  sortOrder: number
}

export interface OptionGroup {
  id: string
  name: string
  required: boolean
  multiSelect: boolean
  isActive: boolean
  sortOrder: number
  createdAt: string
  updatedAt: string
  options: (OptionItem & { id: string })[]
  _count?: { products: number }
}

export interface OptionGroupForm {
  name: string
  required: boolean
  multiSelect: boolean
  isActive: boolean
  sortOrder: number
  options: OptionItem[]
}

export const useOptionGroupsStore = defineStore('adminOptionGroups', () => {
  const listState = ref(initState<OptionGroup[]>())
  const formState = ref(initState<OptionGroup>())

  async function fetchList() {
    const http = useHttpClient()
    listState.value = loadingState()
    try {
      const res = await http.get(API_ENDPOINTS.ADMIN.OPTION_GROUPS.LIST)
      listState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      listState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function create(body: OptionGroupForm) {
    const http = useHttpClient()
    formState.value = loadingState()
    try {
      const res = await http.post(API_ENDPOINTS.ADMIN.OPTION_GROUPS.CREATE, body)
      formState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      formState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function update(id: string, body: OptionGroupForm) {
    const http = useHttpClient()
    formState.value = loadingState()
    try {
      const res = await http.put(API_ENDPOINTS.ADMIN.OPTION_GROUPS.UPDATE(id), body)
      formState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      formState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function remove(id: string) {
    const http = useHttpClient()
    try {
      await http.delete(API_ENDPOINTS.ADMIN.OPTION_GROUPS.DELETE(id))
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
    remove,
  }
})
