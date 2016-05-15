#!/bin/sh

echo "Writing zImage to flash:" > /sysroot/var/log/upgrade.log
/fs/writeflash -z /sysroot/zImage > /sysroot/var/log/upgrade.log 2>&1
echo "Writing initrd to flash:" > /sysroot/var/log/upgrade.log
/fs/writeflash -r /sysroot/initrd.gz > /sysroot/var/log/upgrade.log 2>&1
