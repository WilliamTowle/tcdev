# binutils 2.17			[ since v2.13, 2002-10-14 ]
# last mod WmT, 2011-02-18	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

HOST_BINUTILS_PKG:=binutils
#HOST_BINUTILS_VER:=2.16.1
HOST_BINUTILS_VER:=2.17
#HOST_BINUTILS_VER:=2.18
#HOST_BINUTILS_VER:=2.19.1

HOST_BINUTILS_PATH:=binutils-${HOST_BINUTILS_VER}
HOST_BINUTILS_INSTTEMP:=${EXTTEMP}/host-binutils-${HOST_BINUTILS_VER}-insttemp
HOST_BINUTILS_EGPNAME:=binutils-${HOST_BINUTILS_VER}

HOST_BINUTILS_SRC:=
HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-${HOST_BINUTILS_VER}.tar.bz2
URLS+=http://ftp.kernel.org/pub/linux/devel/binutils/binutils-${HOST_BINUTILS_VER}.tar.bz2

ifeq (${HOST_BINUTILS_VER},2.16.1)
ifeq (${ETCDIR},${XTC_ROOT}/etc/geex)
HOST_BINUTILS_SRC+=${TOPLEV}/gb-patches/binutils/patches/10_uclibc-conf.diff
HOST_BINUTILS_SRC+=${TOPLEV}/gb-patches/binutils/patches/20_uclibc-libtool-conf.diff
else
# NB! Gentoo "v1.11" patches are not all relative to the same directory
#HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.16.1-patches-1.11.tar.bz2
#URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.16.1-patches-1.11.tar.bz2
HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.16.1-uclibc-patches-1.1.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.16.1-uclibc-patches-1.1.tar.bz2
endif
endif

ifeq (${HOST_BINUTILS_VER},2.17)
# NB! Gentoo "v1.6" patches are not all relative to the same directory
#HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17-patches-1.3.tar.bz2
#URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.17-patches-1.3.tar.bz2
HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17-patches-1.6.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.17-patches-1.6.tar.bz2
HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.17-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.17-patches-1.0.tar.bz2
endif

ifeq (${HOST_BINUTILS_VER},2.18)
# NB! Gentoo "v1.10" patches are not all relative to the same directory
HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.18-patches-1.10.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.18-patches-1.10.tar.bz2
endif

ifeq (${HOST_BINUTILS_VER},2.19.1)
# NB! Gentoo "v1.1" patches are not all relative to the same directory
HOST_BINUTILS_SRC+=${SOURCEROOT}/b/binutils-2.19.1-patches-1.2.tar.bz2
URLS+= http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/binutils-2.19.1-patches-1.2.tar.bz2
endif


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
${EXTTEMP}/${HOST_BINUTILS_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${HOST_BINUTILS_PATH} ] || rm -rf ${EXTTEMP}/${HOST_BINUTILS_PATH}
	${MAKE} extract LIST="$(strip ${HOST_BINUTILS_SRC})"
ifeq (${ETCDIR},${XTC_ROOT}/etc/geex)
	( cd ${EXTTEMP} || exit 1 ;\
		if [ -d uclibc-patches ] ; then \
			for PF in uclibc-patches/*patch ; do \
				echo "*** PATCHING -- $${PF} ***" ;\
				grep '+++' $${PF} ;\
				patch --batch -d ${HOST_BINUTILS_PATH} -Np1 < $${PF} ;\
				rm -f $${PF} ;\
			done ;\
		fi ;\
		if [ -d patch ] ; then \
			for PF in patch/*patch ; do \
				echo "*** PATCHING -- $${PF} ***" ;\
				grep '+++' $${PF} ;\
				sed '/+++ binutils/ { s%binutils-[^/]*/%% ; s%binutils/ld%ld% }' $${PF} | patch --batch -d ${HOST_BINUTILS_PATH} -Np0 ;\
				rm -f $${PF} ;\
			done ;\
		fi \
	) || exit 1
