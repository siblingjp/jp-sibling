import { defineStore } from 'pinia'
import { ApiError, initState, loadingState, successState, errorState } from '~/composables/store_models/base'
import { API_ENDPOINTS } from '~/composables/constants/api'
import type { ListQuery } from '~/composables/store_models/base'

export interface Category {
  id: string
  name: string
  slug: string
  imageUrl: string | null
  isActive: boolean
  createdAt: string
  _count?: { products: number }
}

export interface CategoryForm {
  name: string
  slug: string
  imageUrl?: string
  isActive: boolean
}

export const useCategoriesStore = defineStore('categories', () => {
  const listState = ref(initState<Category[]>())
  const formState = ref(initState<Category>())

  async function fetchList(query?: ListQuery) {
    const http = useHttpClient()
    listState.value = loadingState()
    try {
      const res = await http.get(API_ENDPOINTS.ADMIN.CATEGORIES.LIST, query)
      listState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      listState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function create(body: CategoryForm) {
    const http = useHttpClient()
    formState.value = loadingState()
    try {
      const res = await http.post(API_ENDPOINTS.ADMIN.CATEGORIES.CREATE, body)
      formState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      formState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function update(id: string, body: Partial<CategoryForm>) {
    const http = useHttpClient()
    formState.value = loadingState()
    try {
      const res = await http.put(API_ENDPOINTS.ADMIN.CATEGORIES.UPDATE(id), body)
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
      await http.delete(API_ENDPOINTS.ADMIN.CATEGORIES.DELETE(id))
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
