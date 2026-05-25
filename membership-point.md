# Coffee Shop Membership & Point System

## Overview

ระบบสมาชิกสำหรับร้านกาแฟ รองรับ:
- LINE Login
- LINE OA
- Online Ordering
- Point System
- Tier Member
- QR Member สำหรับหน้าร้าน

---

# Authentication

## LINE Login

ใช้ LINE Login เป็นระบบสมาชิกหลัก

### Benefits
- ลูกค้าไม่ต้องสมัครใหม่
- Login ง่าย
- ลดการลืมรหัสผ่าน
- เชื่อม LINE OA ได้ง่าย
- เหมาะกับมือถือ

### User Data
เก็บข้อมูล:
- line_user_id
- display_name
- profile_image
- email (optional)

---

# LINE OA

ใช้สำหรับ:
- Broadcast Promotion
- Coupon
- แจ้งแต้ม
- แจ้ง Tier Upgrade
- แจ้งเมนูใหม่
- Customer Support

---

# Membership System

## Tier Member

### Silver
Default member

#### Benefits
- สะสมแต้มปกติ
- รับโปรโมชั่นทั่วไป

---

### Gold
ยอดสะสมครบ 2,000 บาท

#### Benefits
- รับแต้ม x1.25
- โปรโมชั่นเฉพาะสมาชิก
- โบนัสวันเกิด

---

### VIP
ยอดสะสมครบ 5,000 บาท

#### Benefits
- รับแต้ม x1.5
- ฟรีเครื่องดื่มวันเกิด
- สิทธิ์เข้าถึงเมนูใหม่ก่อน
- โปรโมชั่นพิเศษ

---

# Point System

## Earning Points

### Rate
- ทุก 10 บาท = 1 แต้ม

### Examples
| Amount | Points |
|---|---|
| 35 บาท | 3 แต้ม |
| 40 บาท | 4 แต้ม |
| 85 บาท | 8 แต้ม |

---

# Redeem Rewards

| Points | Reward |
|---|---|
| 30 | เพิ่มท็อปปิ้งฟรี |
| 50 | ลด 20 บาท |
| 100 | ฟรีเครื่องดื่ม 1 แก้ว |
| 150 | ฟรีเมนูพรีเมียม |

---

# Point Rules

## Expiration
- แต้มมีอายุ 1 ปี

## Conditions
- แต้มได้รับหลังชำระเงินสำเร็จ
- แต้มไม่สามารถโอนให้ผู้อื่นได้
- แต้มไม่สามารถแลกเป็นเงินสดได้

---

# Online Ordering Flow

## Customer Flow
1. Login ด้วย LINE
2. สั่งสินค้า
3. ชำระเงิน
4. รับแต้มอัตโนมัติ

---

# In-Store Point Collection

## QR Member

ลูกค้ามี QR Member ส่วนตัว

### Flow
1. ลูกค้าแสดง QR
2. พนักงานสแกน
3. ใส่ยอดซื้อ
4. ระบบเพิ่มแต้ม

---

# Security Recommendation

## Recommended
- ให้ร้านสแกน QR ลูกค้า
- แต้มเพิ่มผ่านระบบหลังบ้านเท่านั้น

## Avoid
- ลูกค้าสแกนเอง
- Manual point editing โดยไม่มี log

---

# Point Ledger System

ควรเก็บประวัติแต้มทุก transaction

## Example
| Type | Points | Description |
|---|---|---|
| Earn | +4 | Order #1024 |
| Redeem | -100 | Free Drink |
| Bonus | +20 | Birthday Reward |

---

# Future Features

## Recommended Features
- Daily Check-in
- Referral Program
- Coupon System
- Stamp Campaign
- Happy Hour Bonus
- Double Point Day

---

# Suggested Opening Promotion

## Launch Campaign
### Double Points
- แต้ม x2 ในช่วงเปิดร้าน

### Referral Bonus
- ชวนเพื่อนรับ +20 แต้ม

---

# Goal of the System

ระบบนี้ถูกออกแบบเพื่อ:
- เพิ่มลูกค้าประจำ
- เพิ่มการซื้อซ้ำ
- สร้าง Customer Loyalty
- เชื่อม Online + Offline Experience
- ใช้ LINE เป็น Customer Ecosystem หลัก