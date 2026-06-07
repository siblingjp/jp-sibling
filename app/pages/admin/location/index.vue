<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const http = useHttpClient()
const { showSuccess, showError, showConfirm } = useAlert()

interface LocationSchedule {
  id: string; name: string; description: string | null
  mapUrl: string | null; openTime: string; closeTime: string
  daysOfWeek: string; isActive: boolean; sortOrder: number
}

interface LocationRequest {
  id: string; name: string; description: string | null
  voteCount: number; weekYear: string; isActive: boolean
  member: { id: string; name: string }
  _count: { votes: number }
}

interface TruckLocation {
  id: string; name: string; description: string | null
  mapUrl: string | null; openTime: string | null; closeTime: string | null
  daysOfWeek: string | null; isOpen: boolean
  schedules: LocationSchedule[]
  activeScheduleId: string | null
}

const requests = ref<LocationRequest[]>([])
const truckLocation = ref<TruckLocation | null>(null)
const weekYear = ref('')
const loading = ref(true)
const savingTruck = ref(false)
const resetting = ref(false)
const showTruckForm = ref(false)

// schedule form state
const showScheduleForm = ref(false)
const editingSchedule = ref<LocationSchedule | null>(null)
const savingSchedule = ref(false)
const deletingId = ref<string | null>(null)

const truckForm = reactive({
  name: '', description: '', mapUrl: '',
  openTime: '', closeTime: '', daysOfWeek: '',
})

const scheduleForm = reactive({
  name: '', description: '', mapUrl: '',
  openTime: '', closeTime: '', daysOfWeek: '', sortOrder: 0,
})

const DAY_OPTIONS = ['จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์']

function toggleDay(day: string) {
  const days = scheduleForm.daysOfWeek ? scheduleForm.daysOfWeek.split(',').map(d => d.trim()).filter(Boolean) : []
  const idx = days.indexOf(day)
  if (idx >= 0) days.splice(idx, 1)
  else days.push(day)
  scheduleForm.daysOfWeek = days.join(',')
}

function hasDay(day: string) {
  return scheduleForm.daysOfWeek.split(',').map(d => d.trim()).includes(day)
}

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
    showSuccess('อัปเดตข้อมูลร้านแล้ว')
    showTruckForm.value = false
    load()
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
  finally { savingTruck.value = false }
}

function openNewSchedule() {
  editingSchedule.value = null
  scheduleForm.name = ''
  scheduleForm.description = ''
  scheduleForm.mapUrl = ''
  scheduleForm.openTime = ''
  scheduleForm.closeTime = ''
  scheduleForm.daysOfWeek = ''
  scheduleForm.sortOrder = (truckLocation.value?.schedules.length ?? 0)
  showScheduleForm.value = true
}

function openEditSchedule(s: LocationSchedule) {
  editingSchedule.value = s
  scheduleForm.name = s.name
  scheduleForm.description = s.description ?? ''
  scheduleForm.mapUrl = s.mapUrl ?? ''
  scheduleForm.openTime = s.openTime
  scheduleForm.closeTime = s.closeTime
  scheduleForm.daysOfWeek = s.daysOfWeek
  scheduleForm.sortOrder = s.sortOrder
  showScheduleForm.value = true
}

