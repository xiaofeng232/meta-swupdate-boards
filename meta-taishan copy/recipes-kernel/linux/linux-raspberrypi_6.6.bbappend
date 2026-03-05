# Copyright (c) 2025-2026 Taishan Control System. All rights reserved.
#
# Description:
#   change linux kernel sources
#
# Authors:
#   Lin Xiaofeng <xiaofeng.lin1@foxmail.com>
#
# Changelog:
#   0.0.1-rt1 (2026-01-19):
#     - Initial implementation
#
# License: Closed - Internal Use Only


SRC_URI:remove:raspberrypi4-64-taishan = "git://github.com/raspberrypi/linux.git;name=machine;branch=${LINUX_RPI_BRANCH};protocol=https"
SRC_URI:append:raspberrypi4-64-taishan = "git://github.com/xiaofeng232/linux-rpi.git;name=machine;branch=${LINUX_RPI_BRANCH};protocol=https"

LINUX_VERSION:raspberrypi4-64-taishan = "6.6.78"
LINUX_RPI_BRANCH:raspberrypi4-64-taishan = "rpi-6.6.y"
SRCREV_machine:raspberrypi4-64-taishan = "bba53a117a4a5c29da892962332ff1605990e17a"
