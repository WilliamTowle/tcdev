# bison 1.875/1.875e, 2.4.1
# last mod WmT, 2008-11-03	[ (c) and GPLv2 1999-2008 ]

# ,-----
# |	Settings
# +-----

BISON_PKG:=bison
#BISON_VER:=1.875
#BISON_VER:=1.875e
BISON_VER:=2.4.1

BISON_SRC:=
BISON_SRC+=${SOURCEROOT}/b/bison-${BISON_VER}.tar.bz2
#BISON_SRC+=${SOURCEROOT}/b/bison-${BISON_VER}.tar.gz

BISON_PATH:=bison-${BISON_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/bison/bison-${BISON_VER}.tar.gz

#DEPS:=
#DEPS+=m4

# ,-----
# |	Configure [htc]
# +-----

${EXTTEMP}/${BISON_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${BISON_PATH} ] || rm -rf ${EXTTEMP}/${BISON_PATH}
	${MAKE} extract LIST="$(strip ${BISON_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${BISON_PKG}*patch ; do \
#			cat $${PF} | ( cd ${BISON_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	touch ${EXTTEMP}/${BISON_PATH}/.extracted


${EXTTEMP}/${BISON_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${BISON_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${BISON_PATH}-htc ] || rm -rf ${EXTTEMP}/${BISON_PATH}-htc
	mv ${EXTTEMP}/${BISON_PATH} ${EXTTEMP}/${BISON_PATH}-htc
	( cd ${EXTTEMP}/${BISON_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	  AS=$(shell echo ${NATIVE_GCC} | sed 's/gcc$$/as/') \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --build=`echo ${NATIVE_SPEC} | sed 's/-uclibc$$//'` \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)	|| exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${BISON_PATH}-htc/src/bison: ${EXTTEMP}/${BISON_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${BISON_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

.PHONY: htc-bison-script
htc-bison-script:
	(	echo '#!/bin/sh' ;\
		echo '# Begin /usr/bin/yacc' ;\
		echo '' ;\
		echo 'exec '${INSTROOT}'/usr/bin/bison -y "$$@"' ;\
		echo '' ;\
		echo '# End /usr/bin/yacc' \
	) > ${INSTROOT}/usr/bin/yacc
	chmod a+x ${INSTROOT}/usr/bin/yacc

${HTC_ROOT}/usr/bin/bison:
	${MAKE} ${EXTTEMP}/${BISON_PATH}-htc/src/bison
	( cd ${EXTTEMP}/${BISON_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
	make htc-bison-script INSTROOT=${HTC_ROOT}
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${BISON_PKG} ${BISON_VER}
endif

# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-bison
htc-bison: ${HTC_ROOT}/usr/bin/bison
