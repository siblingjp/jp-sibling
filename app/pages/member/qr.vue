<script setup lang="ts">
definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()

const qrUrl = computed(() =>
  `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(member.value?.id ?? '')}&margin=10`
)
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <h1 class="text-2xl font-bold text-gray-900">My QR Code</h1>

    <div class="bg-white rounded-2xl shadow p-8 flex flex-col items-center gap-6">
      <p class="text-gray-500 text-sm text-center">Show this QR code at the counter to collect points</p>

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
          <p class="font-semibold text-[#0F1C30]">{{ (member?.points ?? 0).toLocaleString() }} pts</p>
          <p class="text-xs text-[#2a3f6b]">Current balance</p>
        </div>
      </div>
    </div>

    <p class="text-center text-xs text-gray-400">
      Scan this code at the POS to link your account to in-store purchases
    </p>
  </div>
</template>
