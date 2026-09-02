<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useProductsStore()
const { showSuccess, showError } = useAlert()

const form = reactive({
  name: '',
  slug: '',
  description: '',
  price: 0,
  imageUrl: '',
  categoryId: '',
  isActive: true,
  isStampEligible: true,
  optionGroupIds: [] as string[],
})

const isLoading = computed(() => store.formState.isLoading)

const [categoriesRes, optionGroupsRes] = await Promise.all([
  useAsyncData('product-form-categories', () =>
    useHttpClient().get<{ data: { id: string; name: string }[] }>('/api/admin/categories?pagination[limit]=100&filter[isActive]=true'),
  ),
  useAsyncData('product-form-option-groups', () =>
    useHttpClient().get<{ data: OptionGroup[] }>(API_ENDPOINTS.ADMIN.OPTION_GROUPS.LIST),
  ),
])

const categories = computed(() => categoriesRes.data.value?.data ?? [])
const optionGroups = computed(() => optionGroupsRes.data.value?.data ?? [])

watch(() => form.name, (val) => {
  form.slug = val.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')
})

async function handleSubmit() {
  try {
    await store.create({
      name: form.name,
      slug: form.slug,
      description: form.description || undefined,
      price: Number(form.price),
      imageUrl: form.imageUrl || undefined,
      categoryId: form.categoryId,
      isActive: form.isActive,
      isStampEligible: form.isStampEligible,
      optionGroupIds: form.optionGroupIds,
    })
    showSuccess('Product created')
    await navigateTo('/admin/products')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to create')
  }
}
</script>

<template>
  <div class="max-w-xl">
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/admin/products" class="text-gray-400 hover:text-gray-600">← กลับ</NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">สินค้าใหม่</h1>
    </div>

    <form class="space-y-5" @submit.prevent="handleSubmit">
      <div class="bg-white rounded-xl shadow-sm p-6 space-y-5">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อสินค้า <span class="text-red-500">*</span></label>
          <input v-model="form.name" type="text" required class="input" placeholder="e.g. Americano" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Slug <span class="text-red-500">*</span></label>
          <input v-model="form.slug" type="text" required pattern="[a-z0-9-]+" class="input font-mono" placeholder="e.g. americano" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">หมวดหมู่ <span class="text-red-500">*</span></label>
          <select v-model="form.categoryId" required class="input">
            <option value="" disabled>เลือกหมวดหมู่</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">ราคา (บาท) <span class="text-red-500">*</span></label>
          <input v-model.number="form.price" type="number" required min="0" step="0.01" class="input" placeholder="0.00" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">รายละเอียด</label>
          <textarea v-model="form.description" rows="3" class="input resize-none" placeholder="รายละเอียดเพิ่มเติม (ไม่บังคับ)" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">รูปภาพ</label>
          <AdminImageUpload v-model="form.imageUrl" folder="products" />
        </div>

        <div class="flex items-center gap-3">
          <input id="isActive" v-model="form.isActive" type="checkbox" class="rounded" />
          <label for="isActive" class="text-sm text-gray-700">เปิดใช้งาน</label>
        </div>

        <div class="flex items-center gap-3">
          <input id="isStampEligible" v-model="form.isStampEligible" type="checkbox" class="rounded" />
          <label for="isStampEligible" class="text-sm text-gray-700">นับแสตมป์ได้ (สำหรับระบบสะสมแสตมป์)</label>
        </div>
      </div>

      <!-- Option Groups -->
      <div class="bg-white rounded-xl shadow-sm p-6">
        <div class="flex items-center justify-between mb-3">
          <h2 class="font-semibold text-gray-900">กลุ่มตัวเลือก</h2>
          <NuxtLink to="/admin/option-groups/new" target="_blank" class="text-xs text-blue-600 hover:underline">
            + สร้างกลุ่มใหม่
          </NuxtLink>
        </div>
        <AdminOptionGroupPicker v-model="form.optionGroupIds" :options="optionGroups" />
      </div>

      <div class="flex gap-3 pt-2">
        <button type="submit" :disabled="isLoading" class="btn-primary">
          {{ isLoading ? 'กำลังบันทึก...' : 'สร้างสินค้า' }}
        </button>
        <NuxtLink to="/admin/products" class="btn-ghost">ยกเลิก</NuxtLink>
      </div>
    </form>
  </div>
</template>

<style scoped>
.input {
  @apply w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500;
}
.btn-primary {
  @apply bg-blue-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors disabled:opacity-50;
}
.btn-ghost {
  @apply px-5 py-2 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-100 transition-colors;
}
</style>
