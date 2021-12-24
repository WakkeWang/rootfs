#!/bin/sh

if [ -z "$1" ] ; then              
    if [ "$TAGLINK_PATH" = "" ] ; then
        CERT_PATH=/home/root
    else                             
        CERT_PATH=$TAGLINK_PATH          
    fi                           

    if [ -d $CERT_PATH/project ]; then
        KEYFILE=$CERT_PATH/project/server.key
        CSRFILE=$CERT_PATH/project/server.csr
        CAFILE=$CERT_PATH/project/ca.crt
        PEMFILE=$CERT_PATH/project/server.pem
    else
        KEYFILE=$CERT_PATH/server.key
        CSRFILE=$CERT_PATH/server.csr
        CAFILE=$CERT_PATH/ca.crt
        PEMFILE=$CERT_PATH/server.pem
    fi
else                                
    CERT_PATH=$1                            
    KEYFILE=$CERT_PATH/server.key
    CSRFILE=$CERT_PATH/server.csr
    CAFILE=$CERT_PATH/ca.crt
    PEMFILE=$CERT_PATH/server.pem
fi     

OPENSSL=/usr/bin/openssl

C_Name=CN
S_Name=BeiJing
O_Name="Advantech Co., Ltd"
CommName=deviceCA.advantech.com
E_Mail=support@advantech.com

if [ ! -r $PEMFILE ] || [ ! -r $CAFILE ]; then
    $OPENSSL genrsa -out $KEYFILE 2048  &> /dev/null
    $OPENSSL rsa -in $KEYFILE -out $KEYFILE &> /dev/null
    echo -e "$C_Name\n$S_Name\n\n$O_Name\n\n$CommName\n$E_Mail\n\n\n" | $OPENSSL req -new -key $KEYFILE -sha256 -out $CSRFILE &> /dev/null
    echo -e "$C_Name\n$S_Name\n\n$O_Name\n\n$CommName\n$E_Mail\n" | $OPENSSL req -new -x509 -days 36500 -sha256 -in $CSRFILE -key $KEYFILE -out $CAFILE &> /dev/null
    cat $KEYFILE $CAFILE > $PEMFILE
    rm -f $KEYFILE;rm -f $CSRFILE 
    sync;sync
fi

exit 0

