export default defineEventHandler(async () => {
  try {
    const now = new Date()

    let truck = await prisma.truckLocation.findFirst({
      where: { isActive: true },
      include: {
        schedules: {
          where: { isActive: true },
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        },
      },
    })

    if (!truck) return okResponse({ isOpen: false, canOrder: false, nextOpenLabel: null, nextOpenName: null })

    // lazy reset: ถ้าผ่าน 17:00 BKK ของรอบถัดไปมาแล้ว ให้ clear manual override
    if (truck.manualClose || truck.manualOpen || truck.blockOnlineOrder) {
      const { start } = getTodayRangeBKK()
      if (truck.updatedAt < start) {
        await prisma.truckLocation.update({
          where: { id: truck.id },
          data: { manualClose: false, manualOpen: false, blockOnlineOrder: false },
        })
        truck = { ...truck, manualClose: false, manualOpen: false, blockOnlineOrder: false }
      }
    }

    const activeSchedule = getActiveSchedule(truck.schedules, now)
    const timelineOpen = truck.schedules.length > 0 ? !!activeSchedule : truck.isOpen
    const isOpen = truck.manualOpen ? true : truck.manualClose ? false : timelineOpen

    if (isOpen) {
      return okResponse({ isOpen: true, canOrder: true, manualClose: false, manualOpen: truck.manualOpen, nextOpenLabel: null, nextOpenName: null })
    }

    if (truck.blockOnlineOrder) {
      return okResponse({ isOpen: false, canOrder: false, manualClose: true, manualOpen: false, nextOpenLabel: null, nextOpenName: null })
    }

    const next = getNextSlot(truck.schedules, now)

    return okResponse({
      isOpen: false,
      canOrder: true,
      manualClose: truck.manualClose,
      manualOpen: false,
      nextOpenLabel: next?.label ?? null,
      nextOpenName: next?.name ?? null,
    })
  } catch (e) {
    handleError(e)
  }
})

type Schedule = { id: string; openTime: string; closeTime: string; daysOfWeek: string; name: string }

function toMinutes(t: string) {
  const [h, m] = t.split(':').map(Number)
  return h * 60 + m
}

function getBkk(now: Date) {
  return new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
}

function getActiveSchedule(schedules: Schedule[], now: Date) {
  const bkk = getBkk(now)
  const dayNames = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์']
  const todayName = dayNames[bkk.getDay()]
  const hhmm = bkk.getHours() * 60 + bkk.getMinutes()
  for (const s of schedules) {
    if (!s.daysOfWeek.includes(todayName)) continue
    if (hhmm >= toMinutes(s.openTime) && hhmm < toMinutes(s.closeTime)) return s
  }
  return null
}

function getNextSlot(schedules: Schedule[], now: Date) {
  if (!schedules.length) return null

  const bkk = getBkk(now)
  const dayNames = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์']
  const thMonths = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.']
  const hhmm = bkk.getHours() * 60 + bkk.getMinutes()

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
    const label = `วัน${dayNames[target.getDay()]} ที่ ${target.getDate()} ${thMonths[target.getMonth()]} ${buddhistYear} ${slot.openTime} น.`
    const minutesUntilOpen = d * 24 * 60 + toMinutes(slot.openTime) - hhmm

    return { label, name: slot.name, minutesUntilOpen }
  }
  return null
}
