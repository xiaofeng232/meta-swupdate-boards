COMPATIBLE_MACHINE:raspberrypi4-64 = "raspberrypi4-64"

KERNEL_CONFIG += " \
    ${@bb.utils.contains('MACHINE', 'raspberrypi4-64', 'file://config-rpi4-rt', '', d)} \
"
