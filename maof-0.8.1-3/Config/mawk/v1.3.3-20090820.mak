# mawk 1.3.3-20090820		[ EARLIEST v1.3.3 ]
# last mod WmT, 2009-07-16	[ (c) and GPLv2 1999-2009 ]

# ,-----
# |	Settings
# +-----

MAWK_PKG:=mawk
#MAWK_VER:=1.3.3
MAWK_VER:=1.3.3-20090820

#MAWK_SRC+=${SOURCEROOT}/m/${MAWK_PATH}.tar.gz
MAWK_SRC+=${SOURCEROOT}/m/${MAWK_PATH}.tgz

MAWK_PATH:=${MAWK_PKG}-${MAWK_VER}

#URLS+=ftp://ftp.fu-berlin.de/unix/languages/mawk/mawk-1.3.3.tar.gz
URLS+=ftp://invisible-island.net/mawk/mawk-1.3.3-20090820.tgz

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
ifeq (${MAWK_VER},1.3.3)
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
else
	( cd ${EXTTEMP}/${MAWK_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
	    	  MATHLIB=-lm \
			./configure \
			  || exit 1 ;\
		for MF in ` find ./ -name Makefile ` ; do \
			mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed '/^prefix/	s%/local%%' \
				| sed 's%mkdirs.sh%./mkdirs.sh%' \
				> $${MF} || exit 1 ;\
		done \
	)	|| exit 1
endif

# ,-----
# |	Build [htc]
# +-----

# 2008-10-14: Do not assume 'mawk_and_test' is functional. m4 circa
# v1.4.12 introduces circular dependencies between bash/m4/mawk/bison.

${EXTTEMP}/${MAWK_PATH}-htc/mawk: ${EXTTEMP}/${MAWK_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${MAWK_PATH}-htc || exit 1 ;\
		make mawk || exit 1 \
	) || exit 1
#		make SHELL=${HTC_ROOT}/bin/bash mawk_and_test || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/usr/bin/mawk:
	${MAKE} ${EXTTEMP}/${MAWK_PATH}-htc/mawk
	( cd ${EXTTEMP}/${MAWK_PATH}-htc || exit 1 ;\
		mkdir -p ${HTC_ROOT}/usr/bin || exit 1 ;\
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
