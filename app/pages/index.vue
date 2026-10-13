<script setup lang="ts">
definePageMeta({ layout: 'public' })

const http = useHttpClient()
const { member, fetchMe } = useMemberAuth()

interface BundlePromo {
  id: string
  name: string
  bundleQty: number | null
  bundleDiscount: number | null
  category: { name: string } | null
}

interface HomeData {
  products: { id: string; name: string; imageUrl: string | null; category: { name: string } }[]
  campaigns: { id: string; name: string; description: string | null; imageUrl: string | null; displayMode: string | null; bannerColor: string | null; coupons: BundlePromo[] }[]
  truckLocation: { name: string; description: string | null; mapUrl: string | null; openTime: string | null; closeTime: string | null; daysOfWeek: string | null; isOpen: boolean; canOrder: boolean; nextOpenLabel: string | null; nextOpenName: string | null; schedules: { id: string; name: string; openTime: string; closeTime: string; daysOfWeek: string; mapUrl: string | null }[]; activeScheduleId: string | null } | null
}

function formatBundlePromo(c: BundlePromo) {
  const scope = c.category ? `${c.category.name} ` : ''
  return `ซื้อ${scope}ครบ ${c.bundleQty} ชิ้น ลด ฿${Number(c.bundleDiscount).toFixed(0)}`
}

