import { defineStore } from 'pinia'

interface QueueOrder {
  id: string
  queueNo: number
  status: 'PENDING' | 'PREPARING' | 'READY' | 'COMPLETED' | 'CANCELLED'
  total: number
  createdAt: string
}

export const useQueueStore = defineStore('queue', () => {
  const orders = ref<QueueOrder[]>([])

  function setOrders(list: QueueOrder[]) {
    orders.value = list
  }

  function updateStatus(id: string, status: QueueOrder['status']) {
    const order = orders.value.find((o) => o.id === id)
    if (order) order.status = status
  }

  const pendingOrders = computed(() =>
    orders.value.filter((o) => o.status === 'PENDING'),
  )
  const preparingOrders = computed(() =>
    orders.value.filter((o) => o.status === 'PREPARING'),
  )
  const readyOrders = computed(() =>
    orders.value.filter((o) => o.status === 'READY'),
  )

  return { orders, setOrders, updateStatus, pendingOrders, preparingOrders, readyOrders }
})
