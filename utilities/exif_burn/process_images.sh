#!/bin/bash

# Script to process all JPG images in a directory
# First burns EXIF data onto the image, then adds signature

# Check if directory argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    echo "Example: $0 /path/to/images"
    exit 1
fi

# Get the directory and script location
IMAGE_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="$SCRIPT_DIR/env/bin/python3"

# Check if directory exists
if [ ! -d "$IMAGE_DIR" ]; then
    echo "Error: Directory '$IMAGE_DIR' does not exist"
    exit 1
fi

# Check if Python virtual environment exists
if [ ! -f "$PYTHON" ]; then
    echo "Error: Python virtual environment not found at $PYTHON"
    echo "Please run: python3 -m venv env && source env/bin/activate && pip install -r requirements.txt"
    exit 1
fi

# Counter for processed images
count=0
total=$(find "$IMAGE_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | wc -l | tr -d ' ')

echo "Found $total JPG files in $IMAGE_DIR"
echo "Processing..."
echo ""

# Process each JPG file
find "$IMAGE_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r image_file; do
    count=$((count + 1))
    filename=$(basename "$image_file")

    echo "[$count/$total] Processing: $filename"

    # Step 1: Burn EXIF data
    echo "  → Burning EXIF data..."
    "$PYTHON" "$SCRIPT_DIR/image_exif_burn.py" "$image_file"

    if [ $? -ne 0 ]; then
        echo "  ✗ Error burning EXIF to $filename"
        continue
    fi

    # Get the exif_burn file path
    extension="${image_file##*.}"
    basename_no_ext="${image_file%.*}"
    exif_file="${basename_no_ext}-exif_burn.${extension}"

    if [ ! -f "$exif_file" ]; then
        echo "  ✗ EXIF file not created: $exif_file"
        continue
    fi

    # Step 2: Add signature to the EXIF burned image
    echo "  → Adding signature..."
    "$PYTHON" "$SCRIPT_DIR/image_sign_burn.py" "$exif_file"

    if [ $? -ne 0 ]; then
        echo "  ✗ Error adding signature to $exif_file"
        continue
    fi

    # Get the final file path
    final_file="${basename_no_ext}-exif_burn-signed.${extension}"

    if [ -f "$final_file" ]; then
        echo "  ✓ Complete: $(basename "$final_file")"
    else
        echo "  ✗ Final file not created"
    fi

    echo ""
done

echo "Processing complete!"
echo ""
echo "Output files are in the same directory as the source images with suffixes:"
echo "  - Original → *-exif_burn-signed.jpg (final output)"
echo "  - Intermediate → *-exif_burn.jpg (can be deleted if not needed)"
