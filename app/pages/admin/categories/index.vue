<script setup lang="ts">
import type { Category } from '~/stores/categories'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useCategoriesStore()
const { showSuccess, showError, confirmDelete } = useAlert()

const search = ref('')
const filterActive = ref<string>('all')

const query = computed(() => ({
  search: search.value,
  filter: filterActive.value !== 'all' ? { isActive: filterActive.value === 'true' } : {},
  pagination: { page: 1, limit: 20 },
}))

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
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">หมวดหมู่</h1>
      <NuxtLink
        to="/admin/categories/new"
        class="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
      >
        + เพิ่มหมวดหมู่
      </NuxtLink>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-sm p-4 mb-4 flex gap-3">
      <input
        v-model="search"
        type="text"
        placeholder="ค้นหาหมวดหมู่..."
        class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
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
            <th class="text-left px-4 py-3 font-medium text-gray-600">ชื่อ</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Slug</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">สินค้า</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">สถานะ</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="5" class="text-center py-10 text-gray-400">กำลังโหลด...</td>
          </tr>
          <tr v-else-if="categories.length === 0">
            <td colspan="5" class="text-center py-10 text-gray-400">ไม่พบหมวดหมู่</td>
          </tr>
          <tr
            v-for="cat in categories"
            :key="cat.id"
            class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
          >
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

      <!-- Pagination -->
      <div v-if="pagination" class="px-4 py-3 border-t border-gray-100 text-xs text-gray-500 flex justify-between items-center">
        <span>ทั้งหมด {{ pagination.total }} รายการ</span>
        <span>หน้า {{ pagination.page }} / {{ pagination.totalPages }}</span>
      </div>
    </div>
  </div>
</template>
