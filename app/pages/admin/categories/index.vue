<script setup lang="ts">
import type { Category } from '~/stores/categories'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useCategoriesStore()
const http = useHttpClient()
const { showSuccess, showError, confirmDelete } = useAlert()

const search = ref('')
const filterActive = ref<string>('all')
const currentPage = ref(1)
const reorderMode = ref(false)
const isSavingOrder = ref(false)
const dragItems = ref<Category[]>([])

const query = computed(() => ({
  search: search.value,
  filter: filterActive.value !== 'all' ? { isActive: filterActive.value === 'true' } : {},
  pagination: { page: currentPage.value, limit: 20 },
}))

watch([search, filterActive], () => { currentPage.value = 1 })

async function load() {
  await store.fetchList(query.value).catch((e) => showError(e.message))
}

async function handleDelete(category: Category) {
  if (!await confirmDelete(category.name)) return
  try {
    await store.remove(category.id)
    showSuccess('Category deleted')
    load()
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to delete')
  }
}

watch(query, load, { deep: true })
onMounted(load)

const categories = computed(() => (store.listState.response?.data as Category[]) ?? [])
const pagination = computed(() => store.listState.response?.pagination)
const isLoading = computed(() => store.listState.isLoading)

// ─── Reorder mode ────────────────────────────────────────────────────────────
async function enterReorderMode() {
  // load all without pagination
  const res = await http.get<{ data: Category[] }>(API_ENDPOINTS.ADMIN.CATEGORIES.LIST, {
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
    await http.patch(API_ENDPOINTS.ADMIN.CATEGORIES.REORDER, {
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
      <h1 class="text-xl md:text-2xl font-bold text-gray-900">หมวดหมู่</h1>
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
          to="/admin/categories/new"
          class="bg-blue-600 text-white px-3 py-2 md:px-4 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
        >
          + เพิ่มหมวดหมู่
        </NuxtLink>
      </div>
    </div>

    <!-- Reorder mode: drag list -->
    <template v-if="reorderMode">
      <div class="bg-amber-50 border border-amber-200 rounded-xl px-4 py-3 mb-4 text-sm text-amber-700 flex items-center gap-2">
        <Icon name="mdi:information-outline" class="text-lg flex-shrink-0" />
        ลากเพื่อจัดลำดับ กด "บันทึกลำดับ" เมื่อเสร็จ
      </div>

      <div class="bg-white rounded-xl shadow-sm overflow-hidden">
        <div
          v-for="(cat, idx) in dragItems"
          :key="cat.id"
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
          <div class="flex-1 min-w-0">
            <p class="font-medium text-gray-900">{{ cat.name }}</p>
            <p class="text-xs text-gray-400 font-mono">{{ cat.slug }}</p>
          </div>
          <span
            class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium flex-shrink-0"
            :class="cat.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
          >{{ cat.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}</span>
          <span class="text-xs text-gray-400 flex-shrink-0">{{ cat._count?.products ?? 0 }} สินค้า</span>
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
          placeholder="ค้นหาหมวดหมู่..."
          class="flex-1 min-w-0 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
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
        <div v-else-if="categories.length === 0" class="bg-white rounded-xl shadow-sm p-6 text-center text-gray-400 text-sm">
          ไม่พบหมวดหมู่
        </div>
        <div
          v-for="cat in categories"
          :key="cat.id"
          class="bg-white rounded-xl shadow-sm p-4"
        >
          <div class="flex items-start justify-between mb-2">
            <div>
              <p class="font-medium text-gray-900">{{ cat.name }}</p>
              <p class="text-xs text-gray-400 font-mono mt-0.5">{{ cat.slug }}</p>
            </div>
            <span
              class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium flex-shrink-0"
              :class="cat.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
            >
              {{ cat.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}
            </span>
          </div>
          <p class="text-xs text-gray-500 mb-3">{{ cat._count?.products ?? 0 }} สินค้า</p>
          <div class="flex items-center gap-3 pt-2 border-t border-gray-100">
            <NuxtLink :to="`/admin/categories/${cat.id}/edit`" class="text-blue-600 text-xs font-medium">แก้ไข</NuxtLink>
            <button class="text-red-500 text-xs font-medium" @click="handleDelete(cat)">ลบ</button>
          </div>
        </div>
      </div>

      <!-- Desktop: Table -->
      <div class="hidden md:block bg-white rounded-xl shadow-sm overflow-hidden">
        <table class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600 w-12">#</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">ชื่อ</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Slug</th>
              <th class="text-center px-4 py-3 font-medium text-gray-600">สินค้า</th>
              <th class="text-center px-4 py-3 font-medium text-gray-600">สถานะ</th>
              <th class="px-4 py-3" />
            </tr>
          </thead>
          <tbody>
            <tr v-if="isLoading">
              <td colspan="6" class="text-center py-10 text-gray-400">กำลังโหลด...</td>
            </tr>
            <tr v-else-if="categories.length === 0">
              <td colspan="6" class="text-center py-10 text-gray-400">ไม่พบหมวดหมู่</td>
            </tr>
            <tr
              v-for="(cat, idx) in categories"
              :key="cat.id"
              class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
            >
              <td class="px-4 py-3 text-xs text-gray-400">{{ (currentPage - 1) * 20 + idx + 1 }}</td>
              <td class="px-4 py-3 font-medium text-gray-900">{{ cat.name }}</td>
              <td class="px-4 py-3 text-gray-500 font-mono text-xs">{{ cat.slug }}</td>
              <td class="px-4 py-3 text-center text-gray-600">{{ cat._count?.products ?? 0 }}</td>
              <td class="px-4 py-3 text-center">
                <span
                  class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                  :class="cat.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
                >
                  {{ cat.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}
                </span>
              </td>
              <td class="px-4 py-3 text-right">
                <div class="flex justify-end gap-2">
                  <NuxtLink
                    :to="`/admin/categories/${cat.id}/edit`"
                    class="text-blue-600 hover:text-blue-800 text-xs font-medium"
                  >
                    แก้ไข
                  </NuxtLink>
                  <button
                    class="text-red-500 hover:text-red-700 text-xs font-medium"
                    @click="handleDelete(cat)"
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
