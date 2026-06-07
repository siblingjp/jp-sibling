export interface QuickMenuItem {
  productName: string
  options: string[]
  label?: string // ถ้าอยากแสดงชื่อย่อบนปุ่ม
}

export const QUICK_MENU: QuickMenuItem[] = [
  { productName: 'อเมริกาโน่เย็น', options: ['คั่วเข้ม', 'ไม่หวาน 0%'], label: 'อเม เข้ม ไม่หวาน' },
  { productName: 'อเมริกาโน่เย็น', options: ['คั่วกลาง', 'ไม่หวาน 0%'], label: 'อเม กลาง ไม่หวาน' },
  { productName: 'อเมริกาโน่ส้ม', options: ['คั่วเข้ม'], label: 'อเม ส้ม เข้ม' },
  { productName: 'อเมริกาโน่มะพร้าว', options: ['คั่วเข้ม'], label: 'อเม มะพร้าว เข้ม' },
  { productName: 'เอสเปรสโซ่เย็น', options: ['คั่วเข้ม', 'หวานปกติ 100%'], label: 'เอส เข้ม หวานปกติ' },
  { productName: 'เอสเปรสโซ่เย็น', options: ['คั่วเข้ม', 'หวานน้อย 50%'], label: 'เอส เข้ม หวานน้อย' },
  { productName: 'ชาเขียวเย็น', options: ['หวานน้อย 50%'], label: 'ชาเขียว หวานน้อย' },
  { productName: 'ชาไทยเย็น', options: ['หวานปกติ 100%'], label: 'ชาไทย หวานปกติ' },
  { productName: 'ชาไทยเย็น', options: ['หวานน้อย 50%'], label: 'ชาไทย หวานน้อย' },
  { productName: 'ลาเต้เย็น', options: ['หวานน้อย 50%'], label: 'ลาเต้ หวานน้อย' },
  { productName: 'ลาเต้เย็น', options: ['หวานน้อย 100%'], label: 'ลาเต้ หวานปกติ' },
  { productName: 'คาปูชิโน่เย็น', options: ['หวานปกติ 100%'], label: 'คาปู หวานปกติ' },
  { productName: 'กาแฟชาเขียว', options: ['หวานน้อย 100%'], label: 'กาแฟชาเขียว หวานปกติ' },
  { productName: 'กาแฟชาเขียว', options: ['หวานน้อย 50%'], label: 'กาแฟชาเขียว หวานน้อย' },
  { productName: 'กาแฟชาไทย', options: ['หวานปกติ 100%'], label: 'กาแฟชาไทย หวานปกติ' },
  { productName: 'กาแฟชาไทย', options: ['หวานน้อย 50%'], label: 'กาแฟชาไทย หวานน้อย' },
  { productName: 'มัจฉะลาเต้', options: ['หวานน้อย 50%'], label: 'มัจฉะลาเต้ หวานน้อย' },
  { productName: 'โกโก้เย็น', options: ['หวานปกติ 100%'], label: 'โกโก้ หวานปกติ' },
]
