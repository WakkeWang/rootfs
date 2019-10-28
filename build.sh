#!/bin/sh

set -x

mkdir -p Adv_tmp

# 20M
dd if=/dev/zero of=ramdisk bs=1k count=20480

# format to ext3
mkfs.ext3  -F -L "Ramsidk" ramdisk

mount ramdisk Adv_tmp

cp upgrade_ramdisk/* Adv_tmp/ -ad 

sync;
sync;

umount Adv_tmp

gzip -9 -c ramdisk > ramdisk.gz

rm -rf Adv_tmp ramdisk


exit
