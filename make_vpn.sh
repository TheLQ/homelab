#!/bin/bash
source common.sh
CONT_NAME=qvpn

vm_make $CONT_NAME
vm_start_first $CONT_NAME

lxc-attach -n $CONT_NAME -- apt-get install openvpn easy-rsa -y