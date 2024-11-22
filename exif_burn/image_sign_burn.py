import sys
from os import path

from exiftool import ExifToolHelper
from PIL import Image, ImageDraw, ImageFont

# Signature rotation angle
signature_rotate = 45

# Signature size percent
signature_size = 5

# signature padding percentage
padding = 2

# Path to the signature image (must be square)
signature_path = "/Users/deac/Signature_Art.png"

# make sure imbage pathe is passed as argument
if len(sys.argv) != 2:
  print("Usage: python image_sign_burn.py <image_path>")
  sys.exit(1)

image_path = f"{sys.argv[1]}"
image_path_parts = path.splitext(image_path)

# Open the signature image
signature = Image.open(signature_path)

# Open the image
image = Image.open(image_path)
width, height = image.size
print(f"Image size: {width} x {height}")

# Calculate signature padding
padding_right = int(width * padding / 100)
padding_bottom = int(height * padding / 100)
padding_size = max(padding_right, padding_bottom)
print(f"Padding size: {padding_size}")

# Calculate signature size
signature_width = int(width * signature_size / 100)
signature_height = int(height * signature_size / 100)
signature_size = max(signature_height, signature_width)
print(f"Signature size: {signature_size}")

# Resize and rotate the signature
resized_signature = signature.resize((signature_size, signature_size))
resized_signature = resized_signature.rotate(signature_rotate, expand=True)

# Calculate signature position
signature_left = width - signature_size - padding_size
signature_top = height - signature_size - padding_size

# paste the signature on the image
image.paste(resized_signature, (signature_left,signature_top), resized_signature)

# Save the modified image
image.save(f"{image_path_parts[0]}-signed{image_path_parts[1]}")