#!/bin/bash
source common.sh
CONT_NAME=qobtainer

vm_make $CONT_NAME
vm_start_first $CONT_NAME

# setup vpn
lxc-attach -n $CONT_NAME -- apt install openvpn wget unzip uml-utilities -y

# NOTE: lxc config calls mktun-lxc.sh when making the container
# SEE: http://wiki.vpslink.com/TUN/TAP_device_with_OpenVPN_or_Hamachi
# SEE: http://superuser.com/questions/497245/how-to-load-tun-module-in-linux

ln -s /qprodsecure/pia_creds $VM_FS/etc/openvpn/pia_creds
for i in configs/obtainer/etc-openvpn/*; do
	ln -s $DATA_DIR/$i $VM_FS/etc/openvpn
done

lxc-attach -n $CONT_NAME -- systemctl enable openvpn@pia
lxc-attach -n $CONT_NAME -- systemctl start openvpn@pia

echo "Created $CONT_NAME"
