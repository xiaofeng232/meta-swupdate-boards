FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://eth0.network \
"

do_install:append() {
    install -d ${D}/etc/systemd/network
    install -m 0644 ${WORKDIR}/eth0.network ${D}/etc/systemd/network/
}