DESCRIPTION = "Package group for app-related packages"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCHS = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:{PN} += "\
            helloworld \
    "