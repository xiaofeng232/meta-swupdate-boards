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