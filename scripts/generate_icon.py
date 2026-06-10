from PIL import Image, ImageDraw
import os

os.makedirs('assets/icon', exist_ok=True)
S = 1024
img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

C = S // 2

DARK = (8, 60, 44, 255)
EMERALD = (22, 100, 72, 255)
GOLD = (212, 175, 55, 255)
LIGHT_GOLD = (235, 205, 100, 255)
CREAM = (245, 238, 215, 255)
WHITE = (255, 255, 255, 240)

def rounded_rect(x1, y1, x2, y2, r, fill=None, outline=None, w=1):
    draw.rounded_rectangle([x1, y1, x2, y2], radius=r, fill=fill, outline=outline, width=w)

P = 36
R = 180

for y in range(P, S - P):
    t = (y - P) / (S - 2 * P)
    r = int(DARK[0] + (EMERALD[0] - DARK[0]) * t)
    g = int(DARK[1] + (EMERALD[1] - DARK[1]) * t)
    b = int(DARK[2] + (EMERALD[2] - DARK[2]) * t)
    draw.line([(P, y), (S - P, y)], fill=(r, g, b, 255))

rounded_rect(P, P, S - P, S - P, R, fill=None)

overlay = Image.new('RGBA', (S, S), (0, 0, 0, 0))
od = ImageDraw.Draw(overlay)
od.rounded_rectangle([0, 0, S, S], radius=R, fill=(255, 255, 255, 255))
mask = overlay.split()[3]
img.putalpha(mask)

border_overlay = Image.new('RGBA', (S, S), (0, 0, 0, 0))
bd = ImageDraw.Draw(border_overlay)
bd.rounded_rectangle([P, P, S - P, S - P], radius=R, outline=GOLD, width=6)
img = Image.alpha_composite(img, border_overlay)

C1 = Image.new('RGBA', (S, S), (0, 0, 0, 0))
cd = ImageDraw.Draw(C1)

# ========== PREMIUM "B" DESIGN ==========
# Modern B built with smooth arcs and rounded rects

B_COLOR = CREAM
GOLD_ACCENT = GOLD

stem_x = C - 200
stem_w = 130
bowl_right = C + 240
bowl_upper_y = C - 280
bowl_lower_y = C + 30
bowl_h = 250
stem_top = C - 320
stem_bot = C + 320

# Main vertical stem - rounded rect
cd.rounded_rectangle(
    [stem_x, stem_top, stem_x + stem_w, stem_bot],
    radius=65, fill=B_COLOR
)

# Upper bowl - full rounded shape
ub_left = stem_x + stem_w - 40
ub_top = stem_top + 20
ub_right = bowl_right
ub_bottom = ub_top + bowl_h
cd.rounded_rectangle(
    [ub_left, ub_top, ub_right, ub_bottom],
    radius=120, fill=B_COLOR
)

# Lower bowl
lb_top = stem_bot - bowl_h - 20
lb_bottom = stem_bot
cd.rounded_rectangle(
    [ub_left, lb_top, ub_right, lb_bottom],
    radius=120, fill=B_COLOR
)

# Cutout in upper bowl to create elegant B shape
cut_r = 75
cut_x = ub_left + 30
cut_y1 = ub_top + 75
cut_y2 = lb_top + 75
cd.ellipse([cut_x, cut_y1, cut_x + 2 * cut_r, cut_y1 + 2 * cut_r], fill=(0, 0, 0, 0))
cd.ellipse([cut_x, cut_y2, cut_x + 2 * cut_r, cut_y2 + 2 * cut_r], fill=(0, 0, 0, 0))

# ========== LEAF ELEMENT ==========
# Elegant leaf wrapping around the B
LEAF_GREEN = (60, 160, 100, 255)
LEAF_DARK = (40, 120, 75, 255)
LEAF_GOLD = GOLD

# Leaf shape - sweeping curve on right side
leaf_cx = C + 280
leaf_cy = C - 120
leaf_rx = 160
leaf_ry = 80

# Main leaf body as an ellipse rotated using polygon approximation
import math
leaf_pts = []
for a in range(0, 360, 5):
    rad = math.radians(a)
    ex = leaf_cx + leaf_rx * math.cos(rad) * 0.8
    ey = leaf_cy + leaf_ry * math.sin(rad)
    leaf_pts.append((ex, ey))

# Draw leaf as two overlapping ellipses for a natural shape
cd.ellipse([leaf_cx - 60, leaf_cy - 130, leaf_cx + 80, leaf_cy + 30], fill=LEAF_GREEN)
cd.ellipse([leaf_cx - 20, leaf_cy - 100, leaf_cx + 100, leaf_cy + 60], fill=LEAF_DARK)

# Leaf vein
cd.arc([leaf_cx - 80, leaf_cy - 140, leaf_cx + 60, leaf_cy + 40],
       start=200, end=350, fill=LEAF_GOLD, width=10)

# ========== RECYCLE ARROW HINT ==========
# Subtle recycle arrows in gold
arrow_size = 50
arrow_dist = 210

# Three arrow dots/arcs arranged in a triangle
recycle_angles = [(0, "top"), (120, "right"), (240, "left")]
for angle_deg, pos in recycle_angles:
    rad = math.radians(angle_deg)
    ax = C + int(arrow_dist * math.sin(rad))
    ay = C + 80 - int(arrow_dist * math.cos(rad))
    # Small gold arc
    cd.arc([ax - 30, ay - 30, ax + 30, ay + 30],
           start=angle_deg - 60, end=angle_deg + 60, fill=GOLD, width=8)
    # Arrow tip
    tip_rad = math.radians(angle_deg + 60)
    tx = ax + int(35 * math.sin(tip_rad))
    ty = ay - int(35 * math.cos(tip_rad))
    cd.ellipse([tx - 6, ty - 6, tx + 6, ty + 6], fill=LIGHT_GOLD)

# ========== GOLD ACCENT DOT ==========
cd.ellipse([C + 180, C + 200, C + 210, C + 230], fill=GOLD)
cd.ellipse([C + 70, C + 260, C + 90, C + 280], fill=LIGHT_GOLD)
cd.ellipse([C - 70, C - 260, C - 50, C - 240], fill=LIGHT_GOLD)

# Soft glow behind main B
for r in range(30, 0, -1):
    alpha = int(12 * (1 - r / 30))
    cd.ellipse([C - 280 - r, C - 340 - r, C + 280 + r, C + 340 + r],
               outline=(255, 255, 255, alpha))

img = Image.alpha_composite(img, C1)

img.save('assets/icon/app_icon.png')
print('Generated assets/icon/app_icon.png')
