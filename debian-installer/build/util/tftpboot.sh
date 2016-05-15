#!/bin/bash -e
# Boot Disk maker for TFTP protocol.
# Eric Delaunay, February 1998.
# Ben Collins, March 2000,2002
# Thiemo Seufer, 2003-12-10
# This is free software under the GNU General Public License.

# May also be set in Makefile
tmpdir=${tmpdir:-/var/tmp}
arch=${architecture:-$(dpkg --print-architecture)}

# Print a usage message and exit if the argument count is wrong.
if [ $# != 4 ]; then
echo "Usage: $0 linux.bin sys_map.gz root-image tftpimage" 1>&2
	cat 1>&2 << EOF

	linux.bin: the Linux kernel (may be compressed).
	sys_map.gz: compressed System.map.
	root-image: a compressed disk image to load in ramdisk and mount as root.
	tftpimage: name of the image.
EOF

	exit -1
fi

# Set this to the location of the kernel
kernel=$1

# Set this to the name of the compressed System.map
sysmap=$2

# Set this to the location of the root filesystem image
rootimage=$3

# Set this to the name of the TFTP image
tftpimage=$4

# Make sure the files are available, $sysmap can be /dev/null
for file in "$kernel" "$rootimage"; do
	if [ ! -f $file ]; then
		echo "error: could not find $file"
		exit 1
	fi
done

case "$arch" in
    arm* | i386 | mips | mipsel)
	cp $kernel $tftpimage.tmp
	;;
    *)
	echo "uncompressing kernel"
	gzip -cd $kernel > $tftpimage.tmp
	;;
esac

echo "building tftp image in $tftpimage"
tmp=`mktemp -p ${tmpdir} tftpboot.sysmap.XXXXXXXX`
gzip -cdq $sysmap > $tmp || true

# append rootimage to the kernel
case "$arch" in
    sparc)
	elftoaout -o $tftpimage $tftpimage.tmp
	# Piggyback appends the ramdisk to the a.out image in-place
	piggyback64 $tftpimage $tmp $rootimage
	;;
    arm*)
	cat $rootimage >>$tftpimage.tmp
	mv $tftpimage.tmp $tftpimage
	;;
    mipsel) t-rex -k $tftpimage.tmp -r $rootimage -o $tftpimage ;;
    mips)
	case $tftpimage in
	    *ip32*) tip=tip32 ;;
	    *) tip=tip22 ;;
	esac
	$tip $tftpimage.tmp $rootimage $tftpimage
	;;
    *) mv $tftpimage.tmp $tftpimage ;;
esac

# cleanup
rm -f $tftpimage.tmp
rm -f $tmp

size=`ls -l $tftpimage | awk '{print $5}'` || true
rem=`expr \( 4 - $size % 4 \) % 4` || true

echo "padding $tftpimage by $rem bytes"
dd if=/dev/zero bs=1 count=$rem >> $tftpimage

echo "TFTP image is `ls -l $tftpimage` "

exit 0
