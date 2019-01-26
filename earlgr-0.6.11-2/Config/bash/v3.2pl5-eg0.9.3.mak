# bash 3.1			[ EARLIEST 3.1 ]
# last mod WmT, 20/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

BASH_PKG:=bash
BASH_VER:=3.2

BASH_SRC+=${SOURCEROOT}/b/bash-${BASH_VER}.tar.gz
#BASH_SRC+=${SOURCEROOT}/b/bash-3.1-fixes-8.patch
BASH_SRC+=${SOURCEROOT}/b/bash32-001
BASH_SRC+=${SOURCEROOT}/b/bash32-002
BASH_SRC+=${SOURCEROOT}/b/bash32-003
BASH_SRC+=${SOURCEROOT}/b/bash32-004
BASH_SRC+=${SOURCEROOT}/b/bash32-005

BASH_PATH:=bash-${BASH_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/bash/bash-${BASH_VER}.tar.gz
#URLS+=http://www.linuxfromscratch.org/patches/downloads/bash/bash-3.1-fixes-8.patch
URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/bash/bash-3.2-patches/bash32-001
URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/bash/bash-3.2-patches/bash32-002
URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/bash/bash-3.2-patches/bash32-003
URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/bash/bash-3.2-patches/bash32-004
URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/bash/bash-3.2-patches/bash32-005

# ,-----
# |	Configure [htc]
# +-----


# - DON'T use full path to 'configure'
# - DON'T use '-gnulibc1' host/build suffix (deprecated [v2.16.1])
${EXTTEMP}/${BASH_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${BASH_PATH} ] || rm -rf ${EXTTEMP}/${BASH_PATH}
	${MAKE} extract LIST="$(strip ${BASH_SRC})"
	echo "*** PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in bash32-??? ; do \
			cat $${PF} | ( cd ${BASH_PATH} && patch -Np0 -i - ) ;\
		done \
	) || exit 1
	[ ! -d ${EXTTEMP}/${BASH_PATH}-htc ] || rm -rf ${EXTTEMP}/${BASH_PATH}-htc
	mv ${EXTTEMP}/${BASH_PATH} ${EXTTEMP}/${BASH_PATH}-htc
	( cd ${EXTTEMP}/${BASH_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --bindir=${HTC_ROOT}/bin \
			  --enable-alias \
			  --disable-readline \
			  --without-curses \
			  --without-bash-malloc \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)	|| exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${BASH_PATH}-htc/bash: ${EXTTEMP}/${BASH_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${BASH_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/bin/bash:
	${MAKE} ${EXTTEMP}/${BASH_PATH}-htc/bash
	( cd ${EXTTEMP}/${BASH_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${BASH_PKG} ${BASH_VER}
endif

# ,-----
# |	Entry Points [htc]
# +-----

.PHONY: htc-bash
htc-bash: ${HTC_ROOT}/bin/bash
