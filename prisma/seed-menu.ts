/**
 * seed-menu.ts
 * Seed categories, products, option groups for JP Sibling Coffee
 * Source: public/เมนูร้าน JP Sibling Coffee.txt
 *
 * Run: npx tsx prisma/seed-menu.ts
 */

import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// ─── Data ─────────────────────────────────────────────────────────────────────

const categories = [
  { name: 'กาแฟเย็น', slug: 'iced-coffee' },
  { name: 'เมนูร้อน', slug: 'hot-drinks' },
  { name: 'เมนูนม', slug: 'milk-drinks' },
  { name: 'มัจฉะ', slug: 'matcha' },
  { name: 'อิตาเลี่ยน โซดา', slug: 'italian-soda' },
]

const products: {
  categorySlug: string
  name: string
  slug: string
  price: number
}[] = [
  // ─── กาแฟเย็น ───────────────────────────────────────────────────────────────
  { categorySlug: 'iced-coffee', name: 'เอสเปรสโซ่เย็น',        slug: 'iced-espresso',          price: 40 },
  { categorySlug: 'iced-coffee', name: 'ลาเต้เย็น',              slug: 'iced-latte',              price: 40 },
  { categorySlug: 'iced-coffee', name: 'คาปูชิโน่เย็น',          slug: 'iced-cappuccino',         price: 40 },
  { categorySlug: 'iced-coffee', name: 'มอคค่าเย็น',             slug: 'iced-mocha',              price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่เย็น',         slug: 'iced-americano',          price: 35 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่ส้ม',          slug: 'americano-orange',        price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่น้ำผึ้ง',      slug: 'americano-honey',         price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่น้ำผึ้งมะนาว', slug: 'americano-honey-lemon',   price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่มะพร้าว',      slug: 'americano-coconut',       price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่พีช',          slug: 'americano-peach',         price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่สับปะรด',      slug: 'americano-pineapple',     price: 40 },
  { categorySlug: 'iced-coffee', name: 'กาแฟชาไทย',             slug: 'coffee-thai-tea',         price: 40 },
  { categorySlug: 'iced-coffee', name: 'กาแฟชาเขียว',            slug: 'coffee-green-tea',        price: 40 },

  // ─── เมนูร้อน ────────────────────────────────────────────────────────────────
  { categorySlug: 'hot-drinks', name: 'โกโก้ร้อน',      slug: 'hot-cocoa',        price: 30 },
  { categorySlug: 'hot-drinks', name: 'เอสเปรสโซ่ร้อน', slug: 'hot-espresso',     price: 30 },
  { categorySlug: 'hot-drinks', name: 'ลาเต้ร้อน',      slug: 'hot-latte',        price: 30 },
  { categorySlug: 'hot-drinks', name: 'คาปูชิโน่ร้อน',  slug: 'hot-cappuccino',   price: 30 },
  { categorySlug: 'hot-drinks', name: 'มอคค่าร้อน',     slug: 'hot-mocha',        price: 30 },
  { categorySlug: 'hot-drinks', name: 'นมสดร้อน',       slug: 'hot-fresh-milk',   price: 30 },

  // ─── เมนูนม ──────────────────────────────────────────────────────────────────
  { categorySlug: 'milk-drinks', name: 'โกโก้เย็น',             slug: 'iced-cocoa',              price: 40 },
  { categorySlug: 'milk-drinks', name: 'โกโก้มิ้นต์',           slug: 'cocoa-mint',              price: 45 },
  { categorySlug: 'milk-drinks', name: 'ชาไทยเย็น',             slug: 'iced-thai-tea',           price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชาดำเย็น',              slug: 'iced-black-tea',          price: 30 },
  { categorySlug: 'milk-drinks', name: 'ชามะนาว',               slug: 'lemon-tea',               price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชามะนาวน้ำผึ้ง',        slug: 'honey-lemon-tea',         price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชาเขียวเย็น',           slug: 'iced-green-tea',          price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชาเขียวมะนาว',          slug: 'green-tea-lemon',         price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชาเขียวน้ำผึ้งมะนาว',   slug: 'green-tea-honey-lemon',   price: 35 },
  { categorySlug: 'milk-drinks', name: 'นมชมพูเย็น',            slug: 'iced-pink-milk',          price: 35 },
  { categorySlug: 'milk-drinks', name: 'นมสดเย็น',              slug: 'iced-fresh-milk',         price: 35 },
  { categorySlug: 'milk-drinks', name: 'นมสดมิ้นต์',            slug: 'fresh-milk-mint',         price: 40 },
  { categorySlug: 'milk-drinks', name: 'นมสดคาราเมล',           slug: 'fresh-milk-caramel',      price: 40 },
  { categorySlug: 'milk-drinks', name: 'ชาไทยสตรอเบอร์รี่',     slug: 'thai-tea-strawberry',     price: 45 },
  { categorySlug: 'milk-drinks', name: 'ชาเขียวสตรอเบอร์รี่',   slug: 'green-tea-strawberry',    price: 45 },
  { categorySlug: 'milk-drinks', name: 'นมสดสตรอเบอร์รี่',      slug: 'fresh-milk-strawberry',   price: 45 },
  { categorySlug: 'milk-drinks', name: 'นมชมพูสตรอเบอร์รี่',    slug: 'pink-milk-strawberry',    price: 45 },
  { categorySlug: 'milk-drinks', name: 'โกโก้สตรอเบอร์รี่',     slug: 'cocoa-strawberry',        price: 45 },

  // ─── มัจฉะ ───────────────────────────────────────────────────────────────────
  { categorySlug: 'matcha', name: 'เพียวมัจฉะ',            slug: 'pure-matcha',             price: 35 },
  { categorySlug: 'matcha', name: 'มัจฉะน้ำผึ้ง',          slug: 'matcha-honey',            price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะน้ำผึ้งมะนาว',     slug: 'matcha-honey-lemon',      price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะส้ม',              slug: 'matcha-orange',           price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะมะพร้าว',          slug: 'matcha-coconut',          price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะลาเต้',            slug: 'matcha-latte',            price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะลาเต้คาราเมล',     slug: 'matcha-latte-caramel',    price: 45 },
  { categorySlug: 'matcha', name: 'มัจฉะลาเต้สตรอเบอร์รี่', slug: 'matcha-latte-strawberry', price: 45 },
  { categorySlug: 'matcha', name: 'มัจฉะลาเต้โกโก้',       slug: 'matcha-latte-cocoa',      price: 45 },

  // ─── อิตาเลี่ยน โซดา ─────────────────────────────────────────────────────────
  { categorySlug: 'italian-soda', name: 'น้ำส้ม',              slug: 'orange-juice',          price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำบลูฮาวาย',         slug: 'blue-hawaii',           price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำพีช',              slug: 'peach-juice',           price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำบลูเบอร์รี่',      slug: 'blueberry-juice',       price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำสตรอเบอร์รี่',     slug: 'strawberry-juice',      price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำกีวี่',            slug: 'kiwi-juice',            price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำแอปเปิ้ลเขียว',    slug: 'green-apple-juice',     price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำสับปะรด',          slug: 'pineapple-juice',       price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำผึ้งมะนาว',        slug: 'honey-lemon-juice',     price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำบลูฮาวายโซดา',     slug: 'blue-hawaii-soda',      price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำพีชโซดา',          slug: 'peach-soda',            price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำบลูเบอร์รี่โซดา',  slug: 'blueberry-soda',        price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำสตรอเบอร์รี่โซดา', slug: 'strawberry-soda',       price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำกีวี่โซดา',        slug: 'kiwi-soda',             price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำแอปเปิ้ลเขียวโซดา', slug: 'green-apple-soda',    price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำสับปะรดโซดา',      slug: 'pineapple-soda',        price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำผึ้งมะนาวโซดา',    slug: 'honey-lemon-soda',      price: 35 },
]

// ─── Option Groups ────────────────────────────────────────────────────────────

// slugs ของเมนูที่มีตัวเลือก "ความหวาน" (เครื่องดื่มที่ไม่ตายตัวเรื่องน้ำตาล)
const sweetnessSlugs = new Set([
  'iced-espresso', 'iced-latte', 'iced-cappuccino', 'iced-mocha',
  'iced-americano', 'hot-espresso', 'hot-latte', 'hot-cappuccino', 'hot-mocha',
  'iced-cocoa', 'cocoa-mint', 'hot-cocoa',
  'iced-thai-tea', 'iced-black-tea', 'iced-green-tea', 'iced-pink-milk',
  'iced-fresh-milk', 'hot-fresh-milk', 'fresh-milk-mint', 'fresh-milk-caramel',
  'thai-tea-strawberry', 'green-tea-strawberry', 'fresh-milk-strawberry',
  'pink-milk-strawberry', 'cocoa-strawberry',
  'pure-matcha', 'matcha-honey', 'matcha-honey-lemon', 'matcha-latte',
  'matcha-latte-caramel', 'matcha-latte-strawberry', 'matcha-latte-cocoa',
  'coffee-thai-tea', 'coffee-green-tea',
])

const optionGroups: {
  id: string
  name: string
  required: boolean
  multiSelect: boolean
  sortOrder: number
  options: { id: string; name: string; extraPrice: number; sortOrder: number }[]
  applyToAll?: boolean
  applyToSlugs?: Set<string>
}[] = [
  {
    id: 'og-sweetness',
    name: 'ความหวาน',
    required: true,
    multiSelect: false,
    sortOrder: 1,
    applyToSlugs: sweetnessSlugs,
    options: [
      { id: 'opt-sweet-none',    name: 'ไม่หวาน',       extraPrice: 0, sortOrder: 1 },
      { id: 'opt-sweet-less',    name: 'หวานน้อย',      extraPrice: 0, sortOrder: 2 },
      { id: 'opt-sweet-normal',  name: 'หวานปกติ',      extraPrice: 0, sortOrder: 3 },
      { id: 'opt-sweet-extra',   name: 'หวานมาก',       extraPrice: 0, sortOrder: 4 },
    ],
  },
  {
    id: 'og-temperature',
    name: 'อุณหภูมิ',
    required: true,
    multiSelect: false,
    sortOrder: 2,
    applyToSlugs: new Set([
      'iced-espresso', 'iced-latte', 'iced-cappuccino', 'iced-mocha',
      'hot-espresso', 'hot-latte', 'hot-cappuccino', 'hot-mocha',
      'iced-cocoa', 'hot-cocoa',
      'iced-thai-tea', 'iced-green-tea',
      'iced-fresh-milk', 'hot-fresh-milk',
      'coffee-thai-tea', 'coffee-green-tea',
      'matcha-latte',
    ]),
    options: [
      { id: 'opt-temp-hot',  name: 'ร้อน', extraPrice: 0,   sortOrder: 1 },
      { id: 'opt-temp-iced', name: 'เย็น', extraPrice: 0,   sortOrder: 2 },
    ],
  },
  {
    id: 'og-topping',
    name: 'ท็อปปิ้ง',
    required: false,
    multiSelect: true,
    sortOrder: 3,
    applyToAll: true,
    options: [
      { id: 'opt-top-whip',      name: 'วิปครีม',         extraPrice: 10, sortOrder: 1 },
      { id: 'opt-top-caramel',   name: 'ซอสคาราเมล',      extraPrice: 10, sortOrder: 2 },
      { id: 'opt-top-choc',      name: 'ซอสช็อกโกแลต',    extraPrice: 10, sortOrder: 3 },
      { id: 'opt-top-strawberry',name: 'ซอสสตรอเบอร์รี่',  extraPrice: 10, sortOrder: 4 },
    ],
  },
]

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('🌱 Seeding JP Sibling Coffee menu...\n')

  // 1. Upsert categories
  const categoryMap: Record<string, string> = {}
  for (const cat of categories) {
    const record = await prisma.category.upsert({
      where: { slug: cat.slug },
      update: { name: cat.name },
      create: { name: cat.name, slug: cat.slug, isActive: true },
    })
    categoryMap[cat.slug] = record.id
    console.log(`  📁 ${cat.name}`)
  }

  // 2. Upsert option groups + options
  for (const og of optionGroups) {
    await prisma.optionGroup.upsert({
      where: { id: og.id },
      update: { name: og.name, required: og.required, multiSelect: og.multiSelect, sortOrder: og.sortOrder },
      create: {
        id: og.id,
        name: og.name,
        required: og.required,
        multiSelect: og.multiSelect,
        sortOrder: og.sortOrder,
        isActive: true,
      },
    })

    for (const opt of og.options) {
      await prisma.option.upsert({
        where: { id: opt.id },
        update: { name: opt.name, extraPrice: opt.extraPrice, sortOrder: opt.sortOrder },
        create: {
          id: opt.id,
          name: opt.name,
          extraPrice: opt.extraPrice,
          sortOrder: opt.sortOrder,
          isActive: true,
          groupId: og.id,
        },
      })
    }

    console.log(`  🔧 ${og.name} (${og.options.length} ตัวเลือก)`)
  }

  // 3. Upsert products + link option groups
  console.log('')
  let count = 0
  for (const p of products) {
    const categoryId = categoryMap[p.categorySlug]
    if (!categoryId) {
      console.warn(`  ⚠️  ไม่พบหมวด: ${p.categorySlug}`)
      continue
    }

    const product = await prisma.product.upsert({
      where: { slug: p.slug },
      update: { name: p.name, price: p.price, categoryId },
      create: {
        name: p.name,
        slug: p.slug,
        price: p.price,
        imageUrl: null,
        isActive: true,
        categoryId,
      },
    })

    // Link option groups ที่ apply กับ product นี้
    let sortOrder = 0
    for (const og of optionGroups) {
      const applies = og.applyToAll || og.applyToSlugs?.has(p.slug)
      if (!applies) continue

      await prisma.productOptionGroup.upsert({
        where: { productId_optionGroupId: { productId: product.id, optionGroupId: og.id } },
        update: { sortOrder },
        create: { productId: product.id, optionGroupId: og.id, sortOrder },
      })
      sortOrder++
    }

    console.log(`  ☕ ${p.name.padEnd(28)} ฿${p.price}`)
    count++
  }

  console.log(`\n✅ เสร็จสิ้น — ${count} เมนู, ${categories.length} หมวด, ${optionGroups.length} option groups`)
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(() => prisma.$disconnect())
