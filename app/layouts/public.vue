<script setup lang="ts">
const { member, fetchMe } = useMemberAuth()
const scrolled = ref(false)

onMounted(async () => {
  await fetchMe()
  window.addEventListener('scroll', () => { scrolled.value = window.scrollY > 20 }, { passive: true })
})
</script>

<template>
  <div class="min-h-screen flex flex-col">
    <header
      class="sticky top-0 z-50 transition-all duration-300"
      :class="scrolled ? 'bg-white/95 backdrop-blur shadow-sm' : 'bg-transparent'"
    >
      <nav class="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
        <NuxtLink to="/" class="flex items-center gap-2.5">
          <img src="/logo.jpg" alt="Sibling Coffee" class="w-8 h-8 rounded-full object-cover" />
          <span class="font-bold text-[#1B2B4B] text-lg">Sibling Coffee</span>
        </NuxtLink>

        <div class="flex items-center gap-4 text-sm font-medium">
          <template v-if="member">
            <NuxtLink
              to="/member"
              class="flex items-center gap-1.5 px-4 py-2 bg-[#1B2B4B] text-white rounded-xl hover:bg-[#2a3f6b] transition-colors"
            >
              <Icon name="flat-color-icons:businessman" class="text-base" />
              <span>{{ member.name }}</span>
            </NuxtLink>
          </template>
          <template v-else>
            <NuxtLink to="/member/login" class="text-[#1B2B4B] hover:text-[#2a3f6b] transition-colors">
              เข้าสู่ระบบ
            </NuxtLink>
            <NuxtLink
              to="/member/register"
              class="px-4 py-2 bg-[#1B2B4B] text-white rounded-xl hover:bg-[#2a3f6b] transition-colors"
            >
              สมัครสมาชิก
            </NuxtLink>
          </template>
        </div>
      </nav>
    </header>

    <main class="flex-1">
      <slot />
    </main>
  </div>
</template>
