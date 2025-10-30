#!/bin/bash
set -e
export LANG=en_US.UTF-8

##############################################################################
# Modified to support specific image files (e.g., taishan-base-image-*.rpi-sdimg)
##############################################################################

# ========================== Configuration ==========================
# Supported image patterns (adjust to match your specific filenames)
SUPPORTED_IMAGE_PATTERNS=(
    "taishan-base-image-*.rpi-sdimg"       # Primary supported pattern
    "taishan-debug-image-*.rpi-sdimg"      # Optional: Add more patterns
)
DEFAULT_IMAGE_PATH="build/tmp/deploy/images/raspberrypi4-64/taishan-base-image-raspberrypi4-64.rootfs.rpi-sdimg"
MOUNT_POINT="/tmp/sdcard_mount"


# ========================== Utility Functions ==========================
info() { echo -e "\033[32m[INFO] $1\033[0m"; }
warn() { echo -e "\033[33m[WARN] $1\033[0m"; }
error() { echo -e "\033[31m[ERROR] $1\033[0m"; exit 1; }
confirm() {
    read -p "$1 (y/N) " -n 1 -r; echo
    [[ $REPLY =~ ^[Yy]$ ]] || error "Operation cancelled"
}


# ========================== Image Validation (Key Addition) ==========================
# Check if image matches any supported pattern
is_image_supported() {
    local image_basename=$(basename "$1")
    for pattern in "${SUPPORTED_IMAGE_PATTERNS[@]}"; do
        if [[ $image_basename == $pattern ]]; then
            return 0  # Supported
        fi
    done
    return 1  # Not supported
}


# ========================== Main Logic ==========================
# 1. Parse image path from argument or use default
IMAGE_PATH="${1:-$DEFAULT_IMAGE_PATH}"

# 2. Validate image existence
info "Checking image file..."
if [ ! -f "$IMAGE_PATH" ]; then
    error "Image file not found: $IMAGE_PATH"
fi

# 3. Check if image is supported (NEW: Enforce specific image patterns)
info "Validating image compatibility..."
if ! is_image_supported "$IMAGE_PATH"; then
    error "Unsupported image! Supported patterns: ${SUPPORTED_IMAGE_PATTERNS[*]}"
fi
info "Image is supported: $(basename "$IMAGE_PATH")"

# 4. Additional validation (ensure it's a valid SD image)
if ! file "$IMAGE_PATH" | grep -q "DOS/MBR boot sector"; then
    error "Invalid SD image format (must be rpi-sdimg with MBR)"
fi


# 5. (Optional) Special handling for specific images
image_basename=$(basename "$IMAGE_PATH")
if [[ $image_basename == *"debug"* ]]; then
    info "Debug image detected - enabling verbose flash mode"
    DD_EXTRA_ARGS="status=progress,verbose"  # Example: Special handling for debug images
else
    DD_EXTRA_ARGS="status=progress"
fi


# 6. Detect and select SD card (same as before)
info "Detecting SD card devices..."
SD_DEVICES=$(lsblk -dno NAME,TYPE,SIZE | grep -vE "sda|loop|nvme0n1" | grep "disk" | awk '{print "/dev/" $1}')
if [ -z "$SD_DEVICES" ]; then error "No SD card detected!"; fi

info "Detected SD cards:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT $(echo "$SD_DEVICES" | tr ' ' '\n')

if [ $(echo "$SD_DEVICES" | wc -w) -gt 1 ]; then
    read -p "Enter SD card to flash (e.g., /dev/sdb): " SD_DEVICE
    if ! echo "$SD_DEVICES" | grep -q "$SD_DEVICE"; then error "Invalid device"; fi
else
    SD_DEVICE="$SD_DEVICES"
fi


# 7. Unmount partitions and erase (same as before)
info "Unmounting SD card partitions..."
for PART in $(lsblk -no NAME "$SD_DEVICE" | grep -v "$(basename "$SD_DEVICE")"); do
    if mount | grep -q "/dev/$PART"; then
        sudo umount "/dev/$PART" || warn "Partition /dev/$PART not mounted"
    fi
done

confirm "Erase SD card partition table? (Recommended)"
sudo dd if=/dev/zero of="$SD_DEVICE" bs=1M count=10 status=progress || error "Erase failed"


# 8. Flash image with optional special handling
info "Flashing image to $SD_DEVICE..."
START_TIME=$(date +%s)
sudo dd if="$IMAGE_PATH" of="$SD_DEVICE" bs=4M $DD_EXTRA_ARGS conv=fsync || error "Flash failed"
END_TIME=$(date +%s)
info "Flash completed! Time: $(( (END_TIME-START_TIME)/60 ))m$(( (END_TIME-START_TIME)%60 ))s"


# 9. Validate and complete (same as before)
info "Validating flash..."
mkdir -p "$MOUNT_POINT"
BOOT_PARTITION="${SD_DEVICE}1"
if [ -b "$BOOT_PARTITION" ]; then
    sudo mount "$BOOT_PARTITION" "$MOUNT_POINT"
    if [ -f "$MOUNT_POINT/config.txt" ] && [ -f "$MOUNT_POINT/bootcode.bin" ]; then
        info "Validation successful: Boot files detected"
    else
        warn "Validation warning: Missing boot files"
    fi
    sudo umount "$MOUNT_POINT"
else
    warn "Validation warning: No boot partition found"
fi

info "==================== Done ===================="
info "Image: $IMAGE_PATH"
info "Flashed to: $SD_DEVICE"