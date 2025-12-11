#!/bin/bash
set -e
BUILD_DIR="${BUILD_DIR:-build}"
MACHINE="${MACHINE:-raspberrypi4-64}"
LOG_FILE="build-$(date +%Y%m%d-%H%M%S).log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# 1. Validate outputs
log "Validating build outputs..."
IMAGE_DIR="${BUILD_DIR}/tmp/deploy/images/${MACHINE}"

if [[ -f "${IMAGE_DIR}"/*.wic.bz2 ]]; then
    log "✅ WIC images generated:"
    ls -lh "${IMAGE_DIR}"/*.wic.bz2
else
    log "⚠️  WIC images not found"
fi

if [[ -f "${IMAGE_DIR}"/*.swu ]]; then
    log "✅ SWU update packages generated:"
    ls -lh "${IMAGE_DIR}"/*.swu
else
    log "⚠️  .swu not generated (configure in kas.yml if needed)"
fi

# 2. SDK build (if requested)
if [[ "$1" == "--sdk" || "$2" == "--sdk" ]]; then
    SDK_DIR="${BUILD_DIR}/tmp/deploy/sdk"
    if [[ -f "${SDK_DIR}"/*.sh ]]; then
        log "✅ SDK scripts generated:"
        ls -lh "${SDK_DIR}"*.sh
    else
        log "⚠️  SDK scripts not found"
    fi
fi

# 3. Build summary
log "=" "Build Summary"
log "✅ Build completed!"
log "Images: ${IMAGE_DIR}"
log "Log: $LOG_FILE"
log "Disk usage: $(du -sh ${BUILD_DIR})"