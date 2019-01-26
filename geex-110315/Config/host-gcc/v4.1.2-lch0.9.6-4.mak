# gcc 4.1.2 			[ since v2.7.2.3, c. 2003-10-31 ]
# last mod WmT, 2011-01-19	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

HOST_GCC_PKG:=gcc
HOST_GCC_VER:=4.1.2
#HOST_GCC_VER:=4.2.0

HOST_GCC_PATH:=gcc-${HOST_GCC_VER}
HOST_GCC_INSTTEMP:=${EXTTEMP}/${HOST_GCC_PATH}-insttemp
HOST_GCC_EGPNAME:=gcc-${HOST_GCC_VER}

HOST_GCC_SRC:=

#HOST_GCC_SRC+=${SOURCEROOT}/g/gcc-${HOST_GCC_VER}.tar.bz2
HOST_GCC_SRC+=${SOURCEROOT}/g/gcc-core-${HOST_GCC_VER}.tar.bz2
URLS+= http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/gcc-${HOST_GCC_VER}/gcc-core-${HOST_GCC_VER}.tar.bz2

ifeq (${HOST_GCC_VER},4.1.1)
HOST_GCC_SRC+=${SOURCEROOT}/g/gcc-4.1.1-uclibc-patches-1.1.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.1.1-uclibc-patches-1.1.tar.bz2
endif
ifeq (${HOST_GCC_VER},4.1.2)
HOST_GCC_SRC+=${SOURCEROOT}/g/gcc-4.1.2-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.1.2-uclibc-patches-1.0.tar.bz2
endif
ifeq (${HOST_GCC_VER},4.2.0)
HOST_GCC_SRC+=${SOURCEROOT}/g/gcc-4.2.0-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.2.0-uclibc-patches-1.0.tar.bz2
endif

#DEPS:=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [htc, xdc]
# +-----

# arch opts for cross-native compiler
ifeq (${TARGET_CPU},mipsel)
HOST_GCC_XNAT_ARCH_OPTS:=--with-arch=mips32
endif
ifeq (${TARGET_CPU},mips)
HOST_GCC_XNAT_ARCH_OPTS:=--with-arch=mips32
endif


${EXTTEMP}/${HOST_GCC_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${HOST_GCC_PATH} ] || rm -rf ${EXTTEMP}/${HOST_GCC_PATH}
	${MAKE} extract LIST="$(strip ${HOST_GCC_SRC})"
	echo "*** PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc/*patch ; do \
			patch --batch -d ${HOST_GCC_PATH} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	[ ! -d ${EXTTEMP}/${HOST_GCC_PATH}-htc ] || rm -rf ${EXTTEMP}/${HOST_GCC_PATH}-htc
	mv ${EXTTEMP}/${HOST_GCC_PATH} ${EXTTEMP}/${HOST_GCC_PATH}-htc
ifeq (${HAVE_GLIBC_SYSTEM},y)
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-htc || exit 1 ;\
		CC=${NATIVE_GCC} \
			./configure -v \
			  --prefix=${HTC_ROOT}/usr \
			  --host=${NATIVE_SPEC} \
			  --target=${NATIVE_SPEC} \
			  --with-sysroot=/ \
			  --with-local-prefix=${HTC_ROOT}/usr \
			  --enable-languages=c \
			  --disable-nls \
			  --disable-libmudflap \
			  --disable-libssp \
			  --enable-shared \
			  || exit 1 \
	) || exit 1
else
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-htc || exit 1 ;\
		CC=${NATIVE_GCC} \
			./configure -v \
			  --prefix=${HTC_ROOT}/usr \
			  --host=`echo ${NATIVE_SPEC} | sed 's/gnu$$/uclibc/'` \
			  --target=`echo ${NATIVE_SPEC} | sed 's/gnu$$/uclibc/'` \
			  ${HOST_GCC_XNAT_ARCH_OPTS} \
			  --enable-clocale=uclibc \
			  --with-sysroot=/ \
			  --with-local-prefix=${HTC_ROOT}/usr \
			  --enable-languages=c \
			  --disable-nls \
			  --disable-libmudflap \
			  --disable-libssp \
			  --enable-shared \
			  || exit 1 \
	) || exit 1
endif

