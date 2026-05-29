/**
 * seed-menu.ts
 * - Delete all existing products & categories
 * - Upload product images to S3
 * - Seed categories & products (no option groups)
 *
 * Run: npx tsx prisma/seed-menu.ts
 */

import { PrismaClient } from '@prisma/client'
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'
import { readFileSync, existsSync } from 'fs'
import { extname } from 'path'
import { randomUUID } from 'crypto'

const prisma = new PrismaClient()

// ─── S3 ───────────────────────────────────────────────────────────────────────

const S3_BUCKET = process.env.S3_BUCKET ?? 'jp-sibling-upload-bucket'
const S3_REGION = process.env.S3_REGION ?? 'ap-southeast-1'

const s3 = new S3Client({
  region: S3_REGION,
  credentials: {
    accessKeyId: process.env.S3_ACCESS_KEY!,
    secretAccessKey: process.env.S3_ACCESS_SECRET!,
  },
})

async function uploadImage(filePath: string, folder = 'products'): Promise<string> {
  const ext = extname(filePath).slice(1).toLowerCase()
  const mime = ext === 'jpg' || ext === 'jpeg' ? 'image/jpeg'
    : ext === 'png' ? 'image/png'
    : ext === 'webp' ? 'image/webp'
    : 'image/jpeg'

  const key = `${folder}/${randomUUID()}.${ext}`
  const body = readFileSync(filePath)

  await s3.send(new PutObjectCommand({
    Bucket: S3_BUCKET,
    Key: key,
    Body: body,
    ContentType: mime,
  }))

  return `https://${S3_BUCKET}.s3.${S3_REGION}.amazonaws.com/${key}`
}

// ─── Image folders ────────────────────────────────────────────────────────────

const BASE = '/Users/phurachanphowutthirat/Me/JP Sibling/images'

const IMG = {
  icedCoffee:   `${BASE}/เมนูกาแฟเย็น`,
  hot:          `${BASE}/เมนูร้อน`,
  milk:         `${BASE}/เมนูนม`,
  matcha:       `${BASE}/เมนูมัจฉะ`,
  italianSoda:  `${BASE}/เมนูอิลตาเลี่ยน`,
}

