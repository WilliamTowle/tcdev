# uClibc-rt 0.9.29		[ since 0.9.20 ]
# last mod WmT, 2007-08-30	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

UCLIBC_RT_PKG:=uClibc
#UCLIBC_RT_VER:=0.9.20
#UCLIBC_RT_VER:=0.9.26
#UCLIBC_RT_VER:=0.9.28.3
UCLIBC_RT_VER:=0.9.29

UCLIBC_RT_SRC+=${SOURCEROOT}/u/uClibc-${UCLIBC_RT_VER}.tar.bz2
URLS+=http://www.uclibc.org/downloads/uClibc-${UCLIBC_RT_VER}.tar.bz2

ifeq (${UCLIBC_RT_VER},0.9.28)
UCLIBC_RT_SRC+=${SOURCEROOT}/u/uClibc-0.9.28-patches-1.5.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/uClibc-0.9.28-patches-1.5.tar.bz2
endif
ifeq (${UCLIBC_RT_VER},0.9.29)
UCLIBC_RT_SRC+=${TOPLEV}/gb-patches/v1.1-uClibc/10_mmap.diff
UCLIBC_RT_SRC+=${TOPLEV}/gb-patches/v1.1-uClibc/20_mount.diff
UCLIBC_RT_SRC+=${TOPLEV}/gb-patches/v1.1-uClibc/30_dlsym-verbose-dev.diff
UCLIBC_RT_SRC+=${TOPLEV}/gb-patches/v1.1-uClibc/50_config-no-timestamp.diff
endif

UCLIBC_RT_PATH:=uClibc-${UCLIBC_RT_VER}


# ,-----
# |	Configure [xdc]
# +-----

HAVE_OWN_AWK:=$(shell if [ -r ${HTC_ROOT}/usr/bin/awk ] ; then echo y ; else echo n ; fi)
ifeq (${HAVE_OWN_AWK},y)
AWK_EXE:=${HTC_ROOT}/usr/bin/awk
else
AWK_EXE:=awk
endif

ifeq (${ETCDIR},)
ETCDIR:=${XTC_ROOT}/etc
endif


${EXTTEMP}/${UCLIBC_RT_PATH}-rt/.config:
	[ ! -d ${EXTTEMP}/${UCLIBC_RT_PATH} ] || rm -rf ${EXTTEMP}/${UCLIBC_RT_PATH}
	${MAKE} extract LIST="$(strip ${UCLIBC_RT_SRC})"
	echo "*** PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in *diff ; do \
			patch --batch -d ${UCLIBC_RT_PATH} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	[ ! -d ${EXTTEMP}/${UCLIBC_RT_PATH}-rt ] || rm -rf ${EXTTEMP}/${UCLIBC_RT_PATH}-rt
	mv ${EXTTEMP}/${UCLIBC_RT_PATH} ${EXTTEMP}/${UCLIBC_RT_PATH}-rt
	( cd ${EXTTEMP}/${UCLIBC_RT_PATH}-rt || exit 1 ;\
		cp ${ETCDIR}/uClibc-${UCLIBC_RT_VER}-config .config || exit 1 ;\
		for MF in libc/sysdeps/linux/*/Makefile ; do \
			[ -r $${MF}.OLD ] || mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed 's/-g,,/-g , ,/' \
				> $${MF} || exit 1 ;\
		done ;\
		case ${UCLIBC_RT_VER} in \
		0.9.20) \
			[ -r ldso/util/Makefile.OLD ] || mv ldso/util/Makefile ldso/util/Makefile.OLD || exit 1 ;\
			cat ldso/util/Makefile.OLD \
				| sed 's%$$(HOSTCC)%'${HTC_GCC}'%' \
				> ldso/util/Makefile || exit 1 ;\
			[ -r ldso/util/bswap.h.OLD ] || mv ldso/util/bswap.h ldso/util/bswap.h.OLD || exit 1 ;\
			cat ldso/util/bswap.h.OLD \
				| sed 's%def __linux__%def __glibc_linux__ /* __linux__ */%' \
				| sed 's/<string.h>/"stdint.h"/' \
				> ldso/util/bswap.h || exit 1 \
		;; \
		0.9.26) \
			[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD || exit 1 ;\
			cat Rules.mak.OLD \
				| sed	' /^CROSS/	s%=.*%= '${XTC_ROOT}'/usr/bin/'$(shell echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/')'-% ; /(CROSS)/	s%$$(CROSS)%$$(shell if [ -n "$${CROSS}" ] ; then echo $${CROSS} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ; /USE_CACHE/ s/#// ; /usr.bin.*awk/ s%/usr/bin/awk%'${AWK_EXE}'% ' > Rules.mak || exit 1 \
		;; \
		0.9.2[89]*) ;; \
		*)	echo "$0: Configure 'Makefile's: Unexpected UCLIBC_RT_VER ${UCLIBC_RT_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	) || exit 1


