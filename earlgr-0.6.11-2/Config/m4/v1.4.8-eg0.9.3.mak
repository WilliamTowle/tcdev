# m4 1.4.9
# last mod WmT, 27/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

M4_PKG:=m4
M4_VER:=1.4.8
#M4_VER:=1.4.9
# 1.4.9 broken wchar support w/uClibc?

M4_SRC:=
M4_SRC+=${SOURCEROOT}/m/m4-${M4_VER}.tar.bz2

M4_PATH:=m4-${M4_VER}

##	ftp://ftp.seindal.dk/gnu/m4-${M4_VER}.tar.gz	# v1.4[a-z]
URLS+=http://www.mirror.ac.uk/mirror/ftp.gnu.org/gnu/m4/m4-${M4_VER}.tar.bz2

#DEPS:=
#DEPS+=m4

# ,-----
# |	Configure [htc]
# +-----


${EXTTEMP}/${M4_PATH}/Makefile:
	[ ! -d ${EXTTEMP}/${M4_PATH} ] || rm -rf ${EXTTEMP}/${M4_PATH}
	${MAKE} extract LIST="$(strip ${M4_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${M4_PKG}*patch ; do \
#			cat $${PF} | ( cd ${M4_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1


${EXTTEMP}/${M4_PATH}-htc/config.status:
	${MAKE} ${EXTTEMP}/${M4_PATH}/Makefile
	[ ! -d ${EXTTEMP}/${M4_PATH}-htc ] || rm -rf ${EXTTEMP}/${M4_PATH}-htc
	mv ${EXTTEMP}/${M4_PATH} ${EXTTEMP}/${M4_PATH}-htc
	( cd ${EXTTEMP}/${M4_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	  AS=$(shell echo ${NATIVE_GCC} | sed 's/gcc$$/as/') \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1 \
	)	|| exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${M4_PATH}-htc/src/m4: ${EXTTEMP}/${M4_PATH}-htc/config.status
	( cd ${EXTTEMP}/${M4_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/usr/bin/m4:
	${MAKE} ${EXTTEMP}/${M4_PATH}-htc/src/m4
	( cd ${EXTTEMP}/${M4_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${COREUTILS_PKG} ${COREUTILS_VER}
endif

# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-m4
htc-m4: ${HTC_ROOT}/usr/bin/m4
