#!/bin/sh
APPS=/media/mmcblk1p1/apps.tar.gz

if [ "$TAGLINK_PATH" = "" ] ; then
    TARGET_DIR=/home/root
else                             
    TARGET_DIR=$TAGLINK_PATH          
fi

if [ ! -z "$1" ] ; then
    APPS=$1
fi

read -p 'Do you want update applications? [y/n] : ' ISANSWER
case $ISANSWER in
	"y" | "Y") 
	if [ -f $APPS ]; then
	    echo "This will update applications and reboot system."
	    [ -d $TARGET_DIR/bin ] && rm -rf $TARGET_DIR/bin
	    [ -d $TARGET_DIR/driver ] && rm -rf $TARGET_DIR/driver
	    [ -d $TARGET_DIR/lib ] && rm -rf $TARGET_DIR/lib
	    #[ -d $TARGET_DIR/project ] && rm -rf $TARGET_DIR/project
	    [ -d $TARGET_DIR/update ] && rm -rf $TARGET_DIR/update
	    [ -d $TARGET_DIR/user ] && rm -rf $TARGET_DIR/user
	    [ -d $TARGET_DIR/util ] && rm -rf $TARGET_DIR/util
	    [ -d $TARGET_DIR/www ] && rm -rf $TARGET_DIR/www
	    [ -d $TARGET_DIR/doc ] && rm -rf $TARGET_DIR/doc
	    tar -xzf $APPS -C $TARGET_DIR
	    sync
	    echo "update finish, system will reboot"
	    reboot
	else
	    echo "not apps.tar.gz file in the SD card."
	fi
	;;

	"n" | "N") echo "Exit update applications."
	;;

	*)  echo "Please enter y or n."
	;;
esac

exit 0

