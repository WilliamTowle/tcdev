# diffutils 2.8.7
# last mod WmT, 20/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

DIFFUTILS_PKG:=diffutils
DIFFUTILS_VER:=2.8.7

DIFFUTILS_SRC:=
DIFFUTILS_SRC+=${SOURCEROOT}/d/diffutils-${DIFFUTILS_VER}.tar.gz

DIFFUTILS_PATH:=diffutils-${DIFFUTILS_VER}

URLS+=http://www.mirror.ac.uk/mirror/ftp.gnu.org/gnu/diffutils/diffutils-${DIFFUTILS_VER}.tar.gz

#DEPS:=
#DEPS+=cmp

# ,-----
# |	Configure [htc]
# +-----

${EXTTEMP}/${DIFFUTILS_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${DIFFUTILS_PATH} ] || rm -rf ${EXTTEMP}/${DIFFUTILS_PATH}
	${MAKE} extract LIST="$(strip ${DIFFUTILS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${DIFFUTILS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${DIFFUTILS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	touch ${EXTTEMP}/${DIFFUTILS_PATH}/.extracted


${EXTTEMP}/${DIFFUTILS_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${DIFFUTILS_PATH}-htc ] || rm -rf ${EXTTEMP}/${DIFFUTILS_PATH}-htc
	mv ${EXTTEMP}/${DIFFUTILS_PATH} ${EXTTEMP}/${DIFFUTILS_PATH}-htc
	(  cd ${EXTTEMP}/${DIFFUTILS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)	|| exit 1
	touch ${EXTTEMP}/${DIFFUTILS_PATH}-htc/.configured


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${DIFFUTILS_PATH}-htc/src/diff:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${DIFFUTILS_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1
	touch ${EXTTEMP}/${DIFFUTILS_PATH}-htc/.built


# ,-----
# |	Install [htc]
# +-----

# BAD? make install-exec-recursive || exit 1
${HTC_ROOT}/usr/bin/diff:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}-htc/src/diff
	( cd ${EXTTEMP}/${DIFFUTILS_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${DIFFUTILS_PKG} ${DIFFUTILS_VER}
endif

# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-diffutils
htc-diffutils: ${HTC_ROOT}/usr/bin/diff
