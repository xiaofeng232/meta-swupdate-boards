require recipes-core/images/rpi-test-image.bb
SUMMARY = "a taishan image"

IMAGE_FEATURES += "package-management"
PACKAGE_CLASSES = "package_dpkg"
INIT_MANAGER = "systemd"



IMAGE_INSTALL:append = " libgpiod libgpiod-dev libgpiod-tools curl net-tools"
IMAGE_INSTALL:append = " u-boot-fw-utils libubootenv"