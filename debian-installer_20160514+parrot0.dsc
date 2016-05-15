Format: 1.0
Source: debian-installer
Binary: debian-installer
Architecture: any
Version: 20160514+parrot0
Maintainer: Lorenzo "Palinuro" Faletra <palinuro@parrotsec.org
Uploaders: Lorenzo "Palinuro" Faletra <palinuro@parrotsec.org>
Standards-Version: 3.9.8
Vcs-Browser: https://anonscm.debian.org/cgit/d-i/debian-installer.git
Vcs-Git: https://anonscm.debian.org/git/d-i/debian-installer.git
Build-Depends: debhelper (>= 7.0.0), apt (>= 0.8.16), apt-utils, gnupg, debian-archive-keyring (>= 2006.11.22), parrot-archive-keyring, dctrl-tools, wget, bc, debiandoc-sgml, xsltproc, docbook-xml, docbook-xsl, libbogl-dev, glibc-pic, libslang2-pic (>= 2.0.6-4), libnewt-pic (>= 0.52.2-11.3) [!mipsel], libnewt-dev (>= 0.52.2-11.3) [mipsel], libgcc1 [i386 amd64], genext2fs (>= 1.3-7.1), e2fsprogs, mklibs (>= 0.1.40), mklibs-copy (>= 0.1.40), genisoimage [!s390 !s390x], genromfs [sparc sparc64], hfsutils [powerpc], dosfstools [i386 m68k amd64 armhf arm64], cpio, xz-utils, devio [armeb armel], slugimage (>= 0.10+r58-6) [armeb armel], dns323-firmware-tools (>= 0.7.3-1) [armel], u-boot-tools [armel armhf], syslinux [i386 amd64], syslinux-utils [i386 amd64], isolinux [i386 amd64], pxelinux [i386 amd64], syslinux-common (>= 3:6) [i386 amd64], yaboot [powerpc], aboot (>= 0.9b-2) [alpha], silo [sparc sparc64], sparc-utils [sparc sparc64], atari-bootstrap [m68k], vmelilo [m68k], m68k-vme-tftplilo [m68k], amiboot [m68k], emile [m68k], emile-bootblocks [m68k], apex-nslu2 [armeb armel], grub-efi-amd64-bin [amd64], grub-efi-arm64-bin [arm64], grub-efi-ia32-bin [i386], grub-common [amd64 arm64 i386], xorriso, grub-ieee1275-bin [ppc64el], u-boot-imx [armhf], u-boot-omap [armhf], u-boot-sunxi [armhf], u-boot-rockchip [armhf], u-boot (>= 2016.01+dfsg1-1) [armel], tofrodos [i386 amd64 kfreebsd-i386 kfreebsd-amd64], mtools [i386 m68k amd64 armhf arm64 kfreebsd-i386 kfreebsd-amd64 hurd-i386], kmod [linux-any], bf-utf-source [!s390 !s390x], mkvmlinuz [powerpc], openssl, win32-loader (>= 0.7.2) [i386 amd64 kfreebsd-i386 kfreebsd-amd64 hurd-i386], makefs (>= 20100306-5+kbsd8u1~) [kfreebsd-any], grub-pc (>= 2.02~beta2~) [kfreebsd-i386 kfreebsd-amd64 hurd-i386], xorriso (>= 1.3.2-1~) [kfreebsd-i386 kfreebsd-amd64 hurd-i386], debian-ports-archive-keyring [sh4 sparc64], librsvg2-bin [any-amd64 any-i386]
Build-Conflicts: libnewt-pic [mipsel]
Package-List:
 debian-installer deb devel optional arch=any
Checksums-Sha1:
 6a0deb24be64b9131a99e5b5a2c3ad082b6011b5 1453279 debian-installer_20160514+parrot0.tar.gz
Checksums-Sha256:
 12ec5f8807ffb57b982e4c19de360737c7dfdec9fa664bd2a37d8127a9155e0a 1453279 debian-installer_20160514+parrot0.tar.gz
Files:
 33f0f6e206b206e1d0cc61b4898ccb82 1453279 debian-installer_20160514+parrot0.tar.gz
