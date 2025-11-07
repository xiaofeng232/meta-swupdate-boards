# Enable webserver support at build time (optional - keeps ability to build swupdate with internal webserver)
EXTRA_OECONF:append = " \
	--enable-webserver \
	--enable-http \
	--with-microhttpd \
"
DEPENDS:append = " libmicrohttpd"

# Prefer files/ in this layer for additional service/configuration files
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Install layer-provided systemd unit and swupdate.cfg into the image/rootfs
SRC_URI += " \
	file://swupdate.service \
	file://hwrevision \
"

do_install:append() {
	# install systemd unit
	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/swupdate.service ${D}${systemd_system_unitdir}/swupdate.service

	# install hwrevision file
	install -d ${D}${sysconfdir}
	install -m 0644 ${WORKDIR}/hwrevision ${D}${sysconfdir}/hwrevision
}

# Ensure files are packaged and systemd integration is enabled
FILES_${PN} += " ${systemd_system_unitdir}/swupdate.service ${sysconfdir}/hwrevision"
SYSTEMD_SERVICE_${PN} = "swupdate.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

