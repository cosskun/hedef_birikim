import os
from PIL import Image, ImageDraw, ImageFilter

def make_squircle_mask(size, radius_ratio=0.22):
    scale = 4
    s = size * scale
    mask = Image.new('L', (s, s), 0)
    draw = ImageDraw.Draw(mask)
    r = int(s * radius_ratio)
    draw.rounded_rectangle([(0, 0), (s, s)], radius=r, fill=255)
    return mask.resize((size, size), Image.Resampling.LANCZOS)

def make_circle_mask(size):
    scale = 4
    s = size * scale
    mask = Image.new('L', (s, s), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse([(0, 0), (s, s)], fill=255)
    return mask.resize((size, size), Image.Resampling.LANCZOS)

base = Image.open('assets/images/logo.png').convert('RGBA')
bg_color = (204, 236, 221, 255)

# Center emblem extraction
cx, cy = 512, 512
radius = 350
emblem_crop = base.crop((cx - radius, cy - radius, cx + radius, cy + radius))

mask_emblem = make_circle_mask(radius * 2)
emblem_circle = Image.new('RGBA', (radius * 2, radius * 2), (0, 0, 0, 0))
emblem_circle.paste(emblem_crop, (0, 0), mask=mask_emblem)

# Master Adaptive Foreground (1024x1024)
fg_master = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
shadow_size = 720
shadow = Image.new('RGBA', (shadow_size, shadow_size), (0, 0, 0, 0))
shadow_draw = ImageDraw.Draw(shadow)
shadow_draw.ellipse([(10, 15), (shadow_size - 10, shadow_size - 5)], fill=(20, 60, 45, 60))
shadow = shadow.filter(ImageFilter.GaussianBlur(16))

fg_master.paste(shadow, ((1024 - shadow_size) // 2, (1024 - shadow_size) // 2 + 10), mask=shadow)
emblem_scaled = emblem_circle.resize((680, 680), Image.Resampling.LANCZOS)
fg_master.paste(emblem_scaled, ((1024 - 680) // 2, (1024 - 680) // 2), mask=emblem_scaled)

# Master Legacy Icon
legacy_master = Image.new('RGBA', (1024, 1024), bg_color)
legacy_master.paste(fg_master, (0, 0), mask=fg_master)

squircle_mask = make_squircle_mask(1024, radius_ratio=0.22)
legacy_squircle = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
legacy_squircle.paste(legacy_master, (0, 0), mask=squircle_mask)

circle_mask = make_circle_mask(1024)
legacy_circle = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
legacy_circle.paste(legacy_master, (0, 0), mask=circle_mask)

# Save updated in-app logo
legacy_squircle.save('assets/images/logo.png', 'PNG')
legacy_squircle.save('assets/images/logo_rounded.png', 'PNG')
fg_master.save('assets/images/logo_foreground.png', 'PNG')

# Android sizes
densities = {
    'mipmap-mdpi': (48, 108),
    'mipmap-hdpi': (72, 162),
    'mipmap-xhdpi': (96, 216),
    'mipmap-xxhdpi': (144, 324),
    'mipmap-xxxhdpi': (192, 432),
}

res_path = 'android/app/src/main/res'

for folder, (icon_size, fg_size) in densities.items():
    dir_p = os.path.join(res_path, folder)
    os.makedirs(dir_p, exist_ok=True)
    
    # 1. ic_launcher.png (squircle)
    ic = legacy_squircle.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    ic.save(os.path.join(dir_p, 'ic_launcher.png'), 'PNG')
    
    # 2. ic_launcher_round.png (circle)
    ic_r = legacy_circle.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    ic_r.save(os.path.join(dir_p, 'ic_launcher_round.png'), 'PNG')
    
    # 3. ic_launcher_foreground.png
    fg = fg_master.resize((fg_size, fg_size), Image.Resampling.LANCZOS)
    fg.save(os.path.join(dir_p, 'ic_launcher_foreground.png'), 'PNG')

# Create mipmap-anydpi-v26 folder and xmls
v26_dir = os.path.join(res_path, 'mipmap-anydpi-v26')
os.makedirs(v26_dir, exist_ok=True)

adaptive_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
'''

with open(os.path.join(v26_dir, 'ic_launcher.xml'), 'w', encoding='utf-8') as f:
    f.write(adaptive_xml)

with open(os.path.join(v26_dir, 'ic_launcher_round.xml'), 'w', encoding='utf-8') as f:
    f.write(adaptive_xml)

# Create/Update values/colors.xml
val_dir = os.path.join(res_path, 'values')
os.makedirs(val_dir, exist_ok=True)
colors_xml = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#CCECCD</color>
</resources>
'''
with open(os.path.join(val_dir, 'colors.xml'), 'w', encoding='utf-8') as f:
    f.write(colors_xml)

# Also web icons
web_icons_dir = 'web/icons'
if os.path.exists(web_icons_dir):
    legacy_squircle.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, 'Icon-192.png'), 'PNG')
    legacy_squircle.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, 'Icon-512.png'), 'PNG')
    legacy_squircle.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, 'Icon-maskable-192.png'), 'PNG')
    legacy_squircle.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons_dir, 'Icon-maskable-512.png'), 'PNG')
if os.path.exists('web/favicon.png'):
    legacy_squircle.resize((64, 64), Image.Resampling.LANCZOS).save('web/favicon.png', 'PNG')

print('All app icons and adaptive icon files generated successfully!')
