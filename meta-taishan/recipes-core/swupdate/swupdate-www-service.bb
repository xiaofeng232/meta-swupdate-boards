SUMMARY = "Systemd service for SWUpdate web interface"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "swupdate"
RDEPENDS:${PN} = "swupdate"

SYSTEMD_SERVICE:${PN} = "swupdate-www.service"


FILESEXTRAPATHS:prepend := "${THISDIR}/swupdate-www-service:"

SRC_URI = "file://swupdate-www.service"


S = "${WORKDIR}"


do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/swupdate-www.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/swupdate-www.service"