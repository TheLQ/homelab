#!/bin/bash
# Debian mirror proxy
# this is designed to run on the physical host and be used in creation of all VMs
source common.sh
CONT_NAME=qmirror

# make sure SSL is setup
source ca_common.sh
ca_init_vm

vm_make $CONT_NAME

# disable default apt proxy as that's this machine
rm $VM_FS$APT_PROXY_PATH

vm_start_first $CONT_NAME

lxc-attach -n $CONT_NAME -- apt install apt-cacher-ng

# old nginx based way, removed due to complexity
# and httpredir.debian.org redirecting us to different mirrors which were all cached separetly
#lxc-attach -n $CONT_NAME -- apt install nginx -y
#lxc-attach -n $CONT_NAME -- bash -c 'rm /etc/nginx/sites-enabled/*'
#lxc-attach -n $CONT_NAME -- ln -s $DATA_DIR/configs/package-mirror/nginx-proxy-server.conf /etc/nginx/sites-enabled/
#lxc-attach -n $CONT_NAME -- ln -s $DATA_DIR/configs/package-mirror/nginx-proxy-http.conf /etc/nginx/conf.d/
##lxc-attach -n $CONT_NAME -- mkdir /srv #already exists?
#lxc-attach -n $CONT_NAME -- service nginx restart
