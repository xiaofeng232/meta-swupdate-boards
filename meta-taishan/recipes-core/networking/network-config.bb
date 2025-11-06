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

# 声明打包的文件（与实际安装的文件名一致）
FILES_${PN} += "${sysconfdir}/systemd/network/90-eth0.network"

SYSTEMD_SERVICE_${PN} = "systemd-networkd.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

# 禁用系统默认的DHCP配置（80-wired.network），避免覆盖静态IP
pkg_postinst:${PN}() {
    if [ -f $D/usr/lib/systemd/network/80-wired.network ]; then
        mv $D/usr/lib/systemd/network/80-wired.network $D/usr/lib/systemd/network/80-wired.network.bak
    fi
}