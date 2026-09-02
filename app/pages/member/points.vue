<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const http = useHttpClient()
const { showSuccess, showError } = useAlert()
const { mode, fetchMode } = useLoyaltyMode()
const memberStore = useMemberStore()

interface PointLogItem {
  id: string
  action: 'EARN' | 'REDEEM' | 'ADJUST' | 'EXPIRE'
  amount: number
  note: string | null
  expiredAt: string | null
  createdAt: string
  order: { queueNo: number | null } | null
}

interface StampLogItem {
  id: string
  action: 'EARN' | 'REDEEM' | 'ADJUST'
  amount: number
  note: string | null
  createdAt: string
  order: { queueNo: number | null } | null
}

interface PendingRedemption {
  id: string
  requestedAt: string
}

const logs = ref<PointLogItem[]>([])
const stampLogs = ref<StampLogItem[]>([])
const stampCount = ref(0)
const maxStamps = ref(10)
const pendingRedemption = ref<PendingRedemption | null>(null)
const loading = ref(true)
const error = ref('')
const requesting = ref(false)

onMounted(async () => {
  await fetchMode()
  try {
    if (mode.value === 'STAMPS') {
      const res = await http.get<{ success: boolean; data: { stampCount: number; maxStamps: number; logs: StampLogItem[]; pendingRedemption: PendingRedemption | null } }>(
        API_ENDPOINTS.MEMBER.STAMPS.SHOW
      )
      stampCount.value = res.data?.stampCount ?? 0
      maxStamps.value = res.data?.maxStamps ?? 10
      stampLogs.value = res.data?.logs ?? []
      pendingRedemption.value = res.data?.pendingRedemption ?? null
    } else {
      const res = await http.get<{ success: boolean; data: { points: number; tier: string; logs: PointLogItem[] } }>(
        API_ENDPOINTS.MEMBER.POINTS
      )
      logs.value = res.data?.logs ?? []
    }
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Failed to load'
  } finally {
    loading.value = false
  }
})

async function requestRedeem() {
  requesting.value = true
  try {
    const res = await http.post<{ data: PendingRedemption }>(API_ENDPOINTS.MEMBER.STAMPS.REDEEM)
    pendingRedemption.value = res.data ?? null
    stampCount.value = 0
    memberStore.setStampCount(0)
    showSuccess('ส่งคำขอแลกฟรีคัพแล้ว รอพนักงานยืนยันที่ร้าน')
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'ขอแลกไม่สำเร็จ')
  } finally {
    requesting.value = false
  }
}

const actionLabel: Record<string, string> = {
  EARN: 'ได้รับ',
  REDEEM: 'แลกแล้ว',
  ADJUST: 'ปรับ',
  EXPIRE: 'หมดอายุ',
}

