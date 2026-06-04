<script setup lang="ts">
import type { Product } from '~/stores/products'
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useProductsStore()
const { showSuccess, showError, confirmDelete } = useAlert()

const search = ref('')
const filterActive = ref<string>('all')
const filterCategory = ref<string>('all')
const currentPage = ref(1)

const query = computed(() => ({
  search: search.value,
  filter: {
    ...(filterActive.value !== 'all' ? { isActive: filterActive.value === 'true' } : {}),
    ...(filterCategory.value !== 'all' ? { categoryId: filterCategory.value } : {}),
  },
  pagination: { page: currentPage.value, limit: 20 },
}))

// Reset to page 1 when filters change
watch([search, filterActive, filterCategory], () => { currentPage.value = 1 })

// Load categories for filter dropdown
const { data: categoriesRes } = await useAsyncData('admin-categories-select', () =>
  useHttpClient().get<{ data: { id: string; name: string }[] }>('/api/admin/categories?pagination[limit]=100'),
)
const categoryOptions = computed(() => categoriesRes.value?.data ?? [])

async function load() {
  await store.fetchList(query.value).catch((e) => showError(e.message))
}

async function handleDelete(product: Product) {
  if (!await confirmDelete(product.name)) return
  try {
    await store.remove(product.id)
    showSuccess('Product deleted')
    load()
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to delete')
  }
}

async function handleToggleFeatured(product: Product) {
  try {
    await useHttpClient().patch(API_ENDPOINTS.ADMIN.PRODUCTS.TOGGLE_FEATURED(product.id), {})
    product.isFeatured = !product.isFeatured
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to update')
  }
}

watch(query, load, { deep: true })
onMounted(load)

const products = computed(() => (store.listState.response?.data as Product[]) ?? [])
const pagination = computed(() => store.listState.response?.pagination)
const isLoading = computed(() => store.listState.isLoading)

function formatPrice(price: number) {
  return new Intl.NumberFormat('th-TH', { style: 'currency', currency: 'THB' }).format(price)
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">สินค้า</h1>
      <NuxtLink
        to="/admin/products/new"
        class="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
      >
        + เพิ่มสินค้า
      </NuxtLink>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3">
      <input
        v-model="search"
        type="text"
        placeholder="ค้นหาสินค้า..."
        class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <select
        v-model="filterCategory"
        class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <option value="all">ทุกหมวดหมู่</option>
        <option v-for="cat in categoryOptions" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
      </select>
      <select
        v-model="filterActive"
        class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <option value="all">ทุกสถานะ</option>
        <option value="true">ใช้งานอยู่</option>
        <option value="false">ปิดใช้งาน</option>
      </select>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">ชื่อสินค้า</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">หมวดหมู่</th>
            <th class="text-right px-4 py-3 font-medium text-gray-600">ราคา</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">สถานะ</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">แนะนำ</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="6" class="text-center py-10 text-gray-400">Loading...</td>
          </tr>
          <tr v-else-if="products.length === 0">
            <td colspan="6" class="text-center py-10 text-gray-400">No products found</td>
          </tr>
          <tr
            v-for="product in products"
            :key="product.id"
            class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
          >
            <td class="px-4 py-3">
              <div class="flex items-center gap-3">
                <img
                  v-if="product.imageUrl"
                  :src="product.imageUrl"
                  class="w-8 h-8 rounded object-cover"
                  :alt="product.name"
                />
                <div v-else class="w-8 h-8 rounded bg-gray-100" />
                <span class="font-medium text-gray-900">{{ product.name }}</span>
              </div>
            </td>
            <td class="px-4 py-3 text-gray-500">{{ product.category.name }}</td>
            <td class="px-4 py-3 text-right font-medium text-gray-900">{{ formatPrice(product.price) }}</td>
            <td class="px-4 py-3 text-center">
              <span
                class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                :class="product.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
              >
                {{ product.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}
              </span>
            </td>
            <td class="px-4 py-3 text-center">
              <button
                type="button"
                :title="product.isFeatured ? 'ยกเลิกแนะนำ' : 'ตั้งเป็นแนะนำ'"
                class="text-xl transition-transform hover:scale-125"
                :class="product.isFeatured ? 'text-yellow-400' : 'text-gray-200 hover:text-yellow-300'"
                @click="handleToggleFeatured(product)"
              >★</button>
            </td>
            <td class="px-4 py-3 text-right">
              <div class="flex justify-end gap-2">
                <NuxtLink
                  :to="`/admin/products/${product.id}/edit`"
                  class="text-blue-600 hover:text-blue-800 text-xs font-medium"
                >
                  แก้ไข
                </NuxtLink>
                <button
                  class="text-red-500 hover:text-red-700 text-xs font-medium"
                  @click="handleDelete(product)"
                >
                  ลบ
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="pagination && pagination.totalPages > 1" class="px-4 py-3 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
        <span>ทั้งหมด {{ pagination.total }} รายการ</span>
        <div class="flex items-center gap-1">
          <button
            class="px-2.5 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
            :disabled="currentPage <= 1"
            @click="currentPage--"
          >‹</button>
          <button
            v-for="p in pagination.totalPages"
            :key="p"
            class="px-2.5 py-1.5 rounded-lg border transition"
            :class="p === currentPage ? 'border-[#1B2B4B] text-white font-semibold' : 'border-gray-200 hover:bg-gray-50'"
            :style="p === currentPage ? 'background:#1B2B4B' : ''"
            @click="currentPage = p"
          >{{ p }}</button>
          <button
            class="px-2.5 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
            :disabled="currentPage >= pagination.totalPages"
            @click="currentPage++"
          >›</button>
        </div>
      </div>
      <div v-else-if="pagination" class="px-4 py-3 border-t border-gray-100 text-xs text-gray-500">
        ทั้งหมด {{ pagination.total }} รายการ
      </div>
    </div>
  </div>
</template>
