# yocto-taishan
[raspberrypi](https://meta-raspberrypi.readthedocs.io/en/latest)
## Quick links

## Description
## Dependencies
## Quick Start
runqemu qemux86-64 serialstdio
ssh root@192.168.7.2
## Quick Start with kas
## delete ssh-key
ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R "192.168.7.2"

#OPKG
    IMAGE_INSTALL += " opkg"
    EXTRA_IMAGE_FEATURES += "package-management"
    PACKAGE_FEED_URIS = "http://repo.opkg.net/edison/repo/all"
T


## Task
-- 生成镜像[OK]
-- OTA/多设备镜像同步
-- LINUX RT
-- MB
-- CAN
-- EtherCAT

# SDK
bitbake taishan-base-image -c populate_sdk
bitbake taishan-base-image -c populate_sdk_ext

# Scripts

## 基础构建（不生成SDK）
./scripts/Gen-yocto-taishan

## 增量构建并生成SDK
./scripts/Gen-yocto-taishan --sdk

## 清理后构建并生成SDK
./scripts/Gen-yocto-taishan --clean --sdk

## 仅清理sstate并生成SDK
./scripts/Gen-yocto-taishan --cleansstate --sdk

## 指定自定义镜像生成SDK
SDKIMAGE=core-image-full-cmdline ./scripts/Gen-yocto-taishan --sdk



    PREFERRED_PROVIDER_virtual/kernel = "linux-raspberrypi"
    PREFERRED_VERSION_linux-raspberrypi = "6.1%"
    IMAGE_INSTALL:append = " raspberrypi-firmware raspberrypi-firmware-bootloader"
    SERIAL_CONSOLE = "115200 ttyAMA0"
    RPI_USE_U_BOOT = "1"

    IMAGE_INSTALL:append = " swupdate swupdate-utils"
    DISABLE_ROOTFS_RESIZE = "1"
    SWUPDATE_TARGETS = "mmcblk0"
    SWUPDATE_IMAGES = "rootfs"
    SWUPDATE_ROOTFS_PARTITION = "/dev/mmcblk0p2"
    SWUPDATE_BOOT_PARTITION = "/dev/mmcblk0p1"
    KERNEL_FEATURES:append = " features/swupdate/swupdate.scc"

    DISTRO_FEATURES:append = " systemd"
    VIRTUAL-RUNTIME_init_manager = "systemd"
    DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"
    VIRTUAL-RUNTIME_initscripts = "systemd-compat-units"