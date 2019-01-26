# last mod WmT, 2007-08-22	[ (c) and GPLv2 1999-2007 ]

HAVE_OPT_FREGLX:=$(shell if [ -d /opt/freglx ] ; then echo y ; else echo n ; fi)

EXTTEMP:=${TOPLEV}/exttemp
#EXTTEMP:=/home/build-temp
INSTTEMP:=${TOPLEV}/insttemp
ifeq (${HAVE_OPT_FREGLX},y)
SOURCEROOT:=/opt/freglx/etc/sources
else
SOURCEROOT:=${TOPLEV}/../../source/
endif
HTC_ROOT:=${TOPLEV}/toolchain
HTC_TARGETS:=
XTC_ROOT:=${TOPLEV}/toolchain
XTC_TARGETS:=
XDC_ROOT:=${TOPLEV}/roottemp
XDC_TARGETS:=
ETCDIR:=${XTC_ROOT}/etc/sencha
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

# <-- target configuration
TARGET_TRIPLET:=${TARGET_CPU}-senban-linux
TARGET_SPEC:=${TARGET_TRIPLET}-${TARGET_SUFFIX}

# <-- chroot vs packages (xdc)
ifeq (${MAKE_CHROOT},y)
XDC_INSTTEMP:=${XDC_ROOT}
else
XDC_INSTTEMP:=${INSTTEMP}
endif

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

HAVE_OWN_BASH:=$(shell if [ -x ${HTC_ROOT}/bin/bash ] ; then echo y ; else echo n ; fi)
ifeq (${HAVE_OWN_BASH},y)
CONFIG_SHELL:=${HTC_ROOT}/bin/bash
else
CONFIG_SHELL:=/bin/bash
endif
 
# sanity checks
.PHONY: htc-sanity
htc-sanity:

ifeq (${HAVE_PTRACKING},y)
htc-sanity: ptracking-init
endif
ifeq (${HTC_GCC},)
htc-sanity: htc-sanity-nogcc
htc-sanity-nogcc:
	@echo "HTC_GCC unset" ; exit 1
else
# (LChing) makes the compiler build first, which requires 'awk' :(
htc-sanity:
#htc-sanity: htc-sanity-gcc
#htc-sanity-gcc: ${HTC_GCC}
endif

.PHONY: xtc-sanity
xtc-sanity:
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
ifeq (${MAKE_CHROOT},)
xdc-sanity-chroot:
	@echo "MAKE_CHROOT unset (use y/n)" ; exit 1
xdc-sanity: xdc-sanity-chroot
else
PCREATE_SCRIPT:=${TOPLEV}/scripts/egp
# combined test based on fact MAKE_CHROOT non-empty string
ifeq (${MAKE_CHROOT}${XDC_ROOT},y)
xdc-sanity-chroot:
	@echo "XDC_ROOT unset, and MAKE_CHROOT=y" ; exit 1
xdc-sanity: xdc-sanity-chroot
else
xdc-sanity-insttemp:
ifeq (${INSTTEMP},)
	@echo "INSTTEMP unset, and MAKE_CHROOT=n (!= y)" ; exit 1
endif
xdc-sanity: xdc-sanity-insttemp
endif
endif
