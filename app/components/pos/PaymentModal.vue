<script setup lang="ts">
const props = defineProps<{
  total: number
  isSubmitting: boolean
}>()

const emit = defineEmits<{
  confirm: [method: 'CASH' | 'QR' | 'THAI_HELP' | 'UNPAID', amount: number, ref?: string, startPreparing?: boolean]
  cancel: []
}>()

const method = ref<'CASH' | 'QR' | 'THAI_HELP' | 'UNPAID'>('CASH')

const methodLabel: Record<string, string> = {
  CASH: 'เงินสด',
  QR: 'QR พร้อมเพย์',
  THAI_HELP: 'ไทยช่วยไทยพลัส',
  UNPAID: 'ยังไม่ได้จ่าย',
}
const cashReceived = ref(0)
const transactionRef = ref('')

watch(() => props.total, (v) => { cashReceived.value = v }, { immediate: true })

const change = computed(() => method.value === 'CASH' ? Math.max(0, cashReceived.value - props.total) : 0)
const isValid = computed(() => {
  if (method.value === 'CASH') return cashReceived.value >= props.total
  return true
})

const isUnpaid = computed(() => method.value === 'UNPAID')

const quickAmounts = computed(() => {
  const t = props.total
  const candidates = [
    Math.ceil(t / 10) * 10,
    Math.ceil(t / 20) * 20,
    Math.ceil(t / 50) * 50,
    Math.ceil(t / 100) * 100,
  ]
  return [...new Set(candidates)].filter((v) => v >= t).slice(0, 4)
})

function handleConfirm(startPreparing = false) {
  if (!isValid.value) return
  const amount = method.value === 'CASH' ? cashReceived.value : method.value === 'UNPAID' ? 0 : props.total
  emit('confirm', method.value, amount, transactionRef.value || undefined, startPreparing)
}
</script>

<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-black/40" @click="emit('cancel')" />
      <div class="relative bg-white w-full max-w-sm rounded-2xl shadow-xl p-6 space-y-5">
        <h2 class="text-lg font-semibold text-gray-900 text-center">ชำระเงิน</h2>

        <!-- Total -->
        <div class="bg-gray-50 rounded-xl py-4 text-center">
          <p class="text-xs text-gray-500 mb-1">ยอดรวม</p>
          <p class="text-3xl font-bold text-gray-900">฿{{ total.toFixed(2) }}</p>
        </div>

        <!-- Method -->
        <div class="grid grid-cols-2 gap-2">
          <button
            v-for="m in (['CASH', 'QR', 'THAI_HELP', 'UNPAID'] as const)"
            :key="m"
            type="button"
            class="py-2.5 rounded-lg border text-sm font-medium transition-colors"
            :class="method === m
              ? m === 'UNPAID' ? 'border-orange-400 bg-orange-50 text-orange-700' : 'border-blue-500 bg-blue-50 text-blue-700'
              : 'border-gray-200 text-gray-600 hover:bg-gray-50'"
            @click="method = m"
          >{{ methodLabel[m] }}</button>
        </div>

        <!-- CASH -->
        <div v-if="method === 'CASH'" class="space-y-3">
          <div>
            <label class="block text-xs text-gray-500 mb-1">รับเงิน</label>
            <input
              v-model.number="cashReceived"
              type="number"
              min="0"
              step="1"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg text-center text-lg font-semibold focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div class="flex gap-2">
            <button
              v-for="amt in quickAmounts"
              :key="amt"
              type="button"
              class="flex-1 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-sm font-medium transition-colors"
              @click="cashReceived = amt"
            >฿{{ amt }}</button>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">ทอน</span>
            <span class="font-semibold text-green-600">฿{{ change.toFixed(2) }}</span>
          </div>
        </div>

        <!-- UNPAID -->
        <div v-else-if="isUnpaid" class="bg-orange-50 border border-orange-200 rounded-xl p-4 text-center">
          <p class="text-sm text-orange-700 font-medium">บันทึกออเดอร์โดยยังไม่ชำระเงิน</p>
          <p class="text-xs text-orange-500 mt-1">ลูกค้าค้างชำระ ฿{{ total.toFixed(2) }}</p>
        </div>

        <!-- QR / THAI_HELP -->
        <div v-else>
          <label class="block text-xs text-gray-500 mb-1">เลขอ้างอิง (ไม่บังคับ)</label>
          <input
            v-model="transactionRef"
            type="text"
            placeholder="Transaction ID / Ref no."
            class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Actions -->
        <div v-if="isUnpaid" class="flex flex-col gap-2">
          <div class="flex gap-3">
            <button
              type="button"
              class="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600 hover:bg-gray-50"
              @click="emit('cancel')"
            >ยกเลิก</button>
            <button
              type="button"
              class="flex-1 py-2.5 rounded-xl font-semibold text-white transition-colors"
              :class="!isSubmitting ? 'bg-orange-500 hover:bg-orange-600' : 'bg-gray-300 cursor-not-allowed'"
              :disabled="isSubmitting"
              @click="handleConfirm(false)"
            >{{ isSubmitting ? '...' : 'บันทึก (ค้างชำระ)' }}</button>
          </div>
          <button
            type="button"
            class="w-full py-2.5 rounded-xl font-semibold text-white transition-colors"
            :class="!isSubmitting ? 'bg-blue-600 hover:bg-blue-700' : 'bg-gray-300 cursor-not-allowed'"
            :disabled="isSubmitting"
            @click="handleConfirm(true)"
          >{{ isSubmitting ? 'กำลังดำเนินการ...' : 'บันทึกออเดอร์ (กำลังทำ)' }}</button>
        </div>

        <div v-else class="flex gap-3">
          <button
            type="button"
            class="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600 hover:bg-gray-50"
            @click="emit('cancel')"
          >ยกเลิก</button>
          <button
            type="button"
            class="flex-1 py-2.5 rounded-xl font-semibold text-white transition-colors"
            :class="isValid && !isSubmitting ? 'bg-green-600 hover:bg-green-700' : 'bg-gray-300 cursor-not-allowed'"
            :disabled="!isValid || isSubmitting"
            @click="handleConfirm()"
          >{{ isSubmitting ? 'กำลังดำเนินการ...' : 'ยืนยันการชำระเงิน' }}</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
