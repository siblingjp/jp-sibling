export const API_ENDPOINTS = {
  AUTH: {
    LOGIN: '/api/auth/login',
    LOGOUT: '/api/auth/logout',
    ME: '/api/auth/me',
  },

  ADMIN: {
    CATEGORIES: {
      LIST: '/api/admin/categories',
      CREATE: '/api/admin/categories',
      UPDATE: (id: string) => `/api/admin/categories/${id}`,
      DELETE: (id: string) => `/api/admin/categories/${id}`,
      REORDER: '/api/admin/categories/reorder',
    },
    PRODUCTS: {
      LIST: '/api/admin/products',
      CREATE: '/api/admin/products',
      UPDATE: (id: string) => `/api/admin/products/${id}`,
      DELETE: (id: string) => `/api/admin/products/${id}`,
      TOGGLE_FEATURED: (id: string) => `/api/admin/products/${id}/featured`,
      REORDER: '/api/admin/products/reorder',
    },
    OPTION_GROUPS: {
      LIST: '/api/admin/option-groups',
      CREATE: '/api/admin/option-groups',
      SHOW: (id: string) => `/api/admin/option-groups/${id}`,
      UPDATE: (id: string) => `/api/admin/option-groups/${id}`,
      DELETE: (id: string) => `/api/admin/option-groups/${id}`,
    },
    USERS: {
      LIST: '/api/admin/users',
      CREATE: '/api/admin/users',
      UPDATE: (id: string) => `/api/admin/users/${id}`,
      DELETE: (id: string) => `/api/admin/users/${id}`,
    },
    MEMBERS: {
      LIST: '/api/admin/members',
      SHOW: (id: string) => `/api/admin/members/${id}`,
      TOGGLE_ACTIVE: (id: string) => `/api/admin/members/${id}`,
    },
    DISCOUNTS: {
      LIST: '/api/admin/discounts',
      CREATE: '/api/admin/discounts',
      UPDATE: (id: string) => `/api/admin/discounts/${id}`,
      DELETE: (id: string) => `/api/admin/discounts/${id}`,
    },
    COUPONS: {
      LIST: '/api/admin/coupons',
      CREATE: '/api/admin/coupons',
      UPDATE: (id: string) => `/api/admin/coupons/${id}`,
      DELETE: (id: string) => `/api/admin/coupons/${id}`,
    },
    CAMPAIGNS_DISCOUNT: {
      LIST: '/api/admin/campaigns',
      CREATE: '/api/admin/campaigns',
      UPDATE: (id: string) => `/api/admin/campaigns/${id}`,
      DELETE: (id: string) => `/api/admin/campaigns/${id}`,
    },
    ORDERS: {
      LIST: '/api/admin/orders',
      SHOW: (id: string) => `/api/admin/orders/${id}`,
      UPDATE_STATUS: (id: string) => `/api/admin/orders/${id}/status`,
    },
    DASHBOARD: {
      SUMMARY: '/api/admin/dashboard/summary',
    },
    REWARDS: {
      LIST: '/api/admin/rewards',
      CREATE: '/api/admin/rewards',
      UPDATE: (id: string) => `/api/admin/rewards/${id}`,
      DELETE: (id: string) => `/api/admin/rewards/${id}`,
    },
    CAMPAIGNS: {
      LIST: '/api/admin/campaigns',
      CREATE: '/api/admin/campaigns',
      UPDATE: (id: string) => `/api/admin/campaigns/${id}`,
      DELETE: (id: string) => `/api/admin/campaigns/${id}`,
    },
    LOCATION: {
      LIST: '/api/admin/location',
      UPDATE_TRUCK: '/api/admin/location/truck',
      RESET: '/api/admin/location/reset',
      TOGGLE_OPEN: '/api/admin/location/toggle-open',
      SCHEDULES: {
        LIST: '/api/admin/location/schedules',
        CREATE: '/api/admin/location/schedules',
        UPDATE: (id: string) => `/api/admin/location/schedules/${id}`,
        DELETE: (id: string) => `/api/admin/location/schedules/${id}`,
      },
    },
  },

  POS: {
    PRODUCTS: '/api/pos/products',
    DISCOUNTS: '/api/pos/discounts',
    MEMBER_LOOKUP: '/api/pos/member-lookup',
    COUPON_VALIDATE: '/api/pos/coupon/validate',
    COUPON_USE_SCAN: (id: string) => `/api/pos/coupon-use/${id}`,
    ORDERS: {
      LIST: '/api/pos/orders',
      CREATE: '/api/pos/orders',
      SHOW: (id: string) => `/api/pos/orders/${id}`,
      UPDATE: (id: string) => `/api/pos/orders/${id}`,
      FILL: (id: string) => `/api/pos/orders/${id}/fill`,
      EDIT_ITEMS: (id: string) => `/api/pos/orders/${id}/edit-items`,
      ACKNOWLEDGE: (id: string) => `/api/pos/orders/${id}/acknowledge`,
    },
    PAYMENTS: {
      CREATE: '/api/pos/payments',
      UPDATE: (id: string) => `/api/pos/payments/${id}`,
    },
    QUEUE_RESERVE: '/api/pos/queue-reserve',
  },

  MEMBER: {
    AUTH: {
      LOGIN: '/api/member/auth/login',
      LOGOUT: '/api/member/auth/logout',
      ME: '/api/member/auth/me',
      REGISTER: '/api/member/auth/register',
    },
    ORDERS: {
      LIST: '/api/member/orders',
      CREATE: '/api/member/orders',
      SHOW: (id: string) => `/api/member/orders/${id}`,
      CANCEL: (id: string) => `/api/member/orders/${id}/cancel`,
      FREQUENT: '/api/member/orders/frequent',
    },
    PROFILE: '/api/member/profile',
    POINTS: '/api/member/points',
    REDEEM: '/api/member/redeem',
    REWARDS: '/api/member/rewards',
    COUPONS: {
      LIST: '/api/member/coupons',
      REDEEM: '/api/member/coupons/redeem',
    },
    CAMPAIGNS: '/api/member/campaigns',
    PRODUCTS: '/api/member/products',
  },

  PUBLIC: {
    LOCATION_STATUS: '/api/public/location/status',
    ARTICLES: {
      LIST: '/api/public/news',
      SHOW: (slug: string) => `/api/public/news/${slug}`,
    },
    CAMPAIGNS: {
      LIST: '/api/public/campaigns',
      SHOW: (slug: string) => `/api/public/campaigns/${slug}`,
    },
    VOTE: (campaignId: string) => `/api/public/vote/${campaignId}`,
  },
} as const
