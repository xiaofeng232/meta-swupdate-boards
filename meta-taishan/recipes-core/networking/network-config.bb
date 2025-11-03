SUMMARY = "Static IP config for Raspberry Pi 4B"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://eth0.network"
DEPENDS = "systemd"
RDEPENDS_${PN} = "systemd-networkd"

do_install() {
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/eth0.network ${D}${sysconfdir}/systemd/network/
}

FILES_${PN} += "${sysconfdir}/systemd/network/eth0.network"

SYSTEMD_SERVICE_${PN} = "systemd-networkd.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/
    cat > ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/restart.conf << EOF
[Service]
ExecStartPost=/bin/systemctl restart systemd-networkd
EOF
}