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