# ,-----
# |	Build [xdc]
# +-----

# 1. Fix CROSS= in Rules.mak
# 2. Ensure '-g' CFLAGS fixes don't affect '-g' in CROSS=x-y-z-gnu
# 3. IGNORE bad 'gcc' for i386-uclibc-gcc (extra/gcc-uClibc/Makefile)
# 4. IGNORE bad 'gcc' for u386-uclibc-ld (Makefile?)
## 5. Fix bswap.h's need for glibc-devel byteswap.h (and stdint.h)
## 6. Fix elf.h stdint.h dependency

${EXTTEMP}/uClibc-rt-${UCLIBC_RT_VER}-xdc/lib/libc.a:
	${MAKE} ${EXTTEMP}/${UCLIBC_RT_PATH}-rt/.config
	[ ! -d ${EXTTEMP}/uClibc-rt-${UCLIBC_RT_VER}-xdc ] || rm -rf ${EXTTEMP}/uClibc-rt-${UCLIBC_RT_VER}-xdc
	mv ${EXTTEMP}/${UCLIBC_RT_PATH}-rt ${EXTTEMP}/uClibc-rt-${UCLIBC_RT_VER}-xdc
	( cd ${EXTTEMP}/uClibc-rt-${UCLIBC_RT_VER}-xdc || exit 1 ;\
		case ${UCLIBC_RT_VER} in \
		0.9.20) \
			${MAKE} || exit 1 ;\
			${MAKE} CROSS=${XTC_ROOT}/usr/bin/${TARGET_SPEC}- \
				HOSTCC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
				-C ldso/util ldconfig || exit 1 \
		;; \
		0.9.26) \
			${MAKE} || exit 1 \
		;; \
		0.9.2[89]*) \
			${MAKE} || exit 1 ;\
			${MAKE} CROSS=${XTC_ROOT}/usr/bin/${TARGET_SPEC}- utils || exit 1 \
		;; \
		*)	echo "$0: Build: Unexpected UCLIBC_RT_VER ${UCLIBC_RT_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	) || exit 1

# ,-----
# |	Install [xdc]
# +-----

${XDC_INSTTEMP}/lib/libc.so.0:
	${MAKE} ${EXTTEMP}/uClibc-rt-${UCLIBC_RT_VER}-xdc/lib/libc.a
	mkdir -p ${XDC_INSTTEMP}/sbin || exit 1
	( cd ${EXTTEMP}/uClibc-rt-${UCLIBC_RT_VER}-xdc || exit 1 ;\
		case ${UCLIBC_RT_VER} in \
		0.9.20) \
			${MAKE} PREFIX=${XDC_INSTTEMP} install_target || exit 1 ;\
			cp ldso/util/ldconfig ${XDC_INSTTEMP}/sbin || exit 1 \
		;; \
		0.9.26) \
			${MAKE} PREFIX=${XDC_INSTTEMP} install_runtime || exit 1 \
		;; \
		0.9.2[89]*) \
			make PREFIX=${XDC_INSTTEMP}/ RUNTIME_PREFIX='/' install_runtime || exit 1 ;\
			cp utils/ldconfig ${XDC_INSTTEMP}/sbin || exit 1 \
		;; \
		*) \
			echo "INSTALL: Unexpected UCLIBC_RT_VER ${UCLIBC_RT_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	) || exit 1

${TOPLEV}/uClibc-rt-${UCLIBC_RT_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/lib/libc.so.0
#	tar cvzf uClibc-rt-${UCLIBC_RT_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create uClibc-rt-${UCLIBC_RT_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}

# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-uClibc-rt
ifeq (${MAKE_CHROOT},y)
xdc-uClibc-rt: ${XDC_INSTTEMP}/lib/libc.so.0
else
xdc-uClibc-rt: ${TOPLEV}/uClibc-rt-${UCLIBC_RT_VER}.egp
endif
