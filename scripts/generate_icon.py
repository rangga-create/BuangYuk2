from PIL import Image, ImageDraw, ImageFont
import os

os.makedirs('assets/icon', exist_ok=True)
size = 1024
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Background gradient
for y in range(size):
    t = y / (size - 1)
    r = int(22 + (46 - 22) * t)
    g = int(85 + (135 - 85) * t)
    b = int(48 + (75 - 48) * t)
    draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

# Golden accent ring
ring_margin = 80
ring_width = 24
for i in range(ring_width):
    alpha = int(255 * (1 - i / ring_width))
    draw.ellipse(
        [
            ring_margin + i,
            ring_margin + i,
            size - ring_margin - i,
            size - ring_margin - i,
        ],
        outline=(212, 175, 55, alpha),
    )

# Soft shadow circle behind symbol
symbol_center = size // 2
shadow_radius = 320
for r in range(20):
    alpha = int(18 * (1 - r / 20))
    draw.ellipse(
        [
            symbol_center - shadow_radius - r,
            symbol_center - shadow_radius - r,
            symbol_center + shadow_radius + r,
            symbol_center + shadow_radius + r,
        ],
        outline=(0, 0, 0, alpha),
    )

# Symbol shapes for B + leaf/recycle
# Draw main B letter in dark emerald
b_color = (14, 77, 57, 255)
leaf_color = (183, 151, 54, 255)
accent_color = (206, 183, 87, 255)

# Main B vertical stem
stem_w = 120
stem_h = 520
stem_x = symbol_center - 180
stem_y = symbol_center - stem_h // 2
draw.rounded_rectangle(
    [stem_x, stem_y, stem_x + stem_w, stem_y + stem_h],
    radius=60,
    fill=b_color,
)

# Upper bowl
upper_box = [stem_x + stem_w - 20, stem_y, stem_x + 340, symbol_center - 40]
draw.pieslice(upper_box, start=270, end=90, fill=b_color)
# Lower bowl
lower_box = [stem_x + stem_w - 20, symbol_center + 40, stem_x + 340, stem_y + stem_h]
draw.pieslice(lower_box, start=270, end=90, fill=b_color)

# Cutouts to shape B into more elegant curves
cutout_w = 90
cutout_h = 220
cutout_x = stem_x + stem_w + 40
cutout_y1 = stem_y + 50
cutout_y2 = symbol_center + 30
for cy in (cutout_y1, cutout_y2):
    draw.ellipse([cutout_x, cy, cutout_x + cutout_w, cy + cutout_h], fill=(0, 0, 0, 0))

# Leaf / recycle shape integrated with B
leaf = [
    (symbol_center + 80, symbol_center - 160),
    (symbol_center + 170, symbol_center - 100),
    (symbol_center + 110, symbol_center - 15),
    (symbol_center + 40, symbol_center - 90),
]
draw.polygon(leaf, fill=leaf_color)
draw.ellipse([symbol_center + 50, symbol_center - 145, symbol_center + 150, symbol_center - 45], outline=accent_color, width=16)

# Recycle curve accent
draw.arc([symbol_center - 90, symbol_center - 230, symbol_center + 240, symbol_center + 80], start=220, end=320, fill=accent_color, width=22)

gold_dot = 16
for offset in [(symbol_center + 160, symbol_center - 100), (symbol_center - 120, symbol_center + 140)]:
    draw.ellipse([
        offset[0] - gold_dot,
        offset[1] - gold_dot,
        offset[0] + gold_dot,
        offset[1] + gold_dot,
    ], fill=accent_color)

img.save('assets/icon/app_icon.png')
print('Generated assets/icon/app_icon.png')
