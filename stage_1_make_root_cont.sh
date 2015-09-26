#!/bin/bash
source common.sh
CONT_NAME=qprod0

#pre-checks
if [[ ! -d $DATA_DIR ]]; then 
	echo "Making data directory at $DATA_DIR"
	ln -s `pwd` $DATA_DIR
fi

vm_make $CONT_NAME
vm_start_first $CONT_NAME

echo "Created $CONT_NAME"