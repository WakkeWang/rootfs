################################################################################
This README file describes how to build root filesystem for adv335x platform.
################################################################################
1> build u-boot and kernel.

2> copy the u-boot file(MLO, u-boot.img) and  the kernel file(uImage, am335x-???.dtb) to current directory.
MLO file locate at: PowerEnergy/os/linux/trunk/adv335x/u-boot-2013.01.01-psp06.00.00.00/adv335x/MLO
u-boot.img file locate at: PowerEnergy/os/linux/trunk/adv335x/u-boot-2013.01.01-psp06.00.00.00/adv335x/u-boot.img
uImage file locate at: PowerEnergy/os/linux/trunk/adv335x/linux-3.12.10-ti2013.12.01-rt/arch/arm/boot/uImage
dtb file locate at: PowerEnergy/os/linux/trunk/adv335x/linux-3.12.10-ti2013.12.01-rt/arch/arm/boot/dts/am335x-???.dtb

am335x-???.dtb is am335x-adam3600.dtb, am335x-ecu1152.dtb, am335x-ecu4552.dtb or am335x-ecu4553.dtb ...
Note: in the current directory to only one DTB file.

For the BOSCH's WISE4610 device, please copy PowerEnergy/os/trunk/fs/rootfs/external/java/jre/ejre-7u75-fcs-b13-linux-arm-vfp-hflt-server_headless-18_dec_2014.tar.gz
to the current directory.

3> run create-sdcard.sh to make root filesystem:
sudo ./create-sdcard.sh

################################################################################
build rootfs.tar.gz/rootfs.ubi
################################################################################
./build_fs.sh ADAM3600 /home/sysuser
or
./build_fs.sh ADAM3600 /home/sysuser [PART_NUMBER]

For the ECU1051/ECU1050/ADAM5630 NAND device, will build a rootfs.ubi file, to use update image for factory production.
################################################################################
SD/TF card update image
1> Format SD/TF card for FAT format.
2> Copy MLO, u-boot.img, uImage, am335x-???.dtb, ramdisk.gz, rootfs.tar.gz, advupdate.txt, 
apps.tar.gz/custom.tar.gz(according to the device, maybe not this file), checksum.md5 file to SD/TF card.
3> Insert the SD/TF card into the Storage card slot, power on.
4> A few minutes later, the system will restart, remove the SD card, complete the update.


################################################################################
advupdate.txt configuration file description
1> advimage=y will update uboot and kernel
2> advrootfs=y will recovery linux file system
3> advrecover=y will copy files to recovery partition
4> advfactory=y will restore factory deafault setting


################################################################################
TF card image backup and restore
backup:
1> Insert TF card reader to linux distributions system, open a terminal, run the command:
sudo fdisk -l
   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1       10443    83883366   83  Linux
list TF card dev name is /dev/sdb
2> run the command:
sudo dd if=/dev/sdb of=~/adam3600.img bs=1M

restore:
open a terminal, run the command:
sudo dd if=~/adam3600.img of=/dev/sdb bs=1M

