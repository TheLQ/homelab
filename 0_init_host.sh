#!/bin/bash
source common.sh

[ -z $IP_BRIDGE_INTERFACE ] && { echo "IP_BRIDGE_INTERFACE is not defined" 1>&2 ; exit 1; }
[ -z $IP_GATEWAY ] && { echo "IP_GATEWAY is not defined" 1>&2 ; exit 1; }

# Must match whats in lxc-hosts
LXC_HOST_NAME=qbox
# renamed interface to qeth0 according to http://forums.debian.net/viewtopic.php?f=19&t=122795
ETH=eth0

# defines IP_ADDR
vm_get_ip $LXC_HOST_NAME
[ -z $IP_ADDR ] && { echo "IP_ADDR is not defined" 1>&2 ; exit 1; }

# fail if the interface is already configured
if grep -E -q '^[[:space:]]*[^#\;].*(eth|enp).*' /etc/network/interfaces; then
	echo "Detected existing config of $ETH in /etc/network/interfaces"
	exit 2
fi
if grep -q $LXC_HOST_NAME /etc/network/interfaces; then
	echo "Detected existing config of $LXC_HOST_NAME in /etc/network/interfaces"
	exit 2
fi

apt install $APT_COMMON_PACKAGES
apt install bridge-utils

interfaces_file=/etc/network/interfaces.d/$IP_BRIDGE_INTERFACE.conf
if [ -f $interfaces_file ]; then
	echo "Existing interfaces file found, run rm $interfaces_file"
	exit 2
fi
#TODO: This relies on the existance of /etc/resolv.conf, was it created during install?
ln -s /qprodconfig/configs/host/$IP_BRIDGE_INTERFACE.conf $interfaces_file

# enable routing for lxc containers
echo net.ipv4.ip_forward = 1 > /etc/sysctl.d/enable-routing.conf

echo "==Verify enviornment before restarting networking=="
bash
#TODO: apt-proxy but commented out
#if interface is enabled, reboot
#install zfs, hdparm, lshw, iperf
#enable root in sshd_config

service networking restart

echo source $DATA_DIR/.bashrc > /root/.bashrc

apt update
apt full-upgrade
apt install btrfs-progs

# TODO: As of 4/30/16 linux-zfs was in unstable, stuck in https://ftp-master.debian.org/new.html
# SEE: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=686447#426
# SEE: https://qa.debian.org/developer.php?login=pkg-zfsonlinux-devel@lists.alioth.debian.org
#wget http://archive.zfsonlinux.org/debian/pool/main/z/zfsonlinux/zfsonlinux_6_all.deb
#dpkg -i zfsonlinux_6_all.deb
apt update
apt install debian-zfs

# LXC according to https://wiki.debian.org/LXC
# TODO: libvirt?
apt install lxc debootstrap

rm -rf /root/.ssh
ln -s $SECURE_DIR/ssh /root/.ssh
