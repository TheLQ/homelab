#!/bin/bash
set -e -x

#Depends on creds.sh, should contain
#export PASSWORD=yourpassword
source creds.sh

export DEBIAN_RELEASE=jessie
export DATA_DIR=/qproddata

function vm_make() {
	if [ "$#" -ne 1 ]; then
		echo "Must specify VM"
		exit 1
	fi
	VM_NAME=$1

	[ -z $DATA_DIR ] && { echo "DATA_DIR is not defined" 1>&2 ; exit 1; }
	[ -z $DEBIAN_RELEASE ] && { echo "DEBIAN_RELEASE is not defined" 1>&2 ; exit 1; }

	if lxc-ls | grep -q $VM_NAME; then 
		echo "Container $VM_NAME already exists, must be destroyed first!"
		echo "Run lxc-stop -n $VM_NAME; lxc-destroy -n $VM_NAME"
		exit 1
	fi

	#create and setup pre container
	lxc-create -n $VM_NAME -t debian -- -r $DEBIAN_RELEASE

	VM_ROOT=/var/lib/lxc/$VM_NAME
	VM_FS=$VM_ROOT/rootfs

	echo lxc.mount.entry=$DATA_DIR $VM_FS$DATA_DIR none bind 0 0 >> $VM_ROOT/config
	mkdir $VM_FS$DATA_DIR
}

function vm_start() {
	if [ "$#" -ne 1 ]; then
		echo "Must specify VM"
		exit 1
	fi
	VM_NAME=$1

	lxc-start -n $VM_NAME -d
	lxc-wait -n $VM_NAME -s RUNNING
}

function vm_start_first() {
	if [ "$#" -ne 1 ]; then
		echo "Must specify VM"
		exit 1
	fi
	VM_NAME=$1

	[ -z $PASSWORD ] && { echo "PASSWORD is not defined" 1>&2 ; exit 1; }

	vm_start $VM_NAME

	printf "$PASSWORD\n$PASSWORD" | passwd --root /var/lib/lxc/$VM_NAME/rootfs
}