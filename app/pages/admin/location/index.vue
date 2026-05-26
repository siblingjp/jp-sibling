<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const http = useHttpClient()
const { showSuccess, showError, showConfirm } = useAlert()

interface LocationRequest {
  id: string; name: string; description: string | null
  voteCount: number; weekYear: string; isActive: boolean
  member: { id: string; name: string }
  _count: { votes: number }
}

interface TruckLocation {
  id: string; name: string; description: string | null
  mapUrl: string | null; openTime: string | null; closeTime: string | null
  daysOfWeek: string | null
}

const requests = ref<LocationRequest[]>([])
const truckLocation = ref<TruckLocation | null>(null)
const weekYear = ref('')
const loading = ref(true)
const savingTruck = ref(false)
const resetting = ref(false)
const showTruckForm = ref(false)

const truckForm = reactive({
  name: '', description: '', mapUrl: '',
  openTime: '', closeTime: '', daysOfWeek: '',
})

async function load() {
  loading.value = true
  try {
    const res = await http.get<{ data: { truckLocation: TruckLocation | null; requests: LocationRequest[]; weekYear: string } }>(
      API_ENDPOINTS.ADMIN.LOCATION.LIST
    )
    truckLocation.value = res.data?.truckLocation ?? null
    requests.value = res.data?.requests ?? []
    weekYear.value = res.data?.weekYear ?? ''
    if (truckLocation.value) {
      truckForm.name = truckLocation.value.name
      truckForm.description = truckLocation.value.description ?? ''
      truckForm.mapUrl = truckLocation.value.mapUrl ?? ''
      truckForm.openTime = truckLocation.value.openTime ?? ''
      truckForm.closeTime = truckLocation.value.closeTime ?? ''
      truckForm.daysOfWeek = truckLocation.value.daysOfWeek ?? ''
    }
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
  finally { loading.value = false }
}

async function saveTruck() {
  savingTruck.value = true
  try {
    await http.put(API_ENDPOINTS.ADMIN.LOCATION.UPDATE_TRUCK, {
      name: truckForm.name,
      description: truckForm.description || null,
      mapUrl: truckForm.mapUrl || null,
      openTime: truckForm.openTime || null,
      closeTime: truckForm.closeTime || null,
      daysOfWeek: truckForm.daysOfWeek || null,
    })
    showSuccess('อัปเดตตำแหน่งรถแล้ว')
    showTruckForm.value = false
    load()
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
  finally { savingTruck.value = false }
}

async function resetVotes() {
  if (!await showConfirm({
    title: 'Reset Votes',
    message: `รีเซ็ต votes ทั้งหมดของสัปดาห์ ${weekYear.value}?`,
    confirmText: 'Reset',
  })) return
  resetting.value = true
  try {
    await http.post(API_ENDPOINTS.ADMIN.LOCATION.RESET)
    showSuccess('Reset เรียบร้อย')
    load()
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
  finally { resetting.value = false }
}

const maxVotes = computed(() => Math.max(...requests.value.map(r => r.voteCount), 1))

onMounted(load)
</script>

<template>
  <div class="space-y-8">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">จัดการตำแหน่งรถ</h1>
        <p class="text-sm text-gray-500 mt-0.5">สัปดาห์: {{ weekYear }}</p>
      </div>
      <div class="flex gap-3">
        <button
          @click="showTruckForm = !showTruckForm"
          class="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700"
        >
          {{ showTruckForm ? 'ซ่อน' : 'แก้ไขตำแหน่งรถ' }}
        </button>
        <button
          @click="resetVotes"
          :disabled="resetting"
          class="px-4 py-2 bg-red-500 text-white text-sm font-semibold rounded-lg hover:bg-red-600 disabled:opacity-50"
        >
          {{ resetting ? 'กำลังรีเซ็ต...' : 'รีเซ็ตโหวต' }}
        </button>
      </div>
    </div>

    <!-- Truck Location Form -->
    <div v-if="showTruckForm" class="bg-white rounded-xl shadow p-6">
      <h2 class="font-semibold text-gray-800 mb-4">ตำแหน่งรถปัจจุบัน</h2>
      <form @submit.prevent="saveTruck" class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อสถานที่</label>
          <input v-model="truckForm.name" required type="text" placeholder="เช่น หน้า Central Eastville"
            class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-1">รายละเอียด</label>
          <input v-model="truckForm.description" type="text" placeholder="เช่น ใกล้ประตูทางเข้าหลัก"
            class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">วันทำการ</label>
          <input v-model="truckForm.daysOfWeek" type="text" placeholder="เช่น จ-ศ หรือ ทุกวัน"
            class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">เปิด</label>
            <input v-model="truckForm.openTime" type="text" placeholder="07:00"
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">ปิด</label>
            <input v-model="truckForm.closeTime" type="text" placeholder="14:00"
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
          </div>
        </div>
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-1">Google Maps URL</label>
          <input v-model="truckForm.mapUrl" type="url" placeholder="https://maps.google.com/..."
            class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        <div class="md:col-span-2 flex gap-3">
          <button type="submit" :disabled="savingTruck"
            class="px-6 py-2.5 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 disabled:opacity-50">
            {{ savingTruck ? 'กำลังบันทึก...' : 'บันทึก' }}
          </button>
          <button type="button" @click="showTruckForm = false"
            class="px-6 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200">
            ยกเลิก
          </button>
        </div>
      </form>
    </div>

    <!-- Location Requests -->
    <div class="bg-white rounded-xl shadow overflow-hidden">
      <div class="px-6 py-4 border-b flex items-center justify-between">
        <h2 class="font-semibold text-gray-800">คำขอสถานที่สัปดาห์นี้</h2>
        <span class="text-sm text-gray-500">{{ requests.length }} คำขอ</span>
      </div>
      <div v-if="loading" class="p-8 text-center text-gray-400">กำลังโหลด...</div>
      <div v-else-if="requests.length === 0" class="p-8 text-center text-gray-400">ยังไม่มีคำขอสัปดาห์นี้</div>
      <div v-else class="divide-y divide-gray-50">
        <div v-for="(req, i) in requests" :key="req.id" class="px-6 py-4">
          <div class="flex items-center justify-between mb-2">
            <div class="flex items-center gap-3">
              <span class="text-lg font-bold text-gray-300 w-6">{{ i + 1 }}</span>
              <div>
                <p class="font-semibold text-gray-900">{{ req.name }}</p>
                <p v-if="req.description" class="text-xs text-gray-400">{{ req.description }}</p>
                <p class="text-xs text-gray-400 mt-0.5">เสนอโดย {{ req.member.name }}</p>
              </div>
            </div>
            <div class="text-right flex-shrink-0 ml-4">
              <p class="text-2xl font-bold text-blue-600">{{ req.voteCount }}</p>
              <p class="text-xs text-gray-400">โหวต</p>
            </div>
          </div>
          <div class="ml-9 h-2 bg-gray-100 rounded-full overflow-hidden">
            <div
              class="h-full bg-blue-200 rounded-full transition-all"
              :style="{ width: (req.voteCount / maxVotes * 100) + '%' }"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
