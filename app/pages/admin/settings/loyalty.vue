<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const http = useHttpClient()
const { showSuccess, showError } = useAlert()

type LoyaltyMode = 'POINTS' | 'STAMPS'

interface PendingRedemption {
  id: string
  requestedAt: string
  member: { id: string; name: string; phone: string | null }
}

const mode = ref<LoyaltyMode>('POINTS')
const loading = ref(true)
const saving = ref(false)
const pending = ref<PendingRedemption[]>([])
const confirming = ref<string | null>(null)

async function load() {
  loading.value = true
  try {
    const [modeRes, pendingRes] = await Promise.all([
      http.get<{ data: { loyaltyMode: LoyaltyMode } }>(API_ENDPOINTS.PUBLIC.LOYALTY_MODE),
      http.get<{ data: PendingRedemption[] }>(API_ENDPOINTS.ADMIN.STAMP_REDEMPTIONS.LIST),
    ])
    mode.value = modeRes.data?.loyaltyMode ?? 'POINTS'
    pending.value = pendingRes.data ?? []
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'โหลดข้อมูลไม่สำเร็จ')
  } finally {
    loading.value = false
  }
}

onMounted(load)

async function setMode(newMode: LoyaltyMode) {
  if (newMode === mode.value || saving.value) return
  saving.value = true
  try {
    await http.put(API_ENDPOINTS.ADMIN.SETTINGS.LOYALTY, { loyaltyMode: newMode })
    mode.value = newMode
    showSuccess('บันทึกการตั้งค่าเรียบร้อย')
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'บันทึกไม่สำเร็จ')
  } finally {
    saving.value = false
  }
}

async function confirmRedemption(id: string) {
  confirming.value = id
  try {
    await http.post(API_ENDPOINTS.POS.STAMP_REDEMPTION_CONFIRM(id))
    pending.value = pending.value.filter(p => p.id !== id)
    showSuccess('ยืนยันการแลกแสตมป์เรียบร้อย')
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'ยืนยันไม่สำเร็จ')
  } finally {
    confirming.value = null
  }
}

function formatDateTime(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <div class="max-w-2xl space-y-6">
    <h1 class="text-xl font-bold text-gray-900">ตั้งค่าระบบสะสมแต้ม/แสตมป์</h1>

    <div v-if="loading" class="text-center py-10 text-gray-400">กำลังโหลด...</div>

    <template v-else>
      <div class="bg-white rounded-2xl shadow p-6">
        <p class="text-sm text-gray-500 mb-4">เลือกระบบสะสมที่ต้องการใช้งาน — ใช้ได้ทีละระบบเท่านั้น การสลับโหมดจะไม่ลบข้อมูลแต้ม/แสตมป์ของสมาชิกที่มีอยู่</p>
        <div class="grid grid-cols-2 gap-3">
          <button
            class="p-4 rounded-xl border-2 text-left transition-colors"
            :class="mode === 'POINTS' ? 'border-[#1B2B4B] bg-[#F0F4F8]' : 'border-gray-200 hover:border-gray-300'"
            :disabled="saving"
            @click="setMode('POINTS')"
          >
            <div class="flex items-center gap-2 mb-1">
              <Icon name="mdi:star-circle" class="text-xl text-yellow-500" />
              <span class="font-semibold text-gray-900">สะสมแต้ม</span>
            </div>
            <p class="text-xs text-gray-500">แต้มตามยอดซื้อ แลกเป็นคูปองส่วนลด</p>
          </button>
          <button
            class="p-4 rounded-xl border-2 text-left transition-colors"
            :class="mode === 'STAMPS' ? 'border-[#1B2B4B] bg-[#F0F4F8]' : 'border-gray-200 hover:border-gray-300'"
            :disabled="saving"
            @click="setMode('STAMPS')"
          >
            <div class="flex items-center gap-2 mb-1">
              <Icon name="mdi:coffee" class="text-xl text-amber-700" />
              <span class="font-semibold text-gray-900">สะสมแสตมป์</span>
            </div>
            <p class="text-xs text-gray-500">ซื้อ 1 แก้ว = 1 แสตมป์ ครบ 10 แลกฟรี 1 แก้ว</p>
          </button>
        </div>
      </div>

      <div v-if="mode === 'STAMPS'" class="bg-white rounded-2xl shadow p-6">
        <h2 class="font-semibold text-gray-800 mb-3">คำขอแลกแสตมป์ที่รอยืนยัน</h2>
        <div v-if="pending.length === 0" class="text-center py-6 text-gray-400 text-sm">ไม่มีคำขอที่รอดำเนินการ</div>
        <div v-else class="space-y-2">
          <div
            v-for="req in pending"
            :key="req.id"
            class="flex items-center justify-between gap-3 p-3 rounded-xl bg-gray-50 border border-gray-200"
          >
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900">{{ req.member.name }}</p>
              <p class="text-xs text-gray-400">{{ req.member.phone ?? '-' }} · ขอเมื่อ {{ formatDateTime(req.requestedAt) }}</p>
            </div>
            <button
              class="px-3 py-1.5 bg-[#1B2B4B] text-white text-xs font-semibold rounded-lg hover:bg-[#2a3f6b] disabled:opacity-40 transition-colors flex-shrink-0"
              :disabled="confirming === req.id"
              @click="confirmRedemption(req.id)"
            >
              {{ confirming === req.id ? '...' : 'ยืนยันแลก' }}
            </button>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
