# grep 2.5.1a
# last mod WmT, 20/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

GREP_PKG:=grep
GREP_VER:=2.5.1a

GREP_SRC+=${SOURCEROOT}/g/grep-${GREP_VER}.tar.bz2

GREP_PATH:=grep-${GREP_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/grep/grep-2.5.1a.tar.bz2

#DEPS:=
#DEPS+=cmp

# ,-----
# |	Configure [htc]
# +-----


${EXTTEMP}/${GREP_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${GREP_PATH} ] || rm -rf ${EXTTEMP}/${GREP_PATH}
	${MAKE} extract LIST="$(strip ${GREP_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${GREP_PKG}*patch ; do \
#			cat $${PF} | ( cd ${GREP_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${GREP_PATH}-htc ] || rm -rf ${EXTTEMP}/${GREP_PATH}-htc
	mv ${EXTTEMP}/${GREP_PATH} ${EXTTEMP}/${GREP_PATH}-htc
	( cd ${EXTTEMP}/${GREP_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)	|| exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${GREP_PATH}-htc/src/grep: ${EXTTEMP}/${GREP_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${GREP_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

# (bad?) make INSTALL_DATA=false man1dir='' install || exit 1
${HTC_ROOT}/bin/grep:
	${MAKE} ${EXTTEMP}/${GREP_PATH}-htc/src/grep
	( cd ${EXTTEMP}/${GREP_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${GREP_PKG} ${GREP_VER}
endif

# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-grep
htc-grep: ${HTC_ROOT}/bin/grep
