#!/bin/bash
source common.sh
CONT_NAME=qprod0

#pre-checks
if [[ ! -d $DATA_DIR ]]; then 
	echo "Making data directory at $DATA_DIR"
	ln -s `pwd` $DATA_DIR
fi

#TODO: Depends on qbr0 existing on host
vm_make $CONT_NAME 100 qbr0
vm_start_first $CONT_NAME

lxc-attach -n $CONT_NAME -- apt-get install lxc -y

echo "Created $CONT_NAME"