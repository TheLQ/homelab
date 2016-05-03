#!/bin/bash
source common.sh

apt-get install nfs-kernel-server samba -y

rm /etc/exports
ln -s $DATA_DIR/configs/nas/exports /etc/exports
service nfs-kernel-server restart

rm /etc/samba/smb.conf
ln -s $DATA_DIR/configs/nas/smb.conf /etc/samba/smb.conf
service smbd restart

#TODO: fstab
