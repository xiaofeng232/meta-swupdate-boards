# Copyright (c) 2025-2026 Taishan Control System. All rights reserved.
#
# Description:
#   A simple core image recipe for Taishan embedded systems.
#
# Authors:
#   Lin Xiaofeng <xiaofeng.lin1@foxmail.com>
#
# Changelog:
#   0.0.1 (2026-01-20):
#     - Initial implementation
#
# License: Closed - Internal Use Only

SUMMARY = "A simple core image for Taishan embedded systems"
DESCRIPTION = "This is a minimal core image recipe tailored for Taishan embedded systems, providing"
LICENSE = "CLOSED"

include recipes-core/images/rpi-test-image.bb

IMAGE_INSTALL:append = " \
    zeromq \
    cjson  \
    "
    
IMAGE_FEATURES += " \
    package-management \
    "

PACKAGE_CLASSES = "package_ipk"

CORE_IMAGE_EXTRA_INSTALL:append =" \
    packagegroup-apps \
    packagegroup-debug \
"