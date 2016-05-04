#!/bin/bash
# SEE: https://wiki.archlinux.org/index.php/Linux_Containers#Systemd_considerations_.28required.29
cd ${LXC_ROOTFS_MOUNT}/dev
mkdir net
mknod net/tun c 10 200
chmod 0666 net/tun
