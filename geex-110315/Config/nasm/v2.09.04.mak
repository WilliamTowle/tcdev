# nasm 2.09.04			[ since v0.98.35, c.2002-10-21 ]
# last mod WmT, 2011-01-18	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

NASM_PKG:=nasm
#NASM_VER:=2.05.01
#NASM_VER:=2.07
NASM_VER:=2.09.04

NASM_SRC:=
NASM_SRC+=${SOURCEROOT}/n/nasm-${NASM_VER}.tar.bz2

NASM_PATH:=nasm-${NASM_VER}

URLS+= http://www.nasm.us/pub/nasm/releasebuilds/${NASM_VER}/nasm-${NASM_VER}.tar.bz2


#DEPS:=

# ,-----
# |	Configure [htc]
# +-----


${EXTTEMP}/${NASM_PATH}-htc/config.status:
	[ ! -d ${EXTTEMP}/${NASM_PATH} ] || rm -rf ${EXTTEMP}/${NASM_PATH}
	${MAKE} extract LIST="$(strip ${NASM_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${NASM_PKG}*patch ; do \
#			cat $${PF} | ( cd ${NASM_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${NASM_PATH}-htc ] || rm -rf ${EXTTEMP}/${NASM_PATH}-htc
	mv ${EXTTEMP}/${NASM_PATH} ${EXTTEMP}/${NASM_PATH}-htc
	( cd ${EXTTEMP}/${NASM_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	${NASM_ACOPTS} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${NASM_PATH}-htc/nasm: ${EXTTEMP}/${NASM_PATH}-htc/config.status
	( cd ${EXTTEMP}/${NASM_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/bin/nasm:
	${MAKE} ${EXTTEMP}/${NASM_PATH}-htc/nasm
	( cd ${EXTTEMP}/${NASM_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1


# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-nasm
htc-nasm: ${HTC_ROOT}/bin/nasm
