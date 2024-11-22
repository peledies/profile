import sys
from os import path

from exiftool import ExifToolHelper
from PIL import ExifTags, Image

# make sure imbage pathe is passed as argument
if len(sys.argv) != 2:
  print("Usage: python image_sign_burn.py <image_path>")
  sys.exit(1)

image_path = f"{sys.argv[1]}"
image_path_parts = path.splitext(image_path)
print(image_path)
# with ExifToolHelper() as et:
#   metadata = et.get_metadata(image_path)

#   # Get specific tags
#   tags = [
#     "XMP:Model",
#     "XMP:LensModel",
#     "XMP:FocalLength",
#     "XMP:ISO",
#     "XMP:ExposureTime",
#     "XMP:FNumber",
#     "XMP:ShutterSpeedValue",
#     "XMP:DateTimeOriginal"
#   ]

#   specific_metadata = et.get_tags(image_path, tags=tags)[0]

#   c_model        = specific_metadata["XMP:Model"]
#   c_lens         = specific_metadata["XMP:LensModel"]
#   c_focalLength  = specific_metadata["XMP:FocalLength"]
#   c_iso          = specific_metadata["XMP:ISO"]
#   c_exposure     = specific_metadata["XMP:ExposureTime"]
#   c_fStop        = specific_metadata["XMP:FNumber"]
#   c_shutterSpeed = specific_metadata["XMP:ShutterSpeedValue"]
#   c_date         = specific_metadata["XMP:DateTimeOriginal"]

#   # build the exif string
#   exif_string = f"{c_model} + {c_lens} @ {c_focalLength}mm, ISO {c_iso}, {c_exposure} sec, f/{c_fStop}, {c_date}"


with ExifToolHelper() as et:
  # et.execute("-all=", "-overwrite_original", image_path)
  et.set_tags(image_path, {
    "XMP:Model": "Canon EOS 5D Mark IV",
    "XMP:LensModel": "150-600mm F5-6.3 DG OS HSM | Contemporary 015",
    "XMP:ISO": "640",
    "XMP:ExposureTime": "1/800",
    "XMP:Aperature": "6.3",
    "Artist": "Deac Karns",
    "FocalLength": "600.0mm",
  })

