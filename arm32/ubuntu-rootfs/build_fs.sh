#!/bin/sh
# usage: ./build_fs.sh DEVICE_NAME TAGLINK_PATH [PART_NUMBER]

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$6" ] || [ -z "$7" ]; then
    echo "Usage: ./build_fs.sh DEVICE_NAME TAGLINK_PATH [PART_NUMBER] [RT_ARG] [PHP_ARG] [PYTHON_ARG] [KERNELDIR] [THIRDPARTY_DIR] [RAMDISKDIR]" 
    echo "example:"
    echo "  $0 ADAM3600 /home/sysuser ADAM3600 NORT PHP_NO PYTHON_NO [KERNELDIR] [THIRDPARTY_DIR] [RAMDISKDIR]"
    exit 1
fi

if [ "$2" != "/home/root" ] && [ "$2" != "/home/sysuser" ]; then
    echo "path is not correct, please input correct path."
    echo "path is /home/sysuser or /home/root."
    echo "$0 DEVICE_NAME /home/sysuser for TAGLINK image."
    echo "$0 DEVICE_NAME /home/root for pure image."
    exit 1
fi

KERNELDIR=$7
THIRDPARTY_DIR=$8
RAMDISKDIR=$9

if [ ! -n "$TMP_PATH" ]; then
    TMP_PATH=/tmp/$1_$$
fi

if [ -d $TMP_PATH ]; then
    rm -rf $TMP_PATH
fi
mkdir -p $TMP_PATH
cp -a ubuntu_18.04/ $TMP_PATH/
sync

ROOTDIR=`pwd`

FS_TARGET=$TMP_PATH/ubuntu_18.04

RFS_FILE=rootfs.tar.gz
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabihf-

