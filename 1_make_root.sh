#!/bin/bash
source common.sh
CONT_NAME=qprod0

#TODO: Depends on qbr0 existing on host
vm_make $CONT_NAME 100 qbr0
vm_start_first $CONT_NAME

lxc-attach -n $CONT_NAME -- apt-get install lxc -y

echo "Created $CONT_NAME"