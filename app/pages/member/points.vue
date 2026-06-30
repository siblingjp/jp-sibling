<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const http = useHttpClient()

interface PointLogItem {
  id: string
  action: 'EARN' | 'REDEEM' | 'ADJUST' | 'EXPIRE'
  amount: number
  note: string | null
  expiredAt: string | null
  createdAt: string
  order: { queueNo: number | null } | null
}

const logs = ref<PointLogItem[]>([])
const loading = ref(true)
const error = ref('')

onMounted(async () => {
  try {
    const res = await http.get<{ success: boolean; data: { points: number; tier: string; logs: PointLogItem[] } }>(
      API_ENDPOINTS.MEMBER.POINTS
    )
    logs.value = res.data?.logs ?? []
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Failed to load'
  } finally {
    loading.value = false
  }
})

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
    <h1 class="text-2xl font-bold text-gray-900">ประวัติแต้ม</h1>

    <!-- Summary -->
    <div class="bg-gradient-to-br from-[#1B2B4B] to-[#2a3f6b] rounded-2xl p-6 text-white">
      <p class="text-white/70 text-sm">ยอดแต้มปัจจุบัน</p>
      <p class="text-5xl font-bold mt-1">{{ (member?.points ?? 0).toLocaleString() }}</p>
      <p class="text-white/70 text-sm mt-1">แต้ม</p>
    </div>


    <!-- Log list -->
    <div class="bg-white rounded-2xl shadow overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-gray-400">กำลังโหลด...</div>
      <div v-else-if="error" class="p-8 text-center text-red-500">{{ error }}</div>
      <div v-else-if="logs.length === 0" class="p-8 text-center text-gray-400">ยังไม่มีรายการแต้ม</div>
      <div v-else class="divide-y divide-gray-50">
        <div
          v-for="log in logs"
          :key="log.id"
          class="flex items-center justify-between px-5 py-4"
        >
          <div>
            <p class="font-medium text-gray-800">{{ actionLabel[log.action] }}</p>
            <p class="text-xs text-gray-400 mt-0.5">{{ log.note }}</p>
            <div class="flex items-center gap-2 mt-0.5">
              <p class="text-xs text-gray-400">{{ formatDate(log.createdAt) }}</p>
              <span v-if="log.order?.queueNo" class="text-xs text-[#1B2B4B] font-medium">· ออเดอร์ #{{ log.order.queueNo }}</span>
            </div>
          </div>
          <span
            class="text-lg font-bold"
            :class="actionColor[log.action]"
          >
            {{ log.amount > 0 ? '+' : '' }}{{ log.amount }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>