async function saveSchedule() {
  savingSchedule.value = true
  try {
    const body = {
      name: scheduleForm.name,
      description: scheduleForm.description || null,
      mapUrl: scheduleForm.mapUrl || null,
      openTime: scheduleForm.openTime,
      closeTime: scheduleForm.closeTime,
      daysOfWeek: scheduleForm.daysOfWeek,
      sortOrder: scheduleForm.sortOrder,
    }
    if (editingSchedule.value) {
      await http.put(API_ENDPOINTS.ADMIN.LOCATION.SCHEDULES.UPDATE(editingSchedule.value.id), body)
      showSuccess('แก้ไข slot เรียบร้อย')
    } else {
      await http.post(API_ENDPOINTS.ADMIN.LOCATION.SCHEDULES.CREATE, body)
      showSuccess('เพิ่ม slot เรียบร้อย')
    }
    showScheduleForm.value = false
    load()
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
  finally { savingSchedule.value = false }
}

async function deleteSchedule(id: string) {
  if (!await showConfirm({ title: 'ลบ slot', message: 'ต้องการลบ slot นี้?', confirmText: 'ลบ' })) return
  deletingId.value = id
  try {
    await http.delete(API_ENDPOINTS.ADMIN.LOCATION.SCHEDULES.DELETE(id))
    showSuccess('ลบเรียบร้อย')
    load()
  } catch (e: unknown) { showError(e instanceof Error ? e.message : 'Error') }
  finally { deletingId.value = null }
}

async function resetVotes() {
  if (!await showConfirm({
    title: 'Reset Votes',
    message: `รีเซ็ต votes ทั้งหมดของเดือน ${weekYear.value}?`,
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

const schedules = computed(() => truckLocation.value?.schedules ?? [])
const activeScheduleId = computed(() => truckLocation.value?.activeScheduleId ?? null)

onMounted(load)
</script>

<template>
  <div class="space-y-8">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">จัดการตำแหน่งรถ</h1>
        <p class="text-sm text-gray-500 mt-0.5">เดือน: {{ weekYear }}</p>
      </div>
      <div class="flex gap-3">
        <button
          class="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700"
          @click="showTruckForm = !showTruckForm"
        >{{ showTruckForm ? 'ซ่อน' : 'แก้ไขข้อมูลร้าน' }}</button>
        <button
          :disabled="resetting"
          class="px-4 py-2 bg-red-500 text-white text-sm font-semibold rounded-lg hover:bg-red-600 disabled:opacity-50"
          @click="resetVotes"
        >{{ resetting ? 'กำลังรีเซ็ต...' : 'รีเซ็ตโหวต' }}</button>
      </div>
    </div>

    <!-- Shop Info Form -->
    <div v-if="showTruckForm" class="bg-white rounded-xl shadow p-6">
      <h2 class="font-semibold text-gray-800 mb-4">ข้อมูลร้านเริ่มต้น (fallback)</h2>
      <form class="grid grid-cols-1 md:grid-cols-2 gap-4" @submit.prevent="saveTruck">
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อร้าน / สถานที่หลัก</label>
          <input v-model="truckForm.name" required type="text" placeholder="เช่น JP Sibling Coffee Truck"
            class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        <div class="md:col-span-2 flex gap-3">
          <button type="submit" :disabled="savingTruck"
            class="px-6 py-2.5 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 disabled:opacity-50">
            {{ savingTruck ? 'กำลังบันทึก...' : 'บันทึก' }}
          </button>
          <button type="button" class="px-6 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200"
            @click="showTruckForm = false">ยกเลิก</button>
        </div>
      </form>
    </div>

    <!-- Timeline Schedules -->
    <div class="bg-white rounded-xl shadow overflow-hidden">
      <div class="px-6 py-4 border-b flex items-center justify-between">
        <div>
          <h2 class="font-semibold text-gray-800">Timeline ตำแหน่งรถ</h2>
          <p class="text-xs text-gray-400 mt-0.5">ร้านจะเปิด/ปิดอัตโนมัติตาม slot ที่ตรงกับวัน+เวลาปัจจุบัน</p>
        </div>
        <button
          class="flex items-center gap-1.5 px-4 py-2 bg-green-600 text-white text-sm font-semibold rounded-lg hover:bg-green-700"
          @click="openNewSchedule"
        >
          <Icon name="mdi:plus" class="text-base" />
          เพิ่ม Slot
        </button>
      </div>

      <div v-if="loading" class="p-8 text-center text-gray-400">กำลังโหลด...</div>
      <div v-else-if="schedules.length === 0" class="p-8 text-center text-gray-400">
        ยังไม่มี slot — กดปุ่ม "เพิ่ม Slot" เพื่อสร้าง timeline
      </div>
      <div v-else class="relative">
        <!-- Timeline line -->
        <div class="absolute left-[2.75rem] top-0 bottom-0 w-0.5 bg-gray-100 ml-px" />
        <div class="divide-y divide-gray-50">
          <div v-for="slot in schedules" :key="slot.id" class="flex gap-4 px-6 py-5 relative">
            <!-- Dot -->
            <div class="flex-shrink-0 mt-1 flex flex-col items-center gap-1 w-8">
              <div class="w-4 h-4 rounded-full border-2 z-10"
                :class="slot.id === activeScheduleId
                  ? 'bg-green-500 border-green-500 shadow-[0_0_0_3px_rgba(34,197,94,0.2)]'
                  : 'bg-white border-gray-300'"
              />
            </div>
            <!-- Content -->
            <div class="flex-1 min-w-0">
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                  <div class="flex items-center gap-2 flex-wrap">
                    <p class="font-semibold text-gray-900">{{ slot.name }}</p>
                    <span v-if="slot.id === activeScheduleId"
                      class="text-xs px-2 py-0.5 rounded-full bg-green-100 text-green-700 font-medium">เปิดอยู่ตอนนี้</span>
                  </div>
                  <p class="text-sm text-blue-600 font-medium mt-0.5">
                    {{ slot.openTime }} – {{ slot.closeTime }}
                  </p>
                  <p class="text-xs text-gray-400">{{ slot.daysOfWeek }}</p>
                  <p v-if="slot.description" class="text-xs text-gray-500 mt-0.5">{{ slot.description }}</p>
                </div>
                <div class="flex items-center gap-2 flex-shrink-0">
                  <a v-if="slot.mapUrl" :href="slot.mapUrl" target="_blank" rel="noopener"
                    class="text-xs text-gray-400 hover:text-gray-700 px-2 py-1 rounded hover:bg-gray-100">
                    <Icon name="mdi:map-marker" />
                  </a>
                  <button class="text-xs text-blue-600 hover:text-blue-800 px-2 py-1 rounded hover:bg-blue-50"
                    @click="openEditSchedule(slot)">แก้ไข</button>
                  <button
                    :disabled="deletingId === slot.id"
                    class="text-xs text-red-500 hover:text-red-700 px-2 py-1 rounded hover:bg-red-50 disabled:opacity-50"
                    @click="deleteSchedule(slot.id)"
                  >ลบ</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Schedule Form Modal -->
    <Teleport to="body">
      <div v-if="showScheduleForm" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md">
          <div class="px-6 py-4 border-b flex items-center justify-between">
            <h3 class="font-bold text-gray-900">{{ editingSchedule ? 'แก้ไข Slot' : 'เพิ่ม Slot ใหม่' }}</h3>
            <button class="text-gray-400 hover:text-gray-700" @click="showScheduleForm = false">
              <Icon name="mdi:close" class="text-xl" />
            </button>
          </div>
          <form class="p-6 space-y-4" @submit.prevent="saveSchedule">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อสถานที่ <span class="text-red-500">*</span></label>
              <input v-model="scheduleForm.name" required type="text" placeholder="เช่น หน้า Central Eastville"
                class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">วันที่เปิด <span class="text-red-500">*</span></label>
              <div class="flex flex-wrap gap-2">
                <button
                  v-for="day in DAY_OPTIONS"
                  :key="day"
                  type="button"
                  class="px-3 py-1.5 rounded-lg text-sm font-medium border transition-colors"
                  :class="hasDay(day)
                    ? 'bg-blue-600 text-white border-blue-600'
                    : 'bg-white text-gray-600 border-gray-300 hover:border-blue-400'"
                  @click="toggleDay(day)"
                >{{ day }}</button>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">เปิด <span class="text-red-500">*</span></label>
                <input v-model="scheduleForm.openTime" required type="time"
                  class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">ปิด <span class="text-red-500">*</span></label>
                <input v-model="scheduleForm.closeTime" required type="time"
                  class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">รายละเอียด</label>
              <input v-model="scheduleForm.description" type="text" placeholder="เช่น ใกล้ประตูทางเข้าหลัก"
                class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Google Maps URL</label>
              <input v-model="scheduleForm.mapUrl" type="url" placeholder="https://maps.google.com/..."
                class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">ลำดับ</label>
              <input v-model.number="scheduleForm.sortOrder" type="number" min="0"
                class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div class="flex gap-3 pt-2">
              <button type="submit" :disabled="savingSchedule || !scheduleForm.daysOfWeek"
                class="flex-1 py-2.5 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 disabled:opacity-50">
                {{ savingSchedule ? 'กำลังบันทึก...' : 'บันทึก' }}
              </button>
              <button type="button" class="flex-1 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200"
                @click="showScheduleForm = false">ยกเลิก</button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>

    <!-- Location Requests -->
    <div class="bg-white rounded-xl shadow overflow-hidden">
      <div class="px-6 py-4 border-b flex items-center justify-between">
        <h2 class="font-semibold text-gray-800">คำขอสถานที่เดือนนี้</h2>
        <span class="text-sm text-gray-500">{{ requests.length }} คำขอ</span>
      </div>
      <div v-if="loading" class="p-8 text-center text-gray-400">กำลังโหลด...</div>
      <div v-else-if="requests.length === 0" class="p-8 text-center text-gray-400">ยังไม่มีคำขอเดือนนี้</div>
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
            <div class="h-full bg-blue-200 rounded-full transition-all" :style="{ width: (req.voteCount / maxVotes * 100) + '%' }" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
