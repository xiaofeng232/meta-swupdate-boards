inherit kernel

SRC_URI:append = " \
    https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.6/older/patch-6.6.63-rt47-rc2.patch.gz;name=rtpatch \
"

do_patch:append() {
    cd ${S}
    gunzip -c ${WORKDIR}/patch-6.6.63-rt47-rc2.patch.gz | patch -p1 --verbose || true
}
SRC_URI[rtpatch.sha256sum] = "9abe3405e85b3c5901018b94985c781eb6cc33e8c10452ad6c509c9bb596fd6d"

KERNEL_CONFIG:append = " \
    CONFIG_PREEMPT_RT=y \
    CONFIG_HZ_1000=y \
    CONFIG_HIGH_RES_TIMERS=y \
    CONFIG_NO_HZ_FULL=y \
"
KBUILD_DEFCONFIG:raspberrypi4-64 = "bcm2711_defconfig"