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
    },
    PRODUCTS: {
      LIST: '/api/admin/products',
      CREATE: '/api/admin/products',
      UPDATE: (id: string) => `/api/admin/products/${id}`,
      DELETE: (id: string) => `/api/admin/products/${id}`,
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
    ORDERS: {
      LIST: '/api/admin/orders',
      SHOW: (id: string) => `/api/admin/orders/${id}`,
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
    },
  },

  POS: {
    PRODUCTS: '/api/pos/products',
    DISCOUNTS: '/api/pos/discounts',
    MEMBER_LOOKUP: '/api/pos/member-lookup',
    ORDERS: {
      LIST: '/api/pos/orders',
      CREATE: '/api/pos/orders',
      UPDATE: (id: string) => `/api/pos/orders/${id}`,
    },
    PAYMENTS: {
      CREATE: '/api/pos/payments',
    },
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
    },
    PROFILE: '/api/member/profile',
    POINTS: '/api/member/points',
    REDEEM: '/api/member/redeem',
    REWARDS: '/api/member/rewards',
  },

  PUBLIC: {
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
