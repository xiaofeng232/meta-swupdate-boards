#!/bin/bash
set -e

# ==================== Configuration ====================
KAS_FILE="${KAS_FILE:-kas/rpi-swupdate-dev.yml}"
MACHINE="${MACHINE:-raspberrypi4-64}"
BUILD_DIR="${BUILD_DIR:-build}"
LOG_FILE="build-$(date +%Y%m%d-%H%M%S).log"

# ==================== Functions ====================

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Disk space check
check_disk_space() {
    local required_gb=50
    local available=$(df -BG "${BUILD_DIR}" | awk 'NR==2 {print $4}' | sed 's/G//')
    
    if [[ "$available" -lt "$required_gb" ]]; then
        log "⚠️  Warning: Available disk space < ${required_gb}GB (current: ${available}GB)"
        log "Consider freeing up space before building"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    fi
}

# Gracefully terminate bitbake
kill_bitbake() {
    log "Checking and terminating orphaned bitbake processes..."
    if pgrep -f bitbake >/dev/null; then
        pkill -SIGTERM -f bitbake || true
        sleep 3
        pgrep -f bitbake && pkill -9 -f bitbake || true
        sleep 2
    fi
}

# ==================== Main Execution ====================

log "Starting Yocto Build Process"
log "Config: $KAS_FILE | Machine: $MACHINE | Build Dir: $BUILD_DIR"

# 1. Pre-flight checks
command -v kas-container >/dev/null 2>&1 || { 
    log "❌ Error: kas-container not found. Install KAS first."
    exit 1
}
check_disk_space

# 2. Clean up processes and lock files
kill_bitbake
log "Removing lock files..."
find "${BUILD_DIR}" -name "*.lock" -delete 2>/dev/null || true
find "${BUILD_DIR}" -name "bitbake.*" -delete 2>/dev/null || true

# 3. Handle cleaning modes
case "$1" in
    --clean)
        log "Executing --clean: Removing tmp directory"
        rm -rf "${BUILD_DIR}"/tmp
        ;;
    --cleansstate)
        log "Executing --cleansstate: Removing sstate-cache"
        rm -rf "${BUILD_DIR}"/sstate-cache
        ;;
    --cleanall)
        log "Executing --cleanall: Complete cleanup"
        rm -rf "${BUILD_DIR}"/{tmp,sstate-cache,buildhistory,cache}
        ;;
    *) log "Incremental build (no cleanup)" ;;
esac

# 4. Main build process
log "Starting main image build..."
start_time=$(date +%s)

if kas-container build "${KAS_FILE}" 2>&1 | tee -a "$LOG_FILE"; then
    end_time=$(date +%s)
    log "✅ Main build completed in $(( (end_time - start_time) / 60 ))m $(( (end_time - start_time) % 60 ))s"
else
    log "❌ Build failed. Check log: $LOG_FILE"
    exit 1
fi

# 5. Validate outputs
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

# 6. SDK build (if requested)
if [[ "$1" == "--sdk" || "$2" == "--sdk" ]]; then
    SDK_DIR="${BUILD_DIR}/tmp/deploy/sdk"
    if [[ -f "${SDK_DIR}"/*.sh ]]; then
        log "✅ SDK scripts generated:"
        ls -lh "${SDK_DIR}"*.sh
    else
        log "⚠️  SDK scripts not found"
    fi
fi

# 7. Build summary
log "=" "Build Summary"
log "✅ Build completed!"
log "Images: ${IMAGE_DIR}"
log "Log: $LOG_FILE"
log "Disk usage: $(du -sh ${BUILD_DIR})"