TARGETS = mountkernfs.sh alsa-utils resolvconf pppd-dns hostname.sh x11-common udev mountdevsubfs.sh procps hwclock.sh networking urandom checkroot.sh mountnfs-bootclean.sh mountnfs.sh bootmisc.sh mountall.sh checkfs.sh checkroot-bootclean.sh mountall-bootclean.sh kmod
INTERACTIVE = udev checkroot.sh checkfs.sh
udev: mountkernfs.sh
mountdevsubfs.sh: mountkernfs.sh udev
procps: mountkernfs.sh udev
hwclock.sh: mountdevsubfs.sh
networking: mountkernfs.sh urandom resolvconf procps
urandom: hwclock.sh
checkroot.sh: hwclock.sh mountdevsubfs.sh hostname.sh
mountnfs-bootclean.sh: mountnfs.sh
mountnfs.sh: networking
bootmisc.sh: mountnfs-bootclean.sh udev mountall-bootclean.sh checkroot-bootclean.sh
mountall.sh: checkfs.sh checkroot-bootclean.sh
checkfs.sh: checkroot.sh
checkroot-bootclean.sh: checkroot.sh
mountall-bootclean.sh: mountall.sh
kmod: checkroot.sh
