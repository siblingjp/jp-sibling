<script setup lang="ts">
const props = defineProps<{
  modelValue: string
  folder?: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const { uploadViaPresign } = useUpload()
const { showError } = useAlert()

const isUploading = ref(false)
const dragOver = ref(false)
const fileInput = ref<HTMLInputElement | null>(null)

const preview = computed(() => props.modelValue || null)

async function handleFile(file: File) {
  if (!file.type.startsWith('image/')) {
    showError('เฉพาะไฟล์รูปภาพเท่านั้น')
    return
  }
  isUploading.value = true
  try {
    const result = await uploadViaPresign(file, { folder: props.folder ?? 'products' })
    emit('update:modelValue', result.publicUrl)
  } catch {
    showError('อัปโหลดรูปภาพไม่สำเร็จ')
  } finally {
    isUploading.value = false
  }
}

function onFileChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) handleFile(file)
}

function onDrop(e: DragEvent) {
  dragOver.value = false
  const file = e.dataTransfer?.files?.[0]
  if (file) handleFile(file)
}

function clearImage() {
  emit('update:modelValue', '')
  if (fileInput.value) fileInput.value.value = ''
}
</script>

<template>
  <div class="space-y-2">
    <!-- Preview -->
    <div
      v-if="preview"
      class="relative w-full aspect-video rounded-lg overflow-hidden bg-gray-100 border border-gray-200"
    >
      <img :src="preview" class="w-full h-full object-cover" alt="preview" />
      <button
        type="button"
        class="absolute top-2 right-2 bg-white/80 hover:bg-white text-gray-600 hover:text-red-500 rounded-full w-7 h-7 flex items-center justify-center shadow transition-colors"
        @click="clearImage"
      >
        ×
      </button>
    </div>

    <!-- Drop Zone -->
    <div
      v-else
      class="relative w-full aspect-video rounded-lg border-2 border-dashed transition-colors flex flex-col items-center justify-center cursor-pointer"
      :class="dragOver ? 'border-blue-400 bg-blue-50' : 'border-gray-300 bg-gray-50 hover:bg-gray-100'"
      @click="fileInput?.click()"
      @dragover.prevent="dragOver = true"
      @dragleave="dragOver = false"
      @drop.prevent="onDrop"
    >
      <template v-if="isUploading">
        <div class="w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin mb-2" />
        <p class="text-sm text-blue-600">กำลังอัปโหลด...</p>
      </template>
      <template v-else>
        <Icon name="flat-color-icons:add-image" class="text-4xl mb-2 text-gray-400" />
        <p class="text-sm text-gray-500">คลิกหรือลากไฟล์รูปภาพมาวาง</p>
        <p class="text-xs text-gray-400 mt-1">JPEG, PNG, WebP, GIF / ไม่เกิน 5 MB</p>
      </template>
    </div>

    <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="onFileChange" />

    <!-- Manual URL fallback -->
    <div class="flex items-center gap-2">
      <span class="text-xs text-gray-400 shrink-0">หรือวาง URL:</span>
      <input
        :value="modelValue"
        type="url"
        class="flex-1 px-2 py-1 border border-gray-200 rounded text-xs text-gray-600 focus:outline-none focus:ring-1 focus:ring-blue-400"
        placeholder="https://..."
        @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
      />
    </div>
  </div>
</template>
