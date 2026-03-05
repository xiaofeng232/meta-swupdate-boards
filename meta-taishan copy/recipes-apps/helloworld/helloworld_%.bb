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

SUMMARY = "Hello World Example"
DESCRIPTION = "A simple Hello World application for demonstration purposes."
LICENSE = "CLOSED"

PV= "1.0"
PR = "r0"

SRC_URI = " \
    file://helloworld.c \
    file://goodbye.c \
"

DEPENDS = ""

S = "${WORKDIR}"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} helloworld.c -o helloworld
    ${CC} ${CFLAGS} ${LDFLAGS} goodbye.c -o goodbye
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 helloworld ${D}${bindir}
    install -m 0755 goodbye ${D}${bindir}   
}

