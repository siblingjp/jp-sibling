<script setup lang="ts">
import type { CartItem, PosDiscount, PosMember, PosCoupon } from '~/stores/pos'

const props = defineProps<{
  cart: readonly CartItem[]
  member: PosMember | null
  discountMode: 'badge' | 'percent' | 'amount' | null
  discountBadge: PosDiscount | null
  discountPercent: number
  discountAmount: number
  discountCalc: number
  appliedCoupon: PosCoupon | null
  couponDiscount: number
  pointsToRedeem: number
  pointsRedeemCapped: number
  maxRedeemable: number
  subtotal: number
  total: number
  discounts: readonly PosDiscount[]
  isSubmitting: boolean
  pickupTime: string
  orderNote: string
  editMode?: boolean
}>()

const emit = defineEmits<{
  removeItem: [cartId: string]
  editItem: [cartId: string]
  lookupMember: []
  clearMember: []
  applyBadge: [badge: PosDiscount]
  setPercent: [v: number]
  setAmount: [v: number]
  clearDiscount: []
  applyCoupon: [code: string]
  clearCoupon: []
  updatePointsRedeem: [v: number]
  checkout: []
  checkoutUnpaid: []
  changePayment: []
  badgeCreated: [badge: any]
  scanCoupon: []
  scanMember: []
  updatePickupTime: [v: string]
  resetPickupTime: []
  updateOrderNote: [v: string]
}>()

// pickup time options: ทุก 10 นาที ล่วงหน้าสูงสุด 16 ชั่วโมง
const pickupOptions = computed(() => {
  const TZ = 'Asia/Bangkok'
  const now = new Date()
  const options: { value: string; label: string }[] = []
  const startMs = Math.ceil(now.getTime() / (10 * 60 * 1000)) * 10 * 60 * 1000
  const endMs = now.getTime() + 16 * 60 * 60 * 1000
  const todayDate = new Intl.DateTimeFormat('en-CA', { timeZone: TZ }).format(now)
  for (let ms = startMs; ms <= endMs; ms += 10 * 60 * 1000) {
    const t = new Date(ms)
    const tDate = new Intl.DateTimeFormat('en-CA', { timeZone: TZ }).format(t)
    const timeStr = new Intl.DateTimeFormat('th-TH', { hour: '2-digit', minute: '2-digit', timeZone: TZ, hour12: false }).format(t)
    const dateLabel = new Intl.DateTimeFormat('th-TH', { day: 'numeric', month: 'short', timeZone: TZ }).format(t)
    const label = tDate !== todayDate ? `${dateLabel} ${timeStr} น.` : `${timeStr} น.`
    options.push({ value: `${tDate} ${timeStr}`, label })
  }
  // ถ้า pickupTime ที่ restore มาไม่อยู่ใน options (step ต่างกัน) ให้เพิ่มเข้าไป
  if (props.pickupTime && !options.find(o => o.value === props.pickupTime)) {
    const [datePart, timePart] = props.pickupTime.split(' ')
    if (datePart && timePart) {
      const d = new Date(`${datePart}T${timePart}:00+07:00`)
      const tDate = new Intl.DateTimeFormat('en-CA', { timeZone: TZ }).format(d)
      const dateLabel = new Intl.DateTimeFormat('th-TH', { day: 'numeric', month: 'short', timeZone: TZ }).format(d)
      const label = tDate !== todayDate ? `${dateLabel} ${timePart} น.` : `${timePart} น.`
      options.unshift({ value: props.pickupTime, label })
    }
  }
  return options
})

const discountInput = ref(0)
const discountName = ref('')
const showDiscountPanel = ref(false)
const discountTab = ref<'badge' | 'percent' | 'amount' | 'coupon'>('badge')
const isSavingBadge = ref(false)
const saveAsBadge = ref(false)

const couponInput = ref('')
const couponLoading = ref(false)

async function handleApplyCoupon() {
  if (!couponInput.value.trim()) return
  couponLoading.value = true
  try {
    emit('applyCoupon', couponInput.value.trim())
    couponInput.value = ''
    showDiscountPanel.value = false
  } finally {
    couponLoading.value = false
  }
}

async function handleApplyPercent() {
  if (saveAsBadge.value && discountName.value.trim()) await createBadge('PERCENT', discountInput.value)
  emit('setPercent', discountInput.value)
  showDiscountPanel.value = false
  saveAsBadge.value = false
  discountName.value = ''
}

async function handleApplyAmount() {
  if (saveAsBadge.value && discountName.value.trim()) await createBadge('AMOUNT', discountInput.value)
  emit('setAmount', discountInput.value)
  showDiscountPanel.value = false
  saveAsBadge.value = false
  discountName.value = ''
}