// slug → absolute image path
const imageMap: Record<string, string> = {
  // ── กาแฟเย็น ──────────────────────────────────────────────────────────────
  'iced-latte':           `${IMG.icedCoffee}/ลาเต้เย็น_พื้นหลังขาว_นมล่างกาแฟบน_2K_202605261309.jpeg`,
  'iced-cappuccino':      `${IMG.icedCoffee}/คาปูชิโน่เย็น_พื้นหลังขาว_2K_202605261312.jpeg`,
  'iced-mocha':           `${IMG.icedCoffee}/มอคค่าเย็น_พื้นหลังขาว_ไม่ต้องมีท็อปปิ้ง_2K_202605261315.jpeg`,
  'iced-americano':       `${IMG.icedCoffee}/อเมริกาโน่เย็น_พื้นหลังขาว_2K_202605261317.jpeg`,
  'americano-orange':     `${IMG.icedCoffee}/อเมริกาโน่ส้ม_พื้นหลังขาว_2K_202605261319.jpeg`,
  'americano-honey':      `${IMG.icedCoffee}/อเมริกาโน่น้ำผึ้้งเย็น_พื้นหลังขาว_ผึ้งเกาะปากแก้ว_2K_202605261323.jpeg`,
  'americano-honey-lemon':`${IMG.icedCoffee}/อเมริกาโน่น้ำผึ้งมะนาวเย็น_พื้นหลังขาว_มีมะนาวในแก้วและผึ้งเกาะปากแก้ว_2K_202605261326.jpeg`,
  'americano-coconut':    `${IMG.icedCoffee}/อเมริกาโน่มะพร้าวเย็น_พื้นหลังขาว_2K_202605261327.jpeg`,
  'americano-peach':      `${IMG.icedCoffee}/อเมริกาโน่พีชเย็น_พื้นหลังขาว_2K_202605261329.jpeg`,
  'americano-pineapple':  `${IMG.icedCoffee}/อเมริกาโน่สับปรดเย็น_พื้นหลังขาว_2K_202605261330.jpeg`,
  'coffee-thai-tea':      `${IMG.icedCoffee}/กาแฟชาไทยเย็น_พื้นหลังขาว_202605261332.jpeg`,
  'coffee-green-tea':     `${IMG.icedCoffee}/กาแฟชาเขียวเย็น_พื้นหลังขาว_2K_202605261333.jpeg`,

  // ── เมนูร้อน ──────────────────────────────────────────────────────────────
  'hot-cocoa':        `${IMG.hot}/โกโก้ร้อน_แก้วใส_พื้นหลังขาว_2K_202605261338.jpeg`,
  'hot-espresso':     `${IMG.hot}/เอสเปรสโซ่ร้อน_แก้วใส_พื้นหลังขาว_2K_202605261341.jpeg`,
  'hot-latte':        `${IMG.hot}/ลาเต้ร้อน_แก้วใส_พื้นหลังขาว_202605261343.jpeg`,
  'hot-cappuccino':   `${IMG.hot}/คาปูชิโน่ร้อน_แก้วใส_พื้นหลังขาว_202605261347.jpeg`,
  'hot-mocha':        `${IMG.hot}/มอคค่าร้อน_แก้วใส_พื้นหลังขาว_202605261345.jpeg`,
  'hot-fresh-milk':   `${IMG.hot}/นมสดร้อน_แก้วใส_พื้นหลังขาว_202605261346.jpeg`,

  // ── เมนูนม ────────────────────────────────────────────────────────────────
  'iced-cocoa':             `${IMG.milk}/โกโก้เย็น_พื้นหลังขาว_202605261352.jpeg`,
  'cocoa-mint':             `${IMG.milk}/โกโก้มิ้นต์เย็น_พื้นหลังขาว_202605261355.jpeg`,
  'iced-thai-tea':          `${IMG.milk}/Thai_iced_tea_white_background_202605261357.jpeg`,
  'iced-black-tea':         `${IMG.milk}/ชาดำเย็น_พื้นหลังขาว_202605261400.jpeg`,
  'lemon-tea':              `${IMG.milk}/ชามะนาวเย็น_พื้นหลังขาว_202605261401.jpeg`,
  'honey-lemon-tea':        `${IMG.milk}/Honey_lemon_drink_bee_glass_202605261404.jpeg`,
  'iced-green-tea':         `${IMG.milk}/ชาเขียวนมเย็น_พื้นหลังขาว_202605261409.jpeg`,
  'green-tea-lemon':        `${IMG.milk}/Iced_green_tea_with_lime_202605261412.jpeg`,
  'green-tea-honey-lemon':  `${IMG.milk}/ชาเขียวน้ำผึ้งมะนาวเย็น_202605261418.jpeg`,
  'iced-pink-milk':         `${IMG.milk}/นมชมพูเย็น_พื้นหลังขาว_202605261422.jpeg`,
  'iced-fresh-milk':        `${IMG.milk}/นมสดเย็น_มีน้ำแข็ง_พื้นหลังขาว_202605261422.jpeg`,
  'fresh-milk-mint':        `${IMG.milk}/นมสดมิ้นต์_พื้นหลังขาว_ท็อปปิ้ง_202605261423.jpeg`,
  'fresh-milk-caramel':     `${IMG.milk}/นมสดคาราเมลเย็น_พื้นหลังขาว_202605261423.jpeg`,
  'thai-tea-strawberry':    `${IMG.milk}/Thai_strawberry_tea_with_jam_202605261426.jpeg`,
  'green-tea-strawberry':   `${IMG.milk}/เย็นชาเขียวสตอเบอร์รี่แยม_202605261428.jpeg`,
  'fresh-milk-strawberry':  `${IMG.milk}/นมสดสตอเบอร์รี่เย็น_แยมสตอเบอร์รี่_202605261431.jpeg`,
  'pink-milk-strawberry':   `${IMG.milk}/นมชมพูสตอเบอร์รี่เย็น_แยมสตอเบอร…_202605261433.jpeg`,
  'cocoa-strawberry':       `${IMG.milk}/โกโก้สตรอเบอร์รี่เย็น_แยม_นม_202605261434.jpeg`,
  'taiwanese-iced-tea':     `${IMG.milk}/Taiwanese_iced_tea_white_background_202605261419.jpeg`,

  // ── มัจฉะ ─────────────────────────────────────────────────────────────────
  'pure-matcha':            `${IMG.matcha}/เพียวมัจฉะเย็น_ไม่มีท็อปปิ้ง_202605261439.jpeg`,
  'matcha-honey':           `${IMG.matcha}/มัจฉะน้ำผึ้งเย็น_มีน้ำแข็ง_202605261441.jpeg`,
  'matcha-honey-lemon':     `${IMG.matcha}/มัจฉะน้ำผึ้งมะนาวเย็น_แก้ว_202605261446.jpeg`,
  'matcha-orange':          `${IMG.matcha}/มัจฉะส้มเย็น_มีน้ำแข็ง_202605261449.jpeg`,
  'matcha-coconut':         `${IMG.matcha}/มัจฉะมะพร้าวเย็น_น้ำมะพร้าว_202605261454.jpeg`,
  'matcha-latte':           `${IMG.matcha}/มัจฉะลาเต้เย็น_นมข้างล่าง_มัจฉะข…_202605261455.jpeg`,
  'matcha-latte-caramel':   `${IMG.matcha}/มัจฉะลาเต้คาราเมลเย็น_202605261454.jpeg`,
  'matcha-latte-strawberry':`${IMG.matcha}/Strawberry_Matcha_Latte_202605261458.jpeg`,
  'matcha-latte-cocoa':     `${IMG.matcha}/มัจฉะลาเต้โกโก้เย็น_นม_มัจฉะ_202605261459.jpeg`,

  // ── อิตาเลี่ยน โซดา ───────────────────────────────────────────────────────
  'orange-juice':       `${IMG.italianSoda}/น้ำส้มเย็น_มีน้ำแข็ง_202605261506.jpeg`,
  'blue-hawaii':        `${IMG.italianSoda}/Blue_Hawaii_drink_with_ice_202605261506.jpeg`,
  'peach-juice':        `${IMG.italianSoda}/น้ำพีชเย็น_มีน้ำแข็ง_202605261507.jpeg`,
  'blueberry-juice':    `${IMG.italianSoda}/น้ำบลูเบอร์รี่เย็น_มีน้ำแข็ง_202605261507.jpeg`,
  'strawberry-juice':   `${IMG.italianSoda}/Strawberry_water_with_ice_202605261507.jpeg`,
  'kiwi-juice':         `${IMG.italianSoda}/น้ำกีวี่เย็น_มีน้ำแข็ง_202605261507.jpeg`,
  'green-apple-juice':  `${IMG.italianSoda}/Green_apple_juice_with_ice_202605261507.jpeg`,
  'pineapple-juice':    `${IMG.italianSoda}/Pineapple_juice_with_ice_202605261509.jpeg`,
  'honey-lemon-juice':  `${IMG.italianSoda}/น้ำผึ้งมะนาวเย็น_มีน้ำแข็ง_202605261509.jpeg`,
  'blue-hawaii-soda':   `${IMG.italianSoda}/Blue_Hawaii_soda_with_ice_202605261510.jpeg`,
  'peach-soda':         `${IMG.italianSoda}/Peach_soda_with_ice_202605261512.jpeg`,
  'blueberry-soda':     `${IMG.italianSoda}/Blueberry_soda_with_ice_202605261512.jpeg`,
  'strawberry-soda':    `${IMG.italianSoda}/Strawberry_soda_with_ice_202605261512.jpeg`,
  'kiwi-soda':          `${IMG.italianSoda}/น้ำกีวี่โซดา_มีน้ำแข็ง_202605261512.jpeg`,
  'green-apple-soda':   `${IMG.italianSoda}/Green_apple_soda_with_ice_202605261512.jpeg`,
  'pineapple-soda':     `${IMG.italianSoda}/Pineapple_soda_with_ice_202605261513.jpeg`,
  'honey-lemon-soda':   `${IMG.italianSoda}/น้ำผึ้งมะนาวโซดา_มีน้ำแข็ง_202605261513.jpeg`,
}

