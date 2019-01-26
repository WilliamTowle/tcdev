# tar 1.13
# last mod WmT, 21/05/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

TAR_PKG:=tar
TAR_VER:=1.13

TAR_SRC+=${SOURCEROOT}/t/tar-${TAR_VER}.tar.gz

TAR_PATH:=tar-${TAR_VER}
TAR_INSTTEMP:=${EXTTEMP}/${TAR_PATH}-insttemp
TAR_EGPNAME:=tar-${TAR_VER}

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
# |	Build [xdc]
# +-----

${EXTTEMP}/${TAR_PATH}-xdc/src/tar: ${EXTTEMP}/${TAR_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${TAR_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [xdc]
# +-----

${TAR_INSTTEMP}/bin/tar:
	${MAKE} ${EXTTEMP}/${TAR_PATH}-xdc/src/tar
	( cd ${EXTTEMP}/${TAR_PATH}-xdc || exit 1 ;\
		make DESTDIR=${TAR_INSTTEMP} install-exec-recursive || exit 1 \
	) || exit 1

${TOPLEV}/${TAR_EGPNAME}.egp: ${TAR_INSTTEMP}/bin/tar
	${PCREATE_SCRIPT} create ${TOPLEV}/${TAR_EGPNAME}.egp ${TAR_INSTTEMP}

${XDC_ROOT}/bin/tar: ${TOPLEV}/${TAR_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${TAR_EGPNAME}.egp

REALCLEAN_TARGETS+= ${XDC_ROOT} ${TOPLEV}/${TAR_EGPNAME}.egp


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-tar
ifeq (${MAKE_CHROOT},y)
xdc-tar: ${XDC_ROOT}/bin/tar
else
xdc-tar: ${TOPLEV}/${TAR_EGPNAME}.egp
endif