endif
	mkdir -p ${EXTTEMP}/${HOST_BINUTILS_PATH}-htc
	( cd ${EXTTEMP}/${HOST_BINUTILS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	AR=$(shell echo ${NATIVE_GCC} | sed 's/g*cc$$/ar/') \
	    	  CFLAGS=-O2 \
			../${HOST_BINUTILS_PATH}/configure -v \
			  --prefix=${HTC_ROOT}/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --target=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --program-prefix=${NATIVE_SPEC}- \
			  --with-sysroot=/ \
			  --with-lib-path=/lib:/usr/lib \
			  --enable-shared \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	) || exit 1
ifeq ($(shell which makeinfo 2>/dev/null),)
	( cd ${EXTTEMP}/${HOST_BINUTILS_PATH}-htc || exit 1 ;\
		mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed '/^MAKEINFO/ s%/.*%true%' \
			> Makefile || exit 1 \
	)
endif

# - DON'T use full path to 'configure'
# - DON'T use '-gnulibc1' host/build suffix (deprecated [v2.16.1])
${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${HOST_BINUTILS_PATH} ] || rm -rf ${EXTTEMP}/${HOST_BINUTILS_PATH}
	${MAKE} extract LIST="$(strip ${HOST_BINUTILS_SRC})"
ifeq (${ETCDIR},${XTC_ROOT}/etc/geex)
	( cd ${EXTTEMP} || exit 1 ;\
		if [ -d uclibc-patches ] ; then \
			for PF in uclibc-patches/*patch ; do \
				echo "*** PATCHING -- $${PF} ***" ;\
				grep '+++' $${PF} ;\
				patch --batch -d ${HOST_BINUTILS_PATH} -Np1 < $${PF} ;\
				rm -f $${PF} ;\
			done ;\
		fi ;\
		if [ -d patch ] ; then \
			for PF in patch/*patch ; do \
				echo "*** PATCHING -- $${PF} ***" ;\
				grep '+++' $${PF} ;\
				sed '/+++ binutils/ { s%binutils-[^/]*/%% ; s%binutils/ld%ld% }' $${PF} | patch --batch -d ${HOST_BINUTILS_PATH} -Np0 ;\
				rm -f $${PF} ;\
			done ;\
		fi \
	) || exit 1
endif
	mkdir -p ${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc
	( cd ${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
		AR=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ar \
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
ifeq ($(shell which makeinfo 2>/dev/null),)
	( cd ${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc || exit 1 ;\
		mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed '/^MAKEINFO/ s%/.*%true%' \
			> Makefile || exit 1 \
	)
endif


# ,-----
# |	Build [htc, xdc]
# +-----

${EXTTEMP}/${HOST_BINUTILS_PATH}-htc/binutils/ar: ${EXTTEMP}/${HOST_BINUTILS_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${HOST_BINUTILS_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1

${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc/binutils/ar: ${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

${HTC_ROOT}/usr/${NATIVE_SPEC}/bin/ar:
	${MAKE} ${EXTTEMP}/${HOST_BINUTILS_PATH}-htc/binutils/ar
	( cd ${EXTTEMP}/${HOST_BINUTILS_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade host-binutils ${HOST_BINUTILS_VER}
endif

${HOST_BINUTILS_INSTTEMP}/usr/${TARGET_SPEC}/bin/ar:
	${MAKE} ${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc/binutils/ar
	( cd ${EXTTEMP}/${HOST_BINUTILS_PATH}-xdc || exit 1 ;\
	  	make install DESTDIR=${HOST_BINUTILS_INSTTEMP} || exit 1 ;\
	) || exit 1

${TOPLEV}/${HOST_BINUTILS_EGPNAME}.egp: ${HOST_BINUTILS_INSTTEMP}/usr/${TARGET_SPEC}/bin/ar
	${PCREATE_SCRIPT} create ${TOPLEV}/${HOST_BINUTILS_EGPNAME}.egp ${HOST_BINUTILS_INSTTEMP}

${XDC_ROOT}/usr/${TARGET_SPEC}/bin/ar: ${TOPLEV}/${HOST_BINUTILS_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	STRIP=${TARGET_SPEC}-strip ${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${HOST_BINUTILS_EGPNAME}.egp

REALCLEAN_TARGETS+= ${TOPLEV}/${HOST_BINUTILS_EGPNAME}.egp


# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-host-binutils
htc-host-binutils: ${HTC_ROOT}/usr/${NATIVE_SPEC}/bin/ar

.PHONY: xdc-host-binutils
ifeq (${MAKE_CHROOT},y)
xdc-host-binutils: ${XDC_ROOT}/usr/${TARGET_SPEC}/bin/ar
else
xdc-host-binutils: ${TOPLEV}/${HOST_BINUTILS_EGPNAME}.egp
endif
