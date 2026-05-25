declare module '#auth-utils' {
  interface UserSession {
    user?: {
      id: string
      email: string
      name: string
      role: 'ADMIN' | 'CASHIER' | 'STAFF'
    }
    member?: {
      id: string
      name: string
      email: string | null
      tier: 'SILVER' | 'GOLD' | 'VIP'
      points: number
    }
  }
}

export {}
