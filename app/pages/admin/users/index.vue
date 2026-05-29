<script setup lang="ts">
import type { AdminUser } from '~/stores/users'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useUsersStore()
const { user: me } = useAuth()
const { showSuccess, showError, confirmDelete } = useAlert()

const search = ref('')
const filterRole = ref<string>('all')
const filterActive = ref<string>('all')
const currentPage = ref(1)

const query = computed(() => ({
  search: search.value,
  filter: {
    ...(filterRole.value !== 'all' ? { role: filterRole.value } : {}),
    ...(filterActive.value !== 'all' ? { isActive: filterActive.value === 'true' } : {}),
  },
  pagination: { page: currentPage.value, limit: 20 },
}))

watch([search, filterRole, filterActive], () => { currentPage.value = 1 })

async function load() {
  await store.fetchList(query.value).catch((e) => showError(e.message))
}

async function handleDeactivate(user: AdminUser) {
  if (!await confirmDelete(user.name)) return
  try {
    await store.deactivate(user.id)
    showSuccess('User deactivated')
    load()
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to deactivate')
  }
}

watch(query, load, { deep: true })
onMounted(load)

const users = computed(() => (store.listState.response?.data as AdminUser[]) ?? [])
const pagination = computed(() => store.listState.response?.pagination)
const isLoading = computed(() => store.listState.isLoading)

const roleBadge: Record<string, string> = {
  ADMIN: 'bg-purple-100 text-purple-700',
  CASHIER: 'bg-blue-100 text-blue-700',
  STAFF: 'bg-gray-100 text-gray-600',
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">ผู้ใช้งาน</h1>
      <NuxtLink
        to="/admin/users/new"
        class="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
      >
        + เพิ่มผู้ใช้งาน
      </NuxtLink>
    </div>

    <div class="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3">
      <input
        v-model="search"
        type="text"
        placeholder="ค้นหาชื่อหรืออีเมล..."
        class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <select v-model="filterRole" class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
        <option value="all">ทุกบทบาท</option>
        <option value="ADMIN">Admin</option>
        <option value="CASHIER">Cashier</option>
        <option value="STAFF">Staff</option>
      </select>
      <select v-model="filterActive" class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
        <option value="all">ทุกสถานะ</option>
        <option value="true">ใช้งานอยู่</option>
        <option value="false">ปิดใช้งาน</option>
      </select>
    </div>

    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">ชื่อ</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">อีเมล</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">บทบาท</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">สถานะ</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="5" class="text-center py-10 text-gray-400">กำลังโหลด...</td>
          </tr>
          <tr v-else-if="users.length === 0">
            <td colspan="5" class="text-center py-10 text-gray-400">ไม่พบผู้ใช้งาน</td>
          </tr>
          <tr
            v-for="u in users"
            :key="u.id"
            class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
          >
            <td class="px-4 py-3 font-medium text-gray-900">
              {{ u.name }}
              <span v-if="u.id === me?.id" class="ml-1 text-xs text-gray-400">(คุณ)</span>
            </td>
            <td class="px-4 py-3 text-gray-500">{{ u.email }}</td>
            <td class="px-4 py-3 text-center">
              <span class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="roleBadge[u.role]">
                {{ u.role }}
              </span>
            </td>
            <td class="px-4 py-3 text-center">
              <span
                class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                :class="u.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
              >
                {{ u.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}
              </span>
            </td>
            <td class="px-4 py-3 text-right">
              <div class="flex justify-end gap-2">
                <NuxtLink
                  :to="`/admin/users/${u.id}/edit`"
                  class="text-blue-600 hover:text-blue-800 text-xs font-medium"
                >
                  แก้ไข
                </NuxtLink>
                <button
                  v-if="u.id !== me?.id && u.isActive"
                  class="text-red-500 hover:text-red-700 text-xs font-medium"
                  @click="handleDeactivate(u)"
                >
                  ปิดใช้งาน
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
