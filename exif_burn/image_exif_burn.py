import sys
from collections import namedtuple
from decimal import Decimal
from fractions import Fraction
from os import path

from exiftool import ExifToolHelper
from PIL import Image, ImageDraw, ImageFont

# exif text padding percentage
padding_side = 20
padding_bottom = 2

# Path to the signature image (must be square)
signature_path = "/Users/deac/Signature_Art.png"

# make sure imbage pathe is passed as argument
if len(sys.argv) != 2:
  print("Usage: python image_exif_burn.py <image_path>")
  sys.exit(1)

image_path = f"{sys.argv[1]}"
image_path_parts = path.splitext(image_path)

def get_exif_data(image_path):
  with ExifToolHelper() as et:
    metadata = et.get_metadata(image_path)

    # Get specific tags
    tags = [
      "XMP:Model",
      "XMP:LensModel",
      "XMP:FocalLength",
      "XMP:ISO",
      "XMP:ExposureTime",
      "XMP:FNumber",
      "Composite:ShutterSpeed",
      "XMP:DateTimeOriginal"
    ]

    specific_metadata = et.get_tags(image_path, tags=tags)[0]

    xmp_model               = specific_metadata["XMP:Model"]
    xmp_lens_model          = specific_metadata["XMP:LensModel"]
    xmp_focal_length        = specific_metadata["XMP:FocalLength"]
    xmp_iso                 = specific_metadata["XMP:ISO"]
    xmp_exposure_time       = specific_metadata["XMP:ExposureTime"]
    xmp_f_number            = specific_metadata["XMP:FNumber"]
    xmp_date_time_original  = specific_metadata["XMP:DateTimeOriginal"]
    composite_shutter_speed       = specific_metadata['Composite:ShutterSpeed']

    # Convert the shutter speed float to a fraction
    if isinstance(composite_shutter_speed, float):
      shutter_speed = Fraction(Decimal(composite_shutter_speed)).limit_denominator()
    else:
      shutter_speed = composite_shutter_speed

    exif_string = f"{xmp_model} + {xmp_lens_model} @ {xmp_focal_length}mm, ISO {xmp_iso}, {shutter_speed} sec, f/{xmp_f_number}, {xmp_date_time_original}"

    data = namedtuple("exif", ["model", "lens_model", "focal_length", "iso", "exposure_time", "f_number", "shutter_speed", "date_time_original", "exif_string"])
    return data(xmp_model, xmp_lens_model, xmp_focal_length, xmp_iso, xmp_exposure_time, xmp_f_number, shutter_speed, xmp_date_time_original, exif_string)

  # Finds the maximum font size that fits the text within the image width.
def calculate_font_size(text, image_width, max_font_size=72):
  image = Image.new("RGB", (image_width, 200))
  draw = ImageDraw.Draw(image)

  font_size = max_font_size
  font = ImageFont.load_default(font_size)

  while draw.textlength(text, font) > image_width:
      font_size -= 1
      font = ImageFont.load_default(font_size)

  return font

# Open the image
image = Image.open(image_path)
width, height = image.size
print(f"Image size: {width} x {height}")

ppih,ppiv = image.info.get("dpi")
print(f"PPIv: {ppiv}")

# Calculate text padding
padding_right = int(width * padding_side / 100)
padding_bottom = int(height * padding_bottom / 100)
print(f"Padding side: {padding_right}")
print(f"Padding bottom: {padding_bottom}")

data = get_exif_data(image_path)

print(f"Exif data: {data.exif_string}")
print(f"model: {data.model}")

font = calculate_font_size(data.exif_string, image.width - padding_right * 2)
print(f"Font size: {font.size}")

draw = ImageDraw.Draw(image)

text_width = draw.textlength(data.exif_string, font)
print(f"Text width: {text_width}")

draw.text(((width - text_width) // 2, height - padding_bottom), data.exif_string, font=font)

# Save the modified image
image.save(f"{image_path_parts[0]}-exif_burn{image_path_parts[1]}")
# image.show()