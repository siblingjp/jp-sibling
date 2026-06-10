<script setup lang="ts">
import type { Product } from '~/stores/products'
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useProductsStore()
const http = useHttpClient()
const { showSuccess, showError, confirmDelete } = useAlert()

const search = ref('')
const filterActive = ref<string>('all')
const filterCategory = ref<string>('all')
const currentPage = ref(1)
const reorderMode = ref(false)
const isSavingOrder = ref(false)
const dragItems = ref<Product[]>([])

const query = computed(() => ({
  search: search.value,
  filter: {
    ...(filterActive.value !== 'all' ? { isActive: filterActive.value === 'true' } : {}),
    ...(filterCategory.value !== 'all' ? { categoryId: filterCategory.value } : {}),
  },
  pagination: { page: currentPage.value, limit: 20 },
}))

watch([search, filterActive, filterCategory], () => { currentPage.value = 1 })

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
    await http.patch(API_ENDPOINTS.ADMIN.PRODUCTS.TOGGLE_FEATURED(product.id), {})
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

// ─── Reorder mode ────────────────────────────────────────────────────────────
async function enterReorderMode() {
  const filter: Record<string, unknown> = {}
  if (filterCategory.value !== 'all') filter.categoryId = filterCategory.value
  const res = await http.get<{ data: Product[] }>(API_ENDPOINTS.ADMIN.PRODUCTS.LIST, {
    filter,
    pagination: { page: 1, limit: 1000 },
  })
  dragItems.value = [...(res.data ?? [])]
  reorderMode.value = true
}

function cancelReorder() {
  reorderMode.value = false
  dragItems.value = []
}

async function saveOrder() {
  isSavingOrder.value = true
  try {
    await http.patch(API_ENDPOINTS.ADMIN.PRODUCTS.REORDER, {
      orders: dragItems.value.map((item, idx) => ({ id: item.id, sortOrder: idx })),
    })
    showSuccess('บันทึกลำดับเรียบร้อย')
    reorderMode.value = false
    dragItems.value = []
    await load()
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to save order')
  } finally {
    isSavingOrder.value = false
  }
}

// ─── Drag handlers ───────────────────────────────────────────────────────────
const dragIndex = ref<number | null>(null)
const dragOverIndex = ref<number | null>(null)

function onDragStart(idx: number) {
  dragIndex.value = idx
}

function onDragOver(e: DragEvent, idx: number) {
  e.preventDefault()
  dragOverIndex.value = idx
}

function onDrop(idx: number) {
  if (dragIndex.value === null || dragIndex.value === idx) return
  const items = [...dragItems.value]
  const [moved] = items.splice(dragIndex.value, 1)
  items.splice(idx, 0, moved)
  dragItems.value = items
  dragIndex.value = null
  dragOverIndex.value = null
}

