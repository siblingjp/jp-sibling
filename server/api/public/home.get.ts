export default defineEventHandler(async () => {
  try {
    const now = new Date()

    const [products, campaigns, truckLocation, topRequests] = await Promise.all([
      prisma.product.findMany({
        where: { isActive: true },
        select: { id: true, name: true, imageUrl: true, category: { select: { name: true } } },
        orderBy: { createdAt: 'asc' },
        take: 8,
      }),
      prisma.campaign.findMany({
        where: {
          isActive: true,
          memberOnly: false,
          OR: [{ startAt: null }, { startAt: { lte: now } }],
          AND: [{ OR: [{ expiredAt: null }, { expiredAt: { gte: now } }] }],
        },
        select: { id: true, name: true, description: true, imageUrl: true, displayMode: true, bannerColor: true },
        orderBy: { createdAt: 'desc' },
        take: 4,
      }),
      prisma.truckLocation.findFirst({
        where: { isActive: true },
        include: {
          schedules: {
            where: { isActive: true },
            orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
          },
        },
      }),
      prisma.locationRequest.findMany({
        where: { isActive: true, weekYear: getMonthYear() },
        orderBy: { voteCount: 'desc' },
        take: 5,
        select: { id: true, name: true, description: true, voteCount: true },
      }),
    ])

    // lazy reset: ถ้าผ่าน 17:00 BKK รอบใหม่มาแล้ว ให้ clear manual override
    if (truckLocation && (truckLocation.manualClose || truckLocation.manualOpen || truckLocation.blockOnlineOrder)) {
      const { start } = getTodayRangeBKK()
      if (truckLocation.updatedAt < start) {
        await prisma.truckLocation.update({
          where: { id: truckLocation.id },
          data: { manualClose: false, manualOpen: false, blockOnlineOrder: false },
        })
        truckLocation.manualClose = false
        truckLocation.manualOpen = false
        truckLocation.blockOnlineOrder = false
      }
    }

    const activeSchedule = truckLocation ? getActiveSchedule(truckLocation.schedules, now) : null
    const nextSlot = (!activeSchedule && truckLocation)
      ? getNextSlot(truckLocation.schedules, now)
      : null

    const timelineOpen = truckLocation
      ? (truckLocation.schedules.length > 0 ? !!activeSchedule : truckLocation.isOpen)
      : false
    const isOpen = truckLocation?.manualOpen ? true : truckLocation?.manualClose ? false : timelineOpen

    const canOrder = !(truckLocation?.blockOnlineOrder ?? false)

    const locationData = truckLocation
      ? {
          id: truckLocation.id,
          name: activeSchedule?.name ?? truckLocation.name,
          description: activeSchedule?.description ?? truckLocation.description,
          mapUrl: activeSchedule?.mapUrl ?? truckLocation.mapUrl,
          openTime: activeSchedule?.openTime ?? truckLocation.openTime,
          closeTime: activeSchedule?.closeTime ?? truckLocation.closeTime,
          daysOfWeek: activeSchedule?.daysOfWeek ?? truckLocation.daysOfWeek,
          isOpen,
          canOrder,
          manualClose: truckLocation.manualClose,
          manualOpen: truckLocation.manualOpen,
          blockOnlineOrder: truckLocation.blockOnlineOrder,
          schedules: truckLocation.schedules,
          activeScheduleId: activeSchedule?.id ?? null,
          nextOpenLabel: nextSlot?.label ?? null,
          nextOpenName: nextSlot?.name ?? null,
        }
      : null

    return okResponse({ products, campaigns, truckLocation: locationData, topRequests })
  } catch (e) {
    handleError(e)
  }
})

type Schedule = { id: string; openTime: string; closeTime: string; daysOfWeek: string; name: string; description: string | null; mapUrl: string | null }

function getBkkAndToday(now: Date) {
  const bkk = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  const dayNames = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์']
  const todayName = dayNames[bkk.getDay()]
  const hhmm = bkk.getHours() * 60 + bkk.getMinutes()
  return { bkk, todayName, hhmm }
}

function toMinutes(t: string) {
  const [h, m] = t.split(':').map(Number)
  return h * 60 + m
}

function getActiveSchedule(schedules: Schedule[], now: Date) {
  const { todayName, hhmm } = getBkkAndToday(now)
  for (const s of schedules) {
    if (!s.daysOfWeek.includes(todayName)) continue
    if (hhmm >= toMinutes(s.openTime) && hhmm < toMinutes(s.closeTime)) return s
  }
  return null
}

function getNextSlot(schedules: Schedule[], now: Date) {
  if (!schedules.length) return null

  const bkk = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  const dayNames = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์']
  const thDayNames = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์']
  const thMonths = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.']
  const hhmm = bkk.getHours() * 60 + bkk.getMinutes()

  // วนหาสูงสุด 7 วันข้างหน้า
  for (let d = 0; d <= 7; d++) {
    const target = new Date(bkk)
    target.setDate(target.getDate() + d)
    const dayName = dayNames[target.getDay()]

    const candidates = schedules
      .filter(s => s.daysOfWeek.includes(dayName))
      .filter(s => d > 0 || toMinutes(s.openTime) > hhmm)
      .sort((a, b) => toMinutes(a.openTime) - toMinutes(b.openTime))

    if (!candidates.length) continue

    const slot = candidates[0]
    const buddhistYear = target.getFullYear() + 543
    const label = `วัน${thDayNames[target.getDay()]} ที่ ${target.getDate()} ${thMonths[target.getMonth()]} ${buddhistYear} ${slot.openTime} น.`

    return { label, name: slot.name, id: slot.id }
  }
  return null
}

function getMonthYear() {
  const bkk = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  return `${bkk.getFullYear()}-${String(bkk.getMonth() + 1).padStart(2, '0')}`
}
