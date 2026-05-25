<script setup lang="ts">
import type { AdminMember } from '~/stores/members'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useMembersStore()
const { showSuccess, showError, showConfirm } = useAlert()

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
      <h1 class="text-2xl font-bold text-gray-900">Members</h1>
    </div>

    <div class="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3">
      <input
        v-model="search"
        type="text"
        placeholder="Search by name, email, phone..."
        class="flex-1 min-w-48 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <select
        v-model="filterActive"
        class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <option value="all">All Status</option>
        <option value="true">Active</option>
        <option value="false">Inactive</option>
      </select>
    </div>

    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Name</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Email</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Phone</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Points</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Orders</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Status</th>
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
                {{ m.isActive ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td class="px-4 py-3 text-right">
              <div class="flex justify-end gap-2">
                <NuxtLink
                  :to="`/admin/members/${m.id}`"
                  class="text-blue-600 hover:text-blue-800 text-xs font-medium"
                >
                  View
                </NuxtLink>
                <button
                  class="text-xs font-medium"
                  :class="m.isActive ? 'text-red-500 hover:text-red-700' : 'text-green-600 hover:text-green-800'"
                  @click="handleToggleActive(m)"
                >
                  {{ m.isActive ? 'Deactivate' : 'Activate' }}
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="pagination" class="px-4 py-3 border-t border-gray-100 text-xs text-gray-500 flex justify-between items-center">
        <span>Total {{ pagination.total }} members</span>
        <span>Page {{ pagination.page }} / {{ pagination.totalPages }}</span>
      </div>
    </div>
  </div>
</template>
