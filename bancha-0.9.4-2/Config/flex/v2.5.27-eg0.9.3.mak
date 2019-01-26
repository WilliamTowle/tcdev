# flex 2.5.27
# last mod WmT, 20/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

FLEX_PKG:=flex
FLEX_VER:=2.5.27

FLEX_SRC:=
FLEX_SRC+=${SOURCEROOT}/f/flex-${FLEX_VER}.tar.bz2

FLEX_PATH:=flex-${FLEX_VER}

URLS+=http://www.mirror.ac.uk/mirror/ftp.gnu.org/gnu/flex/flex-${PKGVER}.tar.bz2

#DEPS:=
#DEPS+=

# ,-----
# |	Configure [htc]
# +-----

${EXTTEMP}/${FLEX_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${FLEX_PATH} ] || rm -rf ${EXTTEMP}/${FLEX_PATH}
	${MAKE} extract LIST="$(strip ${FLEX_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${FLEX_PKG}*patch ; do \
#			cat $${PF} | ( cd ${FLEX_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	touch ${EXTTEMP}/${FLEX_PATH}/.extracted


${EXTTEMP}/${FLEX_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${FLEX_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${FLEX_PATH}-htc ] || rm -rf ${EXTTEMP}/${FLEX_PATH}-htc
	mv ${EXTTEMP}/${FLEX_PATH} ${EXTTEMP}/${FLEX_PATH}-htc
	( cd ${EXTTEMP}/${FLEX_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --disable-largefile --disable-nls \
			  || exit 1 ;\
		find ./ -name [Mm]akefile | while read MF ; do \
			mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed '/^	.*--info-dir/	s/install-info/true/' \
				> $${MF} ;\
		done \
	)	|| exit 1
	touch ${EXTTEMP}/${FLEX_PATH}-htc/.configured


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${FLEX_PATH}-htc/flex: ${EXTTEMP}/${FLEX_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${FLEX_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1
	touch ${EXTTEMP}/${FLEX_PATH}-htc/.built


# ,-----
# |	Install [htc]
# +-----

.PHONY: htc-flex-script
htc-flex-script:
	(	echo '#!/bin/sh' ;\
		echo '# Begin /usr/bin/lex' ;\
		echo '' ;\
		echo 'exec '${INSTROOT}'/usr/bin/flex -l "$@"' ;\
		echo '' ;\
		echo '# End /usr/bin/lex' \
	) > ${INSTROOT}/usr/bin/lex
	chmod a+x ${INSTROOT}/usr/bin/lex

${HTC_ROOT}/usr/bin/flex:
	${MAKE} ${EXTTEMP}/${FLEX_PATH}-htc/flex
	( cd ${EXTTEMP}/${FLEX_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
	make htc-flex-script INSTROOT=${HTC_ROOT}
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${FLEX_PKG} ${FLEX_VER}
endif

# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-flex
htc-flex: ${HTC_ROOT}/usr/bin/flex
