from PIL import Image
import os

src_path = 'assets/icon/app_icon.png'
if not os.path.exists(src_path):
    raise FileNotFoundError(f'Icon source not found: {src_path}')

sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

base_res = 'android/app/src/main/res'
img = Image.open(src_path).convert('RGBA')

for folder, size in sizes.items():
    path = os.path.join(base_res, folder)
    os.makedirs(path, exist_ok=True)
    out_path = os.path.join(path, 'ic_launcher.png')
    resized = img.resize((size, size), Image.LANCZOS)
    resized.save(out_path)
    print(f'Wrote {out_path} ({size}x{size})')

print('Android mipmap icons generated successfully.')
