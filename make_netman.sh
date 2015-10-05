#!/bin/bash
source common.sh
CONT_NAME=qnetman

vm_make $CONT_NAME
vm_start_first $CONT_NAME

lxc-attach -n $CONT_NAME -- apt-get install dnsmasq -y
mv $VM_FS/etc/dnsmasq.conf $VM_FS/etc/dnsmasq.conf.orig
ln -s $DATA_DIR/configs/netman/dnsmasq.conf $VM_FS/etc/dnsmasq.conf
lxc-attach -n $CONT_NAME -- service dnsmasq restart