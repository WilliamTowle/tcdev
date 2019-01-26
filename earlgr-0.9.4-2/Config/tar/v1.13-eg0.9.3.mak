# tar 1.13
# last mod WmT, 21/05/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

TAR_PKG:=tar
TAR_VER:=1.13

TAR_SRC+=${SOURCEROOT}/t/tar-${TAR_VER}.tar.gz

TAR_PATH:=tar-${TAR_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/tar/tar-1.13.tar.gz

#DEPS:=

# ,-----
# |	Configure [htc, xdc]
# +-----


#${EXTTEMP}/${TAR_PATH}-htc/.configured:
#	[ ! -d ${EXTTEMP}/${TAR_PATH} ] || rm -rf ${EXTTEMP}/${TAR_PATH}
#	${MAKE} extract LIST="$(strip ${TAR_SRC})"
##	echo "*** PATCHING ***"
##	( cd ${EXTTEMP} || exit 1 ;\
##		for PF in ${TAR_PKG}*patch ; do \
##			cat $${PF} | ( cd ${TAR_PATH} && patch -Np1 -i - ) ;\
##			rm -f $${PF} ;\
##		done \
##	) || exit 1
#	[ ! -d ${EXTTEMP}/${TAR_PATH}-htc ] || rm -rf ${EXTTEMP}/${TAR_PATH}-htc
#	mv ${EXTTEMP}/${TAR_PATH} ${EXTTEMP}/${TAR_PATH}-htc
#	( cd ${EXTTEMP}/${TAR_PATH}-htc || exit 1 ;\
#	  	CC=${NATIVE_GCC} \
#	    	  CFLAGS=-O2 \
#			./configure \
#			  --prefix=${HTC_ROOT} \
#			  --disable-largefile --disable-nls \
#			  || exit 1 \
#	) || exit 1
#	touch ${EXTTEMP}/${TAR_PATH}-htc/.configured

${EXTTEMP}/${TAR_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${TAR_PATH} ] || rm -rf ${EXTTEMP}/${TAR_PATH}
	${MAKE} extract LIST="$(strip ${TAR_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${TAR_PKG}*patch ; do \
#			cat $${PF} | ( cd ${TAR_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${TAR_PATH}-xdc ] || rm -rf ${EXTTEMP}/${TAR_PATH}-xdc
	mv ${EXTTEMP}/${TAR_PATH} ${EXTTEMP}/${TAR_PATH}-xdc
	( cd ${EXTTEMP}/${TAR_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr --bindir=/bin \
			  --host=${NATIVE_SPEC} \
			  --build=${TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [htc, xdc]
# +-----

#${EXTTEMP}/${TAR_PATH}-htc/.built: ${EXTTEMP}/${TAR_PATH}-htc/.configured
#	( cd ${EXTTEMP}/${TAR_PATH}-htc || exit 1 ;\
#		make || exit 1 \
#	) || exit 1
#	touch ${EXTTEMP}/${TAR_PATH}-htc/.built

${EXTTEMP}/${TAR_PATH}-xdc/src/tar: ${EXTTEMP}/${TAR_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${TAR_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

#.PHONY: htc-tar
#htc-tar:
#	${MAKE} ${EXTTEMP}/${TAR_PATH}-htc/.built
#	( cd ${EXTTEMP}/${TAR_PATH}-htc || exit 1 ;\
#		make install-exec-recursive || exit 1 \
#	) || exit 1

${XDC_INSTTEMP}/bin/tar:
	${MAKE} ${EXTTEMP}/${TAR_PATH}-xdc/src/tar
	( cd ${EXTTEMP}/${TAR_PATH}-xdc || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install-exec-recursive || exit 1 \
	) || exit 1

${TOPLEV}/${TAR_PKG}-${TAR_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/bin/tar
#	tar cvzf ${TAR_PKG}-${TAR_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create ${TAR_PKG}-${TAR_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-tar
ifeq (${MAKE_CHROOT},y)
xdc-tar: ${XDC_INSTTEMP}/bin/tar
else
xdc-tar: ${TOPLEV}/${TAR_PKG}-${TAR_VER}.egp
endif
