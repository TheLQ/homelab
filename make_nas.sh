#!/bin/bash
source common.sh
CONT_NAME=qnas

#TODO: Depends on qbr0 existing on host
vm_make $CONT_NAME

# add the lxc root directory for debugging purposes
echo lxc.mount.entry=/var/lib/lxc/ $VM_FS/lxcroot none bind,create=dir 0 0 >> $VM_ROOT/config

vm_start_first $CONT_NAME

# setup NFS exports
lxc-attach -n $CONT_NAME -- apt-get install nfs-kernel-server -y
rm $VM_FS/etc/exports
ln -s $DATA_DIR/configs/nas/exports $VM_FS/etc/exports
lxc-attach -n $CONT_NAME -- service nfs-kernel-server restart -y

# setup samba
lxc-attach -n $CONT_NAME -- apt-get install samba -y
rm $VM_FS/etc/samba/smb.conf
ln -s $DATA_DIR/configs/nas/smb.conf $VM_FS/etc/samba/smb.conf
lxc-attach -n $CONT_NAME -- service smbd restart