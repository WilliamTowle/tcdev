# last mod WmT, 2008-12-03	[ (c) and GPLv2 1999-2008 ]

NATIVE_CPU:=$(shell uname -m)
TARGET_SUFFIX:=gnu
#!! not sen/ban!! TARGET_SUFFIX:=uclibc

HAVE_GLIBC_SYSTEM:=$(shell if [ -r /lib/libc.so.6 ] ; then echo y ; else echo n ; fi)
HAVE_GLIBC5_SYSTEM:=$(shell if [ -r /lib/ld-linux.so.1 ] ; then echo y ; else echo n ; fi)

# excessively old or minimal/embedded environment?
HAVE_LIMITED_HOST:=$(shell if [ -r /bin/busybox ] ; then echo y ; else echo n ; fi)

HAVE_OPT_FREGLX:=$(shell if [ -d /opt/freglx ] ; then echo y ; else echo n ; fi)

EXTTEMP:=${TOPLEV}/exttemp
#EXTTEMP:=/home/build-temp
ifeq (${HAVE_OPT_FREGLX},y)
SOURCEROOT:=/opt/freglx/etc/sources
else
SOURCEROOT:=$(shell if [ -d ${TOPLEV}/../../source/ ] ; then echo ${TOPLEV}/../../source/ ; else echo ${TOPLEV}/../../sources-current/ ; fi)
endif
HTC_ROOT:=${TOPLEV}/toolchain
HTC_TARGETS:=
XTC_ROOT:=${TOPLEV}/toolchain
XTC_TARGETS:=
XDC_ROOT:=${TOPLEV}/roottemp
XDC_TARGETS:=
ETCDIR:=${XTC_ROOT}/etc/earlgr
ifeq (${TARGET_PLATFORM},)
TARGET_CPU:=i386
#TARGET_CPU:=mips
#TARGET_CPU:=mipsel
TARGET_PLATFORM:=real
endif
URLS:=

# native configuration
NATIVE_TRIPLET:=${NATIVE_CPU}-host-linux
#ifeq (${HAVE_GLIBC_SYSTEM}${HAVE_GLIBC5_SYSTEM},nn)
#NATIVE_SPEC:=${NATIVE_TRIPLET}-uclibc
#else
ifeq (${HAVE_GLIBC5_SYSTEM},y)
NATIVE_SPEC:=${NATIVE_TRIPLET}-gnulibc1
else
NATIVE_SPEC:=${NATIVE_TRIPLET}-gnu
endif
#endif
#(FUTURE) NATIVE_LIBCDIR:=${HTC_ROOT}/usr/${NATIVE_SPEC}

# <-- target configuration
TARGET_TRIPLET:=${TARGET_CPU}-earlgrey-linux
TARGET_SPEC:=${TARGET_TRIPLET}-${TARGET_SUFFIX}

# <-- package generation (intermediate stage to chroot install)
PCREATE_SCRIPT:=${TOPLEV}/scripts/egp

# <-- package tracking (toolchain)
PTRACK_SCRIPT:=${TOPLEV}/scripts/instmgr.sh
ifeq ($(shell [ -r ${PTRACK_SCRIPT} ] && echo y),y)
HAVE_PTRACKING:=y
else
HAVE_PTRACKING:=n
endif

ifeq (${HAVE_PTRACKING},y)
${HTC_ROOT}/opt/freglx/etc/pkgver.dat:
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} init

.PHONY: ptracking-init
ptracking-init: ${HTC_ROOT}/opt/freglx/etc/pkgver.dat
endif

# <-- compilers
NATIVE_GCC:=/usr/bin/gcc
HTC_GCC:=${HTC_ROOT}/usr/bin/${NATIVE_SPEC}-gcc

# <-- path
ifeq (${HTC_ROOT},${XTC_ROOT})
PATH:=${HTC_ROOT}/bin:${HTC_ROOT}/usr/bin:${PATH}
else
PATH:=${HTC_ROOT}/bin:${HTC_ROOT}/usr/bin:${XTC_ROOT}/usr/bin:${PATH}
endif


HAVE_OWN_AWK=$(shell if [ -r ${HTC_ROOT}/usr/bin/awk ] ; then echo y ; else echo n ; fi)
ifeq (${HAVE_OWN_AWK},y)
AWK_EXE:=${HTC_ROOT}/usr/bin/awk
else
AWK_EXE:=awk
endif

HAVE_OWN_BASH=$(shell if [ -x ${HTC_ROOT}/bin/bash ] ; then echo y ; else echo n ; fi)
ifeq (${HAVE_OWN_BASH},y)
CONFIG_SHELL:=${HTC_ROOT}/bin/bash
else
CONFIG_SHELL:=/bin/bash
endif
 
# sanity checks

.PHONY: sourceroot-sanity
sourceroot-sanity:
	@[ -d ${SOURCEROOT} ] || ( echo "SOURCEROOT ${SOURCEROOT} does not exist" 1>&2 ; false )

.PHONY: htc-sanity
htc-sanity: sourceroot-sanity
ifeq (${HAVE_PTRACKING},y)
htc-sanity: ptracking-init
endif
ifeq (${HTC_GCC},)
htc-sanity: htc-sanity-nogcc
htc-sanity-nogcc:
	@echo "HTC_GCC unset" ; exit 1
endif

.PHONY: xtc-sanity
xtc-sanity: sourceroot-sanity
ifeq (${HAVE_PTRACKING},y)
xtc-sanity: ptracking-init
endif
ifeq (${TARGET_CPU},)
xtc-sanity: xtc-sanity-nocpu
xtc-sanity-nocpu:
	@echo "TARGET_CPU (i386, mips, ...) unset" ; exit 1
endif
ifeq (${TARGET_PLATFORM},)
xtc-sanity: xtc-sanity-noplatform
xtc-sanity-noplatform:
	@echo "TARGET_PLATFORM (qemu, real, ...) unset" ; exit 1
endif

.PHONY: xdc-sanity
xdc-sanity: sourceroot-sanity
ifeq (${MAKE_CHROOT},)
xdc-sanity-chroot:
	@echo "MAKE_CHROOT unset (use y/n)" ; exit 1
xdc-sanity: xdc-sanity-chroot
else
# combined test based on fact MAKE_CHROOT non-empty string
ifeq (${MAKE_CHROOT}-${XDC_ROOT},y-)
xdc-sanity-chroot:
	@echo "XDC_ROOT unset, and MAKE_CHROOT=y" ; exit 1
xdc-sanity: xdc-sanity-chroot
endif

${XDC_ROOT}:
	mkdir -p ${XDC_ROOT}
endif
