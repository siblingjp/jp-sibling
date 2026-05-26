<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const http = useHttpClient()
const { showSuccess, showError, showConfirm } = useAlert()

interface Reward {
  id: string
  name: string
  description: string | null
  pointCost: number
  isActive: boolean
  createdAt: string
}

const rewards = ref<Reward[]>([])
const loading = ref(true)
const showModal = ref(false)
const editing = ref<Reward | null>(null)
const saving = ref(false)

const form = reactive({
  name: '',
  description: '',
  pointCost: 100,
  isActive: true,
})

async function load() {
  loading.value = true
  try {
    const res = await http.get<{ success: boolean; data: Reward[] }>(API_ENDPOINTS.ADMIN.REWARDS.LIST)
    rewards.value = res.data ?? []
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to load')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  editing.value = null
  form.name = ''
  form.description = ''
  form.pointCost = 100
  form.isActive = true
  showModal.value = true
}

function openEdit(reward: Reward) {
  editing.value = reward
  form.name = reward.name
  form.description = reward.description ?? ''
  form.pointCost = reward.pointCost
  form.isActive = reward.isActive
  showModal.value = true
}

async function handleSave() {
  saving.value = true
  try {
    const body = {
      name: form.name,
      description: form.description || null,
      pointCost: form.pointCost,
      isActive: form.isActive,
    }
    if (editing.value) {
      await http.put(API_ENDPOINTS.ADMIN.REWARDS.UPDATE(editing.value.id), body)
      showSuccess('Reward updated')
    } else {
      await http.post(API_ENDPOINTS.ADMIN.REWARDS.CREATE, body)
      showSuccess('Reward created')
    }
    showModal.value = false
    load()
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Save failed')
  } finally {
    saving.value = false
  }
}

async function handleDelete(reward: Reward) {
  const confirmed = await showConfirm({
    title: 'Delete Reward',
    message: `Delete "${reward.name}"?`,
    confirmText: 'Delete',
  })
  if (!confirmed) return
  try {
    await http.delete(API_ENDPOINTS.ADMIN.REWARDS.DELETE(reward.id))
    showSuccess('Reward deleted')
    load()
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Delete failed')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">ของรางวัล</h1>
      <button
        @click="openCreate"
        class="px-4 py-2 bg-amber-600 text-white text-sm font-semibold rounded-lg hover:bg-amber-700 transition-colors"
      >
        + เพิ่มของรางวัล
      </button>
    </div>

    <div class="bg-white rounded-xl shadow overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-gray-400">กำลังโหลด...</div>
      <div v-else-if="rewards.length === 0" class="p-8 text-center text-gray-400">
        ยังไม่มีของรางวัล
      </div>
      <table v-else class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ชื่อของรางวัล</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">รายละเอียด</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">แต้มที่ใช้</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">สถานะ</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">จัดการ</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-100">
          <tr v-for="reward in rewards" :key="reward.id">
            <td class="px-6 py-4 font-medium text-gray-900">{{ reward.name }}</td>
            <td class="px-6 py-4 text-sm text-gray-500">{{ reward.description || '-' }}</td>
            <td class="px-6 py-4 text-sm font-semibold text-amber-700">{{ reward.pointCost.toLocaleString() }} แต้ม</td>
            <td class="px-6 py-4">
              <span
                class="px-2.5 py-1 text-xs font-semibold rounded-full"
                :class="reward.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
              >
                {{ reward.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}
              </span>
            </td>
            <td class="px-6 py-4 text-right space-x-2">
              <button @click="openEdit(reward)" class="text-blue-600 hover:text-blue-800 text-sm font-medium">แก้ไข</button>
              <button @click="handleDelete(reward)" class="text-red-500 hover:text-red-700 text-sm font-medium">ลบ</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal -->
    <Teleport to="body">
      <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md">
          <div class="p-6 border-b border-gray-100">
            <h2 class="text-lg font-bold text-gray-900">{{ editing ? 'แก้ไขของรางวัล' : 'เพิ่มของรางวัล' }}</h2>
          </div>

          <form @submit.prevent="handleSave" class="p-6 space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อของรางวัล</label>
              <input
                v-model="form.name"
                type="text"
                required
                class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-amber-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">รายละเอียด</label>
              <textarea
                v-model="form.description"
                rows="2"
                class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-amber-500 resize-none"
                placeholder="รายละเอียด (ไม่บังคับ)"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">แต้มที่ใช้แลก</label>
              <input
                v-model.number="form.pointCost"
                type="number"
                min="1"
                required
                class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-amber-500"
              />
            </div>

            <div class="flex items-center gap-2">
              <input id="isActive" v-model="form.isActive" type="checkbox" class="rounded accent-amber-600" />
              <label for="isActive" class="text-sm text-gray-700">เปิดใช้งาน</label>
            </div>

            <div class="flex gap-3 pt-2">
              <button
                type="submit"
                :disabled="saving"
                class="flex-1 py-2.5 bg-amber-600 text-white font-semibold rounded-xl hover:bg-amber-700 disabled:opacity-50 transition-colors"
              >
                {{ saving ? 'กำลังบันทึก...' : 'บันทึก' }}
              </button>
              <button
                type="button"
                @click="showModal = false"
                class="flex-1 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200"
              >
                ยกเลิก
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>
