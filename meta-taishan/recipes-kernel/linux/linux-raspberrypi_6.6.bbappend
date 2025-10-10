SRC_URI:remove:taishan-64 = "git://github.com/raspberrypi/linux.git;name=machine;branch=${LINUX_RPI_BRANCH};protocol=https"
SRC_URI:prepend:taishan-64 = "git://github.com/xiaofeng232/linux-rpi.git;name=machine;branch=${LINUX_RPI_BRANCH};protocol=https"

LINUX_VERSION:taishan-64 ?= "6.6.63"
LINUX_RPI_BRANCH:taishan-64 ?= "rpi-6.6.y"
LINUX_RPI_KMETA_BRANCH:taishan-64 ?= "yocto-6.6"

SRCREV_machine = "e442e5c1ab6bff5b5460b4fc949beb72aaf77970"