// ─── Categories ───────────────────────────────────────────────────────────────

const categories = [
  { name: 'กาแฟเย็น',        slug: 'iced-coffee' },
  { name: 'เมนูร้อน',         slug: 'hot-drinks' },
  { name: 'เมนูนม',           slug: 'milk-drinks' },
  { name: 'มัจฉะ',            slug: 'matcha' },
  { name: 'อิตาเลี่ยน โซดา',  slug: 'italian-soda' },
]

// ─── Products ─────────────────────────────────────────────────────────────────

const products: { categorySlug: string; name: string; slug: string; price: number }[] = [
  // กาแฟเย็น
  { categorySlug: 'iced-coffee', name: 'ลาเต้เย็น',               slug: 'iced-latte',             price: 40 },
  { categorySlug: 'iced-coffee', name: 'คาปูชิโน่เย็น',            slug: 'iced-cappuccino',        price: 40 },
  { categorySlug: 'iced-coffee', name: 'มอคค่าเย็น',              slug: 'iced-mocha',             price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่เย็น',          slug: 'iced-americano',         price: 35 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่ส้ม',           slug: 'americano-orange',       price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่น้ำผึ้ง',       slug: 'americano-honey',        price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่น้ำผึ้งมะนาว',  slug: 'americano-honey-lemon',  price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่มะพร้าว',       slug: 'americano-coconut',      price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่พีช',           slug: 'americano-peach',        price: 40 },
  { categorySlug: 'iced-coffee', name: 'อเมริกาโน่สับปะรด',       slug: 'americano-pineapple',    price: 40 },
  { categorySlug: 'iced-coffee', name: 'กาแฟชาไทย',              slug: 'coffee-thai-tea',        price: 40 },
  { categorySlug: 'iced-coffee', name: 'กาแฟชาเขียว',             slug: 'coffee-green-tea',       price: 40 },

  // เมนูร้อน
  { categorySlug: 'hot-drinks', name: 'โกโก้ร้อน',      slug: 'hot-cocoa',      price: 30 },
  { categorySlug: 'hot-drinks', name: 'เอสเปรสโซ่ร้อน', slug: 'hot-espresso',   price: 30 },
  { categorySlug: 'hot-drinks', name: 'ลาเต้ร้อน',      slug: 'hot-latte',      price: 30 },
  { categorySlug: 'hot-drinks', name: 'คาปูชิโน่ร้อน',  slug: 'hot-cappuccino', price: 30 },
  { categorySlug: 'hot-drinks', name: 'มอคค่าร้อน',     slug: 'hot-mocha',      price: 30 },
  { categorySlug: 'hot-drinks', name: 'นมสดร้อน',       slug: 'hot-fresh-milk', price: 30 },

  // เมนูนม
  { categorySlug: 'milk-drinks', name: 'โกโก้เย็น',            slug: 'iced-cocoa',            price: 40 },
  { categorySlug: 'milk-drinks', name: 'โกโก้มิ้นต์',          slug: 'cocoa-mint',            price: 45 },
  { categorySlug: 'milk-drinks', name: 'ชาไทยเย็น',            slug: 'iced-thai-tea',         price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชาดำเย็น',             slug: 'iced-black-tea',        price: 30 },
  { categorySlug: 'milk-drinks', name: 'ชามะนาว',              slug: 'lemon-tea',             price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชามะนาวน้ำผึ้ง',       slug: 'honey-lemon-tea',       price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชาเขียวนมเย็น',        slug: 'iced-green-tea',        price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชาเขียวมะนาว',         slug: 'green-tea-lemon',       price: 35 },
  { categorySlug: 'milk-drinks', name: 'ชาเขียวน้ำผึ้งมะนาว',  slug: 'green-tea-honey-lemon', price: 35 },
  { categorySlug: 'milk-drinks', name: 'นมชมพูเย็น',           slug: 'iced-pink-milk',        price: 35 },
  { categorySlug: 'milk-drinks', name: 'นมสดเย็น',             slug: 'iced-fresh-milk',       price: 35 },
  { categorySlug: 'milk-drinks', name: 'นมสดมิ้นต์',           slug: 'fresh-milk-mint',       price: 40 },
  { categorySlug: 'milk-drinks', name: 'นมสดคาราเมล',          slug: 'fresh-milk-caramel',    price: 40 },
  { categorySlug: 'milk-drinks', name: 'ชาไทยสตรอเบอร์รี่',    slug: 'thai-tea-strawberry',   price: 45 },
  { categorySlug: 'milk-drinks', name: 'ชาเขียวสตรอเบอร์รี่',  slug: 'green-tea-strawberry',  price: 45 },
  { categorySlug: 'milk-drinks', name: 'นมสดสตรอเบอร์รี่',     slug: 'fresh-milk-strawberry', price: 45 },
  { categorySlug: 'milk-drinks', name: 'นมชมพูสตรอเบอร์รี่',   slug: 'pink-milk-strawberry',  price: 45 },
  { categorySlug: 'milk-drinks', name: 'โกโก้สตรอเบอร์รี่',    slug: 'cocoa-strawberry',      price: 45 },

  // มัจฉะ
  { categorySlug: 'matcha', name: 'เพียวมัจฉะ',             slug: 'pure-matcha',             price: 35 },
  { categorySlug: 'matcha', name: 'มัจฉะน้ำผึ้ง',           slug: 'matcha-honey',            price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะน้ำผึ้งมะนาว',      slug: 'matcha-honey-lemon',      price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะส้ม',               slug: 'matcha-orange',           price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะมะพร้าว',           slug: 'matcha-coconut',          price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะลาเต้',             slug: 'matcha-latte',            price: 40 },
  { categorySlug: 'matcha', name: 'มัจฉะลาเต้คาราเมล',      slug: 'matcha-latte-caramel',    price: 45 },
  { categorySlug: 'matcha', name: 'มัจฉะลาเต้สตรอเบอร์รี่', slug: 'matcha-latte-strawberry', price: 45 },
  { categorySlug: 'matcha', name: 'มัจฉะลาเต้โกโก้',        slug: 'matcha-latte-cocoa',      price: 45 },

  // อิตาเลี่ยน โซดา
  { categorySlug: 'italian-soda', name: 'น้ำส้ม',               slug: 'orange-juice',     price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำบลูฮาวาย',          slug: 'blue-hawaii',      price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำพีช',               slug: 'peach-juice',      price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำบลูเบอร์รี่',       slug: 'blueberry-juice',  price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำสตรอเบอร์รี่',      slug: 'strawberry-juice', price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำกีวี่',             slug: 'kiwi-juice',       price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำแอปเปิ้ลเขียว',     slug: 'green-apple-juice',price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำสับปะรด',           slug: 'pineapple-juice',  price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำผึ้งมะนาว',         slug: 'honey-lemon-juice', price: 30 },
  { categorySlug: 'italian-soda', name: 'น้ำบลูฮาวายโซดา',      slug: 'blue-hawaii-soda', price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำพีชโซดา',           slug: 'peach-soda',       price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำบลูเบอร์รี่โซดา',   slug: 'blueberry-soda',   price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำสตรอเบอร์รี่โซดา',  slug: 'strawberry-soda',  price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำกีวี่โซดา',         slug: 'kiwi-soda',        price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำแอปเปิ้ลเขียวโซดา', slug: 'green-apple-soda', price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำสับปะรดโซดา',       slug: 'pineapple-soda',   price: 35 },
  { categorySlug: 'italian-soda', name: 'น้ำผึ้งมะนาวโซดา',     slug: 'honey-lemon-soda', price: 35 },
]

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('🗑️  Deleting existing products & categories...')
  await prisma.orderItemOption.deleteMany()
  await prisma.orderItem.deleteMany()
  await prisma.productOptionGroup.deleteMany()
  await prisma.product.deleteMany()
  await prisma.category.deleteMany()
  console.log('   Done.\n')

  // 1. Upload images to S3
  console.log('☁️  Uploading images to S3...')
  const urlMap: Record<string, string> = {}
  for (const [slug, filePath] of Object.entries(imageMap)) {
    if (!existsSync(filePath)) {
      console.warn(`   ⚠️  ไม่พบไฟล์: ${filePath}`)
      continue
    }
    try {
      const url = await uploadImage(filePath)
      urlMap[slug] = url
      console.log(`   ✅ ${slug}`)
    } catch (e) {
      console.error(`   ❌ ${slug}: ${e}`)
    }
  }
  console.log(`\n   อัปโหลดแล้ว ${Object.keys(urlMap).length} รูป\n`)

  // 2. Seed categories
  console.log('📁 Creating categories...')
  const categoryMap: Record<string, string> = {}
  for (const cat of categories) {
    const record = await prisma.category.create({
      data: { name: cat.name, slug: cat.slug, isActive: true },
    })
    categoryMap[cat.slug] = record.id
    console.log(`   ${cat.name}`)
  }
  console.log()

  // 3. Seed products
  console.log('☕ Creating products...')
  let count = 0
  for (const p of products) {
    const categoryId = categoryMap[p.categorySlug]
    if (!categoryId) {
      console.warn(`   ⚠️  ไม่พบหมวด: ${p.categorySlug}`)
      continue
    }
    await prisma.product.create({
      data: {
        name: p.name,
        slug: p.slug,
        price: p.price,
        imageUrl: urlMap[p.slug] ?? null,
        isActive: true,
        categoryId,
      },
    })
    const hasImage = !!urlMap[p.slug]
    console.log(`   ${hasImage ? '🖼 ' : '   '} ${p.name.padEnd(28)} ฿${p.price}`)
    count++
  }

  console.log(`\n✅ เสร็จสิ้น — ${count} เมนู, ${categories.length} หมวดหมู่`)
}

main()
  .catch((e) => { console.error(e); process.exit(1) })
  .finally(() => prisma.$disconnect())