useHead({
  link: [
    { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
    { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
    { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,500;0,9..144,600;1,9..144,500&family=IBM+Plex+Sans+Thai:wght@400;500;600;700&display=swap' },
  ],
})

const data = ref<HomeData | null>(null)
const showTimeline = ref(false)
const { canInstall, platform, hasNativePrompt, install } = usePwaInstall()
const dismissedBanner = ref(false)

async function copyUrlAndDismiss() {
  await navigator.clipboard.writeText(window.location.href)
  dismissedBanner.value = true
}

const benefits = [
  { icon: 'flat-color-icons:approval', title: 'สะสมแต้ม', desc: 'สะสมแต้มจากทุกการสั่ง' },
  { icon: 'mdi:gift', title: 'แต้มแลกลด', desc: 'ใช้แต้มแลกส่วนลด' },
  { icon: null, image: '/logo-icon-white.png', title: 'สั่งล่วงหน้า', desc: 'ไม่ต้องรอนาน' },
  { icon: 'flat-color-icons:vip', title: 'สิทธิ์ VIP', desc: 'แต้มโบนัสพิเศษ' },
]

const atmosphere = [
  { src: '/images/atmosphere/tent-sign.jpg', caption: 'เปิดร้านทุกเช้า ที่ไหนก็ตามไปได้' },
  { src: '/images/atmosphere/espresso-detail.jpg', caption: 'ชงสดทุกแก้ว ไม่มีเตรียมล่วงหน้า' },
  { src: '/images/atmosphere/camp-chairs.jpg', caption: 'มีที่นั่งให้แวะพักจิบกาแฟ' },
  { src: '/images/atmosphere/open-sign.jpg', caption: 'เปิดจันทร์–เสาร์ 09:00–13:00' },
  { src: '/images/atmosphere/roadside-speaker.jpg', caption: 'เพลงเบาๆ ริมถนน บรรยากาศสบายๆ' },
  { src: '/images/atmosphere/rain-day.jpg', caption: 'ฝนตกก็ยังเปิด รอลูกค้าทุกวัน' },
]

onMounted(async () => {
  const res = await http.get<{ success: boolean; data: HomeData }>('/api/public/home')
  data.value = res.data ?? null
})

// duplicate products for seamless marquee loop
const marqueeProducts = computed(() => {
  const p = data.value?.products ?? []
  return p.length > 0 ? [...p, ...p] : []
})
</script>

<template>
  <div class="jp-home">
    <!-- ─── Truck Location Status Pill ───────────────────────────────────── -->
    <div v-if="data?.truckLocation" class="status-bar">
      <div class="status-bar-inner">
        <div class="status-pill" :class="data.truckLocation.isOpen ? 'is-open' : data.truckLocation.canOrder ? 'is-preorder' : 'is-closed'">
          <span class="status-dot" />
          <template v-if="data.truckLocation.isOpen">
            <span>วันนี้อยู่ที่ <b>{{ data.truckLocation.name }}</b></span>
            <span class="sep">·</span>
            <span>{{ data.truckLocation.openTime }}–{{ data.truckLocation.closeTime }}</span>
          </template>
          <template v-else-if="data.truckLocation.canOrder">
            <span>ร้านปิดอยู่ แต่สั่งออนไลน์ได้</span>
            <template v-if="data.truckLocation.nextOpenLabel">
              <span class="sep">·</span>
              <span>เปิดอีกครั้ง {{ data.truckLocation.nextOpenLabel }}</span>
            </template>
          </template>
          <template v-else-if="data.truckLocation.nextOpenLabel">
            <span>ร้านปิดอยู่ เปิดอีกครั้ง {{ data.truckLocation.nextOpenLabel }}</span>
            <template v-if="data.truckLocation.nextOpenName">
              <span class="sep">·</span>
              <span>ที่ {{ data.truckLocation.nextOpenName }}</span>
            </template>
          </template>
          <template v-else>
            <span>ร้านปิดอยู่</span>
          </template>
        </div>
        <div class="status-actions">
          <a
            v-if="data.truckLocation.mapUrl"
            :href="data.truckLocation.mapUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="status-link"
          >
            <Icon name="mdi:map-marker" />
            แผนที่
          </a>
          <button
            v-if="data.truckLocation.schedules?.length"
            class="status-link status-link-ghost"
            @click="showTimeline = true"
          >
            <Icon name="mdi:calendar-clock" />
            ไทม์ไลน์
          </button>
        </div>
      </div>
    </div>

    <SharedLocationTimeline
      v-if="showTimeline && data?.truckLocation"
      :schedules="data.truckLocation.schedules"
      :active-schedule-id="data.truckLocation.activeScheduleId"
      @close="showTimeline = false"
    />

    <!-- ─── Hero ─────────────────────────────────────────────────────────── -->
    <section class="hero">
      <div class="hero-media">
        <img src="/hero-sunset.jpg" alt="" />
      </div>
      <div class="hero-scrim" />

      <div class="hero-body">
        <div class="hero-eyebrow">
          <img src="/logo.jpg" alt="" />
          <span>รถกาแฟข้างทาง · เชียงใหม่</span>
        </div>
        <h1>โคตรเข้ม<br>ที่<em>ริมทาง</em></h1>
        <p class="sub">ตามรถเข็นไปทุกมุมเมือง สั่งล่วงหน้าได้ ไม่ต้องรอคิว แล้วมาจิบกาแฟแก้วโปรดกับเรา</p>
        <div class="hero-ctas">
          <NuxtLink to="/order" class="btn btn-primary">สั่งออนไลน์</NuxtLink>
          <NuxtLink to="/member/register" class="btn btn-secondary">สมัครสมาชิกฟรี</NuxtLink>
        </div>
      </div>

      <svg class="wave" viewBox="0 0 1440 64" preserveAspectRatio="none">
        <path d="M0,32 C240,64 480,0 720,16 C960,32 1200,64 1440,24 L1440,64 L0,64 Z" fill="#FBF4E8" />
      </svg>
    </section>

    <!-- ─── PWA Install Banner ───────────────────────────────────────────── -->
    <Transition name="slide-down">
      <div v-if="canInstall && !dismissedBanner" class="pwa-banner">
        <div class="pwa-banner-inner">
          <img src="/logo.jpg" alt="" class="pwa-logo" />

          <template v-if="hasNativePrompt">
            <div class="pwa-text">
              <p class="pwa-title">ติดตั้ง JP Sibling</p>
              <p class="pwa-sub">เพิ่มไปหน้าจอหลักเพื่อใช้งานง่ายขึ้น</p>
            </div>
            <button class="pwa-btn" @click="install">ติดตั้ง</button>
          </template>

          <template v-else-if="platform === 'ios-safari'">
            <div class="pwa-text">
              <p class="pwa-title">ติดตั้ง JP Sibling บน iPhone</p>
              <p class="pwa-sub">
                กดปุ่ม <Icon name="mdi:export-variant" class="inline-icon" /> แชร์ (Share) แล้วเลือก "เพิ่มไปยังหน้าจอโฮม (Add to Home Screen)"
              </p>
            </div>
          </template>

          <template v-else-if="platform === 'ios-other'">
            <div class="pwa-text">
              <p class="pwa-title">ติดตั้งผ่าน Safari</p>
              <p class="pwa-sub">Chrome บน iOS ไม่รองรับ — คัดลอกลิงก์แล้วเปิดใน Safari จากนั้นกด "เพิ่มไปยังหน้าจอโฮม"</p>
            </div>
            <button class="pwa-btn" @click="copyUrlAndDismiss">คัดลอกลิงก์</button>
          </template>

          <button class="pwa-close" @click="dismissedBanner = true">
            <Icon name="mdi:close" />
          </button>
        </div>
      </div>
    </Transition>

    <!-- ─── Campaigns ────────────────────────────────────────────────────── -->
    <section v-if="data?.campaigns.length" class="promos">
      <div class="wrap">
        <div class="section-head">
          <div>
            <p class="kicker">สิทธิพิเศษประจำเดือน</p>
            <h2>โปรโมชันตอนนี้</h2>
          </div>
        </div>

        <div class="promo-grid">
          <div
            v-for="(campaign, i) in data.campaigns"
            :key="campaign.id"
            class="promo-card"
            :class="i % 2 === 0 ? 'tilt-left' : 'tilt-right'"
          >
            <div class="promo-tag"><span class="d" />NEW</div>

            <template v-if="campaign.displayMode !== 'banner'">
              <div class="promo-img">
                <img v-if="campaign.imageUrl" :src="campaign.imageUrl" :alt="campaign.name" />
                <div v-else class="promo-img-fallback" />
              </div>
              <div class="promo-body">
                <h3>{{ campaign.name }}</h3>
                <p v-if="campaign.description" class="promo-desc">{{ campaign.description }}</p>
                <ul v-if="campaign.coupons.length" class="promo-bundles">
                  <li v-for="c in campaign.coupons" :key="c.id">{{ formatBundlePromo(c) }}</li>
                </ul>
              </div>
            </template>

            <template v-else>
              <div class="promo-banner" :style="`background: ${campaign.bannerColor || '#1C64D1'}`">
                <img v-if="campaign.imageUrl" :src="campaign.imageUrl" alt="" />
                <div class="promo-banner-text">
                  <h3>{{ campaign.name }}</h3>
                  <p v-if="campaign.description">{{ campaign.description }}</p>
                  <ul v-if="campaign.coupons.length" class="promo-bundles promo-bundles-banner">
                    <li v-for="c in campaign.coupons" :key="c.id">{{ formatBundlePromo(c) }}</li>
                  </ul>
                </div>
              </div>
            </template>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── Menu Marquee ─────────────────────────────────────────────────── -->
    <section class="menu">
      <div class="wrap">
        <div class="section-head section-head-center">
          <div>
            <p class="kicker">เมนูแนะนำ</p>
            <h2>รสที่คนสั่งซ้ำบ่อยที่สุด</h2>
          </div>
        </div>
      </div>

      <div v-if="!data" class="menu-skeleton">
        <div v-for="i in 5" :key="i" class="menu-skeleton-card" />
      </div>

      <div v-else-if="!data.products.length" class="menu-empty">ยังไม่มีเมนู</div>

      <div v-else class="marquee-wrap">
        <div class="marquee-track">
          <div v-for="(product, idx) in marqueeProducts" :key="`${product.id}-${idx}`" class="menu-card">
            <div class="menu-card-img">
              <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" />
              <Icon v-else name="flat-color-icons:shop" class="menu-card-fallback" />
            </div>
            <div class="menu-card-info">
              <p class="menu-card-name">{{ product.name }}</p>
              <p class="menu-card-cat">{{ product.category.name }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── Atmosphere Gallery ───────────────────────────────────────────── -->
    <section class="atmosphere">
      <div class="wrap">
        <div class="section-head">
          <div>
            <p class="kicker">บรรยากาศร้าน</p>
            <h2>เช้าแบบนี้ ที่ JP Sibling</h2>
          </div>
          <p class="section-head-note">ภาพจริงจากหน้าร้าน ไม่ปรุงแต่ง เช้าไหนฝนตกก็ยังเปิดรอ</p>
        </div>

        <div class="atmosphere-grid">
          <figure
            v-for="(shot, i) in atmosphere"
            :key="shot.src"
            class="atmosphere-item"
            :class="`atmosphere-item-${i}`"
          >
            <img :src="shot.src" :alt="shot.caption" loading="lazy" />
            <figcaption>{{ shot.caption }}</figcaption>
          </figure>
        </div>
      </div>
    </section>

    <!-- ─── Member Benefits ──────────────────────────────────────────────── -->
    <section class="benefits">
      <div class="wrap">
        <div class="section-head section-head-center">
          <div>
            <p class="kicker">สมัครฟรี ใช้เวลาไม่ถึง 1 นาที</p>
            <h2>ทำไมต้องสมัครสมาชิก?</h2>
          </div>
        </div>

        <div class="benefit-grid">
          <div v-for="b in benefits" :key="b.title" class="benefit-card">
            <div class="benefit-icon">
              <img v-if="b.image" :src="b.image" :alt="b.title" />
              <Icon v-else :name="b.icon!" />
            </div>
            <h4>{{ b.title }}</h4>
            <p>{{ b.desc }}</p>
          </div>
        </div>

        <div class="benefits-cta">
          <NuxtLink to="/member/register" class="btn btn-primary">สมัครสมาชิกฟรี</NuxtLink>
        </div>
      </div>
    </section>

    <!-- ─── Footer ───────────────────────────────────────────────────────── -->
    <footer class="site-footer">
      <div class="wrap">
        <img src="/logo.jpg" alt="JP Sibling" class="footer-logo" />
        <div class="footer-links">
          <a href="https://lin.ee/Yo7V4CO" target="_blank" rel="noopener noreferrer">
            <Icon name="mdi:chat" />LINE OA
          </a>
          <a href="https://www.instagram.com/jp.sibling/" target="_blank" rel="noopener noreferrer">
            <Icon name="mdi:instagram" />Instagram
          </a>
          <a href="https://www.facebook.com/jp.sibling/" target="_blank" rel="noopener noreferrer">
            <Icon name="mdi:facebook" />Facebook
          </a>
        </div>
        <p class="footer-copy">© {{ new Date().getFullYear() }} <NuxtLink to="/admin">JP Sibling</NuxtLink> · Coffee Truck · Chiang Mai</p>
        <p class="footer-version">v{{ $config.public.appVersion }}</p>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.jp-home {
  --ink: #0E2A4D;
  --ink-soft: #4A6487;
  --blue: #1C64D1;
  --blue-deep: #124A9E;
  --cream: #FBF4E8;
  --cream-deep: #F0E2C8;
  --cream-card: #FFFDF8;
  --ember: #E07A1F;
  --line: #E2D4B8;
  --shadow: 0 12px 28px -14px rgba(14, 42, 77, 0.35);

  background: var(--cream);
  color: var(--ink);
  font-family: 'IBM Plex Sans Thai', 'Noto Sans Thai', system-ui, sans-serif;
  overflow-x: hidden;
}

.jp-home :deep(h1),
.jp-home :deep(h2),
.jp-home :deep(h3) {
  text-wrap: balance;
}

.display,
.jp-home h1,
.jp-home h2,
.jp-home h3 {
  font-family: 'Fraunces', 'IBM Plex Sans Thai', serif;
}

.wrap {
  max-width: 1120px;
  margin: 0 auto;
  padding: 0 1.5rem;
}

/* ───────── status bar ───────── */
.status-bar {
  background: var(--ink);
  color: var(--cream);
}
.status-bar-inner {
  max-width: 1120px;
  margin: 0 auto;
  padding: 0.65rem 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
}
.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 500;
  flex-wrap: wrap;
}
.status-pill b { font-weight: 700; }
.status-pill .sep { opacity: 0.4; }
.status-dot {
  width: 8px; height: 8px; border-radius: 50%;
  flex-shrink: 0;
  background: #4ADE80;
  box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.25);
}
.status-pill.is-preorder .status-dot { background: #60A5FA; box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.25); }
.status-pill.is-closed .status-dot { background: #F87171; box-shadow: 0 0 0 3px rgba(248, 113, 113, 0.25); }

.status-actions { display: flex; gap: 0.5rem; flex-shrink: 0; }
.status-link {
  display: inline-flex; align-items: center; gap: 0.35rem;
  padding: 0.4rem 0.8rem;
  background: rgba(255, 255, 255, 0.12);
  border: none;
  color: var(--cream);
  border-radius: 999px;
  font-size: 0.78rem;
  font-weight: 500;
  text-decoration: none;
  cursor: pointer;
  transition: background-color 0.2s ease;
}
.status-link:hover { background: rgba(255, 255, 255, 0.2); }

/* ───────── hero ───────── */
.hero {
  position: relative;
  min-height: 56vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
@media (min-width: 768px) {
  .hero { min-height: 86vh; }
}
.hero-media { position: absolute; inset: 0; }
.hero-media img {
  width: 100%; height: 100%; object-fit: cover;
  object-position: 38% 55%;
}
.hero-scrim {
  position: absolute; inset: 0;
  background:
    linear-gradient(180deg, rgba(14,42,77,0.45) 0%, rgba(14,42,77,0.18) 30%, rgba(14,42,77,0.22) 55%, rgba(8,23,48,0.88) 100%),
    linear-gradient(100deg, rgba(14,42,77,0.5) 0%, rgba(14,42,77,0.08) 50%);
}
.hero-body {
  position: relative;
  margin-top: auto;
  max-width: 1120px;
  margin-left: auto; margin-right: auto;
  width: 100%;
  padding: 0 1.5rem 3rem;
  color: #fff;
}
@media (min-width: 768px) {
  .hero-body { padding-bottom: 4.5rem; }
}
.hero-eyebrow {
  display: flex; align-items: center; gap: 0.6rem;
  margin-bottom: 1rem;
}
.hero-eyebrow img {
  width: 34px; height: 34px; border-radius: 50%; object-fit: cover;
  border: 2px solid rgba(255, 255, 255, 0.5);
}
.hero-eyebrow span { font-size: 0.9rem; opacity: 0.85; font-weight: 500; }

.hero h1 {
  font-weight: 600;
  font-size: clamp(2.1rem, 6vw, 4.2rem);
  line-height: 1.35;
  margin: 0 0 1rem;
  max-width: 14ch;
}
.hero h1 em {
  font-style: italic;
  font-weight: 500;
  color: #FFD9A8;
}
.hero p.sub {
  font-size: clamp(0.95rem, 1.6vw, 1.15rem);
  max-width: 36ch;
  opacity: 0.92;
  margin: 0 0 1.8rem;
  line-height: 1.55;
}
.hero-ctas { display: flex; gap: 0.8rem; flex-wrap: wrap; }

.btn {
  display: inline-flex; align-items: center; gap: 0.5rem;
  padding: 0.85rem 1.6rem;
  border-radius: 999px;
  font-weight: 700;
  font-size: 0.95rem;
  text-decoration: none;
  transition: transform 0.18s ease;
}
.btn:hover { transform: translateY(-2px); }
.btn-primary { background: var(--ember); color: #fff; box-shadow: 0 14px 30px -12px rgba(224, 122, 31, 0.65); }
.btn-secondary { background: rgba(255, 255, 255, 0.95); color: var(--ink); box-shadow: 0 14px 30px -14px rgba(0, 0, 0, 0.3); }

.wave { display: block; width: 100%; height: 48px; position: relative; margin-top: -2px; }
@media (min-width: 768px) {
  .wave { height: 64px; }
}

/* ───────── pwa banner ───────── */
.pwa-banner { background: rgba(14, 42, 77, 0.96); color: #fff; }
.pwa-banner-inner {
  max-width: 1120px; margin: 0 auto;
  padding: 0.75rem 1.5rem;
  display: flex; align-items: center; gap: 0.75rem;
}
.pwa-logo { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; flex-shrink: 0; }
.pwa-text { flex: 1; min-width: 0; }
.pwa-title { font-size: 0.9rem; font-weight: 600; line-height: 1.3; margin: 0; }
.pwa-sub { font-size: 0.78rem; color: rgba(255, 255, 255, 0.6); line-height: 1.3; margin: 0; }
.inline-icon { display: inline; vertical-align: middle; }
.pwa-btn {
  padding: 0.5rem 0.9rem;
  background: #fff; color: var(--ink);
  font-size: 0.78rem; font-weight: 700;
  border-radius: 8px; border: none; flex-shrink: 0; cursor: pointer;
}
.pwa-close { background: none; border: none; color: rgba(255, 255, 255, 0.5); padding: 0.25rem; flex-shrink: 0; cursor: pointer; }
.pwa-close:hover { color: #fff; }

.slide-down-enter-active, .slide-down-leave-active { transition: all 0.3s ease; }
.slide-down-enter-from, .slide-down-leave-to { opacity: 0; transform: translateY(-12px); }

/* ───────── section shells ───────── */
.section-head {
  display: flex; align-items: flex-end; justify-content: space-between;
  gap: 1.5rem; margin-bottom: 2rem; flex-wrap: wrap;
}
.section-head-center { justify-content: center; text-align: center; }
.section-head-note { margin: 0; color: var(--ink-soft); max-width: 28ch; font-size: 0.92rem; }
.kicker { font-size: 0.82rem; color: var(--blue); font-weight: 600; margin: 0 0 0.35rem; }
.section-head h2 {
  font-weight: 600;
  font-size: clamp(1.5rem, 2.6vw, 2.1rem);
  margin: 0;
  color: var(--ink);
}

/* ───────── promos ───────── */
.promos { padding: 4rem 0 3rem; }
.promo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(0, 420px));
  gap: 2rem 1.8rem;
}
.promo-grid:has(.promo-card:only-child) { grid-template-columns: minmax(0, 420px); }
.promo-card {
  position: relative;
  background: var(--cream-card);
  border: 1px solid var(--line);
  border-radius: 22px;
  overflow: hidden;
  box-shadow: var(--shadow);
  transition: transform 0.25s ease;
}
.promo-card.tilt-left { transform: rotate(-1.1deg); }
.promo-card.tilt-right { transform: rotate(1deg); }
.promo-card:hover { transform: rotate(0deg) translateY(-4px); }

.promo-tag {
  position: absolute; top: 1rem; left: 1rem; z-index: 2;
  background: var(--ember); color: #fff;
  font-size: 0.72rem; font-weight: 700;
  padding: 0.35rem 0.75rem; border-radius: 999px;
  display: flex; align-items: center; gap: 0.4rem;
}
.promo-tag .d { width: 6px; height: 6px; border-radius: 50%; background: #fff; opacity: 0.85; }

.promo-img { height: 220px; background: var(--cream-deep); overflow: hidden; }
.promo-img img { width: 100%; height: 100%; object-fit: cover; }
.promo-img-fallback { width: 100%; height: 100%; background: linear-gradient(135deg, var(--blue), var(--blue-deep)); }
.promo-body { padding: 1.4rem 1.5rem 1.6rem; }
.promo-body h3 { font-size: 1.2rem; font-weight: 600; margin: 0 0 0.5rem; color: var(--ink); }
.promo-body p { margin: 0; color: var(--ink-soft); font-size: 0.92rem; line-height: 1.55; }
.promo-desc {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  white-space: pre-line;
}

.promo-banner { position: relative; display: flex; align-items: center; gap: 1.5rem; padding: 1.5rem; min-height: 220px; }
.promo-banner img { width: 96px; height: 96px; border-radius: 16px; object-fit: cover; border: 2px solid rgba(255,255,255,0.2); flex-shrink: 0; }
.promo-banner-text h3 { color: #fff; font-size: 1.2rem; margin: 0 0 0.5rem; }
.promo-banner-text p { color: rgba(255,255,255,0.75); font-size: 0.9rem; margin: 0; }

.promo-bundles {
  list-style: none;
  margin: 0.7rem 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}
.promo-bundles li {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--blue-deep);
  background: var(--cream-deep);
  padding: 0.35rem 0.7rem;
  border-radius: 999px;
  width: fit-content;
}
.promo-bundles li::before {
  content: "";
  width: 6px; height: 6px; border-radius: 50%;
  background: var(--ember);
  flex-shrink: 0;
}
.promo-bundles-banner li {
  color: #fff;
  background: rgba(255, 255, 255, 0.15);
}

/* ───────── menu marquee ───────── */
.menu { background: var(--cream-card); padding: 4rem 0; border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); }
.menu-skeleton, .marquee-wrap { margin-top: 0.5rem; }
.menu-skeleton { display: flex; gap: 1.25rem; padding: 0 1.5rem; }
.menu-skeleton-card { flex-shrink: 0; width: 160px; height: 208px; background: var(--cream-deep); border-radius: 18px; animation: pulse 1.5s ease-in-out infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
.menu-empty { text-align: center; color: var(--ink-soft); padding: 2rem 0; }

.marquee-wrap { position: relative; overflow: hidden; }
.marquee-wrap::before, .marquee-wrap::after {
  content: ""; position: absolute; top: 0; bottom: 0; width: 80px; z-index: 3;
}
.marquee-wrap::before { left: 0; background: linear-gradient(90deg, var(--cream-card), transparent); }
.marquee-wrap::after { right: 0; background: linear-gradient(270deg, var(--cream-card), transparent); }
.marquee-track {
  display: flex; gap: 1.25rem; width: max-content;
  animation: marquee 32s linear infinite;
  padding: 0 1.5rem;
}
.marquee-track:hover { animation-play-state: paused; }
@keyframes marquee { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }

.menu-card { flex-shrink: 0; width: 160px; background: var(--cream); border-radius: 18px; overflow: hidden; border: 1px solid var(--line); }
.menu-card-img { height: 136px; background: linear-gradient(145deg, var(--cream-deep), var(--line)); display: flex; align-items: center; justify-content: center; overflow: hidden; }
.menu-card-img img { width: 100%; height: 100%; object-fit: cover; }
.menu-card-fallback { font-size: 2.5rem; }
.menu-card-info { padding: 0.8rem 0.9rem 1rem; }
.menu-card-name { font-weight: 600; font-size: 0.88rem; line-height: 1.35; color: var(--ink); margin: 0; }
.menu-card-cat { font-size: 0.74rem; color: var(--ink-soft); margin: 0.25rem 0 0; }

/* ───────── atmosphere gallery ───────── */
.atmosphere { background: var(--cream-deep); padding: 4.5rem 0; }
.atmosphere-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  grid-auto-rows: 120px;
  gap: 0.9rem;
}
.atmosphere-item {
  position: relative;
  margin: 0;
  border-radius: 18px;
  overflow: hidden;
  box-shadow: var(--shadow);
}
.atmosphere-item img { width: 100%; height: 100%; object-fit: cover; display: block; transition: transform 0.4s ease; }
.atmosphere-item:hover img { transform: scale(1.05); }
.atmosphere-item figcaption {
  position: absolute; left: 0; right: 0; bottom: 0;
  padding: 0.9rem 1rem 0.7rem;
  background: linear-gradient(0deg, rgba(14,42,77,0.82) 0%, rgba(14,42,77,0) 100%);
  color: #fff;
  font-size: 0.78rem;
  font-weight: 500;
  line-height: 1.3;
  opacity: 0;
  transition: opacity 0.3s ease;
}
.atmosphere-item:hover figcaption { opacity: 1; }

.atmosphere-item-0 { grid-column: span 3; grid-row: span 2; }
.atmosphere-item-1 { grid-column: span 3; grid-row: span 1; }
.atmosphere-item-2 { grid-column: span 3; grid-row: span 1; }
.atmosphere-item-3 { grid-column: span 2; grid-row: span 2; }
.atmosphere-item-4 { grid-column: span 2; grid-row: span 2; }
.atmosphere-item-5 { grid-column: span 2; grid-row: span 2; }

@media (max-width: 860px) {
  .atmosphere-grid { grid-template-columns: repeat(2, 1fr); grid-auto-rows: 160px; }
  .atmosphere-item-0, .atmosphere-item-1, .atmosphere-item-2,
  .atmosphere-item-3, .atmosphere-item-4, .atmosphere-item-5 {
    grid-column: span 1; grid-row: span 1;
  }
  .atmosphere-item figcaption { opacity: 1; }
}

/* ───────── member benefits ───────── */
.benefits { background: var(--ink); padding: 5rem 0; position: relative; overflow: hidden; }
.benefits::before {
  content: ""; position: absolute; top: -120px; right: -120px;
  width: 420px; height: 420px; border-radius: 50%;
  background: radial-gradient(circle, rgba(28,100,209,0.35), transparent 70%);
}
.benefits .kicker { color: #8FB6F0; }
.benefits .section-head h2 { color: var(--cream); }

.benefit-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.1rem; margin: 2.2rem 0 2.8rem; position: relative; }
@media (max-width: 860px) {
  .benefit-grid { grid-template-columns: repeat(2, 1fr); }
}
.benefit-card { background: rgba(255,255,255,0.06); border: 1px solid rgba(255,255,255,0.1); border-radius: 20px; padding: 1.5rem 1.2rem; text-align: center; }
.benefit-icon {
  width: 44px; height: 44px; border-radius: 12px;
  background: rgba(28,100,209,0.3);
  display: flex; align-items: center; justify-content: center;
  font-size: 1.3rem; color: #8FB6F0;
  margin: 0 auto 1rem;
}
.benefit-icon img { width: 24px; height: 24px; object-fit: contain; }
.benefit-card h4 { color: var(--cream); font-size: 0.95rem; margin: 0 0 0.3rem; font-weight: 600; font-family: inherit; }
.benefit-card p { color: rgba(251,244,232,0.55); font-size: 0.8rem; margin: 0; line-height: 1.5; }
.benefits-cta { text-align: center; position: relative; }

/* ───────── footer ───────── */
.site-footer { background: #081730; color: rgba(251,244,232,0.55); padding: 3rem 0 2.2rem; text-align: center; }
.footer-logo { width: 44px; height: 44px; border-radius: 50%; margin: 0 auto 1rem; opacity: 0.85; object-fit: cover; }
.footer-links { display: flex; justify-content: center; gap: 2rem; font-size: 0.88rem; font-weight: 500; margin-bottom: 1rem; flex-wrap: wrap; }
.footer-links a { display: inline-flex; align-items: center; gap: 0.4rem; text-decoration: none; color: rgba(251,244,232,0.75); transition: color 0.2s ease; }
.footer-links a:hover { color: #fff; }
.footer-copy { font-size: 0.8rem; margin: 0 0 0.3rem; }
.footer-copy :deep(a) { color: inherit; text-decoration: none; }
.footer-copy :deep(a:hover) { color: #fff; }
.footer-version { font-size: 0.68rem; color: rgba(251,244,232,0.3); margin: 0; }
</style>
