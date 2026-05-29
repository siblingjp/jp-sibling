<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const http = useHttpClient()

interface CouponUse {
  id: string
  isUsed: boolean
  usedAt: string | null
  createdAt: string
  coupon: {
    code: string
    name: string
    description: string | null
    discountKind: 'PERCENT' | 'AMOUNT'
    discountValue: number
    expiredAt: string | null
  }
}

const uses = ref<CouponUse[]>([])
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await http.get<{ data: CouponUse[] }>(API_ENDPOINTS.MEMBER.COUPONS.LIST)
    uses.value = res.data ?? []
  } catch {
    // silent
  } finally {
    loading.value = false
  }
})

const available = computed(() => uses.value.filter((u) => !u.isUsed))
const used = computed(() => uses.value.filter((u) => u.isUsed))

const qrTarget = ref<CouponUse | null>(null)

function formatDiscount(u: CouponUse) {
  return u.coupon.discountKind === 'PERCENT'
    ? `${u.coupon.discountValue}%`
    : `฿${Number(u.coupon.discountValue).toFixed(0)}`
}

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric' })
}

function isExpired(u: CouponUse) {
  return u.coupon.expiredAt && new Date(u.coupon.expiredAt) < new Date()
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <div class="flex items-center gap-3">
      <NuxtLink to="/member/redeem" class="text-gray-400 hover:text-gray-600">
        <Icon name="mdi:chevron-left" class="w-6 h-6" />
      </NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">กระเป๋าคูปอง</h1>
    </div>

    <div v-if="loading" class="py-16 text-center text-gray-400">กำลังโหลด...</div>

    <template v-else>
      <!-- Available -->
      <div>
        <h2 class="font-semibold text-gray-700 mb-3">ใช้ได้ ({{ available.length }})</h2>

        <div v-if="available.length === 0" class="bg-white rounded-2xl shadow p-8 text-center text-gray-400">
          <Icon name="mdi:ticket-off" class="text-5xl mb-2" />
          <p class="text-sm">ยังไม่มีคูปอง</p>
          <NuxtLink to="/member/redeem" class="text-sm text-[#1B2B4B] font-medium hover:underline mt-2 inline-block">
            แลกแต้มได้เลย →
          </NuxtLink>
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="u in available"
            :key="u.id"
            class="bg-white rounded-2xl shadow overflow-hidden"
            :class="{ 'opacity-60': isExpired(u) }"
          >
            <!-- Coupon ticket style -->
            <div class="flex">
              <div class="bg-[#1B2B4B] text-white flex flex-col items-center justify-center px-4 py-5 min-w-[80px]">
                <p class="text-2xl font-bold">{{ formatDiscount(u) }}</p>
                <p class="text-xs text-white/70 mt-0.5">ส่วนลด</p>
              </div>
              <div class="flex-1 p-4">
                <p class="font-semibold text-gray-800">{{ u.coupon.name }}</p>
                <p v-if="u.coupon.description" class="text-xs text-gray-400 mt-0.5">{{ u.coupon.description }}</p>
                <div class="flex items-center justify-between mt-2">
                  <div>
                    <p class="text-xs font-mono font-bold text-[#2a3f6b] tracking-widest">{{ u.coupon.code }}</p>
                    <p v-if="u.coupon.expiredAt" class="text-xs mt-0.5"
                      :class="isExpired(u) ? 'text-red-500' : 'text-gray-400'">
                      {{ isExpired(u) ? 'หมดอายุแล้ว' : `หมดอายุ ${formatDate(u.coupon.expiredAt!)}` }}
                    </p>
                  </div>
                  <span v-if="isExpired(u)" class="text-xs text-red-500 font-medium">หมดอายุ</span>
                  <button
                    v-else
                    class="flex items-center gap-1 text-xs text-white font-medium bg-[#1B2B4B] px-3 py-1.5 rounded-lg hover:bg-[#2a3f6b] transition-colors"
                    @click="qrTarget = u"
                  >
                    <Icon name="mdi:qrcode" class="w-3.5 h-3.5" />
                    แสดง QR
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Used -->
      <div v-if="used.length > 0">
        <h2 class="font-semibold text-gray-400 mb-3 text-sm">ใช้แล้ว ({{ used.length }})</h2>
        <div class="space-y-2">
          <div
            v-for="u in used"
            :key="u.id"
            class="bg-gray-50 rounded-xl p-4 flex items-center justify-between opacity-60"
          >
            <div>
              <p class="text-sm font-medium text-gray-600">{{ u.coupon.name }}</p>
              <p class="text-xs font-mono text-gray-400">{{ u.coupon.code }}</p>
            </div>
            <div class="text-right">
              <p class="text-sm font-bold text-gray-500">{{ formatDiscount(u) }}</p>
              <p v-if="u.usedAt" class="text-xs text-gray-400">{{ formatDate(u.usedAt) }}</p>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>

  <!-- QR Modal -->
  <Teleport to="body">
    <div v-if="qrTarget" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="qrTarget = null" />
      <div class="relative bg-white rounded-2xl shadow-2xl p-6 w-full max-w-xs space-y-4">
        <div class="text-center">
          <p class="font-bold text-gray-900 text-lg">{{ qrTarget.coupon.name }}</p>
          <p class="text-2xl font-bold text-[#1B2B4B] mt-0.5">{{ formatDiscount(qrTarget) }} ส่วนลด</p>
        </div>
        <div class="flex justify-center">
          <div class="bg-white p-3 rounded-xl border-2 border-[#C8D8E8] shadow-sm">
            <img
              :src="`https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(qrTarget.id)}&margin=4`"
              :alt="`QR ${qrTarget.coupon.code}`"
              class="w-52 h-52"
            />
          </div>
        </div>
        <div class="text-center space-y-1">
          <p class="text-sm font-mono font-bold text-[#2a3f6b] tracking-widest">{{ qrTarget.coupon.code }}</p>
          <p class="text-xs text-gray-400">แสดง QR นี้ให้พนักงานสแกน</p>
        </div>
        <button
          class="w-full py-2.5 rounded-xl bg-gray-100 text-gray-700 text-sm font-medium hover:bg-gray-200"
          @click="qrTarget = null"
        >ปิด</button>
      </div>
    </div>
  </Teleport>
</template>