async function createBadge(kind: 'PERCENT' | 'AMOUNT', value: number) {
  isSavingBadge.value = true
  try {
    const res = await useHttpClient().post<{ data: any }>(API_ENDPOINTS.ADMIN.DISCOUNTS.CREATE, {
      name: discountName.value.trim(),
      kind,
      value,
      isActive: true,
    })
    emit('badgeCreated', res.data)
  } catch {
    // silent fail — discount ยังใช้ได้แม้บันทึก badge ไม่สำเร็จ
  } finally {
    isSavingBadge.value = false
  }
}

</script>

<template>
  <div class="overflow-y-auto bg-white border-l border-gray-200 px-4 py-3 space-y-2">
    <!-- Header -->
    <div class="flex items-center justify-between pt-1 pb-2 border-b border-gray-100">
      <h2 class="font-semibold text-gray-900">ตะกร้า</h2>
      <span class="text-xs text-gray-400">{{ cart.length }} รายการ</span>
    </div>

    <div class="space-y-2">
      <div v-if="cart.length === 0" class="text-center py-12 text-gray-300 text-sm">
        ยังไม่มีรายการ
      </div>
      <div
        v-for="item in cart"
        :key="item.cartId"
        class="flex gap-2 p-2.5 rounded-lg bg-gray-50 group"
      >
        <div class="flex-1 min-w-0">
          <div class="flex items-start justify-between gap-1">
            <p class="text-sm font-medium text-gray-900 leading-tight">{{ item.productName }}</p>
            <p class="text-sm font-semibold text-gray-900 whitespace-nowrap">฿{{ item.subtotal.toFixed(0) }}</p>
          </div>
          <p v-if="item.options.length" class="text-xs text-gray-400 mt-0.5">
            {{ item.options.map(o => o.name).join(', ') }}
          </p>
          <p v-if="item.note" class="text-xs text-orange-500 mt-0.5">{{ item.note }}</p>
          <div class="flex items-center gap-3 mt-1.5">
            <span class="text-xs text-gray-400">x{{ item.quantity }}</span>
            <button class="text-xs text-blue-500 hover:text-blue-700" @click="emit('editItem', item.cartId)">แก้ไข</button>
            <button class="text-xs text-red-400 hover:text-red-600" @click="emit('removeItem', item.cartId)">ลบ</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Bottom Panel -->
    <div class="border-t border-gray-100 px-4 py-3 space-y-3">
      <!-- Member -->
      <div>
        <div v-if="member" class="flex items-center gap-2 p-2.5 rounded-lg bg-blue-50 border border-blue-200">
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-1.5">
              <p class="text-sm font-medium text-gray-900 truncate">{{ member.name }}</p>
              <span class="inline-flex items-center gap-0.5 text-xs px-1.5 py-0.5 rounded-full font-medium"
                :class="[useTier(member.tier).badgeBg, useTier(member.tier).badgeText]">
                <Icon :name="useTier(member.tier).icon" class="w-3 h-3" :class="useTier(member.tier).iconColor" />
                {{ useTier(member.tier).label }}
              </span>
            </div>
            <p class="text-xs text-gray-500">{{ member.points.toLocaleString() }} pts</p>
          </div>
          <button class="text-gray-400 hover:text-red-500 text-lg" @click="emit('clearMember')">×</button>
        </div>
        <button
          v-else
          class="w-full py-2 rounded-lg border border-dashed border-gray-300 text-sm text-gray-400 hover:text-gray-600 hover:border-gray-400 transition-colors"
          @click="emit('lookupMember')"
        >
          + ค้นหาสมาชิก
        </button>
      </div>

      <!-- Point Redeem -->
      <div v-if="member && member.points > 0">
        <div class="flex items-center justify-between mb-1">
          <span class="text-xs text-gray-500">แลกแต้ม (สูงสุด {{ maxRedeemable }})</span>
          <span class="text-xs font-medium text-purple-600">-฿{{ pointsRedeemCapped.toFixed(0) }}</span>
        </div>
        <input
          :value="pointsToRedeem"
          type="range"
          :min="0"
          :max="Math.min(member.points, maxRedeemable)"
          step="1"
          class="w-full accent-purple-600"
          @input="emit('updatePointsRedeem', Number(($event.target as HTMLInputElement).value))"
        />
        <div class="flex justify-between text-xs text-gray-400">
          <span>0</span>
          <span>ใช้ {{ pointsRedeemCapped }} แต้ม</span>
          <span>{{ Math.min(member.points, maxRedeemable) }}</span>
        </div>
      </div>

      <!-- Discount / Coupon -->
      <div>
        <!-- Active: discount -->
        <div v-if="discountMode" class="flex items-center justify-between p-2.5 rounded-lg bg-orange-50 border border-orange-200">
          <div>
            <p class="text-xs font-medium text-orange-700">
              {{ discountMode === 'badge' ? discountBadge?.name : discountMode === 'percent' ? `${discountPercent}% off` : `฿${discountAmount} off` }}
            </p>
            <p class="text-xs text-orange-500">-฿{{ discountCalc.toFixed(2) }}</p>
          </div>
          <button class="text-gray-400 hover:text-red-500 text-lg" @click="emit('clearDiscount')">×</button>
        </div>
        <!-- Active: coupon -->
        <div v-else-if="appliedCoupon" class="flex items-center justify-between p-2.5 rounded-lg bg-green-50 border border-green-200">
          <div>
            <p class="text-xs font-bold text-green-700 font-mono">{{ appliedCoupon.code }}</p>
            <p class="text-xs text-green-600">{{ appliedCoupon.name }} · -฿{{ couponDiscount.toFixed(2) }}</p>
          </div>
          <button class="text-gray-400 hover:text-red-500 text-lg" @click="emit('clearCoupon')">×</button>
        </div>
        <!-- Toggle button -->
        <button
          v-else
          class="w-full py-2 rounded-lg border border-dashed border-gray-300 text-sm text-gray-400 hover:text-gray-600 hover:border-gray-400 transition-colors"
          @click="showDiscountPanel = !showDiscountPanel"
        >
          + ส่วนลด / คูปอง
        </button>

        <!-- Panel -->
        <div v-if="showDiscountPanel && !discountMode && !appliedCoupon" class="mt-2 p-3 rounded-lg border border-gray-200 bg-gray-50 space-y-3">
          <div class="flex gap-1">
            <button
              v-for="tab in (['badge','percent','amount','coupon'] as const)"
              :key="tab"
              type="button"
              class="flex-1 py-1.5 rounded text-xs font-medium transition-colors"
              :class="discountTab === tab ? 'bg-white shadow text-gray-900' : 'text-gray-500 hover:text-gray-700'"
              @click="discountTab = tab"
            >{{ tab === 'badge' ? 'บันทึกไว้' : tab === 'percent' ? '%' : tab === 'amount' ? '฿' : 'คูปอง' }}</button>
          </div>

          <!-- Badge -->
          <div v-if="discountTab === 'badge'" class="space-y-1.5">
            <button
              v-for="d in discounts"
              :key="d.id"
              type="button"
              class="w-full flex justify-between items-center px-3 py-2 rounded-lg bg-white border border-gray-200 hover:border-blue-300 text-sm transition-colors"
              @click="emit('applyBadge', d); showDiscountPanel = false"
            >
              <span>{{ d.name }}</span>
              <span class="text-xs text-gray-500">{{ d.kind === 'PERCENT' ? `${d.value}%` : `฿${d.value}` }}</span>
            </button>
            <p v-if="!discounts.length" class="text-xs text-gray-400 text-center py-2">ไม่มีส่วนลดที่บันทึกไว้</p>
          </div>

          <!-- Percent -->
          <div v-if="discountTab === 'percent'" class="space-y-2">
            <div class="flex gap-2">
              <input
                v-model.number="discountInput"
                type="number" min="0" max="100" step="1"
                class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="0"
              />
              <button class="px-3 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700" @click="handleApplyPercent">ใช้</button>
            </div>
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="saveAsBadge" type="checkbox" class="rounded" />
              <span class="text-xs text-gray-500">บันทึกไว้</span>
            </label>
            <input
              v-if="saveAsBadge"
              v-model="discountName"
              type="text"
              placeholder="ชื่อ..."
              class="w-full px-3 py-1.5 border border-gray-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <!-- Amount -->
          <div v-if="discountTab === 'amount'" class="space-y-2">
            <div class="flex gap-2">
              <input
                v-model.number="discountInput"
                type="number" min="0" step="1"
                class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="0"
              />
              <button class="px-3 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700" @click="handleApplyAmount">ใช้</button>
            </div>
            <label class="flex items-center gap-2 cursor-pointer">
              <input v-model="saveAsBadge" type="checkbox" class="rounded" />
              <span class="text-xs text-gray-500">บันทึกไว้</span>
            </label>
            <input
              v-if="saveAsBadge"
              v-model="discountName"
              type="text"
              placeholder="ชื่อ..."
              class="w-full px-3 py-1.5 border border-gray-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <!-- Coupon -->
          <div v-if="discountTab === 'coupon'" class="flex gap-2">
            <input
              v-model="couponInput"
              type="text"
              placeholder="รหัสคูปอง..."
              class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-green-400 uppercase"
              @keyup.enter="handleApplyCoupon"
            />
            <button
              type="button"
              class="px-2.5 py-2 border border-gray-300 rounded-lg text-gray-500 hover:bg-gray-50"
              title="สแกน QR"
              @click="emit('scanCoupon')"
            >
              <Icon name="mdi:qrcode-scan" class="text-base" />
            </button>
            <button
              :disabled="!couponInput.trim() || couponLoading || cart.length === 0"
              class="px-3 py-2 bg-green-600 text-white rounded-lg text-xs font-medium hover:bg-green-700 disabled:opacity-40"
              @click="handleApplyCoupon"
            >ใช้</button>
          </div>
        </div>
      </div>

      <!-- Summary -->
      <div class="space-y-1 text-sm">
        <div class="flex justify-between text-gray-500">
          <span>ยอดรวม</span><span>฿{{ subtotal.toFixed(2) }}</span>
        </div>
        <div v-if="discountCalc > 0" class="flex justify-between text-orange-500">
          <span>ส่วนลด</span><span>-฿{{ discountCalc.toFixed(2) }}</span>
        </div>
        <div v-if="couponDiscount > 0" class="flex justify-between text-green-600">
          <span>คูปอง</span><span>-฿{{ couponDiscount.toFixed(2) }}</span>
        </div>
        <div v-if="pointsRedeemCapped > 0" class="flex justify-between text-purple-600">
          <span>แลกแต้ม</span><span>-฿{{ pointsRedeemCapped.toFixed(2) }}</span>
        </div>
        <div class="flex justify-between font-bold text-gray-900 text-base pt-1 border-t border-gray-100">
          <span>รวมทั้งหมด</span><span>฿{{ total.toFixed(2) }}</span>
        </div>
      </div>

      <!-- Order Note -->
      <div>
        <label class="text-xs text-gray-500 block mb-1">หมายเหตุ (ไม่บังคับ)</label>
        <input
          :value="orderNote"
          type="text"
          placeholder="เช่น ไม่เอาน้ำแข็ง..."
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          @input="emit('updateOrderNote', ($event.target as HTMLInputElement).value)"
        />
      </div>

      <!-- Pickup Time -->
      <div>
        <div class="flex items-center justify-between mb-1">
          <label class="text-xs text-gray-500">เวลารับ (ไม่บังคับ)</label>
          <button type="button" class="text-gray-400 hover:text-blue-500 transition-colors" title="รีเซ็ตเวลา" @click="emit('resetPickupTime')">
            <Icon name="mdi:refresh" class="text-base" />
          </button>
        </div>
        <select
          :value="pickupTime"
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          @change="emit('updatePickupTime', ($event.target as HTMLSelectElement).value)"
        >
          <option value="">เลือกเวลารับ...</option>
          <option v-for="opt in pickupOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
        </select>
      </div>

      <!-- Checkout Buttons -->
      <div class="flex gap-2 pt-1 pb-8">
        <button
          v-if="!editMode"
          type="button"
          class="flex-1 py-3.5 rounded-xl font-semibold text-white transition-colors"
          :class="cart.length > 0 && !isSubmitting ? 'bg-orange-500 hover:bg-orange-600' : 'bg-gray-300 cursor-not-allowed'"
          :disabled="cart.length === 0 || isSubmitting"
          @click="emit('checkoutUnpaid')"
        >
          ยังไม่จ่าย
        </button>
        <button
          v-if="editMode"
          type="button"
          class="flex-shrink-0 px-3 py-3.5 rounded-xl font-semibold transition-colors border border-gray-300 text-gray-600 hover:bg-gray-100 text-sm"
          :disabled="isSubmitting"
          @click="emit('changePayment')"
        >
          💳 ชำระ
        </button>
        <button
          type="button"
          class="flex-1 py-3.5 rounded-xl font-semibold text-white transition-colors"
          :class="cart.length > 0 && !isSubmitting ? 'bg-blue-600 hover:bg-blue-700' : 'bg-gray-300 cursor-not-allowed'"
          :disabled="cart.length === 0 || isSubmitting"
          @click="emit('checkout')"
        >
          {{ editMode ? '💾 บันทึก' : 'ชำระเงิน →' }}
        </button>
      </div>
    </div>
  </div>
</template>
