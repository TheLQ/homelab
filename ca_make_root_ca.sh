#!/bin/bash
source common.sh

if [[ ! -d "$SECURE_DIR" ]]; then
	echo "Could not find $SECURE_DIR"
	exit 2
fi

if [[ ! -d "$SECURE_DIR/certs" ]]; then
	mkdir $SECURE_DIR/certs
fi

source ca_common.sh

# see http://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/
if [[ -f $CA_KEY ]]; then
	echo "Key file $CA_KEY already exists"
	exit 2
fi
if [[ -f $CA_CERT ]]; then
	echo "Certificate $CA_KEY already exists"
	exit 2
fi

openssl genrsa -des3 -out $CA_KEY 2048
openssl req -x509 -new -nodes -key $CA_KEY -days 1024 -out $CA_CERT