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
-- 生成镜像
-- OTA/多设备镜像同步
-- LINUX RT
-- EtherCAT
-- MB
-- CAN