<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const http = useHttpClient()
const { showSuccess, showError } = useAlert()

type LoyaltyMode = 'POINTS' | 'STAMPS'

const mode = ref<LoyaltyMode>('POINTS')
const loading = ref(true)
const saving = ref(false)

async function load() {
  loading.value = true
  try {
    const res = await http.get<{ data: { loyaltyMode: LoyaltyMode } }>(API_ENDPOINTS.PUBLIC.LOYALTY_MODE)
    mode.value = res.data?.loyaltyMode ?? 'POINTS'
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
    </template>
  </div>
</template>
