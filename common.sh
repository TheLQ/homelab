#!/bin/bash
set -e -x

#Depends on creds.sh, should contain
#export PASSWORD=yourpassword
source creds.sh

DEBIAN_RELEASE=jessie
DATA_DIR=/qprodconfig
SECURE_DIR=/qprodsecure
IP_CIDR=23
IP_SUBNET=255.255.254.0
IP_GATEWAY=192.168.66.1
IP_BRIDGE_INTERFACE=lxc-host-bridge
IP_HOSTS_FILE=lxc-hosts
DEB_REPO_MIRROR=192.168.67.110
APT_COMMON_PACKAGES="nano curl htop wget less"

#other static fields
APT_PROXY_PATH=/etc/apt/apt.conf.d/apt-proxy.conf
LXC_PATH=/qprodconfig/configs/lxc
LXC_CONFIGS=$LXC_PATH/containers
LXC_INTERFACE_CONFIGS=$LXC_PATH/containers.network

# make sure the data directory always exists
if [[ ! -d $DATA_DIR ]]; then
	echo "Cannot find data directory at $DATA_DIR"
	exit 1
fi

# initialize hosts 
if [[ ! -f $IP_HOSTS_FILE ]]; then
	echo "Cannot find hosts file at $IP_HOSTS_FILE"
	exit 1
fi

declare -A IP_HOSTS
while read line_raw; do
	if [[ ${line_raw:0:1} == '#' ]]; then
		# this is a comment
		continue;
	fi
	
	line_arr=($line_raw)
	IP=${line_arr[0]}
	HOST=${line_arr[1]}

	echo "IP $IP Host $HOST"

	IP_HOSTS["$HOST"]=$IP
done < $IP_HOSTS_FILE

function vm_make() {
	if [ "$#" -ne 1 ]; then
		echo "Must specify VM, last octet of ip, bridge interface"
		exit 1
	fi
	VM_NAME=$1
	LXC_CONFIG=$LXC_CONFIGS/$VM_NAME
	LXC_INTERFACE_CONFIG=$LXC_INTERFACE_CONFIGS/$VM_NAME

	[ -z $DATA_DIR ] && { echo "DATA_DIR is not defined" 1>&2 ; exit 1; }
	[ ! -d $DATA_DIR ] && { echo "DATA_DIR does not exist" 1>&2 ; exit 1; }
	[ -z $DEBIAN_RELEASE ] && { echo "DEBIAN_RELEASE is not defined" 1>&2 ; exit 1; }
	[ -z $IP_CIDR ] && { echo "IP_CIDR is not defined" 1>&2 ; exit 1; }
	[ -z $IP_GATEWAY ] && { echo "IP_GATEWAY is not defined" 1>&2 ; exit 1; }
	[ -z $PASSWORD ] && { echo "PASSWORD is not defined" 1>&2 ; exit 1; }
	[ ! -f $LXC_CONFIG ] && { echo "Missing config in $LXC_CONFIGS" 1>&2 ; exit 1; }
	[ ! -f $LXC_INTERFACE_CONFIG ] && { echo "Missing config in $LXC_INTERFACE_CONFIGS" 1>&2 ; exit 1; }

	# defines IP_ADDR
	vm_get_ip $VM_NAME
	[ -z $IP_ADDR ] && { echo "IP_ADDR is not defined" 1>&2 ; exit 1; }

	if lxc-ls | grep -q $VM_NAME; then 
		echo "Container $VM_NAME already exists, must be destroyed first!"
		echo "Run lxc-stop -n $VM_NAME; lxc-destroy -n $VM_NAME; $0"
		exit 1
	fi

	#create and setup pre container
	lxc-create -n $VM_NAME -t debian -- -r $DEBIAN_RELEASE

	VM_ROOT=/var/lib/lxc/$VM_NAME
	VM_FS=$VM_ROOT/rootfs

	#mount this repository inside the container
	mv $VM_ROOT/config $VM_ROOT/config.orig
	ln -s $LXC_CONFIG $VM_ROOT/config

	#container should use host configuration
	mv $VM_FS/etc/network/interfaces $VM_FS/etc/network/interfaces.orig
	ln -s $LXC_INTERFACE_CONFIG $VM_FS/etc/network/interfaces

	rm -rf $VM_FS/root/.bashrc
	ln -s $DATA_DIR/.bashrc $VM_FS/root/.bashrc

	#setup apt-proxy
	rm $VM_FS/root/.bashrc
	ln -s $DATA_DIR/.bashrc $VM_FS/root/.bashrc
	ln -s $LXC_PATH/apt-proxy.conf $VM_FS$APT_PROXY_PATH

	rm $VM_FS/etc/resolv.conf
	ln -s $DATA_DIR/configs/resolv.conf $VM_FS/etc/resolv.conf
}

function vm_get_ip() {
	if [ "$#" -ne 1 ]; then
		echo "Must specify vm name"
		exit 1
	fi
	VM_NAME=$1

	if [ ! ${IP_HOSTS[$VM_NAME]+isset} ] ; then
		echo "No IP for $VM_NAME found in $IP_HOSTS_FILE"
		exit 2
	fi
	IP_ADDR=${IP_HOSTS[$VM_NAME]}
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

	#common packages
	lxc-attach -n $VM_NAME -- apt-get update
	lxc-attach -n $VM_NAME -- apt-get dist-upgrade -y
	lxc-attach -n $VM_NAME -- apt-get install $APT_COMMON_PACKAGES -y
}
