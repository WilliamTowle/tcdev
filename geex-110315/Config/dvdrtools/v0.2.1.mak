# dvdrtools 0.2.1		[ since v0.3.1, 2009-01-26 ]
# last mod WmT, 2009-01-26	[ (c) and GPLv2 1999-2009 ]

# ,-----
# |	Settings
# +-----

DVDRTOOLS_PKG:=dvdrtools
DVDRTOOLS_VER:=0.2.1
# not on sencha DVDRTOOLS_VER:=0.3.1

DVDRTOOLS_SRC:=${SOURCEROOT}/d/dvdrtools-0.2.1.tar.bz2
#DVDRTOOLS_SRC:=${SOURCEROOT}/d/dvdrtools_${DVDRTOOLS_VER}.orig.tar.gz

DVDRTOOLS_PATH:=dvdrtools-${DVDRTOOLS_VER}

URLS+= http://download.savannah.gnu.org/releases-noredirect/dvdrtools/dvdrtools-0.2.1.tar.bz2
#URLS+= http://www.mirrorservice.org/sites/archive.ubuntu.com/ubuntu/pool/multiverse/d/dvdrtools/dvdrtools_0.3.1.orig.tar.gz


#DEPS:=

# ,-----
# |	Configure [htc]
# +-----


${EXTTEMP}/${DVDRTOOLS_PATH}-htc/config.status:
	[ ! -d ${EXTTEMP}/${DVDRTOOLS_PATH} ] || rm -rf ${EXTTEMP}/${DVDRTOOLS_PATH}
	${MAKE} extract LIST="$(strip ${DVDRTOOLS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${DVDRTOOLS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${DVDRTOOLS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${DVDRTOOLS_PATH}-htc ] || rm -rf ${EXTTEMP}/${DVDRTOOLS_PATH}-htc
	mv ${EXTTEMP}/${DVDRTOOLS_PATH} ${EXTTEMP}/${DVDRTOOLS_PATH}-htc
	( cd ${EXTTEMP}/${DVDRTOOLS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	${DVDRTOOLS_ACOPTS} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  || exit 1 ;\
		[ -r readcd/readcd.c.OLD ] || mv readcd/readcd.c readcd/readcd.c.OLD || exit 1 ;\
		cat readcd/readcd.c.OLD \
			| sed 's/clone/opt_clone/' \
			> readcd/readcd.c \
	) || exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${DVDRTOOLS_PATH}-htc/mkisofs/mkisofs: ${EXTTEMP}/${DVDRTOOLS_PATH}-htc/config.status
	( cd ${EXTTEMP}/${DVDRTOOLS_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/bin/mkisofs:
	${MAKE} ${EXTTEMP}/${DVDRTOOLS_PATH}-htc/mkisofs/mkisofs
	( cd ${EXTTEMP}/${DVDRTOOLS_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1


# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-dvdrtools
htc-dvdrtools: ${HTC_ROOT}/bin/mkisofs
