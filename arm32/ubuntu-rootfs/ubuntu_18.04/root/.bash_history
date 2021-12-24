ls
cd ..
ls
rm -rf file/
sync
du -d 1 -h
df -h
cd /
du -h -d 1
cd usr/
l
du -h -d 1
cd l
cd lib/
ls
cd ..
ls
cd share/
ls
du -d 1 -h
cd vim/
ls
cd vim74/
ls
du -h -d 1
cd spell/
ls
cd ..
ls
mv spell/ spell_
sync
vi /etc/init.d/advantech.sh 
mv spell_/ spell
sync
cd
ls
sync
ifconfig
cd /usr/share/
ls
cd vim/
ls
du -h
sync
reboot
ls
ifconfig
systemctl disable systemd-hostnamed.service
systemctl disable systemd-timesyncd.service
systemctl status systemd-tmpfiles-setup.service
vi /usr/lib/tmpfiles.d/var.conf 
systemctl status systemd-tmpfiles-setup.service
cd /
ll
rm -rf tmp 
mkdir tmp
sync
reboot
ifconfig
cd /etc/NetworkManager/
ls
cd system-connections/
ls
la
ls
nmcli con del eth0-2*
ls
nmcli con del eth0-2*
cd ..
cd 
ifconfig
sync
reboot
ifconfig
vi 1.sh
sh 1.sh 
vi 1.sh
vi /etc/init.d/advantech.sh 
sync
ifconfig
cd /etc/NetworkManager/system-connections/
ls
ifconfig
ls
nmcli con del eth0-23a432e8-fa99-46b5-890b-b53e87704511
ls
rm eth0-2*
ls
rm eth*
ls
sync
cd
reboot
ifconfig
cd /etc/NetworkManager/system-connections/
ls
ifconfig
ls
ifconfig
ls
ifconfig
ls
cd
vi /etc/init.d/advantech.sh 
/etc/init.d/advantech.sh 
ifconfig
vi /etc/init.d/advantech.sh 
sync
ifconfig
reboot
ifconfig
cd /etc/NetworkManager/system-connections/
ls
ll
ps ax
cd /
vi /etc/init.d/advantech.sh 
sync
reboot
ifconfig
cd /etc/NetworkManager/system-connections/
ls
ps ax
cd
cd -
ls
cd
systemctl status advantech.service 
cd -
ls
nmcli con show eth0-e48d4d81-4936-4aa9-b390-67937b648ce4
nmcli con show eth0
ls
ifconfig
rm -rf eth-e*
ls
ll
rm -rf eth0-e48d4d81-4936-4aa9-b390-67937b648ce4
ls
sync
reboot
ifconfig
ps ax
ifconfig
cd /etc/NetworkManager/system-connections/
ls
vi /etc/init.d/advantech.sh 
sync
reboot
lsmod
depmod -a
lsmod
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
sync
cd
reboot
lsmod
cd /etc/init.d/
ls
vi kmod 
ls
/etc/init.d/kmod start
lsmod
systemctl enable kmod.service.
systemctl enable kmod.service
systemctl start kmod.service
lsmod
sync
reboot
lsmod
cd 
cd /etc/systemd/system/
ls
cd /lib/systemd/system
ls
ls *mod*
systemctl enable systemd-modules-load.service 
systemctl start systemd-modules-load.service 
lsmod
sync
reboot
lsmod
uname -a
dmesg 
uname -a
ls
ifconfig
cd /lib/modules/
ls
cd 4.9.69-g9ce43c71ae/
ls
rm -rf *
ls
ifconfig
pwd
ls
tar xvf modules.tar.gz 
date
date -s "2020-11-24 17:29:00"
hwclock -w -f /dev/rtc0 
hwclock -w -f /dev/rtc1
date
tar xvf modules.tar.gz 
sync
rm -rf modules.tar.gz 
ls
cd
sync
reboot 
lsmod
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
depmod -a
ls
sync
reboot 
lsmod
lsusb
lsmod
iptables -L
lsmod
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
rm -rf *
ls
tar xvf modules.tar.gz 
sync
ls
cd /lib/systemd/system
ls
ls *mod*
cat systemd-modules-load.service 
cat kmod.service 
systemctl status kmod.service 
systemctl status systemd-modules-load.service 
cat systemd-modules-load.service 
ls /lib/modules-load.d
/lib/systemd/systemd-modules-load
lsmod
ls
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
cd
cd -
ls
cd
sync
reboot
ifconfig
lsmod
172.21.67.255
systemctl daemon-reload
cd /lib/modules/
ls
cd 4.9.69-g9ce43c71ae/
ls
cat /lib/systemd/system/systemd-modules-load.service 
cd
cat /lib/systemd/system/systemd-modules-load.service 
mkdir /lib/modules-load.d
mkdir /usr/lib/modules-load.d
mkdir /etc/modules-load.d
mkdir /run/modules-load.d
/lib/systemd/systemd-modules-load
lsmod
systemd-analyze
systemd-analyze blame
systemd-analyze plot
systemd-analyze plot > boot.svg
ls
scp boot.svg root@192.168.172.3:/home/advantech
cd /lib/systemd/system
cat systemd-udevd-kernel.socket 
cat systemd-remount-fs.service 
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
mv modules.tar.gz ../
ls
depmod -a
lsmod
/lib/systemd/systemd-modules-load 
lsmod
ls
/etc/init.d/kmod start
lsmod
/etc/init.d/kmod start
lsmod
systemctl enable systemd-modules-load.service
lsmod
systemctl enable systemd-modules-load.service
cd 
systemctl start systemd-modules-load.service
lsmod
echo "loop" > /etc/modules-load.d/loop.conf
sync
systemctl start systemd-modules-load.servicel
systemctl start systemd-modules-load.service
lsmod
reboot
lsmod
systemd-analyze blame
systemd-analyze blame 
systemd-udevd.service
lsmod
ls
cd /lib/firmware/
ls
ll
ls
cd
lsmod
lsusb
cd /
cd
cd /lib/modules
ls
cd 4.9.69-g9ce43c71ae/
ls
rm -rf *
ls
tar xvf ../modules.tar.gz 
ls
date
hwclock -r -f /dev/rtc1
cd
systemd-analyze 
systemd-analyze blame
cd /lib/systemd/system
ls *hwclock*
cat hwclock.service 
ll hwclock.service 
cp advantech.service hwclock.service 
vi hwclock.service 
ls
cat advantech.service 
rm hwclock.service 
cp advantech.service hwclock.service 
cat hwclock.service 
ifconfig
cd
reboot
cd /lib/systemd/system
vi hwclock.service 
cd /etc/init.d/
ls hwclock.sh 
vi hwclock.sh 
date
hwclock -r -f /dev/rtc0
hwclock -r -f /dev/rtc1
/etc/init.d/hwclock.sh start
date
vi hwclock.sh 
/etc/init.d/hwclock.sh start
vi hwclock.sh 
/etc/init.d/hwclock.sh start
vi hwclock.sh 
tzconfig -h
tzconfig --help
tzconfig 
dpkg-reconfigure tzdata
tzconfig 
hwclock --help
date
hwclock -r -f /dev/rtc0
hwclock -r -f /dev/rtc1
hwclock --hctosys -f /dev/rtc1
date
date -s "2016"
date
date -s "2016-01-01"
date
vi hwclock.sh 
./hwclock.sh 
./hwclock.sh start
systemctl daemon-reload
./hwclock.sh start
date
systemctl enable hwclock.service 
systemctl start hwclock.service 
date
systemctl status hwclock.service 
vi hwclock.sh 
systemctl start hwclock.service 
systemctl status hwclock.service 
date
vi hwclock.sh 
systemctl start hwclock.service 
date
vi hwclock.sh 
sync
./hwclock.sh stop
date
hwclock -r -f /dev/rtc0
date
./hwclock.sh stop
vi hwclock.sh 
systemctl stop hwcolck.service
systemctl stop hwclock.service
systemctl status hwclock.service
date
hwclock -r -f /dev/rtc0
hwclock -r -f /dev/rtc1
vi hwclock.sh 
./hwclock.sh stop
hwclock -r -f /dev/rtc0
vi hwclock.sh 
systemctl status hwclock.service
date
hwclock -r -f /dev/rtc0
hwclock -r -f /dev/rtc1
vi hwclock.sh 
date -s "2016-01-11"
date
hwclock -r -f /dev/rtc1
systemctl start hwclock.service 
date
date -s "2016-01-11"
systemctl stop hwclock.service 
hwclock -r -f /dev/rtc1
./hwclock.sh stop
hwclock -r -f /dev/rtc1
date
mv hwclock.sh hwclock.sh_
vi hwclock.sh
chmod +x hwclock.sh
date
hwclock -r -f /dev/rtc1
./hwclock.sh stop
date
hwclock -r -f /dev/rtc1
vi hwclock.sh
./hwclock.sh stop
./hwclock.sh start
vi hwclock.sh
systemctl daemon-reload 
date
date -s "2017-01-01"
date
systemctl start hwclock.service 
date
date -s "2017-01-01"
systemctl stop hwclock.service 
date
hwclock -r -f /dev/rt0
hwclock -r -f /dev/rt1
hwclock -r -f /dev/rtc0
hwclock -r -f /dev/rtc1
date
systemctl stop hwclock.service 
hwclock -r -f /dev/rtc1
systemctl status hwclock.service 
./hwclock.sh stop
cd /lib/systemd/system
ls *.service
cat systemd-udevd.service
cat hwclock.service 
vi hwclock.service 
systemctl daemon-reload 
date
hwclock -r -f /dev/rtc1
date -s "2016-1-1"
systemctl stop hwclock.service
hwclock -r -f /dev/rtc1
systemctl status hwclock.service
vi hwclock.service 
vi /etc/init.d/hwclock.sh
systemctl stop hwclock.service
systemctl status hwclock.service
systemctl start hwclock.service
vi hwclock.service 
grep "Exec" -nR .
vi hwclock.service 
vi dropbear.service 
systemctl daemon-reload 
systemctl stop hwclock.service 
systemctl status hwclock.service 
systemctl start hwclock.service 
systemctl status hwclock.service 
systemctl stop hwclock.service 
systemctl status hwclock.service 
vi /etc/init.d/hwclock.sh
rm /etc/init.d/hwclock.sh_ 
sync
date
hwclock -r -f /dev/rct*
hwclock -r -f /dev/rct0
hwclock -r -f /dev/rct1
hwclock -r -f /dev/rtc*
hwclock -r -f /dev/rtc0
hwclock -r -f /dev/rtc1
hwclock -w -f /dev/rtc0
hwclock -r -f /dev/rtc0
date
date -s "2018-01-01"
date
hwclock -r -f /dev/rct0
hwclock -r -f /dev/rtc0
hwclock -r -f /dev/rtc1
date
date -s "2018-01-1"
sync
reboot
cd /lib/systemd/system
cat rc.local.service 
cat dropbear.service 
vi dropbear.service 
vi hwclock.service 
sync
cd
reboot
ifconfig
reboot
lsmod
systemctl stop systemd-modules-load.service
systemctl disable systemd-modules-load.service
cd /lib/modules
ls
cd 4.9.69-g9ce43c71ae/
ls
kernel/
ls
cd kernel/
ls
cd ..
ls
rm -rf kernel/
ls
tar xvf ../modules.tar.gz 
date
date -s "2020-11-25 10:19:50"
date
hwclock -w -f /dev/rtc0
hwclock -w -f /dev/rtc1
tar xvf ../modules.tar.gz 
ls
depmod -s
depmod -a
sync
reboot
date
lsmod
systemctl status kmod.service
lsmod
ls
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
rm -rf *
ls
tar xvf ../modules.tar.gz 
ls
cd ..
ls
cd /lib/systemd/su
cd /lib/systemd/system
ls
cat *udev*
ls *udev*
cat systemd-udevd.service
vi systemd-udevd.service
which depmod
vi systemd-udevd.service
systemctl daemon-reload 
systemctl restart systemd-udevd.service
vi systemd-udevd.service
systemctl daemon-reload 
systemctl restart systemd-udevd.service
vi systemd-udevd.service
cp advantech.service module-depmod.service
vi module-depmod.service 
cd /etc/init.d/
cp advantech.sh /etc/init.d/module-depmod.sh
vi module-depmod.sh 
sync
systemctl daemon-reload
systemctl enable module-depmod.service 
systemctl start module-depmod.service 
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
rm -rf *
tar xvf ../modules.tar.gz 
ls
systemctl start module-depmod.service 
ls
rm -rf *
tar xvf ../modules.tar.gz 
sync
cd
reboot
lsmod
vi /etc/rc.local 
sync
cd /lib/modules
ls
cd 4.9.69-g9ce43c71ae/
ls
lsmod
rm -rf *
tar xvf ../modules.tar.gz 
sync
cd 
reboot
lsmod
cd /lib/modules
ls
cd 4.9.69-g9ce43c71ae/
ls
rm -rf *
sync
ls
tar xvf ../modules.tar.gz ./
sync
reboot
lsmod
ifconfig
sync
reboot
lsmod
dmesg 
dmesg -c
reboot
dmesg 
systemctl disable hwclock.service 
sync
reboot
systemctl disable module-depmod.service
rm /lib/
lls
dmesg 
reboot
dmesg 
systemctl status hwclock.service 
systemctl enable hwclock.service 
systemctl start hwclock.service 
dmesg 
ps
ps aux
ps ax
dmesg 
cat /etc/init.d/hwclock.sh 
cat /lib/systemd/system/*clock*
dmesg -c
/etc/init.d/hwclock.sh start
dmesg 
dmesg -c
ls
dmesg -c
hwclock -w -f /dev/rtc1
dmesg 
ifconfig
ls
./busybox 
./busybox hwclock -w -f /dev/rtc1
dmesg 
dmesg -c
~
dmesg -c
./busybox hwclock -w -f /dev/rtc1
dmesg 
du -h busybox 
hwclock -h
hwclock 
dmesg 
dmesg -c
hwclock -w -f /dev/rtc1
dmesg 
ls
cp busybox /bin/
which hwclock 
cd /sbin/
mv hwclock hwclock_
ln -sf ../bin/busybox hwclock
sync
dmesg -c
cd
hwclock -w -f /dev/rtc1
dmesg 
sync
reboot
ifconfig
reboot
ls
cat /etc/version .
cat /etc/version 
ls
ps
/etc/init.d/docker start
vi /etc/fstab 
ls
mount -o remount,rw /
vi /etc/fstab 
sync
reboot
ls
ifconfig
ls
ps
ifconfig
ps
ifconfig
scp
reboot
lsmod
lmsod
lsmod
cd /lib/modules
ls
cd 4.9.69-g9ce43c71ae/
ls
cd
systemctl status systemd-modules-load.service
reboot
lsmod
cd /lib/systemd/system
ls
ls *mod*
cat systemd-modules-load.service
ls /run/systemd/generator.late/module-depmod.service 
cat /run/systemd/generator.late/module-depmod.service 
cd
cp /run/systemd/generator.late/module-depmod.service /lib/systemd/system
vi /lib/systemd/system/module-depmod.service 
sync
systemctl daemon-reolad
systemctl daemon-reload
sync
reboot
lsmod
cd /lib/modules
ls
modprobe bridege
modprobe bridge
ls
uname -a
ls
cat /var/log/syslog 
rm /var/log/syslog 
sync
reboot
cat /var/log/syslog 
sys
systemctl enable systemd-modules-load.service
systemctl enable kmod.service
ifconfig
ls
cd /lib/modules
ls
cd 4.9.69-g9ce43c71ae/
ls
rm -rf *
ls
tar xvf ~/modules.tar.gz 
dagte
date
date 
date -s "2020-12-4 15:41"
tar xvf ~/modules.tar.gz 
sync
reboot
ifconfig
nmcli d s
ls
df -h
ls
rm advantech.s*
ls
df
cd /
ll
mv root root_
df
cd /home/
ls
cd root/
ls
ll
ls
rm -rf *
ls
cd 
ls
cd /
ln -s /home/root root
ls
cd root
ls
cp ../root_/.* . -ad
ls
ll
rm .vim*
rm .vim* -rf
ls
ll
rm -rf .bakvim/
ls
ll
ls
cd 
ls
cd /
ll
rm -rf root_/
ls
cd
ls
ifconfig
lsmod
systemctl status kmod
ls
cd /lib/
uname -a
mkdir modules
cd modules/
ls
mkdir 4.9.69-g9ce43c71ae
ls
cd 4.9.69-g9ce43c71ae/
ls
tar xvf ~/modules.tar.gz 
sync
reboot
ifconfig
ls
lsmod
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
systemctl status kmod.service
depmod -a
reboot
lsmod
ls
lsusb
cd /lib/systemd/system
cp advantech.service depmod.service
mv depmod.service modutil.service
vi modutil.service 
cp ~/module-depmod.sh /etc/init.d/modutil.sh
cat modutil.service 
ls /etc/init.d/modutil.sh
cat /etc/init.d/modutil.sh
/sbin/depmod -a
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
rm -rf *
tar xvf ~/modules.tar.gz 
sync
vi /lib/systemd/system/advantech.service 
systemctl daemon-reload
systemctl enable modutil.service 
sync
reboot
lsmod
systemctl status modutil.service
/etc/init.d/modutil.sh start
systemctl start modutil.service
vi /lib/systemd/system/modutil.service 
systemctl start modutil.service
systemctl daemon-reload
systemctl start modutil.service
cd /lib/modules/
ls
cd 4.9.69-g9ce43c71ae/
ls
rm -rf *
tar xvf ~/modules.tar.gz '' 
sync
reboot
lsmod
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
cd
systemctl status kmod
systemctl start kmod
lsmod
systemctl enable kmod
systemctl enable kmod.service
systemctl status systemd-modules-load.service 
vi /lib/systemd/system/modutil.service 
sync
systemctl daemon-reload
reboot
cd /lib/systemd/system
ls *udev*
vi modutil.service 
systemctl daemon-reload
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
rm -rf *
tar xvf ~/modules.tar.gz 
sync
reboot
lsmod
vi /lib/systemd/system/modutil.service 
sysnc
systemctl daemon-reload
reboot
cd /lib/systemd/system
ls
grep "Before=" -nir
ls *udev*
vi modutil.service 
sync
systemctl daemon-reload
reboot
ifconfig
cd /lib/systemd/system
ls *udev*
vi modutil.service 
sync
systemctl daemon-reload
reboot
cd /lib/modules/4.9.69-g9ce43c71ae/
ls
rm -rf *
tar xvf ~/modules.tar.gz 
sync
reboot
lsmod
cat /lib/systemd/system/rc.local.service 
cat /lib/systemd/system/rcS.service 
vi /etc/init.d/modutil.sh 
cd /lib/systemd/system
ls *udev*
vi modutil.service 
grep "sysinit.target" -nir
systemctl daemon-reload
sync
reboot
ls
lsmod
lsmor
lsmod
reboot
ifconfig
ls
mkdir 1
tar xvf kmod-27-2-armv7h.pkg.tar.xz -C 1
lsc
cd 1/
ls
cd usr/
ls
cd bin/
ls
ll
ldd kmod 
ls
ll
./depmod -h
cd
ls
mkdir 2
tar xvf modules.tar.gz -C 2
cd 1/
ls
cd usr/bin/
ls
./depmod -a -b ~/2
cd
cd 2/
ls
mkdir 4.9.69-g9ce43c71ae
mv * 4.9.69-g9ce43c71ae/
ls
cd 4.9.69-g9ce43c71ae/
ls
cd ..
cd
cd 1/usr/bin/
./depmod -a -b ~/2
ls
cd
cd 2/
ls
mkdir lib/modules
mkdir lib/modules -p
ls
mv 4.9.69-g9ce43c71ae/ lib/modules/
cd 
cd 1/usr/bin/
./depmod -a -b ~/2
ls
cd 
cd 2/
ls
cd lib/
ls
cd modules/4.9.69-g9ce43c71ae/
ls
cd
ls
echo "ecu1155" > /etc/hostname 
sync
reboot
ls
systemctl disable depmod
systemctl disable modutil.service 
sync
reboot
ls
rm -rf 1 2 kmod-27-2-armv7h.pkg.tar.xz module*
ls
ll
ls
ifconfig
ls
reboot
df -h
ls
ls /dev/mmcblk1p1 
mount /dev/mmcblk1p1 /mnt/
cd /mnt/
ls
cd ..
df
umount /mnt
ls
cd
cd /usr/lib/
ls
cd /lib/udev/rules.d/
ls
mv 62-automount.rules ~
sync
c
cd
reboot
df
df -h
ls
chmod +x dosfsck fsck.exfat 
cp dosfsck fsck.exfat /usr/bin/
cd /usr/bin/
ln -sf dosfsck fsck.vfat
cd
ls
mv 62-automount.rules /lib/udev/rules.d/
sync
reboot
df
df -h
cd /
ls
du -h -d 1
cd /var/
ls
du -h -d 1
cd cache/
ls
cd apt/
ls
du -h -d 1
ll
rm pkgcache.bin srcpkgcache.bin archives/*
ls
cd ..
ls
df -h
ls
cd ..
ls
du -h -d 1
cd lib/
ls
du -h -d 1
cd apt/
ls
du -h -d 1
cd lists/
ls
du -h -d 1
ls
du -h -d 1
cd ..
ls
cd ..
ls
cd ..
du -h -d 1
cd lo
ls
cd log/
ls
du -h -d 1
ls
du -h -d 1
ls
cd journal/
ls
ll
cd c07b052128ec4da08e925a009ba721a2/
ls
ll
rm *
ls
df -h
cd ..
ls
cd ..
ls
cd sy
ll
journalctl --disk-usage
journalctl --verify
vi /etc/systemd/journald.conf.d/00-journal-size.conf
cd /etc/systemd/
ls
vi journald.conf 
sync
systemctl restart systemd-journald.service
vi /etc/rsyslog.d/50-default.conf 
vi /etc/logrotate.d/rsyslog 
systemctl restart rsyslog.service 
sync
cd
reboot
ls
./mount.sh 
ls
mv mount.blacklist /etc/udev/
vi mount.sh 
./mount.sh /dev/mmcblk1p1 
df~
./mount.sh /dev/mmcblk1p1 
vi mount.sh 
which mount
vi mount.sh 
./mount.sh /dev/mmcblk1p1 
vi mount.sh 
sync
./mount.sh 
vi mount.sh 
./mount.sh 
df
vi /lib/udev/rules.d/62-automount.rules 
ls
vi mount.sh 
sync
ls
cp mount.sh /etc/udev/scripts/
sync
reboot
df
df -h
dmesg 
ifconfig
df
ls
cd /lib/udev/
cd rules.d/
ls
cp 62-automount.rules /etc/udev/rules.d/
sync
reboot
udevadm -info /dev/mmcblk1p1
udevadm --info /dev/mmcblk1p1
udevadm --hlpe
udevadm --help
udevadm info /dev/mmcblk1p1
ls
dmesg 
cat /var/log/syslog 
rm /var/log/syslog 
sync
reboot
df
cat /var/log/syslog 
vi /etc/udev/rules.d/62-automount.rules 
vi /etc/udev/scripts/mount.sh 
sync
reboot
df
cat /var/log/syslog 
df
ls
cd /etc/udev/rules.d/
ls
mv 62-automount.rules ~
sync
reboot
cat /var/log/syslog 
df
cd /lib/udev/rules.d/
ls
mv 62-automount.rules 91-automount.rules 
sync
reboot
df
cat /var/log/syslog 
cd /lib/udev/rules.d/
ls
cat 60-block.rules 
cat 60-persistent-storage.rules 
mv 91-automount.rules 61-automount.rules 
cat 61-
cat 61-automount.rules 
cd
ls
vi mount.sh 
sync
ls
./mount.sh 
df
dmesg 
tail -f /var/log/syslog 
vi /etc/udev/scripts/
vi /etc/udev/scripts/mount.sh 
sync
reboot
cat /var/log/syslog | tail - 300
cat /var/log/syslog | tail -300
cat /var/log/syslog | tail -600
df
vi /etc/init.d/advantech.sh 
sync
df
reboot
df
tail -f /var/log/syslog | tail -500
cat -f /var/log/syslog | tail -500
cat  /var/log/syslog | tail -500
cd /etc/udev/scripts/
ls
mv mount.sh mount.sh_
vi mount.sh_ 
ls
cd ..
ls
vi mount.blacklist 
cd scripts/
ls
cp mount.sh_ mount.sh
vi mount.sh
sync
reboot
ifconfig
cd /lib/udev/rules.d/
ls
ll
ls *mount*
udevadm control --reload-rules
ls
df
df -h
ls
mv 61-automount.rules 51-automount.rules 
sync
reboot
ls
df
ls /usr/local/bin/disk-mount.sh 
ls /usr/local/bin/disk-mount.sh -l
ls
systemctl enable usb-mount@ 
cd /lib/systemd/system
mv usb-mount@.service disk-mount.service
systemctl enable disk-mount
cat disk-mount.service 
grep "%" -nir
mv disk-mount.service disk-mount@.service 
cat systemd-backlight@.service
vi disk-mount@.service 
systemctl enable disk-mount@ 
cat advantech.service 
vi disk-mount@.service 
systemctl enable disk-mount@ 
cd /lib/udev/rules.d/
ls
ls *auto*
mv 51-automount.rules ~
cat 99-local.rules 
vi /usr/local/bin/disk-mount.sh 
sync
reboot
systemctl status disk-mount@multi-user.service
/usr/local/bin/disk-mount.sh add /dev/mmcblk1p1 
/usr/local/bin/disk-mount.sh add mmcblk1p1 
cat /usr/local/bin/disk-mount.sh 
df
mount
vi /usr/local/bin/disk-mount.sh 
/usr/local/bin/disk-mount.sh remove mmcblk1p1 
df
/usr/local/bin/disk-mount.sh remove mmcblk1p1 
/usr/local/bin/disk-mount.sh add mmcblk1p1 
df
/usr/local/bin/disk-mount.sh remove mmcblk1p1 
ls
cd /lib/udev/rules.d/
ls
cat 60-persistent-storage.rules 
cat 99-local.rules 
cat ~/51-automount.rules 
vi 99-local.rules
sync
reboot
df
systemctl status disk-mount@multi-user.service
cat /lib/systemd/system/disk-mount@.service
cd /lib/systemd/system
grep "%" -niR
cat systemd-fsck@.service
cat /lib/udev/rules.d/99-local.rules 
ls usb-mount@%k.service
ls disk-mount@.service 
vi /lib/udev/rules.d/99-local.rules
ls disk-mount@.service 
vi /lib/udev/rules.d/99-local.rules
sync
reboot
cd /lib/systemd/system/
ls disk-mount@.service 
cat disk-mount@.service 
cat /var/log/syslog | tail -500
systemctl disable disk-mount@.service 
sync
reboot
vi /lib/systemd/system/disk-mount@.service 
systemctl daemon-reload
sync
reboot
df
systemctl start disk-mount@mmcblk1
/usr/local/bin/disk-mount.sh add mmcblk1
vi /lib/systemd/system/disk-mount@.service 
systemctl start disk-mount@mmcblk1p1 
cat /var/log/syslog | tail -700
cd /lib/systemd/system
ls*@*
ls *@*
cat systemd-fsck@.service
vi disk-mount@.service 
sync
systemctl daemon-reload
vi disk-mount@.service 
systemctl daemon-reload
systemctl start disk-mount@mmcblk1p1
cd /lib/udev/rules.d/
ls
vi 99-local.rules 
ifconfig
dhclient eth1
mv /lib/udev/rules.d/
s
cd /lib/udev/rules.d/
ls
mv 99-local.rules ~
sync
reboot
systemctl start disk-mount@mmcblk1p1
systemctl status disk-mount@mmcblk1p1
df
systemctl stop disk-mount@mmcblk1p1
df
systemctl stop disk-mount@mmcblk1p1
df
cd /lib/systemd/system
cat disk-mount@.service 
/usr/local/bin/disk-mount.sh remove mmcblk1p1
df
systemctl stop disk-mount@mmcblk1p1
systemctl start disk-mount@mmcblk1p1
df
systemctl stop disk-mount@mmcblk1p1
df
systemctl status disk-mount@mmcblk1p1
date
systemctl stop disk-mount@mmcblk1p1
systemctl status disk-mount@mmcblk1p1
systemctl start disk-mount@mmcblk1p1
systemctl stop disk-mount@mmcblk1p1
systemctl status disk-mount@mmcblk1p1
df
systemctl stop disk-mount@mmcblk1p1
df
/usr/local/bin/disk-mount.sh remove mmcblk1p1
df
systemctl stop disk-mount@mmcblk1p1
systemctl status disk-mount@mmcblk1p1
date
systemctl start disk-mount@mmcblk1p1
systemctl status disk-mount@mmcblk1p1
systemctl stop disk-mount@mmcblk1p1
systemctl status disk-mount@mmcblk1p1
df
vi /usr/local/bin/disk-mount.sh 
/bin/mount | /bin/grep ${DEVICE} | /usr/bin/awk '{ print $3 }'
cd
/bin/mount | /bin/grep ${DEVICE} | /usr/bin/awk '{ print $3 }'
/bin/mount | /bin/grep mmcblk1p1 | /usr/bin/awk '{ print $3 }'
vi /usr/local/bin/disk-mount.sh 
df
/usr/local/bin/disk-mount.sh remove mmcblk1p1
df
systemctl start disk-mount@mmcblk1p1
systemctl stop disk-mount@mmcblk1p1
systemctl status disk-mount@mmcblk1p1
cat /usr/local/bin/disk-mount.sh 
systemctl status disk-mount@mmcblk1p1
cat /var/log/syslog | tail -10
cat /var/log/syslog | tail -20
vi /usr/local/bin/disk-mount.sh 
df
umount /media/mmcblk1p1
systemctl start disk-mount@mmcblk1p1
cat /var/log/syslog | tail -20
systemctl stop disk-mount@mmcblk1p1
cat /var/log/syslog | tail -20
vi /usr/local/bin/disk-mount.sh 
umount /media/mmcblk1p1
systemctl start disk-mount@mmcblk1p1
df
systemctl stop disk-mount@mmcblk1p1
df
cat /var/log/syslog | tail -20
ls
cp 99-local.rules /lib/udev/rules.d/
cd /lib/udev/rules.d/
ls
vi 99-local.rules 
ifcofnig
ifconfig
which touch
cd /lib/udev/rules.d/
ls
vi 99-local.rules 
sync
mv 99-local.rules 61-automount.rules
sync
reboot
ls
df
cat /var/log/syslog | tail -500
ls
cd/
cd /
l
ls
ll
cd /lib/udev/rules.d/
ls
cat 61-automount.rules 
udevadm info -a -p $(udevadm info -q path -n /dev/mmcblk1p1)
cat 61-automount.rules 
vi 61-automount.rules 
sync
reboot
cd /lib/udev/rules.d/
ls
mv 61-automount.rules 62-automount.rules 
vi 62-automount.rules 
ls
mv 62-automount.rules ~
sync
systemctl start disk-mount@mmcblk1p1
df
systemctl start disk-mount@mmcblk1p1
df
systemctl stop disk-mount@mmcblk1p1
df
ls
cat 51-automount.rules 
vi /etc/init.d/advantech.sh 
sync
reboot
df
/etc/init.d/advantech.sh 
df
ls
which logger
logger ----
logger "----"
logger -s "----"
logger -s "\----"
logger -s "s----"
logger "s----"
logger -s add
df
cat /var/log/syslog | tail -500
ls
cd /lib/udev/rules.d/
ls
ln -s 62-automount.rules /etc/udev/rules.d/62-automount.rules
sync
cat 62-automount.rules 
/usr/bin/logger -s add_device------
cat /var/log/syslog | tail -500 | grep add
df
df -h
cd /var/
du -h -d 1
cd lib/
ls
du -h -d 1
cd ..
cd lo
cd ap
cd apt
ll
du -h -d 1
cd cache/
ls
du -h -d 1
cd apt/
ls
cd ..
ls
cd l
cd lib/
du -h -d 1
cd apt/
ls
du -h -d 1
cd lists/
ls
cd ..
ls
cd ..
ls
cd 
cd /
du -h -d 1
cd /var/
ls
du -h -d 1
cd cache/
ls
cd apt/
ls
du -h -d 1
ls
ll
rm pkgcache.bin srcpkgcache.bin 
ls
df -h
ls
cd ..
ls
rm /var/log/syslog 
sync
reboot 
cat /var/log/syslog | grep add
udevadm control --reload-rules
reboot
cd /lib/udev/rules.d/
ls
vi 60-persistent-storage.rules 
sync
cat /var/log/syslog | grep add
df
cd /lib/udev/rules.d/
ls
cat 62-automount.rules 
rm /var/log/syslog 
sync
reboot
ls
cat 62-automount.rules 
cd /lib/udev/rules.d/
mv 62-automount.rules 60-automount.rules 
mv 60-automount.rules 60-persistent-storage-automount.rules
sync
cat 60-persistent-storage-automount.rules
vi 60-persistent-storage.rules
vi 60-persistent-storage-automount.rules
rm /var/log/syslog 
sync
reboot
df
cat /var/log/syslog | grep add
df
cd /lib/udev/
ls
cd rules.d/
ls
vi 60-persistent-storage-automount.rules
rm /var/log/syslog 
sync
rm /etc/udev/rules.d/62-automount.rules 
sync
reboot
cat /var/log/syslog | grep add
ls
cd /lib/udev/rules.d/
ls
vi 60-persistent-storage-automount.rules
sync
reboot
cat /var/log/syslog | grep add
cd /lib/udev/rules.d/
ls
mv 60-persistent-storage-automount.rules ~
ls *fsck*
cat /lib/systemd/system/*fsck*
cp ~/60-persistent-storage-automount.rules .
vi 60-persistent-storage-automount.rules 
which mkdir
vi 60-persistent-storage-automount.rules 
sync
reboot
df
cd /lib/udev/
cd rules.d/
ls
cat 60-persistent-storage.rules
cat 60-persistent-storage-automount.rules 
cat /var/log/syslog | grep add
vi 60-persistent-storage-automount.rules 
which logger
vi 60-persistent-storage-automount.rules 
sync
rm /var/log/syslog 
sync
reboot
df
cat /var/log/syslog | grep add_
ifconfig
ls
vi /lib/udev/rules.d/60-persistent-storage-automount.rules 
sync
rm /var/log/syslog 
sync
reboot
ls
vi /usr/local/bin/disk-mount.sh 
sync
rm /var/log/syslog 
sync
reboot
df
cat /var/log/syslog | grep ==
df
cat /var/log/syslog 
cat /var/log/syslog | grep mount
cd /lib/udev/rules.d/
ls
mv 60-persistent-storage-automount.rules 95-automount.rules
ll
sync
rm /var/log/syslog 
sync
reboot
df
cat /var/log/syslog | grep add
cat /var/log/syslog | grep ===
df
cat /lib/systemd/system/*fsck*
ls
vi /usr/local/bin/disk-mount.sh 
sync
ls
df
/usr/local/bin/disk-mount.sh add mmcblk1p1
ls
car 1
cat 1
ls
rm 1
ls
sync
reboot
ls
df
ls
cat /var/log/syslog | grep ==
cat /proc/mounts 
cat /proc/mounts | logger
cat /var/log/syslog | tail -100
vi /usr/local/bin/disk-mount.sh 
sync
rm /var/log/syslog 
sync
reboot
cat /var/log/syslog 
cat /var/log/syslog | grep ==
vi /usr/local/bin/disk-mount.sh 
sync
rm /var/log/syslog 
sync
reboot
ls
cd /lib/udev/
ls
cd rules.d/
ls
vi 95-
vi 95-automount.rules 
sync
df
tail -f /var/log/syslog 
df
tail -f /var/log/syslog 
cd /lib/udev/rules.d
ls
vi 99-systemd.rules 
vi 95-automount.rules 
udevadm control --reload-rules
sfd
sd
df
cd 
lsof | grep mmc
apt-get install lsof
lsof | grep mmc
lsof | grep mmcnlk
lsof | grep mmcblk
df
dfdf
df
/usr/local/bin/disk-mount.sh remove mmcblk1p1
/usr/local/bin/disk-mount.sh add mmcblk1p1
df
/usr/local/bin/disk-mount.sh remove mmcblk1p1
df
cat /proc/mounts 
/usr/local/bin/disk-mount.sh add mmcblk1p1
cat /proc/mounts 
df
/usr/local/bin/disk-mount.sh remove mmcblk1p1
cat /proc/mounts 
df
df -h
lsof
lsof | grep mmc
df
df -h
df
df -h
vi /usr/local/bin/disk-mount.sh 
cd /lib/udev/rules.d/
ls
vi 95-automount.rules 
df
cat /proc/mounts 
cat /proc/mounts | grep mmc
cat /proc/mounts | grep mmcblk1
ls
/usr/local/bin/disk-mount.sh remove mmcblk1p1
/usr/local/bin/disk-mount.sh add mmcblk1p1
ls
cd /media/mmcblk1p1/
ls
ll
dd if=/dev/zero of=img bs=1M count=200
ls
vi /usr/local/bin/disk-mount.sh 
sync
/usr/local/bin/disk-mount.sh remove mmcblk1p1
reboot
ls
vi /etc/init.d/advantech.sh 
ls
cd /lib/udev/rules.d/
ls
cat 95-automount.rules 
ls
mkdir bak
mv 60-persistent-* bak/
sync
ls
vi 95-automount.rules 
sync
reboot
ls
df
cd 
df
cat /var/log/syslog | grep ==
ls
df
;d
ls
df
df -h
cat /var/log/syslog | grep ==
rm /var/log/syslog 
sync
cd /
ls
ll
rm root
ls
cp /home/root . -a
sync
cd
ls
ll
sync
vi /etc/fstab 
sync
reboot
df
ifconfig
df
cat /var/log/syslog 
cat /var/log/syslog | grep ==
tail -f /var/log/syslog 
df
tail -f /var/log/syslog 
/usr/local/bin/disk-mount.sh remove mmcblk1p1
ls
dd if=/dev/zero of=/dev/mmcblk1p1 bs=1M count=5
sync
fdisk /dev/mmcblk1p1 
which dosfsck 
cd /usr/bin/
chmod +x mkfs.fat 
ln -sf mkfs.fat mkfs.vfat
cd
ls
mkfs.vfat -n update -F 32 /dev/mmcblk1p1 
sync
tail -f /var/log/syslog 
df
tail -f /var/log/syslog 
df
tail -f /var/log/syslog
df
rm /var/log/syslog 
sync
reboot
df
cat /var/log/syslog | grep ==
df
df -h
ls
ls
cat /etc/fstab 
vi /etc/fstab 
cat /etc/fstab 
cat /etc/fstab | grep "^/"
cat /etc/fstab | grep "^/dev/mmcblk0p2"
cat /proc/mounts 
df
disk-mount.sh add mmcblk1p1
vi /usr/local/bin/disk-mount.sh 
disk-mount.sh add mmcblk1p1
df
cat /proc/mounts 
cat /proc/mounts | grep "^/dev/mmcb"
ls
vi 1.sh 
./1.sh 
df
./1.sh 
df
vi 1.sh 
./1.sh 
vi /usr/local/bin/disk-mount.sh 
vi 1.sh 
./1.sh 
vi 1.sh 
vi /usr/local/bin/disk-mount.sh 
./1.sh 
df
umount /dev/mmcblk1p1 
umount /dev/mmcblk0p1
./1.sh 
df
ls
cat 1.sh 
vi 1.sh 
vi /etc/init.d/advantech.sh 
vi 1.sh 
./1.sh 
vi 1.sh 
./1.sh 
vi 1.sh 
vi /etc/init.d/advantech.sh 
sync
ls
reboot
ls
cd /var/
ls
du -h -d 1
cd cache/
ls
du -h -d 1
ls
cd apt/
ls
cd ad
cd archives/
ls
rm lsof_4.89+dfsg-0.1_armhf.deb 
ls
cd ..
ls
l
ll
rm pkgcache.bin srcpkgcache.bin 
ls
cd ..
ls
cd ..
ls
cd l
cd lib/
ls
du -h -d 1
cd apt/
ls
ll
cd lists/
ls
rm ports.ubuntu.com_ubuntu-ports_dists_bionic*
ls
df -h
sync
ls
cd
ls
reboot
df
df -h
ls
rm img 
ls
rm dosfsck fsck.exfat 
ls
rm 1.sh 
ls
rm mount.sh 
ls
rm [0-9]*
ls
ll
ls
ll
sync
ifconfig
ls
lsusb
ifconfig
ifconfig -a
ls
mv 80-net-setup-link.rules /etc/udev/rules.d/
cd /lib/udev/rules.d/
ls
sync
reboot
ifconfig
ifconfig -a
nmcli c s
cd /etc/NetworkManager/system-connections/
ls
cd
ls
vi wlan.sh 
vi wan.sh 
ls
ifconfig
vi /etc/init.d/advantech.sh 
sync
ls
vi wlan.sh 
./wlan.sh ads 13456789
ifconfig
ifconfig wlan0 up
ifconfig -a
ifconfig wlan0 up
nmcli c s
nmcli c u 7c
nmcli c u Wired connection 1
ls
ifconfig
ifconfig -a
ifconfig wlan0 up
dmesg 
ls
cd /lib/fr
cd /lib/firmware/
ls
pwd
ifconfig
ls
sync
c
cd
ls
reboot 
ifconfig
apt-get install tzdate
apt-get install
apt-get update
apt-get install tzdate
apt-get install tzdata
apt-get install language-pack-en-base
systemctl enable hwclock.service 
sync
exit
ls
apt-get install minicom
exit
dpkg -i minicom_2.7.1-1_armhf.deb 
dpkg -i ethtool_1%3a4.15-0ubuntu1_armhf.deb 
ls
rm ethtool_1%3a4.15-0ubuntu1_armhf.deb minicom_2.7.1-1_armhf.deb 
exit
