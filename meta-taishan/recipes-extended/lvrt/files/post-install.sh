#!/bin/sh
# LVRT post-installation script

if [ -f /usr/bin/lvrt ]; then
    chmod +x /usr/bin/lvrt
fi

mkdir -p /var/lib/lvrt

if [ -f /lib/systemd/system/lvrt.service ]; then
    systemctl daemon-reload 2>/dev/null || true
    systemctl enable lvrt.service 2>/dev/null || true
fi

echo "LVRT post-installation completed"