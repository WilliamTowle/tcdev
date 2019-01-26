# binutils 2.17
# last mod WmT, 10/07/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

CROSS_BINUTILS_PKG:=binutils
CROSS_BINUTILS_VER:=2.16.1
#CROSS_BINUTILS_VER:=2.17
#CROSS_BINUTILS_VER:=2.17.50.0.9
CROSS_BINUTILS_PATH:=binutils-${CROSS_BINUTILS_VER}

CROSS_BINUTILS_SRC:=
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-${CROSS_BINUTILS_VER}.tar.bz2
URLS+=http://ftp.kernel.org/pub/linux/devel/binutils/binutils-${PKGVER}.tar.bz2
ifeq (${CROSS_BINUTILS_VER},2.16.1)
#CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.16.1-uclibc-patches-1.1.tar.bz2
CROSS_BINUTILS_SRC+=${TOPLEV}/gb-patches/binutils/patches/10_uclibc-conf.diff
CROSS_BINUTILS_SRC+=${TOPLEV}/gb-patches/binutils/patches/20_uclibc-libtool-conf.diff
URLS+=?
endif
ifeq (${CROSS_BINUTILS_VER},2.17)
#CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17-uclibc-patches-1.0.tar.bz2
CROSS_BINUTILS_SRC+=${TOPLEV}/gb-patches/v1.1-binutils/10_uclibc-conf.diff
URLS+=?
endif
ifeq (${CROSS_BINUTILS_VER},2.17.50.0.9)
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17.50.0.9-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.17.50.0.9-uclibc-patches-1.0.tar.bz2
endif

#DEPS=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [xtc]
# +-----

# - DON'T use full path to 'configure'
# - DON'T use '-gnulibc1' host/build suffix (deprecated [v2.16.1])
${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc/Makefile:
	[ ! -d ${EXTTEMP}/${CROSS_BINUTILS_PATH} ] || rm -rf ${EXTTEMP}/${CROSS_BINUTILS_PATH}
	${MAKE} extract LIST="$(strip ${CROSS_BINUTILS_SRC})"
	echo "*** PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in *diff ; do \
			patch --batch -d ${CROSS_BINUTILS_PATH} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	[ ! -d ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc ] || rm -rf ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc
	mv ${EXTTEMP}/${CROSS_BINUTILS_PATH} ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc
	( cd ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc || exit 1 ;\
	  	CC=${HTC_GCC} \
	    	  CFLAGS=-O2 \
			./configure -v \
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

${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc/binutils/ar: ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc/Makefile
	( cd ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [xtc]
# +-----

${XTC_ROOT}/usr/${TARGET_SPEC}/bin/ar:
	${MAKE} ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc/binutils/ar
	mkdir -p ${XTC_ROOT}/usr/`echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`/bin
	( cd ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc || exit 1 ;\
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
