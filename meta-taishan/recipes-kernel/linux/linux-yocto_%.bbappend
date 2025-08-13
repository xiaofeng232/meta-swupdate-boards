# 扩展文件搜索路径
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# 将自定义设备树添加到编译列表（替换原有设备树或追加）
# KERNEL_DEVICETREE = "qemux86-64-gpio.dtb"

# 若需保留原有设备树，使用 += 追加
# KERNEL_DEVICETREE += "qemux86-64-gpio.dtb"