# --with-headers and --with-libs specify dirs to copy FROM
${EXTTEMP}/${HOST_GCC_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${HOST_GCC_PATH} ] || rm -rf ${EXTTEMP}/${HOST_GCC_PATH}
	${MAKE} extract LIST="$(strip ${HOST_GCC_SRC})"
	echo "*** PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc/*patch ; do \
			patch --batch -d ${HOST_GCC_PATH} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	[ ! -d ${EXTTEMP}/${HOST_GCC_PATH}-xdc ] || rm -rf ${EXTTEMP}/${HOST_GCC_PATH}-xdc
	mv ${EXTTEMP}/${HOST_GCC_PATH} ${EXTTEMP}/${HOST_GCC_PATH}-xdc
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
		  CC_FOR_BUILD=${HTC_GCC} \
		  HOSTCC=${HTC_GCC} \
		  GCC_FOR_TARGET=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
	  	  AR=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ar \
	  	  AS=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-as \
	  	  LD=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ld \
	  	  NM=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-nm \
	  	  RANLIB=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ranlib \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HOST_GCC_INSTTEMP}/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${TARGET_SPEC} \
			  --target=${TARGET_SPEC} \
			  ${HOST_GCC_ARCH_OPTS} \
			  --enable-clocale=uclibc \
			  --program-prefix='' \
			  --with-sysroot=/ \
			  --with-local-prefix=${XTC_ROOT}/usr \
			  --enable-languages=c \
			  --disable-__cxa_atexit \
			  --disable-nls \
			  --disable-libmudflap \
			  --disable-libssp \
			  --enable-shared \
			  --with-gnu-as \
			  --with-gnu-ld \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [htc, xdc]
# +-----

${EXTTEMP}/${HOST_GCC_PATH}-htc/host-${NATIVE_SPEC}/libiberty/libiberty.a: ${EXTTEMP}/${HOST_GCC_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1

${EXTTEMP}/${HOST_GCC_PATH}-xdc/build-${TARGET_SPEC}/libiberty/libiberty.a: ${EXTTEMP}/${HOST_GCC_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-xdc || exit 1 ;\
		make all-gcc prefix=/usr || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

#	${HTC_ROOT}/bin/${TARGET_SPEC}-gcc -dM -E - < /dev/null
${HTC_ROOT}/usr/bin/${NATIVE_SPEC}-gcc:
	${MAKE} ${EXTTEMP}/${HOST_GCC_PATH}-htc/host-${NATIVE_SPEC}/libiberty/libiberty.a
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-htc || exit 1 ;\
		make install-gcc || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade host-gcc ${HOST_GCC_VER}
endif

${HOST_GCC_INSTTEMP}/usr/bin/gcc:
	${MAKE} ${EXTTEMP}/${HOST_GCC_PATH}-xdc/build-${TARGET_SPEC}/libiberty/libiberty.a
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-xdc || exit 1 ;\
		make install prefix=${HOST_GCC_INSTTEMP}/usr || exit 1 \
	) || exit 1

${TOPLEV}/${HOST_GCC_EGPNAME}.egp: ${HOST_GCC_INSTTEMP}/usr/bin/gcc
	${PCREATE_SCRIPT} create ${TOPLEV}/${HOST_GCC_EGPNAME}.egp ${HOST_GCC_INSTTEMP}

${XDC_ROOT}/usr/bin/gcc: ${TOPLEV}/${HOST_GCC_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	STRIP=${TARGET_SPEC}-strip ${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${HOST_GCC_EGPNAME}.egp

REALCLEAN_TARGETS+= ${TOPLEV}/${HOST_GCC_EGPNAME}.egp


# ,-----
# |	Entry points [htc]
# +-----

#	${HTC_ROOT}/bin/${TARGET_SPEC}-gcc -dM -E - < /dev/null
.PHONY: htc-host-gcc
htc-host-gcc: htc-host-binutils ${HTC_ROOT}/usr/bin/${NATIVE_SPEC}-gcc

.PHONY: xdc-host-gcc
ifeq (${MAKE_CHROOT},y)
xdc-host-gcc: ${XDC_ROOT}/usr/bin/gcc
else
xdc-host-gcc: ${TOPLEV}/${HOST_GCC_EGPNAME}.egp
endif
