#!/bin/bash
source common.sh
CONT_NAME=qdev
DEBIAN_RELEASE=sid

#TODO: Depends on qbr0 existing on host
vm_make $CONT_NAME

# add the lxc root directory for debugging purposes
#mkdir $VM_FS/lxcroot
#echo lxc.mount.entry=/var/lib/lxc/ $VM_FS/lxcroot none bind 0 0 >> $VM_ROOT/config

# this container should autostart
cat <<EOF >> $VM_ROOT/config
# qprod - autostart
lxc.start.auto = 1
lxc.start.delay = 10
EOF

vm_start_first $CONT_NAME

#lxc-attach -n $CONT_NAME -- apt-get install gnome
lxc-attach -n $CONT_NAME -- apt-get install git mercurial openjdk-8-jdk jenkins dos2unix -y
