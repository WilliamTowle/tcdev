# uClibc-dev 0.9.20		[ since v0.9.9, 2002-10-26 ]
# last mod WmT, 2010-09-15	[ (c) and GPLv2 1999-2010 ]

# ,-----
# |	Settings
# +-----

UCLIBC_DEV_PKG:=uClibc
UCLIBC_DEV_VER:=0.9.20
#UCLIBC_DEV_VER:=0.9.26
#UCLIBC_DEV_VER:=0.9.28.3
#UCLIBC_DEV_VER:=0.9.29

UCLIBC_DEV_SRC+=${SOURCEROOT}/u/uClibc-${UCLIBC_DEV_VER}.tar.bz2
ifeq (${UCLIBC_DEV_VER},0.9.20)
URLS+=http://uclibc.org/downloads/old-releases/uClibc-0.9.20.tar.bz2
else
URLS+=http://www.uclibc.org/downloads/uClibc-${UCLIBC_DEV_VER}.tar.bz2
endif

ifeq (${UCLIBC_DEV_VER},0.9.28)
UCLIBC_DEV_SRC+=${SOURCEROOT}/u/uClibc-0.9.28-patches-1.5.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/uClibc-0.9.28-patches-1.5.tar.bz2
endif
ifeq (${UCLIBC_DEV_VER},0.9.29)
ifeq (${ETCDIR},${XTC_ROOT}/etc/geex)
UCLIBC_DEV_SRC+=${TOPLEV}/gb-patches/v1.1-uClibc/10_mmap.diff
UCLIBC_DEV_SRC+=${TOPLEV}/gb-patches/v1.1-uClibc/20_mount.diff
UCLIBC_DEV_SRC+=${TOPLEV}/gb-patches/v1.1-uClibc/30_dlsym-verbose-dev.diff
UCLIBC_DEV_SRC+=${TOPLEV}/gb-patches/v1.1-uClibc/50_config-no-timestamp.diff
endif
endif

