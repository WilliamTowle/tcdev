# cross-gcc 2.95.3-2		[ since v2.7.2.3, c.2002-10-14 ]
# last mod WmT, 21/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

CROSS_GCC_PKG:=gcc
CROSS_GCC_VER:=2.95.3
#CROSS_GCC_VER:=4.1.1

CROSS_GCC_SRC+=${SOURCEROOT}/g/gcc-${CROSS_GCC_VER}.tar.gz
CROSS_GCC_SRC+=${SOURCEROOT}/g/gcc-${CROSS_GCC_VER}-2.patch
#CROSS_GCC_SRC+=${SOURCEROOT}/g/gcc-core-${CROSS_GCC_VER}.tar.bz2
#CROSS_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/10_uclibc-conf.diff
#CROSS_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/20_uclibc-locale.diff
#CROSS_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/21_uclibc-locale-snprintf-c99-fix.diff
#CROSS_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/22_libstdc-index-macro.diff
#CROSS_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/30_fastmath-fxsave.diff

CROSS_GCC_PATH:=gcc-${CROSS_GCC_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/gcc-2.95.3.tar.gz
URLS+=http://www.linuxfromscratch.org/patches/downloads/gcc/gcc-2.95.3-2.patch


#DEPS:=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [xtc]
# +-----

ifeq (${TARGET_CPU},mipsel)
CROSS_GCC_ARCH_OPTS:=--with-arch=mips32
endif
ifeq (${TARGET_CPU},mips)
CROSS_GCC_ARCH_OPTS:=--with-arch=mips32
endif


## 1. Apply patches if required
## 2. Fix configure so copying the 'no' tree doesn't grab the source
## 3. --with-headers, --with-libs: specify dirs to copy FROM
${EXTTEMP}/${CROSS_GCC_PATH}-xtc/Makefile:
	[ ! -d ${EXTTEMP}/${CROSS_GCC_PATH} ] || rm -rf ${EXTTEMP}/${CROSS_GCC_PATH}
	${MAKE} extract LIST="$(strip ${CROSS_GCC_SRC})"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in gcc*patch ; do \
			cat $${PF} | ( cd ${CROSS_GCC_PATH} && patch -Np1 -i - ) ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	( cd ${EXTTEMP}/${CROSS_GCC_PATH} || exit 1 ;\
		[ -r configure.in.OLD ] || mv configure.in configure.in.OLD || exit 1 ;\
		cat configure.in.OLD \
			| sed '/ tar .* tar / s/; tar/ \&\& tar/g' \
			> configure.in || exit 1 \
	) || exit 1
	mkdir -p ${EXTTEMP}/${CROSS_GCC_PATH}-xtc
	( cd ${EXTTEMP}/${CROSS_GCC_PATH}-xtc || exit 1 ;\
		CC=${HTC_GCC} \
			../${CROSS_GCC_PATH}/configure -v \
			  --prefix=${XTC_ROOT}/usr \
			  --target=${TARGET_SPEC} \
			  ${CROSS_GCC_ARCH_OPTS} \
			  --enable-languages=c \
			  --disable-nls \
			  --enable-shared \
			  --with-headers=${XTC_ROOT}'/usr/'${TARGET_SPEC}'/usr/include' \
			  --with-libs=${XTC_ROOT}'/usr/'${TARGET_SPEC}'/usr/lib' \
			  || exit 1 \
	) || exit 1
#	#		  ac_cv_sizeof_long_long=8 \
#	#		  ac_cv_path_install=${FR_INSTALL} \ #	#		  --disable-long-long


# ,-----
# |	Build [xtc]
# +-----


${EXTTEMP}/${CROSS_GCC_PATH}-xtc/libiberty/libiberty.a: ${EXTTEMP}/${CROSS_GCC_PATH}-xtc/Makefile
	( cd ${EXTTEMP}/${CROSS_GCC_PATH}-xtc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [xtc]
# +-----

${XTC_ROOT}/usr/${TARGET_SPEC}/bin/gcc:
	${MAKE} ${EXTTEMP}/${CROSS_GCC_PATH}-xtc/libiberty/libiberty.a
	( cd ${EXTTEMP}/${CROSS_GCC_PATH}-xtc || exit 1 ;\
		make install || exit 1 ;\
		if [ -r ${HTC_ROOT}/usr/${TARGET_SPEC}/lib/crt1.o ] ; then \
			cat gcc/specs \
				| sed 's/ld-linux.so.2/ld-uClibc.so.0/' > `${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc -v 2>&1 | grep specs | sed 's/.* //'` || exit 1 ;\
		else \
			cat gcc/specs \
				| sed 's/ld-linux.so.2/ld-uClibc.so.0/ ; s/:g*crt1.o/:crt0.o/g' \
				> `${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc -v 2>&1 | grep specs | sed 's/.* //'` || exit 1 ;\
		fi || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade cross-gcc ${CROSS_GCC_VER}
endif

# ,-----
# |	Entry points [htc]
# +-----

.PHONY: xtc-cross-gcc
xtc-cross-gcc: ${XTC_ROOT}/usr/${TARGET_SPEC}/bin/gcc
