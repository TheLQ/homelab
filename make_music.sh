#!/bin/bash
source common.sh
CONT_NAME=qmusic

vm_make $CONT_NAME

# this container should autostart
cat <<EOF >> $VM_ROOT/config
# qprod - autostart
lxc.start.auto = 1
lxc.start.delay = 10
EOF

vm_start_first $CONT_NAME

# setup NFS exports
lxc-attach -n $CONT_NAME -- apt-get install mpd -y
mv $VM_FS/etc/mpd.conf $VM_FS/etc/mpd.conf.orig
ln -s $DATA_DIR/configs/music/mpd.conf $VM_FS/etc/mpd.conf
lxc-attach -n $CONT_NAME -- service mpd restart -y