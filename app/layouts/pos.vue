<script setup lang="ts">
const { user } = useAuth()
</script>

<template>
  <div class="h-screen bg-gray-50 flex flex-col overflow-hidden">
    <header class="bg-white border-b border-gray-200 px-6 py-3 flex items-center justify-between flex-shrink-0">
      <div class="flex items-center gap-6">
        <h1 class="text-base font-bold text-gray-900">POS</h1>
        <nav class="flex gap-1">
          <NuxtLink
            to="/pos"
            class="px-3 py-1.5 rounded-lg text-sm font-medium transition-colors"
            :class="$route.path === '/pos' ? 'bg-blue-600 text-white' : 'text-gray-600 hover:bg-gray-100'"
          >สั่งสินค้า</NuxtLink>
          <NuxtLink
            to="/pos/orders"
            class="px-3 py-1.5 rounded-lg text-sm font-medium transition-colors"
            :class="$route.path === '/pos/orders' ? 'bg-blue-600 text-white' : 'text-gray-600 hover:bg-gray-100'"
          >คิวออเดอร์</NuxtLink>
        </nav>
      </div>
      <div class="flex items-center gap-4 text-sm text-gray-500">
        <span>{{ user?.name }}</span>
        <NuxtLink to="/admin" class="hover:text-gray-900 transition-colors">ระบบหลังบ้าน</NuxtLink>
      </div>
    </header>
    <main class="flex-1 overflow-hidden">
      <slot />
    </main>
  </div>
</template>
