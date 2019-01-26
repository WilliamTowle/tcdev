# last mod WmT, 2010-09-16	[ (c) and GPLv2 1999-2010 ]

# linux 2.0.x needs gcc 2.7.2.3
# gcc 2.7.2.3 needs vfork() in uClibc
# ...this rules out uClibc 0.9.20

# TODO: newer kernel (or alternative uClibc?)

# import package targets
include Config/bash/v3.2pl5-eg0.9.3.mak
include Config/bin86/v0.16.17-eg0.9.2.mak
include Config/bison/v1.875-eg0.9.6-2.mak
include Config/busybox/v0.60.5-eg0.9.5-3.mak
include Config/bzip2/v1.0.5-eg0.9.6.mak
include Config/coreutils/v5.97-eg0.9.6-2.mak
include Config/cross-binutils/v2.16.1-eg0.9.5-2.mak
include Config/cross-gcc/v2.95.3-2-eg0.9.5-2.mak
include Config/diffutils/v2.8.7-eg0.9.6-2.mak
ifeq (${MF_HAVE_ISOFS},y)
include Config/dvdrtools/v0.2.1.mak
endif
ifeq (${MF_HAVE_INITRD},y)
ifeq (${MF_HAVE_GENEXT2FS},n)
include Config/e2fsprogs/v1.40.11.mak
else
include Config/genext2fs/v1.4.1.mak
endif
endif
include Config/findutils/v4.2.33-eg0.9.6.mak
include Config/flex/v2.5.27-eg0.9.6-2.mak
include Config/grep/v2.5.1a-eg0.9.6.mak
include Config/gzip/v1.3.12-eg0.9.6.mak
include Config/host-binutils/v2.16.1-eg0.9.6.mak
include Config/host-gcc/v2.95.3-2-eg0.9.5-5.mak
include Config/kgcc/v2.95.3-2-eg0.9.5-2.mak
include Config/kgcc/v2.7.2.3-eg0.9.2.mak
include Config/lxheaders/v2.0.40-eg0.9.5-3.mak
include Config/lxsource/v2.0.40-eg0.9.2.mak
include Config/m4/v1.4.12-eg0.9.5-2.mak
include Config/make/v3.81-eg0.9.6-2.mak
include Config/mawk/v1.3.3-20090820.mak
ifeq (${MF_HAVE_ISOFS},y)
include Config/nasm/v2.07.mak
endif
include Config/ncurses/v5.6-eg0.9.6.mak
include Config/patch/v2.5.9-eg0.9.6.mak
include Config/sed/v4.1.5-eg0.9.6.mak
ifeq (${MF_HAVE_ISOFS},y)
include Config/syslinux/v3.84.mak
endif
include Config/tar/v1.13-eg0.9.6.mak
include Config/uClibc-dev/v0.9.20-eg0.9.6.mak
include Config/uClibc-rt/v0.9.20-eg0.9.5-3.mak
include Config/util-linux/v2.12r-eg0.9.5-3.mak

# select package targets - host toolchain
ifeq (${HAVE_LIMITED_HOST},y)
HTC_TARGETS+=htc-sed
HTC_TARGETS+=htc-diffutils
HTC_TARGETS+=htc-grep
HTC_TARGETS+=htc-coreutils
HTC_TARGETS+=htc-patch
HTC_TARGETS+=htc-flex
HTC_TARGETS+=htc-mawk
HTC_TARGETS+=htc-m4
HTC_TARGETS+=htc-bison
HTC_TARGETS+=htc-bash
HTC_TARGETS+=htc-findutils
endif
HTC_TARGETS+=htc-make
HTC_TARGETS+=htc-host-binutils
HTC_TARGETS+=htc-host-gcc
HTC_TARGETS+=htc-bin86
ifeq (${MF_HAVE_INITRD},y)
ifeq (${MF_HAVE_GENEXT2FS},y)
HTC_TARGETS+=htc-genext2fs
else
HTC_TARGETS+=htc-e2fsprogs
endif
endif
ifeq (${MF_HAVE_ISOFS},y)
HTC_TARGETS+= htc-dvdrtools
HTC_TARGETS+= htc-nasm
HTC_TARGETS+= htc-syslinux
endif

## select package targets - cross toolchain
XTC_TARGETS+=xtc-cross-binutils
XTC_TARGETS+=xtc-kgcc
XTC_TARGETS+=xtc-kgcc2723
XTC_TARGETS+=xtc-lxheaders
XTC_TARGETS+=xtc-lxsource
XTC_TARGETS+=xtc-uClibc-dev
XTC_TARGETS+=xtc-cross-gcc

## select package targets - cross-distro
XDC_TARGETS+=xdc-uClibc-rt
XDC_TARGETS+=xdc-busybox
XDC_TARGETS+=xdc-diffutils
XDC_TARGETS+=xdc-bzip2
XDC_TARGETS+=xdc-gzip
XDC_TARGETS+=xdc-sed
XDC_TARGETS+=xdc-tar
#
XDC_TARGETS+=xdc-make
XDC_TARGETS+=xdc-uClibc-dev
XDC_TARGETS+=xdc-lxheaders
XDC_TARGETS+=xdc-host-binutils
XDC_TARGETS+=xdc-host-gcc
XDC_TARGETS+=xdc-findutils
XDC_TARGETS+=xdc-ncurses
XDC_TARGETS+=xdc-patch
XDC_TARGETS+=xdc-util-linux
