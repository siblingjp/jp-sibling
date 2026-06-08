<script setup lang="ts">
interface Schedule {
  id: string
  name: string
  openTime: string
  closeTime: string
  daysOfWeek: string
  mapUrl: string | null
}

const props = defineProps<{
  schedules: Schedule[]
  activeScheduleId: string | null
}>()

const emit = defineEmits<{ close: [] }>()

const dayOrder = ['จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์']

const grouped = computed(() => {
  return props.schedules.map(s => ({
    ...s,
    days: dayOrder.filter(d => s.daysOfWeek.includes(d)),
  }))
})
</script>

<template>
  <div class="fixed inset-0 z-[60] flex items-end sm:items-center justify-center">
    <div class="absolute inset-0 bg-black/40" @click="emit('close')" />
    <div class="relative bg-white w-full max-w-sm rounded-t-2xl sm:rounded-2xl shadow-xl p-5 space-y-4 max-h-[80vh] flex flex-col">
      <div class="flex items-center justify-between">
        <h2 class="font-semibold text-gray-900">ไทม์ไลน์ประจำสัปดาห์</h2>
        <button class="text-gray-400 hover:text-gray-600 p-1" @click="emit('close')">
          <Icon name="mdi:close" class="text-lg" />
        </button>
      </div>

      <div v-if="!schedules.length" class="text-center py-8 text-gray-400 text-sm">
        ยังไม่มีกำหนดการ
      </div>

      <div v-else class="overflow-y-auto space-y-2 flex-1">
        <div
          v-for="s in grouped"
          :key="s.id"
          class="flex items-start gap-3 p-3 rounded-xl border transition-colors"
          :class="s.id === activeScheduleId ? 'border-green-400 bg-green-50' : 'border-gray-100 bg-gray-50'"
        >
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 flex-wrap">
              <p class="font-medium text-sm text-gray-900">{{ s.name }}</p>
              <span v-if="s.id === activeScheduleId" class="text-[10px] px-1.5 py-0.5 rounded-full bg-green-500 text-white font-semibold">เปิดอยู่</span>
            </div>
            <p class="text-xs text-gray-500 mt-0.5">{{ s.days.join(' · ') }}</p>
            <p class="text-xs text-gray-400">{{ s.openTime }} – {{ s.closeTime }} น.</p>
          </div>
          <a
            v-if="s.mapUrl"
            :href="s.mapUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="flex items-center gap-1 text-xs text-[#1B2B4B] hover:underline flex-shrink-0 mt-0.5"
          >
            <Icon name="mdi:map-marker" class="text-red-400 text-sm" />แผนที่
          </a>
        </div>
      </div>
    </div>
  </div>
</template>
