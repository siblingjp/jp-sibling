<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useCategoriesStore()
const { showSuccess, showError } = useAlert()

const form = reactive({
  name: '',
  slug: '',
  imageUrl: '',
  isActive: true,
})

const isLoading = computed(() => store.formState.isLoading)

// Auto-generate slug from name
watch(() => form.name, (val) => {
  form.slug = val.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')
})

async function handleSubmit() {
  try {
    await store.create({
      name: form.name,
      slug: form.slug,
      imageUrl: form.imageUrl || undefined,
      isActive: form.isActive,
    })
    showSuccess('Category created')
    await navigateTo('/admin/categories')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to create')
  }
}
</script>

<template>
  <div class="max-w-xl">
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/admin/categories" class="text-gray-400 hover:text-gray-600">
        ← Back
      </NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">New Category</h1>
    </div>

    <form class="bg-white rounded-xl shadow-sm p-6 space-y-5" @submit.prevent="handleSubmit">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Name <span class="text-red-500">*</span></label>
        <input
          v-model="form.name"
          type="text"
          required
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          placeholder="e.g. Beverages"
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
          placeholder="e.g. beverages"
        />
        <p class="text-xs text-gray-400 mt-1">Lowercase letters, numbers, and hyphens only</p>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Image URL</label>
        <input
          v-model="form.imageUrl"
          type="url"
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          placeholder="https://..."
        />
      </div>

      <div class="flex items-center gap-3">
        <input id="isActive" v-model="form.isActive" type="checkbox" class="rounded" />
        <label for="isActive" class="text-sm text-gray-700">Active</label>
      </div>

      <div class="flex gap-3 pt-2">
        <button
          type="submit"
          :disabled="isLoading"
          class="bg-blue-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors disabled:opacity-50"
        >
          {{ isLoading ? 'Saving...' : 'Create Category' }}
        </button>
        <NuxtLink
          to="/admin/categories"
          class="px-5 py-2 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-100 transition-colors"
        >
          Cancel
        </NuxtLink>
      </div>
    </form>
  </div>
</template>
