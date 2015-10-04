#!/bin/bash
set -e -x

#Depends on creds.sh, should contain
#export PASSWORD=yourpassword
source creds.sh

DEBIAN_RELEASE=jessie
DATA_DIR=/qprodconfig
IP_PREFIX=192.168.67
IP_CIDR=23
IP_SUBNET=255.255.254.0
IP_GATEWAY=192.168.66.1
IP_BRIDGE_INTERFACE=lxc-host-bridge
IP_HOSTS_FILE=lxc-hosts
DEB_REPO_MIRROR=$IP_PREFIX.110

#other static fields
APT_PROXY_PATH=/etc/apt/apt.conf.d/apt-proxy.conf

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
	line_arr=($line_raw)
	IP=${line_arr[0]}
	HOST=${line_arr[1]}

	echo "IP $IP Host $HOST"

	IP_HOSTS[$HOST]=$IP
done < $IP_HOSTS_FILE

function vm_make() {
	if [ "$#" -ne 3 ]; then
		echo "Must specify VM, last octet of ip, bridge interface"
		exit 1
	fi
	VM_NAME=$1
	IP_SUFFIX=$2
	IP_BRIDGE=$3

	[ -z $DATA_DIR ] && { echo "DATA_DIR is not defined" 1>&2 ; exit 1; }
	[ ! -d $DATA_DIR ] && { echo "DATA_DIR does not exist" 1>&2 ; exit 1; }
	[ -z $DEBIAN_RELEASE ] && { echo "DEBIAN_RELEASE is not defined" 1>&2 ; exit 1; }
	[ -z $IP_CIDR ] && { echo "IP_CIDR is not defined" 1>&2 ; exit 1; }
	[ -z $IP_GATEWAY ] && { echo "IP_GATEWAY is not defined" 1>&2 ; exit 1; }
	[ -z $PASSWORD ] && { echo "PASSWORD is not defined" 1>&2 ; exit 1; }

	if [ ! ${IP_HOSTS[$VM_NAME]+isset} ] ; then
		echo "No IP for $VM_NAME found in $IP_HOSTS_FILE"
		exit
	fi
	IP_ADDR=${IP_HOSTS[$VM_NAME]}

	if lxc-ls | grep -q $VM_NAME; then 
		echo "Container $VM_NAME already exists, must be destroyed first!"
		echo "Run lxc-stop -n $VM_NAME; lxc-destroy -n $VM_NAME"
		exit 1
	fi

	#create and setup pre container
	lxc-create -n $VM_NAME -t debian -- -r $DEBIAN_RELEASE

	VM_ROOT=/var/lib/lxc/$VM_NAME
	VM_FS=$VM_ROOT/rootfs

	#mount this repository inside the container
	echo lxc.mount.entry=$DATA_DIR $VM_FS$DATA_DIR none bind,create=dir 0 0 >> $VM_ROOT/config
	echo lxc.mount.entry=/quackdrive $VM_FS/quackdrive none bind,create=dir 0 0 >> $VM_ROOT/config
	echo lxc.mount.entry=/scratchdrive $VM_FS/scratchdrive none bind,create=dir 0 0 >> $VM_ROOT/config

	#container should use host configuration
	cat <<EOF > $VM_FS/etc/network/interfaces
## WARNING: Managed by qprod
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet manual
EOF
	
	#configure IP in lxc host, removing any existing config
	sed -i '/lxc\.network/d' $VM_ROOT/config
	cat <<EOF >> $VM_ROOT/config
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = $IP_BRIDGE
lxc.network.ipv4 = $IP_ADDR/$IP_CIDR
lxc.network.ipv4.gateway = $IP_GATEWAY
EOF

	rm -rf $VM_FS/root/.bashrc
	ln -s $DATA_DIR/.bashrc $VM_FS/root/.bashrc

	#setup apt-proxy
	echo "Acquire::http::Proxy \"http://$DEB_REPO_MIRROR\";" >> $VM_FS$APT_PROXY_PATH
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
	lxc-attach -n $VM_NAME -- apt-get install nano curl htop -y
}