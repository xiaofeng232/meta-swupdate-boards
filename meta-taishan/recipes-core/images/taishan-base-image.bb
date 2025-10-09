require recipes-core/images/rpi-test-image.bb
SUMMARY = "a taishan image"

IMAGE_FEATURES += "package-management"
PACKAGE_CLASSES = "package_dpkg"
LINUX_KERNEL_TYPE = "preempt-rt"

IMAGE_INSTALL:append = " libgpiod libgpiod-dev libgpiod-tools curl net-tools"