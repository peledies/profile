# EXIF Burn Utilities

A collection of Python scripts for adding EXIF metadata and signatures to images.

## Scripts

### 1. `image_exif_burn.py`
Burns EXIF metadata directly onto the image as text overlay at the bottom center.

**Output**: Creates a new file with `-exif_burn` suffix
- Example: `photo.jpg` → `photo-exif_burn.jpg`

**What it adds**: Camera model, lens, focal length, ISO, shutter speed, aperture, and date

### 2. `image_sign_burn.py`
Adds a rotated signature image to the bottom right corner of the image.

**Output**: Creates a new file with `-signed` suffix
- Example: `photo.jpg` → `photo-signed.jpg`

**Requirements**: Signature image at `/Users/deac/Signature_Art.png` (must be square)

**⚠️ Before using this script**: Update the `signature_path` variable in [image_sign_burn.py](image_sign_burn.py#L16) to point to your actual signature image file.

### 3. `image_exif_rewrite.py`
Utility for rewriting EXIF metadata in image files (currently configured for testing).

## Setup Instructions

### 1. Install System Dependencies

Then install required system libraries:
```bash
brew install jpeg libtiff little-cms2 openjpeg webp exiftool freetype
```

**Critical**: The `exiftool` command-line tool must be installed for the scripts to work.

### 2. Create Python Virtual Environment

```bash
python3 -m venv env
```

### 3. Activate Virtual Environment

```bash
source env/bin/activate
```

### 4. Install Python Dependencies

```bash
pip install -r requirements.txt
```

## Usage

### Important: Always use the virtual environment

You have two options:

**Option 1: Activate the virtual environment first (recommended)**
```bash
source env/bin/activate
python3 image_exif_burn.py "/path/to/your/image.jpg"
```

**Option 2: Use the virtual environment's Python directly**
```bash
env/bin/python3 image_exif_burn.py "/path/to/your/image.jpg"
```

### Running Each Script

**Burn EXIF data onto image:**
```bash
env/bin/python3 image_exif_burn.py "/path/to/image.jpg"
```

**Add signature to image:**
```bash
env/bin/python3 image_sign_burn.py "/path/to/image.jpg"
```

**Rewrite EXIF metadata:**
```bash
env/bin/python3 image_exif_rewrite.py "/path/to/image.jpg"
```

### Handling File Paths with Spaces

If your file path contains spaces, wrap it in quotes:
```bash
env/bin/python3 image_exif_burn.py "/path/to/my image file.jpg"
```

## Configuration

### image_exif_burn.py
- `padding_side`: Side padding percentage (default: 20%)
- `padding_bottom`: Bottom padding percentage (default: 2%)
- `signature_path`: Path to signature image (not currently used in this script)

### image_sign_burn.py
- `signature_rotate`: Rotation angle for signature (default: 45°)
- `signature_size`: Signature size as percentage of image (default: 5%)
- `padding`: Padding from edges (default: 2%)
- `signature_path`: **REQUIRED** - Path to your signature image file (must be a square PNG with transparency)
  - Update this path in the script before running
  - Example: `/Users/yourusername/Documents/my_signature.png`

## Troubleshooting

### Error: "Signature file not found"
- Open [image_sign_burn.py](image_sign_burn.py) and update the `signature_path` variable (around line 16)
- Point it to your actual signature image file
- The signature image should be:
  - Square dimensions (e.g., 1000x1000 pixels)
  - PNG format with transparent background
  - Your signature or watermark design

### Error: "ModuleNotFoundError: No module named 'exiftool'"
- Make sure you're using the virtual environment's Python: `env/bin/python3`
- Or activate the virtual environment first: `source env/bin/activate`

### Error: "exiftool is not found"
- Install exiftool: `brew install exiftool`
- Verify installation: `which exiftool`

### Error: "PermissionError: Operation not permitted"
- This is a macOS sandboxing issue
- Grant Terminal Full Disk Access in System Settings → Privacy & Security
- Or copy the image to a non-restricted location (not Desktop/Documents/Downloads)

### Error: Font-related errors
- Make sure freetype is installed: `brew install freetype`
- Reinstall Pillow: `env/bin/pip install pillow --upgrade --force-reinstall`

## Dependencies

- **Python 3.x**
- **Pillow**: Image processing library
- **PyExifTool**: Python wrapper for exiftool
- **exiftool**: Command-line tool for reading/writing EXIF data

## macOS Permissions

If you encounter permission errors when accessing images in certain folders (Desktop, Documents, Downloads), you need to grant Terminal full disk access:

1. Open System Settings
2. Go to Privacy & Security → Full Disk Access
3. Enable your Terminal application (Terminal.app or iTerm.app)
4. Restart your terminal