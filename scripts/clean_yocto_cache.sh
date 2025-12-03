#!/bin/bash
###########################################################################
# Script Function: Clear Yocto build caches without deleting downloaded files (DL_DIR)
# Compatible With: Raspberry Pi 4B + Yocto Scarthgap + meta-swupdate build environment
# Cleanup Scope: Compilation temp files, shared state cache, build locks, etc.
# Preserved Scope: Downloads directory (source packages, pre-fetched files, etc.)
###########################################################################

# ==================== Update the following path to match your setup ====================
# Yocto project root directory (parent folder of the "build" directory)
YOCTO_ROOT="/home/vagrant/workspaces/yocto-taishan"
# ======================================================================================

# Define key directories (no changes needed for default Yocto structure)
BUILD_DIR="${YOCTO_ROOT}/build"
DL_DIR="${BUILD_DIR}/downloads"  # Preserved: Downloaded source/packages
TMP_DIR="${BUILD_DIR}/tmp"       # Cleanup: Compilation temporary files
SSTATE_DIR="${BUILD_DIR}/sstate-cache"  # Cleanup: Shared state cache
CACHE_DIR="${BUILD_DIR}/cache"   # Cleanup: Additional cache files
LOCK_FILES="${BUILD_DIR}/*.lock" # Cleanup: Build lock files
LOG_FILES="${BUILD_DIR}/*.log"   # Cleanup: Build log files

# Check if build directory exists
if [ ! -d "${BUILD_DIR}" ]; then
    echo "❌ Error: Build directory ${BUILD_DIR} not found. Verify YOCTO_ROOT configuration!"
    exit 1
fi

# Prompt user for confirmation
echo "⚠️  About to clean the following caches (${DL_DIR} will be PRESERVED):"
echo "  - ${TMP_DIR} (Compilation temp files)"
echo "  - ${SSTATE_DIR} (Shared state cache)"
echo "  - ${CACHE_DIR} (Additional cache)"
echo "  - ${LOCK_FILES} (Build lock files)"
echo "  - ${LOG_FILES} (Build log files)"
read -p "✅ Confirm cleanup? [y/N] " -n 1 -r
echo -e "\n"
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "🚫 Cleanup cancelled. Exiting script."
    exit 0
fi

# Start cleanup (executed in priority order to avoid accidental deletion)
echo "📦 Starting cache cleanup..."

# 1. Clean temporary compilation directory (largest cache folder)
if [ -d "${TMP_DIR}" ]; then
    echo "  - Cleaning temp directory: ${TMP_DIR}"
    rm -rf "${TMP_DIR}"/*
    echo "    ✔️ Temp directory cleanup complete"
else
    echo "  - Temp directory ${TMP_DIR} not found. Skipping."
fi

# 2. Clean shared state cache
if [ -d "${SSTATE_DIR}" ]; then
    echo "  - Cleaning shared state cache: ${SSTATE_DIR}"
    rm -rf "${SSTATE_DIR}"/*
    echo "    ✔️ Sstate cache cleanup complete"
else
    echo "  - Sstate directory ${SSTATE_DIR} not found. Skipping."
fi

# 3. Clean additional cache directory
if [ -d "${CACHE_DIR}" ]; then
    echo "  - Cleaning additional cache: ${CACHE_DIR}"
    rm -rf "${CACHE_DIR}"/*
    echo "    ✔️ Additional cache cleanup complete"
else
    echo "  - Cache directory ${CACHE_DIR} not found. Skipping."
fi

# 4. Clean lock files and log files
if ls ${LOCK_FILES} 1> /dev/null 2>&1; then
    echo "  - Cleaning lock files: ${LOCK_FILES}"
    rm -f ${LOCK_FILES}
    echo "    ✔️ Lock files cleanup complete"
else
    echo "  - No lock files to clean. Skipping."
fi

if ls ${LOG_FILES} 1> /dev/null 2>&1; then
    echo "  - Cleaning log files: ${LOG_FILES}"
    rm -f ${LOG_FILES}
    echo "    ✔️ Log files cleanup complete"
else
    echo "  - No log files to clean. Skipping."
fi

# Verify downloaded files are preserved
if [ -d "${DL_DIR}" ] && [ "$(ls -A ${DL_DIR})" ]; then
    echo -e "\n📥 Download directory ${DL_DIR} is PRESERVED. Example files (first 5):"
    ls -lh "${DL_DIR}" | head -n 5  # Show first 5 files to confirm
else
    echo -e "\n⚠️  Download directory ${DL_DIR} is empty or missing. Verify DL_DIR configuration!"
fi

echo -e "\n🎉 Cache cleanup completed! Run 'kas build' to rebuild without re-downloading sources."