#!/bin/sh

set -x


DEVICE_NAME=$1
if [ "$1" = "" ];then
	echo "please input device_name"
	exit 0
fi
mkdir -p rootfs_tmp

# 20M
dd if=/dev/zero of=ramdisk bs=1k count=20480

mke2fs -F -m 0 -L "ramdisk" ramdisk

mount -o loop ramdisk rootfs_tmp

cp rootfs_ramdisk/* rootfs_tmp/ -ad 

config_file=`find rootfs_tmp -name config_$DEVICE_NAME`
cp $config_file rootfs_tmp/root/config -ad 

rm -rf rootfs_tmp/root/configs

sync;
sync;

find rootfs_tmp/ -name .gitignore | xargs rm -rf 

umount rootfs_tmp

gzip -9 -c ramdisk > ramdisk.gz

rm -rf rootfs_tmp ramdisk

sync

exit 0
