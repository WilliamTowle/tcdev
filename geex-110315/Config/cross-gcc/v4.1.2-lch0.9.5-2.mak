# cross-gcc 4.1.2		[ since v2.7.2.3, c.2002-10-14 ]
# last mod WmT, 2007-08-06	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

CROSS_GCC_PKG:=gcc
CROSS_GCC_VER:=4.1.2
#CROSS_GCC_VER:=4.2.0
CROSS_GCC_PATH:=gcc-${CROSS_GCC_VER}

CROSS_GCC_SRC:=

#CROSS_GCC_SRC+=${SOURCEROOT}/g/gcc-${CROSS_GCC_VER}.tar.bz2
CROSS_GCC_SRC+=${SOURCEROOT}/g/gcc-core-${CROSS_GCC_VER}.tar.bz2
URLS+= http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/gcc-${CROSS_GCC_VER}/gcc-core-${CROSS_GCC_VER}.tar.bz2

ifeq (${CROSS_GCC_VER},4.1.1)
CROSS_GCC_SRC+=${SOURCEROOT}/g/gcc-4.1.1-uclibc-patches-1.1.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.1.1-uclibc-patches-1.1.tar.bz2
endif
ifeq (${CROSS_GCC_VER},4.1.2)
CROSS_GCC_SRC+=${SOURCEROOT}/g/gcc-4.1.2-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.1.2-uclibc-patches-1.0.tar.bz2
endif
ifeq (${CROSS_GCC_VER},4.2.0)
CROSS_GCC_SRC+=${SOURCEROOT}/g/gcc-4.2.0-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.2.0-uclibc-patches-1.0.tar.bz2
endif

#DEPS:=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [xtc]
# +-----

#ifeq (${TARGET_CPU},mipsel)
#CROSS_GCC_ARCH_OPTS:=--with-arch=mips32
#endif
#ifeq (${TARGET_CPU},mips)
#CROSS_GCC_ARCH_OPTS:=--with-arch=mips32
#endif


${EXTTEMP}/${CROSS_GCC_PATH}-xtc/Makefile:
	[ ! -d ${EXTTEMP}/${CROSS_GCC_PATH} ] || rm -rf ${EXTTEMP}/${CROSS_GCC_PATH}
	${MAKE} extract LIST="$(strip ${CROSS_GCC_SRC})"
	echo "*** PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc/*patch ; do \
			patch --batch -d ${CROSS_GCC_PATH} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	[ ! -d ${EXTTEMP}/${CROSS_GCC_PATH}-xtc ] || rm -rf ${EXTTEMP}/${CROSS_GCC_PATH}-xtc
	mv ${EXTTEMP}/${CROSS_GCC_PATH} ${EXTTEMP}/${CROSS_GCC_PATH}-xtc
	( cd ${EXTTEMP}/${CROSS_GCC_PATH}-xtc || exit 1 ;\
		CC=${HTC_GCC} \
			./configure -v \
			  --prefix=${XTC_ROOT}/usr \
			  --host=${NATIVE_SPEC} \
			  --build=${NATIVE_SPEC} \
			  --target=${TARGET_SPEC} \
			  ${CROSS_GCC_ARCH_OPTS} \
			  --with-sysroot=${XTC_ROOT}/usr/${TARGET_SPEC} \
			  --with-local-prefix=${XTC_ROOT}/usr \
			  --enable-languages=c \
			  --enable-clocale=uclibc \
			  --disable-__cxa_atexit \
			  --disable-nls \
			  --disable-libmudflap \
			  --disable-libssp \
			  --enable-shared \
			  || exit 1 \
	) || exit 1

# ,-----
# |	Build [xtc]
# +-----

${EXTTEMP}/${CROSS_GCC_PATH}-xtc/host-${NATIVE_SPEC}/libiberty/libiberty.a: ${EXTTEMP}/${CROSS_GCC_PATH}-xtc/Makefile
	( cd ${EXTTEMP}/${CROSS_GCC_PATH}-xtc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [xtc]
# +-----

${XTC_ROOT}/usr/${TARGET_SPEC}/bin/gcc:
	${MAKE} ${EXTTEMP}/${CROSS_GCC_PATH}-xtc/host-${NATIVE_SPEC}/libiberty/libiberty.a
	( cd ${EXTTEMP}/${CROSS_GCC_PATH}-xtc || exit 1 ;\
		make install || exit 1 ;\
		cat host-${NATIVE_SPEC}/gcc/specs \
			| sed 's/ld-linux.so.2/ld-uClibc.so.0/' > `${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc -v 2>&1 | grep specs | sed 's/.* //'` \
			|| exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade cross-gcc ${CROSS_GCC_VER}
endif

# ,-----
# |	Entry points [xtc]
# +-----

.PHONY: xtc-cross-gcc
xtc-cross-gcc: xtc-cross-binutils ${XTC_ROOT}/usr/${TARGET_SPEC}/bin/gcc
