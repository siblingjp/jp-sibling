import { defineStore } from 'pinia'
import { ApiError, initState, loadingState, successState, errorState } from '~/composables/store_models/base'
import { API_ENDPOINTS } from '~/composables/constants/api'
import type { ListQuery } from '~/composables/store_models/base'

export interface Product {
  id: string
  name: string
  slug: string
  description: string | null
  price: number
  imageUrl: string | null
  isActive: boolean
  isFeatured: boolean
  isStampEligible: boolean
  categoryId: string
  category: { id: string; name: string }
  createdAt: string
}

export interface ProductForm {
  name: string
  slug: string
  description?: string
  price: number
  imageUrl?: string
  categoryId: string
  isActive: boolean
  isFeatured?: boolean
  isStampEligible?: boolean
  optionGroupIds?: string[]
}

export const useProductsStore = defineStore('products', () => {
  const listState = ref(initState<Product[]>())
  const formState = ref(initState<Product>())

  async function fetchList(query?: ListQuery) {
    const http = useHttpClient()
    listState.value = loadingState()
    try {
      const res = await http.get(API_ENDPOINTS.ADMIN.PRODUCTS.LIST, query)
      listState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      listState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function create(body: ProductForm) {
    const http = useHttpClient()
    formState.value = loadingState()
    try {
      const res = await http.post(API_ENDPOINTS.ADMIN.PRODUCTS.CREATE, body)
      formState.value = successState(res)
      return res
    } catch (error) {
      const err = new ApiError(error)
      formState.value = errorState({ message: err.message })
      throw err
    }
  }

  async function update(id: string, body: Partial<ProductForm>) {
    const http = useHttpClient()
    formState.value = loadingState()
    try {
      const res = await http.put(API_ENDPOINTS.ADMIN.PRODUCTS.UPDATE(id), body)
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
      await http.delete(API_ENDPOINTS.ADMIN.PRODUCTS.DELETE(id))
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
