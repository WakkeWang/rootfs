#!/bin/sh
# usage: ./build_fs.sh DEVICE_NAME TAGLINK_PATH [PART_NUMBER]
# example:
# ./build_fs.sh ADAM3600 /home/root 
# or 
# ./build_fs.sh ADAM3600 /home/sysuser

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$6" ] || [ -z "$7" ]; then
    echo "Usage: ./build_fs.sh DEVICE_NAME TAGLINK_PATH [PART_NUMBER] [RT_ARG] [PHP_ARG] [PYTHON_ARG] [KERNELDIR] [THIRDPARTY_DIR] [RAMDISKDIR]" 
    echo "example:"
    echo "  $0 ADAM3600 /home/sysuser ADAM3600 NORT PHP_NO PYTHON_NO [KERNELDIR] [THIRDPARTY_DIR] [RAMDISKDIR]"
    echo "    for TAGLINK image"
    echo "  or "
    echo "  $0 ADAM3600 /home/root ADAM3600 NORT PHP_NO PYTHON_NO [KERNELDIR] [THIRDPARTY_DIR] [RAMDISKDIR]"
    echo "    for pure image"
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
cp -a target/ $TMP_PATH/
sync

ROOTDIR=`pwd`

FS_TARGET=$TMP_PATH/target
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


remove_gplv3_files() {
    file_list=`grep License: var/lib/opkg/info/*.control | grep -i GPLv3 | grep -v RLE | cut -d: -f1 | sort -u | sed 's/control/list/'`

    for i in $file_list
    do
        files=`cat ./$i`
	    for j in $files
	    do
		    echo deleting file : .$j
		    rm -rf .$j
	    done
	
	    pkg_file=`echo ./$i | sed 's/list/*/'`
	    echo deleting package info files : $pkg_file
	    rm -rf $pkg_file
    done
	
    sync
}

remove_Qt_files() {
    rm -rf usr/share/qtopia
    rm -rf usr/lib/qtopia
    rm -f usr/lib/libQt*
    sync
}

remove_misc_files() {
    rm -rf var/lib/opkg
    rm -f bin/su
    rm -f sbin/sulogin
    rm -f usr/bin/telnet
    rm -f usr/sbin/telnetd
    rm -f usr/bin/nc
    rm -f usr/bin/tftp
    rm -f usr/bin/tftpd
    rm -f usr/bin/tcpsvd
    rm -f usr/bin/wget
    rm -f usr/bin/lsattr
    rm -f usr/bin/chattr
    rm -f usr/bin/env
    rm -f usr/sbin/ntpd
    rm -f usr/sbin/crond
    rm -f usr/sbin/crontab
    rm -f usr/sbin/ntpd
    rm -f usr/sbin/inetd
    rm -f sbin/mkfs.ext2
    rm -f sbin/mkfs.ext3
    rm -f sbin/mkfs.ext4
    rm -f sbin/mkfs.ext4dev
    rm -f sbin/mkfs.minix
    sync
}

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

if [ "$1" = "ECU1253" ]; then
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

if [ "$1" = "ECU4553L" ];then
	cd $FS_TARGET
	sed "/mmcblk0p4/c\/dev/mmcblk1p4      /home                  auto       defaults     0  2" -i etc/fstab
	sed "/parameters_speed/c\options musb_hdrc parameters_speed=1" -i etc/modprobe.d/modprobe.conf
	rm etc/udev/rules.d/70-persistent-net.rules
	cd -
fi

# minipcie.sh 
cd $FS_TARGET
cp usr/bin/minipcie_reset_scripts/$1_reset.sh usr/bin/minipcie_reset.sh 
rm -rf usr/bin/minipcie_reset_scripts
cd - 

cd $KERNELDIR
REVISION=`git log -1 --format="%h"`
cd -

cd $FS_TARGET
remove_gplv3_files
remove_Qt_files
if [ -z "$1" ]; then
    echo "build root file system."
    sed "/server.port/c\server.port = 80" -i etc/lighttpd.conf
