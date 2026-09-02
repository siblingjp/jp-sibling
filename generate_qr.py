#!/usr/bin/env python3
"""Generate a QR code for https://jp-sibling.com/order with a coffee cup icon and Thai text."""

import qrcode
from qrcode.constants import ERROR_CORRECT_H
from PIL import Image, ImageDraw, ImageFont
import math

# ── Config ──────────────────────────────────────────────────────────────────
URL        = "https://jp-sibling.com/order"
NAVY       = (27, 43, 75)          # #1B2B4B
WHITE      = (255, 255, 255)
CANVAS_W   = 600
CANVAS_H   = 700
QR_SIZE    = 480                   # target pixel size for the QR image
PADDING    = (CANVAS_W - QR_SIZE) // 2   # 60 px side padding

# ── 1. Generate QR code ──────────────────────────────────────────────────────
qr = qrcode.QRCode(
    version=None,
    error_correction=ERROR_CORRECT_H,
    box_size=10,
    border=4,
)
qr.add_data(URL)
qr.make(fit=True)

qr_img = qr.make_image(fill_color=NAVY, back_color=WHITE).convert("RGB")
qr_img = qr_img.resize((QR_SIZE, QR_SIZE), Image.LANCZOS)

# ── 2. Paste logo-icon.png onto the QR centre ────────────────────────────────
LOGO_PATH  = "/Users/phurachanphowutthirat/repo_jp/public/logo-icon.png"
logo_size  = int(QR_SIZE * 0.20)   # 20% of QR width
pad        = 10                    # white-halo padding

logo = Image.open(LOGO_PATH).convert("RGBA")
logo = logo.resize((logo_size, logo_size), Image.LANCZOS)

halo_size  = logo_size + pad * 2
halo = Image.new("RGBA", (halo_size, halo_size), (255, 255, 255, 255))
halo.paste(logo, (pad, pad), logo)

# Convert halo to RGB and paste onto QR
halo_rgb = Image.new("RGB", (halo_size, halo_size), WHITE)
halo_rgb.paste(halo, mask=halo.split()[3])

paste_x = (QR_SIZE - halo_size) // 2
paste_y = (QR_SIZE - halo_size) // 2
qr_img.paste(halo_rgb, (paste_x, paste_y))

# ── 3. Assemble final canvas ─────────────────────────────────────────────────
canvas = Image.new("RGB", (CANVAS_W, CANVAS_H), WHITE)
canvas.paste(qr_img, (PADDING, PADDING))

# ── 4. Add Thai text "สั่งกาแฟ" ──────────────────────────────────────────────
draw_c = ImageDraw.Draw(canvas)

# Try fonts with Thai support in priority order
font_paths = [
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    "/System/Library/Fonts/Supplemental/Tahoma.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Supplemental/Arial.ttf",
    "/Library/Fonts/Arial Unicode.ttf",
]

thai_font = None
for fp in font_paths:
    try:
        thai_font = ImageFont.truetype(fp, size=54)
        break
    except (OSError, IOError):
        continue

text      = "สั่งกาแฟ"
text_y    = PADDING + QR_SIZE + 20   # 20 px below QR

if thai_font:
    bbox   = draw_c.textbbox((0, 0), text, font=thai_font)
    tw     = bbox[2] - bbox[0]
    text_x = (CANVAS_W - tw) // 2 - bbox[0]
    draw_c.text((text_x, text_y), text, font=thai_font, fill=NAVY)
else:
    # Fallback: default bitmap font (no Thai glyphs, but won't crash)
    fb = ImageFont.load_default()
    draw_c.text((CANVAS_W // 2 - 40, text_y), text, font=fb, fill=NAVY)

# ── 5. Save ───────────────────────────────────────────────────────────────────
out_path = "/Users/phurachanphowutthirat/repo_jp/qr-order.png"
canvas.save(out_path, "PNG", optimize=True)
print(f"Saved: {out_path}")
print(f"Canvas size: {canvas.size}")
print(f"Thai font used: {thai_font.path if thai_font else 'default fallback'}")
