<script setup lang="ts">
definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const { mode, fetchMode } = useLoyaltyMode()

onMounted(fetchMode)

const qrUrl = computed(() =>
  `https://api.qrserver.com/v1/create-qr-code/?size=600x600&data=${encodeURIComponent(member.value?.id ?? '')}&margin=10`
)

const saving = ref(false)

async function saveQR() {
  if (!member.value) return
  saving.value = true
  try {
    const res = await fetch(qrUrl.value)
    const blob = await res.blob()
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `qr-${member.value.name ?? member.value.id}.png`
    a.click()
    URL.revokeObjectURL(url)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <h1 class="text-2xl font-bold text-gray-900">QR Code ของฉัน</h1>

    <div class="bg-white rounded-2xl shadow p-8 flex flex-col items-center gap-6">
      <p class="text-gray-500 text-sm text-center">แสดง QR Code นี้ที่เคาน์เตอร์เพื่อสะสม{{ mode === 'STAMPS' ? 'แสตมป์' : 'แต้ม' }}</p>

      <div class="p-4 bg-white rounded-xl border-2 border-gray-100 shadow-sm">
        <img :src="qrUrl" alt="Member QR" class="w-64 h-64" />
      </div>

      <div class="text-center">
        <p class="text-xl font-bold text-gray-900">{{ member?.name }}</p>
        <p class="text-sm text-gray-400 font-mono mt-1">{{ member?.id }}</p>
      </div>

      <div class="flex items-center gap-3 w-full bg-[#F0F4F8] rounded-xl p-4">
        <Icon name="flat-color-icons:approval" class="text-2xl flex-shrink-0" />
        <div>
          <p v-if="mode === 'STAMPS'" class="font-semibold text-[#0F1C30]">{{ member?.stampCount ?? 0 }}/10 แสตมป์</p>
          <p v-else class="font-semibold text-[#0F1C30]">{{ (member?.points ?? 0).toLocaleString() }} pts</p>
          <p class="text-xs text-[#2a3f6b]">{{ mode === 'STAMPS' ? 'จำนวนแสตมป์ปัจจุบัน' : 'ยอดแต้มปัจจุบัน' }}</p>
        </div>
      </div>

      <button
        :disabled="saving"
        class="w-full py-3 rounded-xl bg-[#1B2B4B] text-white font-semibold text-sm flex items-center justify-center gap-2 hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors"
        @click="saveQR"
      >
        <Icon name="mdi:download" class="text-lg" />
        {{ saving ? 'กำลังบันทึก...' : 'บันทึก QR Code' }}
      </button>
    </div>

    <p class="text-center text-xs text-gray-400">
      สแกน QR นี้ที่หน้าจอ POS เพื่อเชื่อมบัญชีกับการซื้อในร้าน
    </p>
  </div>
</template>
