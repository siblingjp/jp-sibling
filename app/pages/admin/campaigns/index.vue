<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const http = useHttpClient()
const { showSuccess, showError, showConfirm } = useAlert()

interface Campaign {
  id: string; title: string; description: string | null
  imageUrl: string | null; status: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED'
  startsAt: string | null; endsAt: string | null; createdAt: string
}

const campaigns = ref<Campaign[]>([])
const loading = ref(true)
const showModal = ref(false)
const editing = ref<Campaign | null>(null)
const saving = ref(false)

const form = reactive({
  title: '', description: '', imageUrl: '',
  status: 'DRAFT' as 'DRAFT' | 'PUBLISHED' | 'ARCHIVED',
  startsAt: '', endsAt: '',
})

async function load() {
  loading.value = true
  try {
    const res = await http.get<{ data: Campaign[] }>(API_ENDPOINTS.ADMIN.CAMPAIGNS.LIST)
    campaigns.value = res.data ?? []
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
  finally { loading.value = false }
}

function openCreate() {
  editing.value = null
  form.title = ''; form.description = ''; form.imageUrl = ''
  form.status = 'DRAFT'; form.startsAt = ''; form.endsAt = ''
  showModal.value = true
}

function openEdit(c: Campaign) {
  editing.value = c
  form.title = c.title; form.description = c.description ?? ''
  form.imageUrl = c.imageUrl ?? ''; form.status = c.status
  form.startsAt = c.startsAt ? c.startsAt.slice(0, 16) : ''
  form.endsAt = c.endsAt ? c.endsAt.slice(0, 16) : ''
  showModal.value = true
}

async function handleSave() {
  saving.value = true
  try {
    const body = {
      title: form.title,
      description: form.description || null,
      imageUrl: form.imageUrl || null,
      status: form.status,
      startsAt: form.startsAt ? new Date(form.startsAt).toISOString() : null,
      endsAt: form.endsAt ? new Date(form.endsAt).toISOString() : null,
    }
    if (editing.value) {
      await http.put(API_ENDPOINTS.ADMIN.CAMPAIGNS.UPDATE(editing.value.id), body)
      showSuccess('อัปเดตแคมเปญแล้ว')
    } else {
      await http.post(API_ENDPOINTS.ADMIN.CAMPAIGNS.CREATE, body)
      showSuccess('สร้างแคมเปญแล้ว')
    }
    showModal.value = false
    load()
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
  finally { saving.value = false }
}

async function handleDelete(c: Campaign) {
  if (!await showConfirm({ title: 'ลบแคมเปญ', message: `ลบ "${c.title}"?`, confirmText: 'ลบ' })) return
  try {
    await http.delete(API_ENDPOINTS.ADMIN.CAMPAIGNS.DELETE(c.id))
    showSuccess('ลบแล้ว'); load()
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
}

const statusLabel = { DRAFT: 'Draft', PUBLISHED: 'Published', ARCHIVED: 'Archived' }
const statusColor = {
  DRAFT: 'bg-gray-100 text-gray-600',
  PUBLISHED: 'bg-green-100 text-green-700',
  ARCHIVED: 'bg-red-100 text-red-600',
}

function formatDate(d: string | null) {
  if (!d) return '-'
  return new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric' })
}

onMounted(load)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Campaigns</h1>
      <button @click="openCreate" class="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700">
        + สร้างแคมเปญ
      </button>
    </div>

    <div class="bg-white rounded-xl shadow overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-gray-400">Loading...</div>
      <div v-else-if="campaigns.length === 0" class="p-8 text-center text-gray-400">ยังไม่มีแคมเปญ</div>
      <table v-else class="min-w-full divide-y divide-gray-100">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ชื่อ</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">เริ่ม</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">สิ้นสุด</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-50">
          <tr v-for="c in campaigns" :key="c.id">
            <td class="px-6 py-4">
              <p class="font-medium text-gray-900">{{ c.title }}</p>
              <p v-if="c.description" class="text-xs text-gray-400 mt-0.5 truncate max-w-xs">{{ c.description }}</p>
            </td>
            <td class="px-6 py-4">
              <span class="px-2.5 py-1 text-xs font-semibold rounded-full" :class="statusColor[c.status]">
                {{ statusLabel[c.status] }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm text-gray-500">{{ formatDate(c.startsAt) }}</td>
            <td class="px-6 py-4 text-sm text-gray-500">{{ formatDate(c.endsAt) }}</td>
            <td class="px-6 py-4 text-right space-x-3">
              <button @click="openEdit(c)" class="text-blue-600 hover:text-blue-800 text-sm font-medium">แก้ไข</button>
              <button @click="handleDelete(c)" class="text-red-500 hover:text-red-700 text-sm font-medium">ลบ</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <Teleport to="body">
      <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-lg">
          <div class="p-6 border-b"><h2 class="text-lg font-bold">{{ editing ? 'แก้ไขแคมเปญ' : 'สร้างแคมเปญใหม่' }}</h2></div>
          <form @submit.prevent="handleSave" class="p-6 space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อแคมเปญ</label>
              <input v-model="form.title" type="text" required class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">รายละเอียด</label>
              <textarea v-model="form.description" rows="3" class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Image URL</label>
              <input v-model="form.imageUrl" type="url" placeholder="https://..." class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <select v-model="form.status" class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="DRAFT">Draft</option>
                <option value="PUBLISHED">Published</option>
                <option value="ARCHIVED">Archived</option>
              </select>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">เริ่มวันที่</label>
                <input v-model="form.startsAt" type="datetime-local" class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">สิ้นสุดวันที่</label>
                <input v-model="form.endsAt" type="datetime-local" class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
              </div>
            </div>
            <div class="flex gap-3 pt-2">
              <button type="submit" :disabled="saving" class="flex-1 py-2.5 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 disabled:opacity-50">
                {{ saving ? 'Saving...' : 'Save' }}
              </button>
              <button type="button" @click="showModal = false" class="flex-1 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200">
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>