else
	echo "build $1 root file system."

	if [ "$2" = "/home/root" ];then
		sed -i "/remount,/d" etc/init.d/edgelink.sh
        sed "/rootfs/c\rootfs               \/                    auto       defaults              1  1" -i etc/fstab
	fi

    if [ "$1" = "AMCMQ200N" ] || [ "$1" = "SYS800" ] || [ "$1" = "TMS10" ] || [ "$1" = "SYS800021" ]; then
        rm -f etc/init.d/adam3600.sh
    fi
    if [ "$1" = "AMCMQ200N" ]; then
        remove_misc_files
        # remove services
        rm -f etc/rc5.d/S10dropbear
        rm -f etc/rc5.d/S10telnetd
        rm -f etc/rc5.d/S70lighttpd
        # replate lite busybox
        cp -f bin/busybox.lite bin/busybox
        # add root password for Samsung: n5Uv9Dm%CR991a*P
        sed "/root:/c\root:\$5\$m3Xvo2r9UpwzQMtg\$v.FaIcOUYOMyTI5G\/6D4tfahmXkIjd5.vFdOzjXDPq1:17109:0:99999:7:::" -i etc/shadow
        # add sysuser password for Samsung: MgET0k$O2v2ufxWR
        sed "/sysuser:/c\sysuser:\$5\$m.8RI\/5NvKyGnHK\$Jro1bT.FtzKIxhIKwA6g4lMFXkWHjLSg6Arlei\/\/ltA:17109:0:99999:7:::" -i etc/shadow
        # setup timezone
        cp -f usr/share/zoneinfo/Asia/Seoul etc/localtime
    else
        sed "/server.port/c\server.port = 80" -i etc/lighttpd.conf
    fi

    if [ "$1" = "WISE4610" ]; then
        sed "s#size=16M#size=50M#g" -i etc/fstab
        rm -rf usr/lib/jvm
    fi
    
    if [ "$1" = "ADAM5630" ] || [ "$1" = "ECU1051" ] || [ "$1" = "ECU1051B" ] || [ "$1" = "ECU1051BG" ] || [ "$1" = "SYS800022" ] || [ "$1" = "ECU1050" ] || [ "$1" = "ECU1051E" ] || [ "$1" = "ECU1251D" ] || [ "$1" = "SYS800023" ] || [ "$1" = "SYS800024" ]; then
        sed "/\/dev\/mmcblk0p4/d" -i etc/fstab
        echo "/dev/ubi1_0          /media/recovery      ubifs      defaults              0  0" >> etc/fstab
        echo "/dev/ubi2_0          /home                ubifs      defaults              0  2" >> etc/fstab
        # setup lighttpd upload dirs to /media/recovery/uploads
        sed "/^server.upload-dirs=/c\server.upload-dirs=( \"/media/recovery/uploads\" )" -i etc/lighttpd.conf
    fi
    if [ "$1" = "WISE2834" ] || [ "$1" = "ADAM67C1" ]; then
        sed "/\/dev\/mmcblk0p4/d" -i etc/fstab
        echo "/dev/ubi1_0          /home                ubifs      defaults              0  2" >> etc/fstab
    fi
    if [ "$1" = "ADAM6750" ] || [ "$1" = "ADAM6717" ] || [ "$1" = "ADAM6760D" ]; then
        sed "/\/dev\/mmcblk0p4/d" -i etc/fstab
        echo "/dev/ubi2_0          /home                ubifs      defaults              0  2" >> etc/fstab
        # setup lighttpd upload dirs to /media/recovery/uploads
        sed "/^server.upload-dirs=/c\server.upload-dirs=( \"/media/recovery/uploads\" )" -i etc/lighttpd.conf
        
        # add adam67xx restart command
        echo "#!/bin/sh" >> etc/init.d/adam67xx-restart.sh
	echo "TAGLINK_PATH=\`cat /etc/profile | grep TAGLINK_PATH | head -1 | awk -F = '{print \$2}'\`" >> etc/init.d/adam67xx-restart.sh
        echo "\$TAGLINK_PATH/util/iotest ascii \@01RESTART" >> etc/init.d/adam67xx-restart.sh
        echo "exit 0" >> etc/init.d/adam67xx-restart.sh
        chmod +x etc/init.d/adam67xx-restart.sh
	ln -sf ../init.d/adam67xx-restart.sh etc/rc6.d/K80adam67xx-restart.sh
    fi

    if [ "$1" = "ECU4553L" ]; then
        sed "/^server.upload-dirs=/c\server.upload-dirs=( \"/media/mmcblk1p3/uploads\" )" -i etc/lighttpd.conf
    elif [ "$1" = "ECU1155" ]; then
        sed "/^server.upload-dirs=/c\server.upload-dirs=( \"/media/mmcblk3p3/uploads\" )" -i etc/lighttpd.conf
    elif [ "$1" = "ECU1253" ]; then
        sed "/^server.upload-dirs=/c\server.upload-dirs=( \"/media/mmcblk1p6/uploads\" )" -i etc/lighttpd.conf
    fi

    if [ "$1" = "WISE2834" ]; then
        sed "s/ifplugd -d 2/ifplugd -d 5/g" -i etc/init.d/adv335x.sh
    fi

    if [ "$1" = "ECU1155" ]; then
        sed "s/mmcblk0p4/mmcblk3p4/g" -i etc/fstab
        sed "s/ttyO0/ttymxc0/g" -i etc/inittab
        sed "s/mmcblk0p3/mmcblk3p3/g" -i etc/init.d/adv335x.sh
        sed "s/mmcblk0p4/mmcblk3p4/g" -i etc/init.d/adv335x.sh
        sed "/ti_am335x_adc/d" -i etc/init.d/adv335x.sh
    fi

    if [ "$1" = "ECU1253" ]; then
        sed "s/mmcblk0p4/mmcblk1p7/g" -i etc/fstab
        sed "s/ttyO0/ttyFIQ0/g" -i etc/inittab
        sed "s/mmcblk0p3/mmcblk1p6/g" -i etc/init.d/adv335x.sh
        sed "s/mmcblk0p4/mmcblk1p7/g" -i etc/init.d/adv335x.sh
        sed "/ti_am335x_adc/d" -i etc/init.d/adv335x.sh
    fi

	TAGLINK_PATH=$2
	if [ "$TAGLINK_PATH" = "/home/root" ]; then
        sed "/^TAGLINK_PATH=/c\TAGLINK_PATH=/home/root" -i etc/profile
        sed "/^TAGLINK_PATH=/c\TAGLINK_PATH=/home/root" -i etc/init.d/adv335x.sh
        sed "s#\/home\/sysuser#$TAGLINK_PATH#g" -i etc/lighttpd.conf
        sed "/^TAGLINK_PATH=/c\TAGLINK_PATH=/home/root" -i etc/init.d/edgelink.sh
	    sync;sync
    else
        rm -f etc/rc5.d/S70lighttpd
	fi

	if [ "$1" = "ECU1051" ] || [ "$1" = "ECU1051B" ] || [ "$1" = "ECU1051BG" ] || [ "$1" = "ECU1051E" ] || [ "$1" = "ECU1251D" ] || [ "$1" = "SYS800023" ]; then
		rm -rf etc/rcS.d/S22udev
		rm -rf etc/rc5.d/S02dbus-1 etc/rc5.d/S10dropbear etc/rc5.d/S10telnetd
		rm -rf etc/rc5.d/S70lighttpd etc/rc5.d/S91adv335x.sh etc/rc5.d/S90mount-sdcard

		echo "#!/bin/sh" >> etc/init.d/background.sh
		echo "echo 1 4 1 7 > /proc/sys/kernel/printk"  >> etc/init.d/background.sh
		echo "/etc/init.d/udev 2&> /dev/null          "   >> etc/init.d/background.sh
		echo "/etc/init.d/dbus-1 start 2&> /dev/null  "   >> etc/init.d/background.sh
		if [ "$TAGLINK_PATH" = "/home/root" ]; then
			echo "/etc/init.d/lighttpd start 2&> /dev/null"   >> etc/init.d/background.sh
		fi
		echo "/etc/init.d/dropbear start 2&> /dev/null"   >> etc/init.d/background.sh
		echo "/etc/init.d/telnet start 2&> /dev/null  "   >> etc/init.d/background.sh
		echo "/etc/init.d/mount-sdcard 2&> /dev/null  "   >> etc/init.d/background.sh
		echo "/etc/init.d/adv335x.sh 2&> /dev/null    "   >> etc/init.d/background.sh
		echo "exit 0" >> etc/init.d/background.sh

		chmod +x etc/init.d/background.sh 

		echo "#!/bin/sh" >> etc/init.d/start_background.sh
		echo "/etc/init.d/background.sh &" >> etc/init.d/start_background.sh
		echo "exit 0" >> etc/init.d/start_background.sh 
		chmod +x  etc/init.d/start_background.sh 

		ln -sf /etc/init.d/start_background.sh  etc/rc5.d/S30start_background.sh
	fi
