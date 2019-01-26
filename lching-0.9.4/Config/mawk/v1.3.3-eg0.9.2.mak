# mawk 1.3.3			[ EARLIEST 1.3.3 ]
# last mod WmT, 20/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

MAWK_PKG:=mawk
MAWK_VER:=1.3.3

MAWK_SRC+=${SOURCEROOT}/m/${MAWK_PATH}.tar.gz

MAWK_PATH:=${MAWK_PKG}-${MAWK_VER}

URLS+=ftp://ftp.fu-berlin.de/unix/languages/mawk/mawk-1.3.3.tar.gz

#DEPS:=
#DEPS+=cmp


# ,-----
# |	Configure [htc]
# +-----


${EXTTEMP}/${MAWK_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${MAWK_PATH} ] || rm -rf ${EXTTEMP}/${MAWK_PATH}
	${MAKE} extract LIST="$(strip ${MAWK_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${MAWK_PKG}*patch ; do \
#			cat $${PF} | ( cd ${MAWK_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${MAWK_PATH}-htc ] || rm -rf ${EXTTEMP}/${MAWK_PATH}-htc
	mv ${EXTTEMP}/${MAWK_PATH} ${EXTTEMP}/${MAWK_PATH}-htc
	( cd ${EXTTEMP}/${MAWK_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
	    	  MATHLIB=-lm \
			./configure \
			  || exit 1 ;\
		for MF in ` find ./ -name Makefile ` ; do \
			mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed '/^BINDIR/ s%/usr.*bin%$${DESTDIR}/usr/bin%' \
				| sed '/^MANDIR/ s%/usr.*man1%$${DESTDIR}/usr/man/man1%' \
				| sed '/^	/ s%./mawktest%$${SHELL} ./mawktest%' \
				| sed '/^	/ s%./fpe_test%$${SHELL} ./fpe_test%' \
				| sed '/(MAWKMAN)/ s/	/	$${INSTMAN} /' \
				> $${MF} || exit 1 ;\
		done \
	)	|| exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${MAWK_PATH}-htc/mawk: ${EXTTEMP}/${MAWK_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${MAWK_PATH}-htc || exit 1 ;\
		make SHELL=${HTC_ROOT}/bin/bash mawk_and_test || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/usr/bin/mawk:
	${MAKE} ${EXTTEMP}/${MAWK_PATH}-htc/mawk
	( cd ${EXTTEMP}/${MAWK_PATH}-htc || exit 1 ;\
		make DESTDIR=${HTC_ROOT} INSTMAN=-false install || exit 1 ;\
		( cd ${HTC_ROOT}/usr/bin && ln -sf mawk awk ) || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${MAWK_PKG} ${MAWK_VER}
endif

# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-mawk
htc-mawk: ${HTC_ROOT}/usr/bin/mawk
