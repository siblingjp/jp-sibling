const pendingCount = ref(0)

export function useGlobalLoading() {
  const isPending = computed(() => pendingCount.value > 0)

  function increment() { pendingCount.value++ }
  function decrement() { pendingCount.value = Math.max(0, pendingCount.value - 1) }

  return { isPending, increment, decrement }
}