const actionColor: Record<string, string> = {
  EARN: 'text-green-600',
  REDEEM: 'text-red-500',
  ADJUST: 'text-blue-500',
  EXPIRE: 'text-gray-400',
}

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { year: 'numeric', month: 'short', day: 'numeric' })
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <h1 class="text-2xl font-bold text-gray-900">{{ mode === 'STAMPS' ? 'บัตรสะสมแสตมป์' : 'ประวัติแต้ม' }}</h1>

    <!-- STAMPS mode -->
    <template v-if="mode === 'STAMPS'">
      <div class="bg-gradient-to-br from-[#1B2B4B] to-[#2a3f6b] rounded-2xl p-6 text-white">
        <p class="text-white/70 text-sm">แสตมป์สะสม</p>
        <p class="text-5xl font-bold mt-1">{{ stampCount }}<span class="text-2xl text-white/60">/{{ maxStamps }}</span></p>
        <div class="grid grid-cols-5 gap-2 mt-4">
          <div
            v-for="i in maxStamps"
            :key="i"
            class="aspect-square rounded-full flex items-center justify-center overflow-hidden"
            :class="i <= stampCount ? 'bg-white/90' : 'bg-white/10 border border-white/20'"
          >
            <img
              v-if="i <= stampCount"
              src="/icon-circle.png"
              alt="แสตมป์"
              class="w-full h-full object-cover"
            />
            <Icon
              v-else
              name="mdi:coffee-outline"
              class="text-xl text-white/40"
            />
          </div>
        </div>
      </div>

      <div v-if="pendingRedemption" class="bg-white rounded-2xl shadow p-5 text-center space-y-3">
        <Icon name="mdi:clock-outline" class="text-4xl text-amber-500 mx-auto" />
        <p class="font-semibold text-gray-800">รอพนักงานยืนยันการแลก</p>
        <p class="text-xs text-gray-400">แสดงหน้านี้ให้พนักงานที่ร้านเพื่อยืนยันรับแก้วฟรี</p>
        <div class="flex justify-center">
          <div class="bg-white p-3 rounded-xl border-2 border-[#C8D8E8] shadow-sm">
            <img
              :src="`https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(pendingRedemption.id)}&margin=4`"
              alt="QR แลกแสตมป์"
              class="w-48 h-48"
            />
          </div>
        </div>
      </div>
      <button
        v-else-if="stampCount >= maxStamps"
        class="w-full py-3 rounded-xl bg-[#1B2B4B] text-white font-semibold hover:bg-[#2a3f6b] disabled:opacity-40 transition-colors"
        :disabled="requesting"
        @click="requestRedeem"
      >
        {{ requesting ? 'กำลังส่งคำขอ...' : 'ขอแลกฟรี 1 แก้ว' }}
      </button>

      <div class="bg-white rounded-2xl shadow overflow-hidden">
        <div v-if="loading" class="p-8 text-center text-gray-400">กำลังโหลด...</div>
        <div v-else-if="error" class="p-8 text-center text-red-500">{{ error }}</div>
        <div v-else-if="stampLogs.length === 0" class="p-8 text-center text-gray-400">ยังไม่มีรายการแสตมป์</div>
        <div v-else class="divide-y divide-gray-50">
          <div v-for="log in stampLogs" :key="log.id" class="flex items-center justify-between px-5 py-4">
            <div>
              <p class="font-medium text-gray-800">{{ actionLabel[log.action] }}</p>
              <p class="text-xs text-gray-400 mt-0.5">{{ log.note }}</p>
              <div class="flex items-center gap-2 mt-0.5">
                <p class="text-xs text-gray-400">{{ formatDate(log.createdAt) }}</p>
                <span v-if="log.order?.queueNo" class="text-xs text-[#1B2B4B] font-medium">· ออเดอร์ #{{ log.order.queueNo }}</span>
              </div>
            </div>
            <span class="text-lg font-bold" :class="actionColor[log.action]">
              {{ log.amount > 0 ? '+' : '' }}{{ log.amount }}
            </span>
          </div>
        </div>
      </div>
    </template>

    <!-- POINTS mode (unchanged) -->
    <template v-else>
      <div class="bg-gradient-to-br from-[#1B2B4B] to-[#2a3f6b] rounded-2xl p-6 text-white">
        <p class="text-white/70 text-sm">ยอดแต้มปัจจุบัน</p>
        <p class="text-5xl font-bold mt-1">{{ (member?.points ?? 0).toLocaleString() }}</p>
        <p class="text-white/70 text-sm mt-1">แต้ม</p>
      </div>

      <div class="bg-white rounded-2xl shadow overflow-hidden">
        <div v-if="loading" class="p-8 text-center text-gray-400">กำลังโหลด...</div>
        <div v-else-if="error" class="p-8 text-center text-red-500">{{ error }}</div>
        <div v-else-if="logs.length === 0" class="p-8 text-center text-gray-400">ยังไม่มีรายการแต้ม</div>
        <div v-else class="divide-y divide-gray-50">
          <div v-for="log in logs" :key="log.id" class="flex items-center justify-between px-5 py-4">
            <div>
              <p class="font-medium text-gray-800">{{ actionLabel[log.action] }}</p>
              <p class="text-xs text-gray-400 mt-0.5">{{ log.note }}</p>
              <div class="flex items-center gap-2 mt-0.5">
                <p class="text-xs text-gray-400">{{ formatDate(log.createdAt) }}</p>
                <span v-if="log.order?.queueNo" class="text-xs text-[#1B2B4B] font-medium">· ออเดอร์ #{{ log.order.queueNo }}</span>
              </div>
            </div>
            <span class="text-lg font-bold" :class="actionColor[log.action]">
              {{ log.amount > 0 ? '+' : '' }}{{ log.amount }}
            </span>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
