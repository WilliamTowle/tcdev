# chroot.mak 20090126		[ since 2009-01-26 ]
# last mod WmT, 2009-01-26	[ STUBS/tcdev (c) and GPLv2 1999-2009 ]

USAGE_RULES+= "chroot (install to chroot from [some] packages)"

##

CHROOT_EGP_TARGETS:=
CHROOT_EGP_TARGETS+= ${TOPLEV}/${BUSYBOX_PKG}-${BUSYBOX_VER}.egp
CHROOT_EGP_TARGETS+= ${TOPLEV}/uClibc-rt-${UCLIBC_RT_VER}.egp

##

.PHONY: chroot-sanity
chroot-sanity: 
ifneq (${MF_HAVE_PACKAGES},y)
	echo 'chroot-sanity: Missing dependency: ${MF_HAVE_PACKAGES}=y' 1>&2
	exit 1 
endif

.PHONY: chroot
chroot: chroot-sanity xtc ${CHROOT_EGP_TARGETS}
	mkdir ${XDC_ROOT}
	./scripts/egp install ${XDC_ROOT} ${CHROOT_EGP_TARGETS}

CLEAN_TARGETS+=
REALCLEAN_TARGETS+= ${CHROOT_EGP_TARGETS}
