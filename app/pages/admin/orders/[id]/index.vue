<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const route = useRoute()
const id = route.params.id as string
const { showError } = useAlert()

const { data, error } = await useAsyncData(`admin-order-${id}`, () =>
  useHttpClient().get<{ data: any }>(API_ENDPOINTS.ADMIN.ORDERS.SHOW(id)),
)

if (error.value) {
  showError('Order not found')
  await navigateTo('/admin/orders')
}

const order = computed(() => data.value?.data ?? null)

const statusBadge: Record<string, string> = {
  PENDING: 'bg-yellow-100 text-yellow-700',
  PREPARING: 'bg-blue-100 text-blue-700',
  READY: 'bg-indigo-100 text-indigo-700',
  COMPLETED: 'bg-green-100 text-green-700',
  CANCELLED: 'bg-red-100 text-red-500',
}

const tierColor: Record<string, string> = {
  SILVER: 'bg-gray-100 text-gray-600',
  GOLD: 'bg-yellow-100 text-yellow-700',
  VIP: 'bg-purple-100 text-purple-700',
}

function formatDate(d: string) {
  return new Date(d).toLocaleString('th-TH', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function formatPrice(n: any) {
  return Number(n).toLocaleString('th-TH', { minimumFractionDigits: 2 })
}
</script>

<template>
  <div v-if="order" class="max-w-3xl">
    <!-- Back + Header -->
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/admin/orders" class="text-gray-400 hover:text-gray-600">← Back</NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">Order #{{ order.queueNo }}</h1>
      <span class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="statusBadge[order.status]">
        {{ order.status }}
      </span>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Order Info -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Items -->
        <div class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="font-semibold text-gray-900 mb-4">Items</h2>
          <div class="space-y-3">
            <div
              v-for="item in order.items"
              :key="item.id"
              class="flex justify-between gap-3 py-2 border-b border-gray-100 last:border-0"
            >
              <div class="flex-1">
                <p class="text-sm font-medium text-gray-900">
                  {{ item.product.name }}
                  <span class="text-gray-400 font-normal">x{{ item.quantity }}</span>
                </p>
                <p v-if="item.options.length" class="text-xs text-gray-400 mt-0.5">
                  {{ item.options.map((o: any) => o.name).join(', ') }}
                </p>
                <p v-if="item.note" class="text-xs text-orange-500 mt-0.5">{{ item.note }}</p>
              </div>
              <p class="text-sm font-semibold text-gray-900 whitespace-nowrap">฿{{ formatPrice(item.subtotal) }}</p>
            </div>
          </div>

          <!-- Totals -->
          <div class="mt-4 pt-4 border-t border-gray-100 space-y-1.5 text-sm">
            <div class="flex justify-between text-gray-500">
              <span>Subtotal</span><span>฿{{ formatPrice(order.subtotal) }}</span>
            </div>
            <div v-if="Number(order.discount) > 0" class="flex justify-between text-orange-500">
              <span>
                Discount
                <span v-if="order.discountBadge" class="text-xs">({{ order.discountBadge.name }})</span>
                <span v-else-if="order.discountKind" class="text-xs">
                  ({{ order.discountKind === 'PERCENT' ? `${order.discountValue}%` : `฿${order.discountValue}` }})
                </span>
              </span>
              <span>-฿{{ formatPrice(order.discount) }}</span>
            </div>
            <div v-if="order.pointsRedeemed > 0" class="flex justify-between text-purple-600">
              <span>Points Redeemed ({{ order.pointsRedeemed }} pts)</span>
              <span>-฿{{ formatPrice(order.pointsRedeemed) }}</span>
            </div>
            <div class="flex justify-between font-bold text-gray-900 text-base pt-1 border-t border-gray-100">
              <span>Total</span><span>฿{{ formatPrice(order.total) }}</span>
            </div>
          </div>
        </div>

        <!-- Note -->
        <div v-if="order.note" class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="font-semibold text-gray-900 mb-2">Note</h2>
          <p class="text-sm text-gray-600">{{ order.note }}</p>
        </div>
      </div>

      <!-- Side Info -->
      <div class="space-y-6">
        <!-- Payment -->
        <div class="bg-white rounded-xl shadow-sm p-6 space-y-2">
          <h2 class="font-semibold text-gray-900 mb-3">Payment</h2>
          <div v-if="order.payment" class="text-sm space-y-2">
            <div class="flex justify-between">
              <span class="text-gray-500">Method</span>
              <span class="font-medium text-gray-900">{{ order.payment.method }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-500">Amount</span>
              <span class="font-medium text-gray-900">฿{{ formatPrice(order.payment.amount) }}</span>
            </div>
            <div v-if="Number(order.payment.change) > 0" class="flex justify-between">
              <span class="text-gray-500">Change</span>
              <span class="font-medium text-green-600">฿{{ formatPrice(order.payment.change) }}</span>
            </div>
            <div v-if="order.payment.transactionRef" class="flex justify-between">
              <span class="text-gray-500">Ref</span>
              <span class="font-mono text-xs text-gray-600">{{ order.payment.transactionRef }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-500">Paid at</span>
              <span class="text-xs text-gray-600">{{ formatDate(order.payment.paidAt) }}</span>
            </div>
          </div>
          <p v-else class="text-sm text-gray-400">Not paid yet</p>
        </div>

        <!-- Member -->
        <div class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="font-semibold text-gray-900 mb-3">Member</h2>
          <div v-if="order.member" class="text-sm space-y-2">
            <div class="flex items-center gap-2">
              <span class="font-medium text-gray-900">{{ order.member.name }}</span>
              <span class="text-xs px-1.5 py-0.5 rounded-full font-medium" :class="tierColor[order.member.tier]">
                {{ order.member.tier }}
              </span>
            </div>
            <p v-if="order.member.phone" class="text-gray-500">{{ order.member.phone }}</p>
            <p v-if="order.member.email" class="text-gray-500 text-xs">{{ order.member.email }}</p>
            <div v-if="order.pointsEarned > 0" class="flex justify-between pt-1 border-t border-gray-100">
              <span class="text-gray-500">Points Earned</span>
              <span class="font-medium text-green-600">+{{ order.pointsEarned }}</span>
            </div>
            <div v-if="order.pointsRedeemed > 0" class="flex justify-between">
              <span class="text-gray-500">Points Redeemed</span>
              <span class="font-medium text-purple-600">-{{ order.pointsRedeemed }}</span>
            </div>
            <NuxtLink
              :to="`/admin/members/${order.member.id}`"
              class="block text-xs text-blue-600 hover:underline pt-1"
            >View member profile →</NuxtLink>
          </div>
          <p v-else class="text-sm text-gray-400">No member linked</p>
        </div>

        <!-- Cashier -->
        <div class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="font-semibold text-gray-900 mb-3">Info</h2>
          <div class="text-sm space-y-2">
            <div class="flex justify-between">
              <span class="text-gray-500">Cashier</span>
              <span class="text-gray-900">{{ order.user?.name ?? '—' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-500">Created</span>
              <span class="text-xs text-gray-600">{{ formatDate(order.createdAt) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
