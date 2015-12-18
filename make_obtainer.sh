#!/bin/bash
source common.sh
CONT_NAME=qobtainer

#TODO: Depends on qbr0 existing on host
vm_make $CONT_NAME 120 qbr0
vm_start_first $CONT_NAME

# setup vpn
lxc-attach -n $CONT_NAME -- apt-get install openvpn -y

[ -z $PIA_USERNAME ] && { echo "PIA_USERNAME is not defined" 1>&2 ; exit 1; }
[ -z $PIA_PASSWORD ] && { echo "PIA_PASSWORD is not defined" 1>&2 ; exit 1; }
echo $PIA_USERNAME >> $VM_FS/etc/openvpn/pia_creds
echo $PIA_PASSWORD >> $VM_FS/etc/openvpn/pia_creds

for i in configs/obtainer/etc-openvpn/*; do
	ln -s $DATA_DIR/$i $VM_FS/etc/openvpn 
done

wget unzip

echo "Created $CONT_NAME"