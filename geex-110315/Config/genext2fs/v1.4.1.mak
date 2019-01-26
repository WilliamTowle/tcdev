# genext2fs 1.4.1		[ since v1.4.1, 2009-01-22 ]
# last mod WmT, 2009-01-22	[ (c) and GPLv2 1999-2009 ]

# ,-----
# |	Settings
# +-----

GENEXT2FS_PKG:=genext2fs
GENEXT2FS_VER:=1.4.1

GENEXT2FS_SRC:=
GENEXT2FS_SRC+=${SOURCEROOT}/g/genext2fs-${GENEXT2FS_VER}.tar.gz

GENEXT2FS_PATH:=genext2fs-${GENEXT2FS_VER}

URLS+= http://garr.dl.sourceforge.net/sourceforge/genext2fs/genext2fs-1.4.1.tar.gz


#DEPS:=

# ,-----
# |	Configure [htc]
# +-----


${EXTTEMP}/${GENEXT2FS_PATH}-htc/config.status:
	[ ! -d ${EXTTEMP}/${GENEXT2FS_PATH} ] || rm -rf ${EXTTEMP}/${GENEXT2FS_PATH}
	${MAKE} extract LIST="$(strip ${GENEXT2FS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${GENEXT2FS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${GENEXT2FS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${GENEXT2FS_PATH}-htc ] || rm -rf ${EXTTEMP}/${GENEXT2FS_PATH}-htc
	mv ${EXTTEMP}/${GENEXT2FS_PATH} ${EXTTEMP}/${GENEXT2FS_PATH}-htc
	( cd ${EXTTEMP}/${GENEXT2FS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	${GENEXT2FS_ACOPTS} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${GENEXT2FS_PATH}-htc/genext2fs: ${EXTTEMP}/${GENEXT2FS_PATH}-htc/config.status
	( cd ${EXTTEMP}/${GENEXT2FS_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/bin/genext2fs:
	${MAKE} ${EXTTEMP}/${GENEXT2FS_PATH}-htc/genext2fs
	( cd ${EXTTEMP}/${GENEXT2FS_PATH}-htc || exit 1 ;\
		mkdir -p ${HTC_ROOT}/etc || exit 1 ;\
		make install || exit 1 \
	) || exit 1


# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-genext2fs
htc-genext2fs: ${HTC_ROOT}/bin/genext2fs
