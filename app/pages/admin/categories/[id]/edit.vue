<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const route = useRoute()
const id = route.params.id as string

const store = useCategoriesStore()
const { showSuccess, showError } = useAlert()

const form = reactive({
  name: '',
  slug: '',
  imageUrl: '',
  isActive: true,
})

const isLoading = computed(() => store.formState.isLoading)

// Load existing data
onMounted(async () => {
  try {
    const res = await useHttpClient().get<{ data: { name: string; slug: string; imageUrl: string | null; isActive: boolean } }>(
      `/api/admin/categories/${id}`,
    )
    const cat = res.data
    form.name = cat.name
    form.slug = cat.slug
    form.imageUrl = cat.imageUrl ?? ''
    form.isActive = cat.isActive
  } catch {
    showError('Category not found')
    navigateTo('/admin/categories')
  }
})

async function handleSubmit() {
  try {
    await store.update(id, {
      name: form.name,
      slug: form.slug,
      imageUrl: form.imageUrl || undefined,
      isActive: form.isActive,
    })
    showSuccess('Category updated')
    await navigateTo('/admin/categories')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to update')
  }
}
</script>

<template>
  <div class="max-w-xl">
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/admin/categories" class="text-gray-400 hover:text-gray-600">
        ← กลับ
      </NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">แก้ไขหมวดหมู่</h1>
    </div>

    <form class="bg-white rounded-xl shadow-sm p-6 space-y-5" @submit.prevent="handleSubmit">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อหมวดหมู่ <span class="text-red-500">*</span></label>
        <input
          v-model="form.name"
          type="text"
          required
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Slug <span class="text-red-500">*</span></label>

        <input
          v-model="form.slug"
          type="text"
          required
          pattern="[a-z0-9-]+"
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-mono focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">URL รูปภาพ</label>
        <input
          v-model="form.imageUrl"
          type="url"
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          placeholder="https://..."
        />
      </div>

      <div class="flex items-center gap-3">
        <input id="isActive" v-model="form.isActive" type="checkbox" class="rounded" />
        <label for="isActive" class="text-sm text-gray-700">เปิดใช้งาน</label>
      </div>

      <div class="flex gap-3 pt-2">
        <button
          type="submit"
          :disabled="isLoading"
          class="bg-blue-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors disabled:opacity-50"
        >
          {{ isLoading ? 'กำลังบันทึก...' : 'บันทึกการเปลี่ยนแปลง' }}
        </button>
        <NuxtLink
          to="/admin/categories"
          class="px-5 py-2 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-100 transition-colors"
        >
          ยกเลิก
        </NuxtLink>
      </div>
    </form>
  </div>
</template>
