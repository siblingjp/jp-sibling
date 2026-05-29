<script setup lang="ts">
import type { AdminMember } from '~/stores/members'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useMembersStore()
const { showSuccess, showError, showConfirm } = useAlert()

const search = ref('')
const filterActive = ref<string>('all')
const currentPage = ref(1)

const query = computed(() => ({
  search: search.value,
  filter: filterActive.value !== 'all' ? { isActive: filterActive.value === 'true' } : {},
  pagination: { page: currentPage.value, limit: 20 },
}))

watch([search, filterActive], () => { currentPage.value = 1 })

async function load() {
  await store.fetchList(query.value).catch((e) => showError(e.message))
}

async function handleToggleActive(member: AdminMember) {
  const action = member.isActive ? 'deactivate' : 'activate'
  const confirmed = await showConfirm({
    title: `${member.isActive ? 'Deactivate' : 'Activate'} Member`,
    message: `${action.charAt(0).toUpperCase() + action.slice(1)} "${member.name}"?`,
    confirmText: member.isActive ? 'Deactivate' : 'Activate',
  })
  if (!confirmed) return
  try {
    await store.toggleActive(member.id, !member.isActive)
    showSuccess(`Member ${action}d`)
    load()
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : `Failed to ${action}`)
  }
}

watch(query, load, { deep: true })
onMounted(load)

const members = computed(() => (store.listState.response?.data as AdminMember[]) ?? [])
const pagination = computed(() => store.listState.response?.pagination)
const isLoading = computed(() => store.listState.isLoading)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">สมาชิก</h1>
    </div>

    <div class="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3">
      <input
        v-model="search"
        type="text"
        placeholder="ค้นหาชื่อ, อีเมล, เบอร์โทร..."
        class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
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

    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">ชื่อ</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">อีเมล</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">เบอร์โทร</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">แต้ม</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">ออเดอร์</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">สถานะ</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="7" class="text-center py-10 text-gray-400">Loading...</td>
          </tr>
          <tr v-else-if="members.length === 0">
            <td colspan="7" class="text-center py-10 text-gray-400">No members found</td>
          </tr>
          <tr
            v-for="m in members"
            :key="m.id"
            class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
          >
            <td class="px-4 py-3 font-medium text-gray-900">{{ m.name }}</td>
            <td class="px-4 py-3 text-gray-500">{{ m.email }}</td>
            <td class="px-4 py-3 text-gray-500">{{ m.phone ?? '-' }}</td>
            <td class="px-4 py-3 text-center font-medium text-blue-600">{{ m.points.toLocaleString() }}</td>
            <td class="px-4 py-3 text-center text-gray-600">{{ m._count?.orders ?? 0 }}</td>
            <td class="px-4 py-3 text-center">
              <span
                class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                :class="m.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
              >
                {{ m.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}
              </span>
            </td>
            <td class="px-4 py-3 text-right">
              <div class="flex justify-end gap-2">
                <NuxtLink
                  :to="`/admin/members/${m.id}`"
                  class="text-blue-600 hover:text-blue-800 text-xs font-medium"
                >
                  ดูโปรไฟล์
                </NuxtLink>
                <button
                  class="text-xs font-medium"
                  :class="m.isActive ? 'text-red-500 hover:text-red-700' : 'text-green-600 hover:text-green-800'"
                  @click="handleToggleActive(m)"
                >
                  {{ m.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน' }}
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="pagination && pagination.totalPages > 1" class="px-4 py-3 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
        <span>ทั้งหมด {{ pagination.total }} สมาชิก</span>
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
        ทั้งหมด {{ pagination.total }} สมาชิก
      </div>
    </div>
  </div>
</template>
