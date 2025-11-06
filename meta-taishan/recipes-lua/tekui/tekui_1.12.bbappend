# 修正重复的/usr路径：将/usr/usr/lib/下的文件移动到/usr/lib/
do_install:append() {
    if [ -d "${D}/usr/usr/lib" ]; then
        mv ${D}/usr/usr/lib/* ${D}/usr/lib/
        rm -rf ${D}/usr/usr
    fi
}

# 确保修正后的文件被正确打包（补充FILES变量，覆盖可能的遗漏）
FILES:${PN} += " \
    /usr/lib/lua/5.4/tek/ui/class/area.so \
    /usr/lib/lua/5.4/tek/ui/class/frame.so \
    /usr/lib/lua/5.4/tek/ui/layout/default.so \
    /usr/lib/lua/5.4/tek/lib/visual.so \
    /usr/lib/lua/5.4/tek/lib/string.so \
    /usr/lib/lua/5.4/tek/lib/region.so \
    /usr/lib/lua/5.4/tek/lib/support.so \
    /usr/lib/lua/5.4/tek/lib/exec.so \
    /usr/lib/lua/5.4/tek/lib/display/rawfb.so \
"