#!/bin/sh

#/usr2/local/qemu-080310/usr/bin/qemu -kernel toolchain/etc/geex/vmlinuz-2.6.20.1 -append root=/dev/hda -hda iramdisk
/usr2/local/qemu-080310/usr/bin/qemu-system-mips -kernel \
toolchain/etc/maofeng/vmlinux-2.6.20.1 \
-append root=/dev/hda -hda iramdisk