function onDragEnd() {
  dragIndex.value = null
  dragOverIndex.value = null
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-4 md:mb-6">
      <h1 class="text-xl md:text-2xl font-bold text-gray-900">สินค้า</h1>
      <div class="flex items-center gap-2">
        <button
          v-if="!reorderMode"
          class="bg-white border border-gray-300 text-gray-700 px-3 py-2 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors flex items-center gap-1.5"
          @click="enterReorderMode"
        >
          <Icon name="mdi:drag" class="text-base" />
          จัดลำดับ
        </button>
        <template v-else>
          <button
            class="bg-white border border-gray-300 text-gray-500 px-3 py-2 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors"
            :disabled="isSavingOrder"
            @click="cancelReorder"
          >ยกเลิก</button>
          <button
            class="bg-blue-600 text-white px-3 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors disabled:opacity-60"
            :disabled="isSavingOrder"
            @click="saveOrder"
          >{{ isSavingOrder ? 'กำลังบันทึก...' : 'บันทึกลำดับ' }}</button>
        </template>
        <NuxtLink
          v-if="!reorderMode"
          to="/admin/products/new"
          class="bg-blue-600 text-white px-3 py-2 md:px-4 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
        >
          + เพิ่มสินค้า
        </NuxtLink>
      </div>
    </div>

    <!-- Reorder mode: drag list -->
    <template v-if="reorderMode">
      <div class="bg-amber-50 border border-amber-200 rounded-xl px-4 py-3 mb-4 text-sm text-amber-700 flex items-center gap-2">
        <Icon name="mdi:information-outline" class="text-lg flex-shrink-0" />
        ลากเพื่อจัดลำดับ{{ filterCategory !== 'all' ? ' (เฉพาะหมวดหมู่ที่เลือก)' : '' }} กด "บันทึกลำดับ" เมื่อเสร็จ
      </div>

      <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <div
          v-for="(product, idx) in dragItems"
          :key="product.id"
          draggable="true"
          class="flex items-center gap-3 px-4 py-3 border-b border-gray-100 last:border-0 cursor-grab active:cursor-grabbing select-none transition-colors"
          :class="{
            'bg-blue-50 border-blue-200': dragOverIndex === idx && dragIndex !== idx,
            'opacity-40': dragIndex === idx,
            'hover:bg-gray-50': dragOverIndex !== idx,
          }"
          @dragstart="onDragStart(idx)"
          @dragover="onDragOver($event, idx)"
          @drop="onDrop(idx)"
          @dragend="onDragEnd"
        >
          <Icon name="mdi:drag-vertical" class="text-xl text-gray-400 flex-shrink-0" />
          <div class="w-6 h-6 flex items-center justify-center rounded-full bg-gray-100 text-xs font-semibold text-gray-500 flex-shrink-0">
            {{ idx + 1 }}
          </div>
          <img
            v-if="product.imageUrl"
            :src="product.imageUrl"
            class="w-9 h-9 rounded-lg object-cover flex-shrink-0"
            :alt="product.name"
          />
          <div v-else class="w-9 h-9 rounded-lg bg-gray-100 flex-shrink-0" />
          <div class="flex-1 min-w-0">
            <p class="font-medium text-gray-900 truncate">{{ product.name }}</p>
            <p class="text-xs text-gray-400">{{ product.category.name }}</p>
          </div>
          <span class="text-sm font-semibold text-gray-700 flex-shrink-0">{{ formatPrice(product.price) }}</span>
          <span
            class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium flex-shrink-0"
            :class="product.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
          >{{ product.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}</span>
        </div>
      </div>
    </template>

    <!-- Normal mode -->
    <template v-else>
      <!-- Filters -->
      <div class="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3">
        <input
          v-model="search"
          type="text"
          placeholder="ค้นหาสินค้า..."
          class="flex-1 min-w-0 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <select
          v-model="filterCategory"
          class="flex-1 min-w-0 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="all">ทุกหมวดหมู่</option>
          <option v-for="cat in categoryOptions" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
        </select>
        <select
          v-model="filterActive"
          class="flex-1 min-w-0 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="all">ทุกสถานะ</option>
          <option value="true">ใช้งานอยู่</option>
          <option value="false">ปิดใช้งาน</option>
        </select>
      </div>

      <!-- Mobile: Card list -->
      <div class="md:hidden space-y-3">
        <div v-if="isLoading" class="bg-white rounded-xl shadow-sm p-6 text-center text-gray-400 text-sm">
          กำลังโหลด...
        </div>
        <div v-else-if="products.length === 0" class="bg-white rounded-xl shadow-sm p-6 text-center text-gray-400 text-sm">
          ไม่พบสินค้า
        </div>
        <div
          v-for="product in products"
          :key="product.id"
          class="bg-white rounded-xl shadow-sm p-4"
        >
          <div class="flex items-center gap-3 mb-3">
            <img
              v-if="product.imageUrl"
              :src="product.imageUrl"
              class="w-12 h-12 rounded-lg object-cover flex-shrink-0"
              :alt="product.name"
            />
            <div v-else class="w-12 h-12 rounded-lg bg-gray-100 flex-shrink-0" />
            <div class="flex-1 min-w-0">
              <p class="font-medium text-gray-900 truncate">{{ product.name }}</p>
              <p class="text-xs text-gray-400">{{ product.category.name }}</p>
            </div>
            <p class="font-semibold text-gray-900 flex-shrink-0">{{ formatPrice(product.price) }}</p>
          </div>
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
              <span
                class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                :class="product.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
              >
                {{ product.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}
              </span>
              <button
                type="button"
                :title="product.isFeatured ? 'ยกเลิกแนะนำ' : 'ตั้งเป็นแนะนำ'"
                class="text-lg transition-transform hover:scale-125"
                :class="product.isFeatured ? 'text-yellow-400' : 'text-gray-200'"
                @click="handleToggleFeatured(product)"
              >★</button>
            </div>
            <div class="flex items-center gap-3">
              <NuxtLink :to="`/admin/products/${product.id}/edit`" class="text-blue-600 text-xs font-medium">แก้ไข</NuxtLink>
              <button class="text-red-500 text-xs font-medium" @click="handleDelete(product)">ลบ</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Desktop: Table -->
      <div class="hidden md:block bg-white rounded-xl shadow-sm overflow-hidden">
        <table class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600 w-12">#</th>
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
              <td colspan="7" class="text-center py-10 text-gray-400">กำลังโหลด...</td>
            </tr>
            <tr v-else-if="products.length === 0">
              <td colspan="7" class="text-center py-10 text-gray-400">ไม่พบสินค้า</td>
            </tr>
            <tr
              v-for="(product, idx) in products"
              :key="product.id"
              class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
            >
              <td class="px-4 py-3 text-xs text-gray-400">{{ (currentPage - 1) * 20 + idx + 1 }}</td>
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

      <!-- Mobile pagination -->
      <div v-if="pagination && pagination.totalPages > 1" class="md:hidden mt-3 flex items-center justify-between text-xs text-gray-500 bg-white rounded-xl shadow-sm px-4 py-3">
        <span>ทั้งหมด {{ pagination.total }} รายการ</span>
        <div class="flex items-center gap-2">
          <button
            class="px-3 py-1.5 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-40"
            :disabled="currentPage <= 1"
            @click="currentPage--"
          >←</button>
          <span>{{ currentPage }} / {{ pagination.totalPages }}</span>
          <button
            class="px-3 py-1.5 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-40"
            :disabled="currentPage >= pagination.totalPages"
            @click="currentPage++"
          >→</button>
        </div>
      </div>
    </template>
  </div>
</template>
