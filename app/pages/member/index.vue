<script setup lang="ts">
definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()

const tierConfig = computed(() => {
  const tier = member.value?.tier ?? 'SILVER'
  if (tier === 'VIP') return { label: 'VIP', color: 'text-purple-700', bg: 'bg-purple-100', next: null, nextSpend: 0 }
  if (tier === 'GOLD') return { label: 'Gold', color: 'text-yellow-700', bg: 'bg-yellow-100', next: 'VIP', nextSpend: 5000 }
  return { label: 'Silver', color: 'text-gray-600', bg: 'bg-gray-100', next: 'Gold', nextSpend: 2000 }
})

const totalSpent = computed(() => Number(member.value?.totalSpent ?? 0))
const spendProgress = computed(() => {
  if (!tierConfig.value.next) return 100
  return Math.min((totalSpent.value / tierConfig.value.nextSpend) * 100, 100)
})
const spendRemaining = computed(() => {
  if (!tierConfig.value.next) return 0
  return Math.max(tierConfig.value.nextSpend - totalSpent.value, 0)
})
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <!-- Member card -->
    <div class="bg-gradient-to-br from-[#1B2B4B] to-[#2a3f6b] rounded-2xl p-6 text-white shadow-lg">
      <div class="flex items-center gap-4 mb-6">
        <div class="w-14 h-14 rounded-full bg-white/20 flex items-center justify-center text-2xl font-bold overflow-hidden">
          <img v-if="member?.profileImage" :src="member.profileImage" class="w-full h-full object-cover" />
          <span v-else>{{ member?.name?.[0]?.toUpperCase() }}</span>
        </div>
        <div>
          <p class="text-white/70 text-sm">Welcome back</p>
          <p class="text-xl font-bold">{{ member?.name }}</p>
          <span class="text-xs px-2 py-0.5 rounded-full bg-white/20 font-medium">{{ tierConfig.label }}</span>
        </div>
      </div>

      <div class="bg-white/10 rounded-xl p-4">
        <p class="text-white/70 text-sm mb-1">Points Balance</p>
        <p class="text-4xl font-bold">{{ (member?.points ?? 0).toLocaleString() }}</p>
        <p class="text-white/70 text-sm mt-1">= ฿{{ (member?.points ?? 0).toLocaleString() }} discount</p>
      </div>
    </div>

    <!-- Tier progress -->
    <div v-if="tierConfig.next" class="bg-white rounded-2xl shadow p-5">
      <div class="flex justify-between items-center mb-2">
        <span class="font-semibold text-gray-700">Tier Progress</span>
        <span class="text-sm text-gray-500">{{ tierConfig.label }} → {{ tierConfig.next }}</span>
      </div>
      <div class="w-full bg-gray-100 rounded-full h-3 mb-2">
        <div
          class="h-3 rounded-full bg-[#C8D8E8] transition-all"
          :style="{ width: spendProgress + '%' }"
        />
      </div>
      <p class="text-sm text-gray-500">
        Spend ฿{{ spendRemaining.toLocaleString() }} more to reach {{ tierConfig.next }}
      </p>
    </div>
    <div v-else class="bg-white rounded-2xl shadow p-5 text-center">
      <p class="text-purple-700 font-semibold">You're at VIP — the highest tier!</p>
    </div>

    <!-- Quick actions -->
    <div class="grid grid-cols-2 gap-4">
      <NuxtLink
        to="/member/orders/new"
        class="bg-[#1B2B4B] text-white rounded-2xl p-5 text-center shadow hover:bg-[#2a3f6b] transition-colors"
      >
        <Icon name="flat-color-icons:shop" class="text-4xl mb-2" />
        <p class="font-semibold">Order Now</p>
        <p class="text-xs text-[#C8D8E8] mt-0.5">Online ordering</p>
      </NuxtLink>

      <NuxtLink
        to="/member/redeem"
        class="bg-white rounded-2xl p-5 text-center shadow hover:shadow-md transition-shadow border border-gray-100"
      >
        <Icon name="mdi:gift" class="text-4xl mb-2" />
        <p class="font-semibold text-gray-800">Redeem</p>
        <p class="text-xs text-gray-500 mt-0.5">Use your points</p>
      </NuxtLink>

      <NuxtLink
        to="/member/points"
        class="bg-white rounded-2xl p-5 text-center shadow hover:shadow-md transition-shadow border border-gray-100"
      >
        <Icon name="flat-color-icons:bar-chart" class="text-4xl mb-2" />
        <p class="font-semibold text-gray-800">Points History</p>
        <p class="text-xs text-gray-500 mt-0.5">Earn & redeem log</p>
      </NuxtLink>

      <NuxtLink
        to="/member/qr"
        class="bg-white rounded-2xl p-5 text-center shadow hover:shadow-md transition-shadow border border-gray-100"
      >
        <Icon name="flat-color-icons:phone-android" class="text-4xl mb-2" />
        <p class="font-semibold text-gray-800">My QR</p>
        <p class="text-xs text-gray-500 mt-0.5">Show at counter</p>
      </NuxtLink>
    </div>

    <!-- Recent orders shortcut -->
    <NuxtLink
      to="/member/orders"
      class="flex items-center justify-between bg-white rounded-2xl shadow p-5 hover:shadow-md transition-shadow"
    >
      <div>
        <p class="font-semibold text-gray-800">My Orders</p>
        <p class="text-sm text-gray-500">View order history</p>
      </div>
      <Icon name="mdi:chevron-right" class="w-5 h-5 text-gray-400" />
    </NuxtLink>
  </div>
</template>
