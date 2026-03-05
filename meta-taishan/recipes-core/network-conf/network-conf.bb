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

SUMMARY = "Static IP config for Raspberry Pi 4B"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://90-eth0.network"
DEPENDS = "systemd"
RDEPENDS_${PN} = "systemd-networkd"

do_install() {
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/90-eth0.network ${D}${sysconfdir}/systemd/network/
}

FILES_${PN} += "${sysconfdir}/systemd/network/90-eth0.network"

SYSTEMD_SERVICE_${PN} = "systemd-networkd.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

pkg_postinst:${PN}() {
    if [ -f $D/usr/lib/systemd/network/80-wired.network ]; then
        mv $D/usr/lib/systemd/network/80-wired.network $D/usr/lib/systemd/network/80-wired.network.bak
    fi
}