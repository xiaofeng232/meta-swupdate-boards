#!/bin/bash
set -e  # Exit immediately on error

# ==============================================
# Configuration parameters (modify as needed)
# ==============================================
WIC_IMAGE_PATH="build/tmp/deploy/images/raspberrypi4-64/rpi-test-image-raspberrypi4-64.rootfs.wic"  # Path to WIC image
SDCARD_DEVICE=""  # Auto-detected; no manual input needed


# ==============================================
# Function: Display error message and exit
# ==============================================
error_exit() {
    echo -e "\033[31mERROR: $1\033[0m"
    exit 1
}


# ==============================================
# Function: Get file modification time (mtime)
# ==============================================
get_file_modify_time() {
    local file_path=$1
    # Get formatted modification time using stat (compatible with Linux distros)
    if stat --version 2>&1 | grep -q 'GNU'; then
        # GNU stat (Debian/Ubuntu, etc.)
        stat -c "%y" "$file_path"
    else
        # BSD stat (macOS, etc., if running the script on macOS)
        stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file_path"
    fi
}


# ==============================================
# 1. Check if WIC image exists and get update time
# ==============================================
echo "===== Checking WIC image file ====="
if [ ! -f "$WIC_IMAGE_PATH" ]; then
    error_exit "WIC image does not exist! Path: $WIC_IMAGE_PATH"
fi
echo "Found WIC image: $WIC_IMAGE_PATH"
echo "Image size: $(du -h "$WIC_IMAGE_PATH" | awk '{print $1}')"
# Get and display image modification time (update time)
IMAGE_MODIFY_TIME=$(get_file_modify_time "$WIC_IMAGE_PATH")
echo "Image update time (last modified): $IMAGE_MODIFY_TIME"


# ==============================================
# 2. Detect SD card device
# ==============================================
echo -e "\n===== Detecting SD card device ====="
echo "Currently connected storage devices:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -v 'loop\|rom'

read -p "Enter the SD card device name (e.g., sdb, without partition numbers): " SDCARD_DEVICE
SDCARD_PATH="/dev/$SDCARD_DEVICE"

# Verify device exists
if [ ! -b "$SDCARD_PATH" ]; then
    error_exit "Device $SDCARD_PATH does not exist!"
fi

# Warning: Avoid selecting system disks
if [[ "$SDCARD_DEVICE" == "sda" || "$SDCARD_DEVICE" == "nvme0n1" ]]; then
    read -p "Warning: $SDCARD_PATH may be a system disk! Continue? [y/N] " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        error_exit "Operation cancelled by user"
    fi
fi


# ==============================================
# 3. Unmount mounted SD card partitions
# ==============================================
echo -e "\n===== Unmounting SD card partitions ====="
MOUNTED_PARTITIONS=$(lsblk -o MOUNTPOINT "$SDCARD_PATH"* | grep -v '^$')
if [ -n "$MOUNTED_PARTITIONS" ]; then
    echo "Unmounting the following partitions: $MOUNTED_PARTITIONS"
    for part in $(ls "$SDCARD_PATH"*); do
        if mount | grep -q "$part"; then
            sudo umount "$part" || error_exit "Failed to unmount $part"
        fi
    done
else
    echo "No mounted partitions on the SD card; no unmounting needed"
fi


# ==============================================
# 4. Record flash start time and execute flashing
# ==============================================
echo -e "\n===== Starting image flashing ====="
# Record flash start time
BURN_START_TIME=$(date "+%Y-%m-%d %H:%M:%S")
echo "Flash start time: $BURN_START_TIME"
echo "Target device: $SDCARD_PATH"
read -p "Confirm flashing? This will erase all data on the SD card! [y/N] " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    error_exit "Operation cancelled by user"
fi

# Flash using dd with progress
sudo dd if="$WIC_IMAGE_PATH" of="$SDCARD_PATH" bs=4M status=progress conv=fsync || error_exit "Flashing failed!"

# Force sync to write data to SD card
sync

# Record flash completion time
BURN_FINISH_TIME=$(date "+%Y-%m-%d %H:%M:%S")


# ==============================================
# 5. Output complete time information
# ==============================================
echo -e "\033[32m===== Flashing complete! You can safely remove the SD card =====\033[0m"
echo -e "\033[32m===== Time record information =====\033[0m"
echo "WIC image update time: $IMAGE_MODIFY_TIME"
echo "Flash start time: $BURN_START_TIME"
echo "Flash finish time: $BURN_FINISH_TIME"