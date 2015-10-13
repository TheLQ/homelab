#!/bin/bash
[ -z $SECURE_DIR ] && { echo "SECURE_DIR is not defined" 1>&2 ; exit 1; }

CERT_DIR=$SECURE_DIR/certs
CA_CERT=$CERT_DIR/ca_qprod.pem
CA_KEY=$CERT_DIR/ca_qprod.key
if [[ ! -d $CERT_DIR ]]; then
	echo "Cannot find certs at $CERT_DIR"
	exit 1
fi

# see http://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/
ca_make_key() {
	if [[ ! -f $CA_CERT ]]; then
		echo "Cannot find CA certificate at $CA_CERT"
		exit 1
	fi
	[ -z $CONT_NAME ] && { echo "CONT_NAME is not defined" 1>&2 ; exit 1; }

	openssl genrsa -out $CERT_DIR/$CONT_NAME.key 2048
}
ca_make_cert() {
	if [[ ! -f $CA_CERT ]]; then
		echo "Cannot find CA certificate at $CA_CERT"
		exit 1
	fi
	[ -z $CONT_NAME ] && { echo "CONT_NAME is not defined" 1>&2 ; exit 1; }

	openssl req -new -key $CERT_DIR/$CONT_NAME.key -out $CERT_DIR/$CONT_NAME.csr
	openssl x509 -req -in $CERT_DIR/$CONT_NAME.csr \
	    -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial \
	    -out $CERT_DIR/$CONT_NAME.crt -days 500
}

ca_init_vm() {
	[ -z $CONT_NAME ] && { echo "CONT_NAME is not defined" 1>&2 ; exit 1; }

	if [[ ! -f $CERT_DIR/$CONT_NAME.key ]]; then
		ca_make_key
	fi
	if [[ ! -f $CERT_DIR/$CONT_NAME.crt ]]; then
		ca_make_cert
	fi
}