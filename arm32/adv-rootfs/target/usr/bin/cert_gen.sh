#!/bin/sh

if [ -z "$1" ] ; then              
    if [ "$TAGLINK_PATH" = "" ] ; then
        CERT_PATH=/home/root
    else                             
        CERT_PATH=$TAGLINK_PATH          
    fi                           

    if [ -d $CERT_PATH/bin ]; then
        KEYFILE=$CERT_PATH/bin/privatekey.pem
        CERTFILE=$CERT_PATH/bin/certificate.pem
    else
        KEYFILE=$CERT_PATH/privatekey.pem
        CERTFILE=$CERT_PATH/certificate.pem
    fi
else                                
    CERT_PATH=$1                            
    KEYFILE=$CERT_PATH/privatekey.pem
    CERTFILE=$CERT_PATH/certificate.pem
fi     

OPENSSL=/usr/bin/openssl

Host=adv335x
Email=support@advantech.com

if [ ! -r $KEYFILE ] || [ ! -r $CERTFILE ]; then
    $OPENSSL genrsa -out $KEYFILE 2048  &> /dev/null
    echo -e "CN\n\n\n\n\n${Host}\n${Email}\n" | $OPENSSL req -x509 -new -key $KEYFILE -out $CERTFILE -days 36500  &> /dev/null
    sync;sync
fi

exit 0