rm -rf $FS_TARGET/lib/modules/*

if [ "$4" = "RT" ]; then
    MODULE_DIR=$FS_TARGET/lib/modules/4.9.65-rt23-g7069a470d5
else
    if [ "$1" = "ECU1155" ]; then
        MODULE_DIR=$FS_TARGET/lib/modules/4.14.98-g1175b5961153-dirty
		ARCH=arm
		CROSS_COMPILE=arm-linux-gnueabihf-
    elif [ "$1" = "ECU1253" ]; then
        MODULE_DIR=$FS_TARGET/lib/modules/4.4.194
		ARCH=arm64
		CROSS_COMPILE=aarch64-linux-gnu-
    else
        MODULE_DIR=$FS_TARGET/lib/modules/4.9.69-g9ce43c71ae
	fi
fi
MODULE_FILE=$KERNELDIR/modules.tar.gz
VERSION_FILE=$KERNELDIR/Makefile

if [ -f $MODULE_FILE ]; then
    if [ -d $MODULE_DIR ]; then
	    rm -rf $MODULE_DIR
    fi
    mkdir -p $MODULE_DIR
    mkdir -p $MODULE_DIR/updates
	tar -xzpPf $MODULE_FILE -C $MODULE_DIR
	sync
else
    echo "Warning: Not $MODULE_FILE file, use latest build modules!"
    exit 1
fi

if [ -f $RFS_FILE ]; then
	rm -f $RFS_FILE
	sync
fi

if [ -f $VERSION_FILE ]; then
	if [ "$VERSION_NUMBER" = "" ]; then
		VERSION_NUMBER=`cat $VERSION_FILE 2>/dev/null | grep '^VERSION_NUMBER' | awk '{print $NF}'`
	fi
fi


# build RS9113/RS9116 driver . add by yafei
cd $THIRDPARTY_DIR/RS9113.NBZ.NL.GENR.LNX.1.6.3/source/host/ && make clean && make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE KERNELDIR=$KERNELDIR DEVICENAME=DEVICE_NAME_$1
if [ -e release/onebox_nongpl.ko ];then
	cp release/ $FS_TARGET/usr/local/RS9113_Driver -ad
else
	echo "compile RS9113 driver failed"
	rm -rf $TMP_PATH
	exit -1
fi
cd -

# RS9116
cd $THIRDPARTY_DIR/RS9116.NB0.NL.GENR.LNX.1.2.24.0013/source/host/ && make clean && make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE KERNELDIR=$KERNELDIR DEVICENAME=DEVICE_NAME_$1
if [ -e release/onebox_nongpl.ko ];then
	cp release/ $FS_TARGET/usr/local/RS9116_Driver -ad
else
	echo "compile RS9116 driver failed"
	rm -rf $TMP_PATH
	exit -1
fi
cd -

# build CH340 driver 
cd $THIRDPARTY_DIR/ch340 && make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE KERNELDIR=$KERNELDIR
if [ -e ch34x.ko ];then
	cp ch34x.ko $MODULE_DIR/updates -ad
else
	echo "compile ch340 driver failed"
	rm -rf $TMP_PATH
	exit -1
fi
cd -


# 96PD-RYUW131 wifi driver 
cd $THIRDPARTY_DIR/USB-UAPSTA-8801-U16-X86-W14.68.36.p131-C4X14616_B0-MGPL/wlan_src && make clean && make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE KERNELDIR=$KERNELDIR DEVICENAME=DEVICE_NAME_$1
if [ -e mlan.ko ];then
	cp mlan.ko usb8xxx.ko $MODULE_DIR/updates -ad
else
	echo "compile 96PD-RYUW131 driver failed"
	rm -rf $TMP_PATH
	exit -1
fi
cd -

if [ "$1" = "ECU1253" ];then
	cp $ROOTDIR/external/RS911x/rs9113/* $FS_TARGET/usr/local/RS9113_Driver/	
	cp $ROOTDIR/external/RS911x/rs9116/* $FS_TARGET/usr/local/RS9116_Driver/	
fi

# PHP Package 
if [ "$5" = "PHP_YES" ]; then
	cp ./external/php/etc/* $FS_TARGET/etc/ -a
	cp ./external/php/usr/bin/* $FS_TARGET/usr/bin/ -ad 
	cp ./external/php/usr/lib/* $FS_TARGET/usr/lib/ -ad 
fi

# Python Package
if [ "$6" = "PYTHON_2.7" ]; then 
	cd ./external/python/python2.7/
	mkdir -p etc
	cp ../../../target/etc/profile etc/
	echo "export  PATH=\$PATH:/home/python2.7.14/bin" >> etc/profile
	echo "export  LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/python2.7.14/lib" >> etc/profile
	tar -czpf ../../../custom.tar.gz *
	rm -rf etc
	cd -
fi
if [ "$6" = "PYTHON_3.6" ]; then
	cd ./external/python/python3.6/
	mkdir -p etc
	cp ../../../target/etc/profile etc/
	echo "export  PATH=\$PATH:/home/python3.6.0/bin" >> etc/profile 
	echo "export  LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/python3.6.0/lib" >> etc/profile
	tar -czpf ../../../custom.tar.gz *
	rm -rf etc
	cd -
fi

cd $KERNELDIR
REVISION=`git log -1 --format="%h"`

# minipcie.sh
cd $FS_TARGET
cp usr/bin/minipcie_reset_scripts/$1_reset.sh usr/bin/minipcie_reset.sh
rm -rf usr/bin/minipcie_reset_scripts

cd $FS_TARGET

TIMESTAMP=`date`
if [ -z "$1" ]; then
    echo "Advantech image $VERSION_NUMBER rev $REVISION $TIMESTAMP" > etc/version
    echo "Advantech image $VERSION_NUMBER rev $REVISION $TIMESTAMP" > etc/devicename
else
    if [ -z "$3" ]; then
        if [ -z "$PART_NUMBER" ]; then
            echo "$1 image $VERSION_NUMBER rev $REVISION $TIMESTAMP" > etc/version
        else
            echo "$PART_NUMBER image $VERSION_NUMBER rev $REVISION $TIMESTAMP" > etc/version
        fi    
    else
        echo "$3 image $VERSION_NUMBER rev $REVISION $TIMESTAMP" > etc/version
    fi
    echo "$1 image $VERSION_NUMBER rev $REVISION $TIMESTAMP" > etc/devicename
fi
find ./ -name ".gitignore"|xargs rm -f


if [ "$1" = "ECU1155" ]; then
	sed "/mmcblk0p4/c\/dev/mmcblk3p4      /home                  auto       defaults     0  2" -i etc/fstab
	rm -rf lib/firmware/am*
fi

set -x
sync
tar -czpf ../$RFS_FILE ./* --exclude=/lost+found --exclude-vcs --exclude=.gitignore --numeric-owner --owner=0 --group=0
mv -f $TMP_PATH/$RFS_FILE $ROOTDIR

echo "build ramdisk"
cd $RAMDISKDIR
sh build_ramdisk.sh $1
mv $RAMDISKDIR/ramdisk.gz $ROOTDIR
sync 

cd $ROOTDIR

echo "rootfs build finish."

exit 0
