# Copyright (c) 2025-2026 Taishan Control System. All rights reserved.
#
# Description:
#   A simple Hello World application for demonstration purposes
#
# Authors:
#   Lin Xiaofeng <xiaofeng.lin1@foxmail.com>
#
# Changelog:
#   0.0.1-rt1 (2026-01-19):
#     - Initial implementation
#
# License: Closed - Internal Use Only


# meta-your-layer/recipes-core/packagegroups/packagegroup-base.bbappend

RDEPENDS:packagegroup-base:append = " \
    openssh \
    network-conf \
    libgpiod \
    libgpiod-dev \
    libgpiod-tools \
    "