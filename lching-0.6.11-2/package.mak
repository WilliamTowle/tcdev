# last mod WmT, 2007-11-05	[ (c) and GPLv2 1999-2007 ]

# import package targets
include Config/busybox/v1.8.0.mak
include Config/bzip2/v1.0.4-eg0.9.3.mak
include Config/cross-binutils/v2.17-lch0.9.4-2.mak
include Config/cross-gcc/v4.1.2-lch0.9.4.mak
ifeq (${MF_HAVE_INITRD},y)
include Config/e2fsprogs/v1.40.2.mak
endif
include Config/findutils/v4.2.29-eg0.9.3.mak
include Config/gzip/v1.3.12.mak
include Config/host-binutils/v2.17-lch0.9.4-2.mak
include Config/host-gcc/v4.1.2-lch0.9.4.mak
include Config/kgcc/v4.1.2-lch0.9.4.mak
include Config/lxheaders/v2.6.20.1-lch0.9.3.mak
include Config/make/v3.81-eg0.9.3.mak
include Config/ncurses/v5.6-eg0.9.3.mak
include Config/patch/v2.5.4-eg0.9.3.mak
include Config/sed/v4.1.5-eg0.9.3.mak
include Config/tar/v1.13-eg0.9.3.mak
include Config/uClibc-dev/v0.9.28.3-lch0.9.4-2.mak
include Config/uClibc-rt/v0.9.28.3-lch0.9.4-2.mak

# select package targets - host toolchain
HTC_TARGETS+=htc-make
HTC_TARGETS+=htc-host-binutils
HTC_TARGETS+=htc-host-gcc

# select package targets - cross toolchain
XTC_TARGETS+=xtc-cross-binutils
XTC_TARGETS+=xtc-kgcc
XTC_TARGETS+=xtc-lxheaders
XTC_TARGETS+=xtc-uClibc-dev
XTC_TARGETS+=xtc-cross-gcc

# select package targets - cross-distro
XDC_TARGETS+=xdc-uClibc-rt
XDC_TARGETS+=xdc-busybox
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
