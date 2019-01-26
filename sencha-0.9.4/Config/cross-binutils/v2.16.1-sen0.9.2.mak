# binutils 2.17
# last mod WmT, 07/12/2006	[ (c) and GPLv2 1999-2006 ]

# ,-----
# |	Settings
# +-----

CROSS_BINUTILS_PKG:=binutils
CROSS_BINUTILS_VER:=2.16.1
#CROSS_BINUTILS_VER:=2.17

CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-${CROSS_BINUTILS_VER}.tar.bz2
#CROSS_BINUTILS_SRC+=${TOPLEV}/gb-patches/binutils/patches/10_uclibc-conf.diff
#CROSS_BINUTILS_SRC+=${TOPLEV}/gb-patches/binutils/patches/20_uclibc-libtool-conf.diff
#...Gentoo uClibc patches
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.16.1-uclibc-patches-1.1.tar.bz2
#CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17-uclibc-patches-1.0.tar.bz2

CROSS_BINUTILS_PATH:=binutils-${CROSS_BINUTILS_VER}

URLS+=http://ftp.kernel.org/pub/linux/devel/binutils/binutils-${CROSS_BINUTILS_VER}.tar.bz2
URLS+=http://linuv.uv.es/mirror/gentoo/distfiles/binutils-2.16.1-uclibc-patches-1.1.tar.bz2


#DEPS=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [xtc]
# +-----

# - DON'T use full path to 'configure'
# - DON'T use '-gnulibc1' host/build suffix (deprecated [v2.16.1])
${EXTTEMP}/binutils-${CROSS_BINUTILS_VER}-xtc/Makefile:
	[ ! -d ${EXTTEMP}/${CROSS_BINUTILS_PATH} ] || rm -rf ${EXTTEMP}/${CROSS_BINUTILS_PATH}
	${MAKE} extract LIST="$(strip ${CROSS_BINUTILS_SRC})"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc-patches/*patch ; do \
			cat $${PF} | ( cd binutils-${CROSS_BINUTILS_VER} && patch -Np1 -i - ) || exit 1 ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	mkdir -p ${EXTTEMP}/binutils-${CROSS_BINUTILS_VER}-xtc
	( cd ${EXTTEMP}/binutils-${CROSS_BINUTILS_VER}-xtc || exit 1 ;\
	  	CC=${HTC_GCC} \
	    	  CFLAGS=-O2 \
			../${CROSS_BINUTILS_PATH}/configure -v \
			  --prefix=${XTC_ROOT}/usr \
			  --host=${NATIVE_SPEC} \
			  --target=${TARGET_SPEC} \
	  --with-sysroot=/ \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	) || exit 1
#		  ac_cv_sizeof_long_long=8 \
#		  ac_cv_path_install=${FR_INSTALL} \
#		  --disable-long-long

# ,-----
# |	Build [xtc]
# +-----

${EXTTEMP}/binutils-${CROSS_BINUTILS_VER}-xtc/binutils/ar: ${EXTTEMP}/binutils-${CROSS_BINUTILS_VER}-xtc/Makefile
	( cd ${EXTTEMP}/binutils-${CROSS_BINUTILS_VER}-xtc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [xtc]
# +-----

${XTC_ROOT}/usr/${TARGET_SPEC}/bin/ar:
	${MAKE} ${EXTTEMP}/binutils-${CROSS_BINUTILS_VER}-xtc/binutils/ar
	mkdir -p ${XTC_ROOT}/usr/`echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`/bin
	( cd ${EXTTEMP}/binutils-${CROSS_BINUTILS_VER}-xtc || exit 1 ;\
	  	make install || exit 1 ;\
		for EXE in addr2line ar as c++filt ld nm \
			objcopy objdump ranlib readelf size \
			strings strip ; do \
			( cd ${XTC_ROOT}/usr/bin && ln -sf ${TARGET_SPEC}-$${EXE} `echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`-$${EXE} ) || exit 1 ;\
			( cd ${XTC_ROOT}/usr/`echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`/bin && ln -sf ../../${TARGET_SPEC}/bin/$${EXE} ./ ) || exit 1 ;\
		done \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade cross-binutils ${CROSS_BINUTILS_VER}
endif

# ,-----
# |	Entry points [xtc]
# +-----

.PHONY: xtc-cross-binutils
xtc-cross-binutils: ${XTC_ROOT}/usr/${TARGET_SPEC}/bin/ar