UCLIBC_DEV_PATH:=uClibc-${UCLIBC_DEV_VER}
UCLIBC_DEV_INSTTEMP:=${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-insttemp
UCLIBC_DEV_EGPNAME:=uClibc-dev-${UCLIBC_DEV_VER}


# ,-----
# |	Configure [xdc]
# +-----

ifeq (${ETCDIR},)
ETCDIR:=${XTC_ROOT}/etc
endif

${EXTTEMP}/${UCLIBC_DEV_PATH}-dev/.config:
	[ ! -d ${EXTTEMP}/${UCLIBC_DEV_PATH} ] || rm -rf ${EXTTEMP}/${UCLIBC_DEV_PATH}
	${MAKE} extract LIST="$(strip ${UCLIBC_DEV_SRC})"
ifneq (${UCLIBC_DEV_VER},0.9.20)
	echo "*** PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in *diff ; do \
			patch --batch -d ${UCLIBC_DEV_PATH} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
endif
	[ ! -d ${EXTTEMP}/${UCLIBC_DEV_PATH}-dev ] || rm -rf ${EXTTEMP}/${UCLIBC_DEV_PATH}-dev
	mv ${EXTTEMP}/${UCLIBC_DEV_PATH} ${EXTTEMP}/${UCLIBC_DEV_PATH}-dev
	( cd ${EXTTEMP}/${UCLIBC_DEV_PATH}-dev || exit 1 ;\
		[ -s .config ] \
		|| ( \
		case ${UCLIBC_DEV_VER} in \
		0.9.20) \
			echo 'KERNEL_SOURCE="'${XTC_ROOT}'/usr/'${TARGET_SPEC}'/usr/src/linux/"' ;\
			echo 'SHARED_LIB_LOADER_PATH="/lib"' ;\
			echo 'MALLOC=y' \
		;; \
		0.9.26) \
			echo 'KERNEL_SOURCE="'${XTC_ROOT}'/usr/'${TARGET_SPEC}'/usr/src/linux/"' ;\
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
			echo 'RUNTIME_PREFIX="/"' ;\
			echo 'UCLIBC_HAS_SYS_SIGLIST=y' ;\
			echo 'MALLOC=y' ;\
			echo 'MALLOC_STANDARD=y' \
		;; \
		0.9.28*) \
			echo 'KERNEL_SOURCE="'${XTC_ROOT}'/usr/'${TARGET_SPEC}'/usr/src/linux/"' ;\
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
			echo 'RUNTIME_PREFIX="/"' ;\
			echo 'CROSS_COMPILER_PREFIX="'${XTC_ROOT}'/usr/bin/'`echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`'-"' ;\
			echo 'UCLIBC_HAS_SYS_SIGLIST=y' ;\
			echo '# UCLIBC_HAS_SHADOW is not set' ;\
			echo 'MALLOC=y' ;\
			echo 'MALLOC_STANDARD=y' \
		;; \
		0.9.29*) \
			echo 'KERNEL_HEADERS="'${XTC_ROOT}'/usr/'${TARGET_SPEC}'/usr/include/"' ;\
			echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
			echo 'RUNTIME_PREFIX="/"' ;\
			echo 'CROSS_COMPILER_PREFIX="'${XTC_ROOT}'/usr/bin/'`echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`'-"' ;\
			echo 'UCLIBC_HAS_SYS_SIGLIST=y' ;\
			echo '# UCLIBC_HAS_SHADOW is not set' ;\
			echo 'UCLIBC_HAS_GNU_GLOB=y' ;\
			echo '# UCLIBC_BUILD_RELRO is not set' ;\
			echo '# UCLIBC_BUILD_NOEXECSTACK is not set' ;\
			echo 'MALLOC_STANDARD=y' \
		;; \
		*) \
			echo "$0: do_configure: Unexpected UCLIBC_DEV_VER ${UCLIBC_DEV_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac ;\
		echo 'DEVEL_PREFIX="/usr/"' ;\
		case "${TARGET_CPU}" in \
		i386) \
		      echo 'TARGET_ARCH="'${TARGET_CPU}'"' \
		;; \
		mips*)	\
		      echo 'TARGET_ARCH="mips"' ;\
		      echo 'TARGET_mips=y' ;\
		      [ ${TARGET_CPU} = 'mips' ] && echo 'ARCH_SUPPORTS_BIG_ENDIAN=y' ;\
		      [ ${TARGET_CPU} = 'mips' ] && echo 'ARCH_BIG_ENDIAN=y' ;\
		      [ ${TARGET_CPU} = 'mipsel' ] && echo 'ARCH_LITTLE_ENDIAN=y' ;\
		      echo 'CONFIG_MIPS_ISA_MIPS32=y' \
		;; \
		*)	\
		      echo "Unexpected TARGET_CPU '${TARGET_CPU}'" 1>&2 ;\
		      exit 1 \
		;; \
		esac ;\
		echo '# ASSUME_DEVPTS is not set' ;\
		echo 'DO_C99_MATH=y' ;\
		[ -r /lib/ld-linux.so.1 ] && echo '# DOPIC is not set' ;\
		[ -r /lib/ld-linux.so.1 ] && echo '# HAVE_SHARED is not set' ;\
		echo '# UCLIBC_HAS_IPV6 is not set' ;\
		echo '# UCLIBC_HAS_LFS is not set' ;\
		echo 'UCLIBC_HAS_RPC=y' ;\
		echo 'UCLIBC_HAS_FULL_RPC=y' ;\
		echo '# UCLIBC_HAS_CTYPE_UNSAFE is not set' ;\
		[ ${UCLIBC_DEV_VER} != 0.9.20 ] && echo 'UCLIBC_HAS_CTYPE_CHECKED=y' ;\
		echo '# UNIX98PTY_ONLY is not set' \
		) > .config || exit 1 ;\
		for MF in libc/sysdeps/linux/*/Makefile ; do \
			[ -r $${MF}.OLD ] || mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed 's/-g,,/-g , ,/' \
				> $${MF} || exit 1 ;\
		done ;\
		case ${UCLIBC_DEV_VER} in \
		0.9.20) \
			[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD || exit 1 ;\
			cat Rules.mak.OLD \
				| sed	' /^CROSS/	s%=.*%= '${XTC_ROOT}'/usr/bin/'$(shell echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/')'-% ; /(CROSS)/	s%$$(CROSS)%$$(shell if [ -n "$${CROSS}" ] ; then echo $${CROSS} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ; /USE_CACHE/ s/#// ; /usr.bin.*awk/ s%/usr/bin/awk%'${AWK_EXE}'% ' > Rules.mak || exit 1 ;\
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
		*)	echo "$0: do_configure 'Makefile's: Unexpected UCLIBC_DEV_VER ${UCLIBC_DEV_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac ;\
		yes '' | make HOSTCC=${HTC_GCC} oldconfig \
			  || exit 1 ;\
		mkdir -p ${ETCDIR} ;\
		cp .config ${ETCDIR}/uClibc-${UCLIBC_DEV_VER}-config || exit 1 \
	) || exit 1


# ,-----
# |	Build [xtc, xdc]
# +-----

