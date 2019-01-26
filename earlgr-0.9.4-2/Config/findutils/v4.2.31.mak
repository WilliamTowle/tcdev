# findutils 4.2.31
# last mod WmT, 04/06/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

FINDUTILS_PKG:=findutils
#FINDUTILS_VER:=4.2.29
FINDUTILS_VER:=4.2.31

FINDUTILS_SRC:=
FINDUTILS_SRC+=${SOURCEROOT}/f/findutils-${FINDUTILS_VER}.tar.gz

FINDUTILS_PATH:=findutils-${FINDUTILS_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/findutils/findutils-${FINDUTILS_VER}.tar.gz

#DEPS:=

# ,-----
# |	Configure [htc, xdc]
# +-----

ifeq (${HAVE_GLIBC_SYSTEM},y)
${EXTTEMP}/${FINDUTILS_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${FINDUTILS_PATH} ] || rm -rf ${EXTTEMP}/${FINDUTILS_PATH}
	${MAKE} extract LIST="$(strip ${FINDUTILS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${FINDUTILS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${FINDUTILS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	touch ${EXTTEMP}/${FINDUTILS_PATH}/.extracted
else
${EXTTEMP}/${FINDUTILS_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${FINDUTILS_PATH} ] || rm -rf ${EXTTEMP}/${FINDUTILS_PATH}
	${MAKE} extract LIST="$(strip ${FINDUTILS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${FINDUTILS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${FINDUTILS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	( cd ${EXTTEMP}/${FINDUTILS_PATH} || exit 1 ;\
		[ -r xargs/xargs.c.OLD ] || mv xargs/xargs.c xargs/xargs.c.OLD || exit 1 ;\
		cat xargs/xargs.c.OLD \
			| sed '/LINE_MAX/ { s/^/#ifdef LINE_MAX\n/ ; s/$$/\n#endif/ }' \
			>  xargs/xargs.c || exit 1 \
	) || exit 1
	touch ${EXTTEMP}/${FINDUTILS_PATH}/.extracted
endif

${EXTTEMP}/${FINDUTILS_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${FINDUTILS_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${FINDUTILS_PATH}-htc ] || rm -rf ${EXTTEMP}/${FINDUTILS_PATH}-htc
	mv ${EXTTEMP}/${FINDUTILS_PATH} ${EXTTEMP}/${FINDUTILS_PATH}-htc
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	) || exit 1

${EXTTEMP}/${FINDUTILS_PATH}-xdc/Makefile:
	${MAKE} ${EXTTEMP}/${FINDUTILS_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${FINDUTILS_PATH}-xdc ] || rm -rf ${EXTTEMP}/${FINDUTILS_PATH}-xdc
	mv ${EXTTEMP}/${FINDUTILS_PATH} ${EXTTEMP}/${FINDUTILS_PATH}-xdc
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
	    	  CFLAGS=-O2 \
			./configure --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [htc, xdc]
# +-----

${EXTTEMP}/${FINDUTILS_PATH}-htc/find: ${EXTTEMP}/${FINDUTILS_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1

${EXTTEMP}/${FINDUTILS_PATH}-xdc/find: ${EXTTEMP}/${FINDUTILS_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

${HTC_ROOT}/usr/bin/find: 
	${MAKE} ${EXTTEMP}/${FINDUTILS_PATH}-htc/find
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-htc || exit 1 ;\
		make install-exec-recursive || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${FINDUTILS_PKG} ${FINDUTILS_VER}
endif

${XDC_INSTTEMP}/usr/bin/find:
	${MAKE} ${EXTTEMP}/${FINDUTILS_PATH}-xdc/find
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-xdc || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install-exec-recursive || exit 1 \
	) || exit 1

${TOPLEV}/${FINDUTILS_PKG}-${FINDUTILS_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/usr/bin/find
#	tar cvzf ${FINDUTILS_PKG}-${FINDUTILS_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create ${FINDUTILS_PKG}-${FINDUTILS_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}


# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-findutils
htc-findutils: ${HTC_ROOT}/usr/bin/find

.PHONY: xdc-findutils
ifeq (${MAKE_CHROOT},y)
xdc-findutils: ${XDC_INSTTEMP}/usr/bin/find
else
xdc-findutils: ${TOPLEV}/${FINDUTILS_PKG}-${FINDUTILS_VER}.egp
endif
