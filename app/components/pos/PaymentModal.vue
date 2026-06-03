<script setup lang="ts">
const props = defineProps<{
  total: number
  isSubmitting: boolean
}>()

const emit = defineEmits<{
  confirm: [method: 'CASH' | 'QR' | 'THAI_HELP', amount: number, ref?: string]
  cancel: []
}>()

const method = ref<'CASH' | 'QR' | 'THAI_HELP'>('CASH')

const methodLabel: Record<string, string> = {
  CASH: 'เงินสด',
  QR: 'QR พร้อมเพย์',
  THAI_HELP: 'ไทยช่วยไทยพลัส',
}
const cashReceived = ref(0)
const transactionRef = ref('')

watch(() => props.total, (v) => { cashReceived.value = v }, { immediate: true })

const change = computed(() => method.value === 'CASH' ? Math.max(0, cashReceived.value - props.total) : 0)
const isValid = computed(() => {
  if (method.value === 'CASH') return cashReceived.value >= props.total
  return true
})

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

function handleConfirm() {
  if (!isValid.value) return
  const amount = method.value === 'CASH' ? cashReceived.value : props.total
  emit('confirm', method.value, amount, transactionRef.value || undefined)
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
        <div class="grid grid-cols-3 gap-2">
          <button
            v-for="m in (['CASH', 'QR', 'THAI_HELP'] as const)"
            :key="m"
            type="button"
            class="py-2.5 rounded-lg border text-sm font-medium transition-colors"
            :class="method === m ? 'border-blue-500 bg-blue-50 text-blue-700' : 'border-gray-200 text-gray-600 hover:bg-gray-50'"
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
        <div class="flex gap-3">
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
            @click="handleConfirm"
          >
            {{ isSubmitting ? 'กำลังดำเนินการ...' : 'ยืนยันการชำระเงิน' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
