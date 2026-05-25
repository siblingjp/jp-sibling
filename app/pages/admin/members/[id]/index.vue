<script setup lang="ts">
import type { AdminMemberDetail } from '~/stores/members'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const route = useRoute()
const id = route.params.id as string

const store = useMembersStore()
const { showError } = useAlert()

const { data, error } = await useAsyncData(`member-detail-${id}`, () =>
  useHttpClient().get<{ data: AdminMemberDetail }>(API_ENDPOINTS.ADMIN.MEMBERS.SHOW(id)),
)

if (error.value) {
  showError('Member not found')
  await navigateTo('/admin/members')
}

const member = computed(() => data.value?.data ?? null)

const actionBadge: Record<string, string> = {
  EARN: 'bg-green-100 text-green-700',
  REDEEM: 'bg-orange-100 text-orange-700',
  ADJUST: 'bg-gray-100 text-gray-600',
}

const statusBadge: Record<string, string> = {
  PENDING: 'bg-yellow-100 text-yellow-700',
  CONFIRMED: 'bg-blue-100 text-blue-700',
  PREPARING: 'bg-purple-100 text-purple-700',
  READY: 'bg-indigo-100 text-indigo-700',
  COMPLETED: 'bg-green-100 text-green-700',
  CANCELLED: 'bg-red-100 text-red-700',
}

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { day: '2-digit', month: 'short', year: 'numeric' })
}

function formatPrice(n: number) {
  return new Intl.NumberFormat('th-TH', { style: 'currency', currency: 'THB' }).format(n)
}
</script>

<template>
  <div v-if="member">
    <!-- Back + Header -->
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/admin/members" class="text-gray-400 hover:text-gray-600">← Back</NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">{{ member.name }}</h1>
      <span
        class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
        :class="member.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
      >
        {{ member.isActive ? 'Active' : 'Inactive' }}
      </span>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Profile Card -->
      <div class="bg-white rounded-xl shadow-sm p-6 space-y-4">
        <h2 class="font-semibold text-gray-900">Profile</h2>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-gray-500">Email</span>
            <span class="text-gray-900">{{ member.email }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-500">Phone</span>
            <span class="text-gray-900">{{ member.phone ?? '-' }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-500">Joined</span>
            <span class="text-gray-900">{{ formatDate(member.createdAt) }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-500">Total Orders</span>
            <span class="font-medium text-gray-900">{{ member._count?.orders ?? 0 }}</span>
          </div>
        </div>

        <!-- Points Badge -->
        <div class="bg-blue-50 rounded-lg p-4 text-center">
          <p class="text-xs text-blue-500 mb-1">Points Balance</p>
          <p class="text-3xl font-bold text-blue-600">{{ member.points.toLocaleString() }}</p>
        </div>
      </div>

      <!-- Orders -->
      <div class="bg-white rounded-xl shadow-sm p-6 lg:col-span-2">
        <h2 class="font-semibold text-gray-900 mb-4">Recent Orders</h2>
        <div v-if="member.orders.length === 0" class="text-center py-8 text-gray-400 text-sm">
          No orders yet
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50">
            <tr>
              <th class="text-left px-3 py-2 font-medium text-gray-600">Order ID</th>
              <th class="text-center px-3 py-2 font-medium text-gray-600">Status</th>
              <th class="text-right px-3 py-2 font-medium text-gray-600">Total</th>
              <th class="text-right px-3 py-2 font-medium text-gray-600">Date</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="order in member.orders"
              :key="order.id"
              class="border-t border-gray-100"
            >
              <td class="px-3 py-2 font-mono text-xs text-gray-500">{{ order.id.slice(-8) }}</td>
              <td class="px-3 py-2 text-center">
                <span class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="statusBadge[order.status]">
                  {{ order.status }}
                </span>
              </td>
              <td class="px-3 py-2 text-right font-medium">{{ formatPrice(Number(order.total)) }}</td>
              <td class="px-3 py-2 text-right text-gray-500">{{ formatDate(order.createdAt) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Point History -->
      <div class="bg-white rounded-xl shadow-sm p-6 lg:col-span-3">
        <h2 class="font-semibold text-gray-900 mb-4">Point History</h2>
        <div v-if="member.pointLogs.length === 0" class="text-center py-8 text-gray-400 text-sm">
          No point activity
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50">
            <tr>
              <th class="text-left px-3 py-2 font-medium text-gray-600">Action</th>
              <th class="text-left px-3 py-2 font-medium text-gray-600">Note</th>
              <th class="text-right px-3 py-2 font-medium text-gray-600">Points</th>
              <th class="text-right px-3 py-2 font-medium text-gray-600">Date</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="log in member.pointLogs"
              :key="log.id"
              class="border-t border-gray-100"
            >
              <td class="px-3 py-2">
                <span class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="actionBadge[log.action]">
                  {{ log.action }}
                </span>
              </td>
              <td class="px-3 py-2 text-gray-500">{{ log.note ?? '-' }}</td>
              <td class="px-3 py-2 text-right font-medium" :class="log.action === 'EARN' ? 'text-green-600' : 'text-red-500'">
                {{ log.action === 'EARN' ? '+' : '-' }}{{ Math.abs(log.amount) }}
              </td>
              <td class="px-3 py-2 text-right text-gray-500">{{ formatDate(log.createdAt) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
