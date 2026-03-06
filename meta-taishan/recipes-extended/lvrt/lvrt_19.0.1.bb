SUMMARY = "Install pre-built debian package"
DESCRIPTION = "Recipe to automatically install external deb package into rootfs"
LICENSE = "CLOSED"

PN = "lvrt"
PV = "19.0.1-8"

SRC_URI = " \
    https://feeds.labviewmakerhub.com/debian/binary/lvrt19-schroot_19.0.1-8.deb;name=deb \
    file://post-install.sh \
"

SRC_URI[deb.sha256sum] = "5ef2451e2528a3bcfcae05f3ecab9cd3642070ebf0623915ade1cc6f9d564139"

inherit bin_package


pkg_postinst_ontarget:${PN}() {
    #!/bin/sh
    echo "Running post-installation for mydeb..."
    chmod +x /usr/bin/my-application
    systemctl daemon-reload 2>/dev/null || true
    systemctl enable my-application.service 2>/dev/null || true
}

FILES:${PN} += " \
    /usr/bin/* \
    /usr/lib/* \
    /usr/share/* \
    /etc/* \
"

do_configure[noexec] = "1"
do_compile[noexec] = "1"