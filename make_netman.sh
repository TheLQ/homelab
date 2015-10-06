#!/bin/bash
source common.sh
CONT_NAME=qnetman

vm_make $CONT_NAME

# this container should autostart
cat <<EOF >> $VM_ROOT/config
# qprod - autostart
lxc.start.auto = 1
lxc.start.delay = 10
lxc.start.order = 0
EOF

vm_start_first $CONT_NAME

lxc-attach -n $CONT_NAME -- apt-get install dnsmasq -y
mv $VM_FS/etc/dnsmasq.conf $VM_FS/etc/dnsmasq.conf.orig
ln -s $DATA_DIR/configs/netman/dnsmasq.conf $VM_FS/etc/dnsmasq.conf
lxc-attach -n $CONT_NAME -- service dnsmasq restart