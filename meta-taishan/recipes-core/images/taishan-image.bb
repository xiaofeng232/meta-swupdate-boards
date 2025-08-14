require recipes-core/images/core-image-base.bb
SUMMARY = "a taishan image"

IMAGE_FEATURES += "package-management"
PACKAGE_CLASSES = "package_dpkg"
LINUX_KERNEL_TYPE = "preempt-rt"