# 1.	make 'install_dev' to get standard .a/.o
# 2.	'install_runtime' with PREFIX= (as dynamic libs not on host)
# 3.	correct symlinks into ${UCLIBC_DEV_INSTTEMP}
#X		echo 'KERNEL_SOURCE="'${EXTTEMP}'/linux-'${KERN_VER}'"' ;
${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xtc/libc/libc.a:
	${MAKE} ${EXTTEMP}/${UCLIBC_DEV_PATH}-dev/.config
	[ ! -d ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xtc ] || rm -rf ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xtc
	mv ${EXTTEMP}/${UCLIBC_DEV_PATH}-dev ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xtc
	( cd ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xtc || exit 1 ;\
		${MAKE} || exit 1 \
	) || exit 1

## 1.	make 'install_dev' to get standard .a/.o
## 2.	'install_runtime' with PREFIX= (as dynamic libs not on host)
## 3.	correct symlinks into ${UCLIBC_DEV_INSTTEMP}
${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xdc/libc/libc.a:
	${MAKE} ${EXTTEMP}/${UCLIBC_DEV_PATH}-dev/.config
	[ ! -d ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xdc ] || rm -rf ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xdc
	mv ${EXTTEMP}/${UCLIBC_DEV_PATH}-dev ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xdc
	( cd ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xdc || exit 1 ;\
		case ${UCLIBC_DEV_VER} in \
		0.9.20) \
			${MAKE} || exit 1 ;\
			rm -f ldso/util/ldd ;\
			${MAKE} CROSS=${XTC_ROOT}/usr/bin/${TARGET_SPEC}- \
				HOSTCC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
				-C ldso/util ldd || exit 1 \
		;; \
		0.9.26) \
			${MAKE} || exit 1 \
		;; \
		0.9.2[89]*) \
			${MAKE} || exit 1 ;\
			${MAKE} CROSS=${XTC_ROOT}/usr/bin/${TARGET_SPEC}- utils || exit 1 \
		;; \
		*)	echo "$0: Build: Unexpected UCLIBC_DEV_VER ${UCLIBC_DEV_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	) || exit 1


# ,-----
# |	Install [xtc, xdc]
# +-----

${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ldd:
	${MAKE} ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xtc/libc/libc.a
	mkdir -p ${XTC_ROOT}'/usr/'${TARGET_SPEC}'/usr'
	( cd ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xtc || exit 1 ;\
		${MAKE} PREFIX=${XTC_ROOT}'/usr/'${TARGET_SPEC}'/' install_dev || exit 1 ;\
		${MAKE} PREFIX=${XTC_ROOT}'/usr/'${TARGET_SPEC}'/usr/' install_runtime || exit 1 ;\
		( cd ${XTC_ROOT}/usr/${TARGET_SPEC}/usr/lib || exit 1 ;\
			for F in *.so ; do [ -L $${F} ] && ln -sf $${F}.0 $${F} ; done \
		) || exit 1 ;\
		cp ldso/util/ldd ${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ldd || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade uClibc-dev ${UCLIBC_DEV_VER}
endif


# 1. symlinks need PREFIX and DEVEL_PREFIX set
# 2. relative_path.sh needs RUNTIME_PREFIX set to make sane links
${UCLIBC_DEV_INSTTEMP}/usr/lib/libc.a:
	${MAKE} ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xdc/libc/libc.a
	mkdir -p ${UCLIBC_DEV_INSTTEMP}/usr/bin
	( cd ${EXTTEMP}/uClibc-dev-${UCLIBC_DEV_VER}-xdc || exit 1 ;\
		case ${UCLIBC_DEV_VER} in \
		0.9.20) \
 			${MAKE} PREFIX=${UCLIBC_DEV_INSTTEMP}/ DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_dev || exit 1 ;\
			cp ldso/util/ldd ${UCLIBC_DEV_INSTTEMP}/usr/bin || exit 1 \
		;; \
		0.9.26) \
 			${MAKE} PREFIX=${UCLIBC_DEV_INSTTEMP}/ DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_dev || exit 1 \
		;; \
		0.9.2[89]*) \
 			${MAKE} PREFIX=${UCLIBC_DEV_INSTTEMP}/ DEVEL_PREFIX=/usr/ RUNTIME_PREFIX=/ install_dev || exit 1 ;\
			cp utils/ldd ${UCLIBC_DEV_INSTTEMP}/usr/bin || exit 1 \
		;; \
		*)	echo "$0: Install: Unexpected UCLIBC_DEV_VER ${UCLIBC_DEV_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	) || exit 1

${TOPLEV}/${UCLIBC_DEV_EGPNAME}.egp: ${UCLIBC_DEV_INSTTEMP}/usr/lib/libc.a
	${PCREATE_SCRIPT} create ${TOPLEV}/${UCLIBC_DEV_EGPNAME}.egp ${UCLIBC_DEV_INSTTEMP}

# uClibc-dev: 'egp' maintains the dates from the archive
${XDC_ROOT}/usr/lib/libc.a: ${TOPLEV}/${UCLIBC_DEV_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${UCLIBC_DEV_EGPNAME}.egp
	touch $@

REALCLEAN_TARGETS+= ${TOPLEV}/${UCLIBC_DEV_EGPNAME}.egp


# ,-----
# |	Entry points [xtc]
# +-----

.PHONY: xtc-uClibc-dev
xtc-uClibc-dev: ${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ldd

.PHONY: xdc-uClibc-dev
ifeq (${MAKE_CHROOT},y)
xdc-uClibc-dev: ${XDC_ROOT}/usr/lib/libc.a
else
xdc-uClibc-dev: ${TOPLEV}/${UCLIBC_DEV_EGPNAME}.egp
endif
