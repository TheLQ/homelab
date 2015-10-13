#!/bin/bash
# Debian mirror proxy
# this is designed to run on the physical host and be used in creation of all VMs
source common.sh
CONT_NAME=qmirror

# make sure SSL is setup
source ca_common.sh
ca_init_vm

vm_make $CONT_NAME

# autostart because all other machines do updates through it
cat <<EOF >> $VM_ROOT/config
# qprod - autostart
lxc.start.auto = 1
lxc.start.delay = 10
#lxc.start.order = 0
EOF

# disable default apt proxy as that's this machine
rm $VM_FS$APT_PROXY_PATH

vm_start_first $CONT_NAME

lxc-attach -n $CONT_NAME -- apt-get install nginx -y
lxc-attach -n $CONT_NAME -- bash -c 'rm /etc/nginx/sites-enabled/*'
lxc-attach -n $CONT_NAME -- ln -s $DATA_DIR/configs/package-mirror/nginx-proxy-server.conf /etc/nginx/sites-enabled/
lxc-attach -n $CONT_NAME -- ln -s $DATA_DIR/configs/package-mirror/nginx-proxy-http.conf /etc/nginx/conf.d/
#lxc-attach -n $CONT_NAME -- mkdir /srv #already exists?
lxc-attach -n $CONT_NAME -- service nginx restart