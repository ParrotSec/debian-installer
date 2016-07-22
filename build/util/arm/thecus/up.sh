#!/bin/sh

# Copyright (C) 2006  Martin Michlmayr <tbm@cyrius.com>

# This code is covered by the GNU General Public License.

# See installer/doc/devel/hardware/arm/thecus/firmware for an explanation
# of the upgrade process on Thecus machines.


info() {
	echo "$@" > /tmp/upgrade/message
}

debug() {
	echo "$@" > /tmp/upgrade/debug
}

# Note: the firmware upgrade script looks for the string "fail" in the
# error message, so make sure this passed to the error function.
error() {
	info "$@"
	debug "$@"
	rm -f /var/lock/upgrade.lock
	exit 1
}

mtddev() {
	grep "$1" /proc/mtd | cut -d: -f 1 | sed 's/mtd/\/dev\/mtd/'
}

mtddevblock() {
	grep "$1" /proc/mtd | cut -d: -f 1 | sed 's/mtd/\/dev\/mtdblock/'
}



lockfile /var/lock/upgrade.lock

cd /tmp/upgrade

# If hw_status is 0 the machine is being reset to "factory default".  In
# our case, this means that we don't check whether the machine name
# matches /app/manifest.txt.
HW_STATUS=$(redboot_config get /dev/mtdblock4 hw_status)
if [ $HW_STATUS -ne 1 ]; then
	product=$(grep "^type" /app/manifest.txt | cut -f 2)
	case $product in
		# N2100 and compatible machines
		n2100 | all6500 | Mbox)
			info "N2100 compatible machine $product found"
			;;
		# N4100 and compatible machines
		n4100 | all6400 | PlatinumNAS)
			info "N4100 compatible machine $product found"
			;;
		# Unknown
		*)
			error "Machine detection of $product: fail"
			;;
	esac
fi

if [ ! -e /proc/mtd ]; then
	error "Finding /proc/mtd: fail"
fi
mtdramdisk=$(mtddevblock ramdisk)
mtdkernel=$(mtddev kernel)
if [ -z "$mtdramdisk" ]; then
	error "Finding mtd ramdisk: fail"
fi
if [ -z "$mtdkernel" ]; then
	error "Finding mtd kernel: fail"
fi

info "Writing installer ramdisk... please wait..."
ifile=initrd
size=$(grep "ramdisk" /proc/mtd | cut -d " " -f 2)
size=$(printf "%d" 0x$size)
isize=$(wc -c $ifile | cut -d " " -f 1)
pad=$(expr $size - $isize)
(
	cat $ifile
	dd if=/dev/zero bs=$pad count=1 2>/dev/null
) > $mtdramdisk
if [ $? -ne 0 ]; then
	error "Upgrading ramdisk: fail"
fi

info "Writing installer kernel... please wait..."
fcp vmlinuz $mtdkernel
if [ $? -ne 0 ]; then
	error "Upgrading kernel: fail"
fi

echo "Buzzer 0" > /proc/thecus_io
sleep 1
echo "Buzzer 1" > /proc/thecus_io
# The firmware upgrade script looks for the following string.  If it cannot
# find it, it won't terminate.
info "success"
rm -f /var/lock/upgrade.lock

exit 0

