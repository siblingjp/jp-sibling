<script setup lang="ts">
import type { PosProduct, PosOption } from '~/stores/pos'

const props = defineProps<{
  product: PosProduct | null
  initialQty?: number
  initialNote?: string
  initialOptions?: PosOption[]
}>()

const emit = defineEmits<{
  confirm: [options: PosOption[], note: string, qty: number]
  cancel: []
}>()

const qty = ref(1)
const note = ref('')
const selected = ref<Record<string, string[]>>({})

watch(() => props.product, (p) => {
  qty.value = props.initialQty ?? 1
  note.value = props.initialNote ?? ''
  if (!p) { selected.value = {}; return }
  const preselected = new Set((props.initialOptions ?? []).map((o) => o.optionId))
  selected.value = Object.fromEntries(
    p.optionGroups.map((pg) => [
      pg.optionGroup.id,
      pg.optionGroup.options.filter((o) => preselected.has(o.id)).map((o) => o.id),
    ]),
  )
}, { immediate: true })

const groups = computed(() => props.product?.optionGroups.map((pg) => pg.optionGroup) ?? [])

function toggleOption(groupId: string, optionId: string, multiSelect: boolean) {
  if (multiSelect) {
    const idx = selected.value[groupId].indexOf(optionId)
    if (idx === -1) selected.value[groupId].push(optionId)
    else selected.value[groupId].splice(idx, 1)
  } else {
    selected.value[groupId] = selected.value[groupId][0] === optionId ? [] : [optionId]
  }
}

const isValid = computed(() =>
  groups.value.every((g) => !g.required || selected.value[g.id]?.length > 0),
)

const previewPrice = computed(() => {
  if (!props.product) return 0
  const extraTotal = groups.value.flatMap((g) =>
    g.options.filter((o) => selected.value[g.id]?.includes(o.id)),
  ).reduce((s, o) => s + Number(o.extraPrice), 0)
  return (Number(props.product.price) + extraTotal) * qty.value
})

function handleConfirm() {
  if (!props.product || !isValid.value) return
  const opts: PosOption[] = groups.value.flatMap((g) =>
    g.options
      .filter((o) => selected.value[g.id]?.includes(o.id))
      .map((o) => ({ optionId: o.id, name: o.name, extraPrice: Number(o.extraPrice) })),
  )
  emit('confirm', opts, note.value, qty.value)
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="product"
      class="fixed inset-0 z-50 flex items-end sm:items-center justify-center"
    >
      <div class="absolute inset-0 bg-black/40 hidden sm:block" @click="emit('cancel')" />
      <div class="relative bg-white w-full sm:max-w-md sm:rounded-2xl shadow-xl flex flex-col h-full sm:h-auto sm:max-h-[90vh]">
        <!-- Header -->
        <div class="px-5 pt-5 pb-3 border-b border-gray-100">
          <h2 class="text-lg font-semibold text-gray-900">{{ product.name }}</h2>
          <p class="text-sm text-gray-400">ราคาเริ่มต้น: ฿{{ Number(product.price).toFixed(0) }}</p>
        </div>

        <!-- Options -->
        <div class="flex-1 overflow-y-auto px-5 py-4 space-y-5">
          <div v-for="g in groups" :key="g.id">
            <div class="flex items-center gap-2 mb-2">
              <p class="text-sm font-medium text-gray-800">{{ g.name }}</p>
              <span v-if="g.required" class="text-xs text-red-500">*จำเป็น</span>
              <span v-if="g.multiSelect" class="text-xs text-gray-400">(เลือกได้หลายอย่าง)</span>
            </div>
            <div class="space-y-1.5">
              <button
                v-for="opt in g.options"
                :key="opt.id"
                type="button"
                class="w-full flex items-center justify-between px-3 py-2.5 rounded-lg border text-sm transition-colors"
                :class="selected[g.id]?.includes(opt.id)
                  ? 'border-blue-400 bg-blue-50 text-blue-800'
                  : 'border-gray-200 text-gray-700 hover:bg-gray-50'"
                @click="toggleOption(g.id, opt.id, g.multiSelect)"
              >
                <span>{{ opt.name }}</span>
                <span v-if="Number(opt.extraPrice) > 0" class="text-xs font-medium text-green-600">
                  +฿{{ Number(opt.extraPrice).toFixed(0) }}
                </span>
              </button>
            </div>
          </div>

          <!-- Note -->
          <div>
            <p class="text-sm font-medium text-gray-800 mb-2">หมายเหตุ</p>
            <input
              v-model="note"
              type="text"
              placeholder="คำขอพิเศษ..."
              class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>

        <!-- Footer -->
        <div class="px-5 py-4 border-t border-gray-100 space-y-3 sticky bottom-0 bg-white sm:static">
          <!-- Qty -->
          <div class="flex items-center justify-center gap-4">
            <button
              type="button"
              class="w-9 h-9 rounded-full border border-gray-300 flex items-center justify-center text-lg font-medium text-gray-600 hover:bg-gray-100 disabled:opacity-30"
              :disabled="qty <= 1"
              @click="qty--"
            >−</button>
            <span class="text-lg font-semibold w-8 text-center">{{ qty }}</span>
            <button
              type="button"
              class="w-9 h-9 rounded-full border border-gray-300 flex items-center justify-center text-lg font-medium text-gray-600 hover:bg-gray-100"
              @click="qty++"
            >+</button>
          </div>

          <button
            type="button"
            class="w-full py-3 rounded-xl font-semibold text-white transition-colors"
            :class="isValid ? 'bg-blue-600 hover:bg-blue-700' : 'bg-gray-300 cursor-not-allowed'"
            :disabled="!isValid"
            @click="handleConfirm"
          >
            {{ initialOptions !== undefined ? 'บันทึก' : 'เพิ่มลงตะกร้า' }} — ฿{{ previewPrice.toFixed(0) }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
