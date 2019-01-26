# binutils 2.19.1		[ since v2.13, 2002-10-14 ]
# last mod WmT, 2011-02-17	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

CROSS_BINUTILS_PKG:=binutils
#CROSS_BINUTILS_VER:=2.16.1
#CROSS_BINUTILS_VER:=2.17
#CROSS_BINUTILS_VER:=2.18
CROSS_BINUTILS_VER:=2.19.1

CROSS_BINUTILS_PATH:=binutils-${CROSS_BINUTILS_VER}

CROSS_BINUTILS_SRC:=
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-${CROSS_BINUTILS_VER}.tar.bz2
URLS+=http://ftp.kernel.org/pub/linux/devel/binutils/binutils-${CROSS_BINUTILS_VER}.tar.bz2

ifeq (${CROSS_BINUTILS_VER},2.16.1)
ifeq (${ETCDIR},${XTC_ROOT}/etc/geex)
#X	CROSS_BINUTILS_SRC+=${TOPLEV}/gb-patches/binutils/patches/10_uclibc-conf.diff
#X	CROSS_BINUTILS_SRC+=${TOPLEV}/gb-patches/binutils/patches/20_uclibc-libtool-conf.diff
#X	else
# NB! Gentoo "v1.11" patches are not all relative to the same directory
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.16.1-patches-1.11.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.16.1-patches-1.11.tar.bz2
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.16.1-uclibc-patches-1.1.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.16.1-uclibc-patches-1.1.tar.bz2
endif
endif

ifeq (${CROSS_BINUTILS_VER},2.17)
# NB! Gentoo "v1.6" patches are not all relative to the same directory
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17-patches-1.6.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.17-patches-1.6.tar.bz2
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.17-patches-1.0.tar.bz2
endif

ifeq (${CROSS_BINUTILS_VER},2.18)
# NB! Gentoo "v1.10" patches are not all relative to the same directory
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.18-patches-1.10.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.18-patches-1.10.tar.bz2
endif

ifeq (${CROSS_BINUTILS_VER},2.19.1)
# NB! Gentoo "v1.1" patches are not all relative to the same directory
CROSS_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.19.1-patches-1.2.tar.bz2
URLS+= http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.19.1-patches-1.2.tar.bz2
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
ifeq (${ETCDIR},${XTC_ROOT}/etc/geex)
	( cd ${EXTTEMP} || exit 1 ;\
		if [ -d uclibc-patches ] ; then \
			for PF in uclibc-patches/*patch ; do \
				echo "*** PATCHING -- $${PF} ***" ;\
				grep '+++' $${PF} ;\
				patch --batch -d ${CROSS_BINUTILS_PATH} -Np1 < $${PF} ;\
				rm -f $${PF} ;\
			done ;\
		fi ;\
		if [ -d patch ] ; then \
			for PF in patch/*patch ; do \
				echo "*** PATCHING -- $${PF} ***" ;\
				grep '+++' $${PF} ;\
				sed '/+++ / { s%avr-%% ; s%binutils[^/]*/%% ; s%src/%% }' $${PF} | patch --batch -d ${CROSS_BINUTILS_PATH} -Np0 ;\
				rm -f $${PF} ;\
			done ;\
		fi \
	) || exit 1
endif
	[ ! -d ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc ] || rm -rf ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc
	mv ${EXTTEMP}/${CROSS_BINUTILS_PATH} ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc
	( cd ${EXTTEMP}/${CROSS_BINUTILS_PATH}-xtc || exit 1 ;\
	  	CC=${HTC_GCC} \
	  	AR=$(shell echo ${HTC_GCC} | sed 's/g*cc$$/ar/') \
	    	  CFLAGS=-O2 \
			./configure -v \
			  --prefix=${XTC_ROOT}/usr \
			  --build=${NATIVE_SPEC} \
			  --target=${TARGET_SPEC} \
			  --with-sysroot=${XTC_ROOT}/usr/${TARGET_SPEC} \
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