fi


chmod 640 etc/shadow
chmod 640 etc/passwd
chmod 640 etc/group
chmod 640 etc/gshadow
rm -f bin/busybox.lite

TIMESTAMP=`date`
if [ -z "$1" ]; then
    echo "Adv335x image $VERSION_NUMBER rev $REVISION $TIMESTAMP" > etc/version
    echo "Adv335x image $VERSION_NUMBER rev $REVISION $TIMESTAMP" > etc/devicename
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
rm -rf home/root
rm -rf home/ftp
rm -rf home/sysuser
find ./ -name ".gitignore"|xargs rm -f
sync
tar -czpf ../$RFS_FILE ./* --exclude=/lost+found --exclude-vcs --exclude=.gitignore --numeric-owner --owner=0 --group=0
if [ "$1" = "AMCMQ200N" ]; then
    cp -f /tmp/busybox bin/busybox
    cp -f /tmp/shadow etc/shadow
fi
rm -f etc/version
rm -f etc/devicename
sync
cd -
mv -f $TMP_PATH/$RFS_FILE .
if [ "$1" = "ECU1051" ] || [ "$1" = "ECU1051B" ] || [ "$1" = "ECU1051BG" ] || [	"$1" = "SYS800022" ] || [ "$1" = "ECU1050" ] || [ "$1" = "ADAM5630" ] || [ "$1" = "ECU1051E" ] || [ "$1" = "ECU1251D" ] || [ "$1" = "SYS800023" ] || [ "$1" = "SYS800024" ]; then
	find $TMP_PATH/target -name ".gitignore"|xargs rm -f
    if [ -f build_ubifs.sh ]; then
        ./build_ubifs.sh $1 $TMP_PATH/target
	fi
fi
rm -rf $TMP_PATH
sync

echo "build ramdisk"
cd $RAMDISKDIR
sh build_ramdisk.sh $1
mv $RAMDISKDIR/ramdisk.gz $ROOTDIR
sync 

echo "rootfs build finish."

exit 0
