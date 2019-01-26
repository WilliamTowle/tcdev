# binutils 2.16.1
# last mod WmT, 03/04/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

HOST_BINUTILS_PKG:=binutils
HOST_BINUTILS_VER:=2.16.1
#HOST_BINUTILS_VER:=2.17

HOST_BINUTILS_SRC:=
HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-${HOST_BINUTILS_VER}.tar.bz2
#...Gentoo uClibc patches
HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.16.1-uclibc-patches-1.1.tar.bz2
#HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17-uclibc-patches-1.0.tar.bz2

HOST_BINUTILS_PATH:=binutils-${HOST_BINUTILS_VER}

URLS+=http://ftp.kernel.org/pub/linux/devel/binutils/binutils-${HOST_BINUTILS_VER}.tar.bz2
URLS+=http://linuv.uv.es/mirror/gentoo/distfiles/binutils-2.16.1-uclibc-patches-1.1.tar.bz2

#DEPS:=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [htc, xdc]
# +-----

# - DON'T use full path to 'configure'
# - DO configure with '-v' (to include spec in executable names)
# - DON'T use '-gnulibc1' host/build suffix (deprecated [v2.16.1])
${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${HOST_BINUTILS_PATH} ] || rm -rf ${EXTTEMP}/${HOST_BINUTILS_PATH}
	${MAKE} extract LIST="$(strip ${HOST_BINUTILS_SRC})"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc-patches/*patch ; do \
			cat $${PF} | ( cd binutils-${HOST_BINUTILS_VER} && patch -Np1 -i - ) || exit 1 ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	mkdir -p ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-htc
	( cd ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			../${HOST_BINUTILS_PATH}/configure -v \
			  --prefix=${HTC_ROOT}/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --target=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --program-prefix=${NATIVE_SPEC}- \
			  --with-sysroot=/ \
			  --with-lib-path=/lib:/usr/lib \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	) || exit 1

# - DON'T use full path to 'configure'
# - DON'T use '-gnulibc1' host/build suffix (deprecated [v2.16.1])
${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${HOST_BINUTILS_PATH} ] || rm -rf ${EXTTEMP}/${HOST_BINUTILS_PATH}
	${MAKE} extract LIST="$(strip ${HOST_BINUTILS_SRC})"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc-patches/*patch ; do \
			cat $${PF} | ( cd binutils-${HOST_BINUTILS_VER} && patch -Np1 -i - ) || exit 1 ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	mkdir -p ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-xdc
	( cd ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
		  CC_FOR_BUILD=${HTC_GCC} \
		  HOSTCC=${HTC_GCC} \
	  	  AR=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ar \
	  	  AS=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-as \
	  	  LD=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ld \
	  	  NM=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-nm \
	  	  RANLIB=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ranlib \
	    	  CFLAGS=-O2 \
			../${HOST_BINUTILS_PATH}/configure \
			  --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${TARGET_SPEC} \
			  --target=${TARGET_SPEC} \
			  --program-prefix='' \
			  --with-sysroot=/ \
			  --with-lib-path=/lib:/usr/lib \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	) || exit 1
#		  ac_cv_sizeof_long_long=8 \
#		  ac_cv_path_install=${FR_INSTALL} \
#		  --disable-long-long


# ,-----
# |	Build [htc, xdc]
# +-----

${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-htc/binutils/ar: ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-htc/Makefile
	( cd ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1

${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-xdc/binutils/ar: ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-xdc/Makefile
	( cd ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

${HTC_ROOT}/usr/${NATIVE_SPEC}/bin/ar:
	${MAKE} ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-htc/binutils/ar
	( cd ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade host-binutils ${HOST_BINUTILS_VER}
endif

${XDC_INSTTEMP}/usr/${TARGET_SPEC}/bin/ar:
	${MAKE} ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-xdc/binutils/ar
	( cd ${EXTTEMP}/binutils-${HOST_BINUTILS_VER}-xdc || exit 1 ;\
	  	make install DESTDIR=${XDC_INSTTEMP} || exit 1 ;\
	) || exit 1

${TOPLEV}/${HOST_BINUTILS_PKG}-${HOST_BINUTILS_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/usr/${TARGET_SPEC}/bin/ar
#	tar cvzf ${HOST_BINUTILS_PKG}-${HOST_BINUTILS_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create binutils-${HOST_BINUTILS_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}


# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-host-binutils
htc-host-binutils: ${HTC_ROOT}/usr/${NATIVE_SPEC}/bin/ar

.PHONY: xdc-host-binutils
ifeq (${MAKE_CHROOT},y)
xdc-host-binutils: ${XDC_INSTTEMP}/usr/${TARGET_SPEC}/bin/ar
else
xdc-host-binutils: ${TOPLEV}/${HOST_BINUTILS_PKG}-${HOST_BINUTILS_VER}.egp
endif
