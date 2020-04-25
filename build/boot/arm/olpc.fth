\ OLPC XO boot script

: check-ofw-version ( -- )
   " /" find-device
   " compatible" get-property  abort" No compatible property on /" ( -- compatible$ )
   " mrvl,mmp2" 2swap substring? not  if
     cr
     ." Firmware Q4E00 or newer is needed to boot a Devicetree enabled kernel." cr
     cr
     ." One way to update is to copy http://dev.laptop.org/~quozl/q4e00ja.rom" cr
     ." to a FAT partition on a USB flash stick and run ""flash u:\q4e00ja.rom""" cr
     cr
     ." Aborting boot." cr
     show-sad
     abort
   then
   \ Make sure the model is sensible -- flash-kernel relies on this.
   " model" delete-property
   " OLPC XO-1.75" " model" string-property
;

visible unfreeze
check-ofw-version
" last:2,\vmlinuz" to boot-device
" last:2,\initrd.gz" to ramdisk
boot
