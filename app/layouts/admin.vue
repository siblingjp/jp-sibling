<script setup lang="ts">
const { user, logout } = useAuth()

const navGroups = [
  {
    items: [
      { to: '/admin', label: 'ภาพรวม', icon: 'flat-color-icons:bar-chart', exact: true },
      { to: '/pos', label: 'POS', icon: 'flat-color-icons:calculator', exact: false },
    ],
  },
  {
    label: 'ร้านค้า',
    items: [
      { to: '/admin/orders', label: 'ออเดอร์', icon: 'flat-color-icons:list', exact: false },
      { to: '/admin/discounts', label: 'ส่วนลดที่บันทึกไว้', icon: 'flat-color-icons:sales-performance', exact: false },
      { to: '/admin/members', label: 'สมาชิก', icon: 'flat-color-icons:conference-call', exact: false },
      { to: '/admin/coupons', label: 'คูปอง', icon: 'mdi:ticket-percent', exact: false },
      { to: '/admin/campaigns', label: 'แคมเปญ', icon: 'flat-color-icons:advertising', exact: false },
      
      { to: '/admin/users', label: 'ผู้ใช้งาน', icon: 'flat-color-icons:businessman', exact: false },
    ],
  },
  {
    label: 'จัดการสินค้า',
    items: [
      { to: '/admin/categories', label: 'หมวดหมู่', icon: 'flat-color-icons:opened-folder', exact: false },
      { to: '/admin/products', label: 'สินค้า', icon: 'flat-color-icons:shop', exact: false },
      { to: '/admin/option-groups', label: 'ตัวเลือกสินค้า', icon: 'flat-color-icons:settings', exact: false },
    ],
  },
  {
    label: 'CMS',
    items: [
      
      { to: '/admin/location', label: 'ตำแหน่งรถ', icon: 'flat-color-icons:globe', exact: false },
    ],
  },
]

const route = useRoute()

function isActive(to: string, exact: boolean) {
  if (exact) return route.path === to
  return route.path === to || route.path.startsWith(to + '/')
}
</script>

<template>
  <div class="min-h-screen flex bg-gray-100">
    <!-- Sidebar -->
    <aside class="w-56 bg-white shadow-sm flex-shrink-0 flex flex-col">
      <div class="p-5 border-b">
        <p class="text-xs font-medium text-gray-400 uppercase tracking-widest mb-0.5">ระบบหลังบ้าน</p>
        <h1 class="text-base font-bold text-gray-900">Sibling Coffee</h1>
      </div>

      <nav class="flex-1 p-3 overflow-y-auto space-y-4">
        <div v-for="(group, gi) in navGroups" :key="gi">
          <p v-if="group.label" class="px-3 mb-1 text-xs font-semibold text-gray-400 uppercase tracking-wider">
            {{ group.label }}
          </p>
          <div class="space-y-0.5">
            <NuxtLink
              v-for="item in group.items"
              :key="item.to"
              :to="item.to"
              class="flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm transition-colors"
              :class="isActive(item.to, item.exact)
                ? 'bg-blue-50 text-blue-700 font-medium'
                : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'"
            >
              <Icon :name="item.icon" class="text-lg flex-shrink-0" />
              <span>{{ item.label }}</span>
            </NuxtLink>
          </div>
        </div>
      </nav>

      <div class="p-4 border-t">
        <p class="text-xs text-gray-500 truncate mb-2">{{ user?.name }}</p>
        <button
          class="w-full text-left text-sm text-red-500 hover:text-red-700 transition-colors"
          @click="logout"
        >
          ออกจากระบบ
        </button>
      </div>
    </aside>

    <!-- Main -->
    <div class="flex-1 flex flex-col min-w-0">
      <main class="flex-1 overflow-auto p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
