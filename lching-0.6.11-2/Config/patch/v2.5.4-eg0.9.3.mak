# patch 4.1.4
# last mod WmT, 20/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

PATCH_PKG:=patch
PATCH_VER:=2.5.4

SOURCES:=
SOURCES+=${SOURCEROOT}/p/patch-${PATCH_VER}.tar.gz

PATCH_PATH:=patch-${PATCH_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/patch/patch-2.5.4.tar.gz

#DEPS:=


# ,-----
# |	Configure [htc, xdc]
# +-----

${EXTTEMP}/${PATCH_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${PATCH_PATH} ] || rm -rf ${EXTTEMP}/${PATCH_PATH}
	${MAKE} extract LIST="$(strip ${SOURCES})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${PATCH_PKG}*patch ; do \
#			cat $${PF} | ( cd ${PATCH_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	touch ${EXTTEMP}/${PATCH_PATH}/.extracted


# ac_cv_have_mbstate_t=no
${EXTTEMP}/${PATCH_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${PATCH_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${PATCH_PATH}-htc ] || rm -rf ${EXTTEMP}/${PATCH_PATH}-htc
	mv ${EXTTEMP}/${PATCH_PATH} ${EXTTEMP}/${PATCH_PATH}-htc
	( cd ${EXTTEMP}/${PATCH_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  --disable-largefile --disable-nls \
			  || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed 's%$${prefix}%$${DESTDIR}/$${prefix}%' \
			> Makefile || exit 1 \
	) || exit 1

# ac_cv_have_mbstate_t=no
${EXTTEMP}/${PATCH_PATH}-xdc/Makefile:
	${MAKE} ${EXTTEMP}/${PATCH_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${PATCH_PATH}-xdc ] || rm -rf ${EXTTEMP}/${PATCH_PATH}-xdc
	mv ${EXTTEMP}/${PATCH_PATH} ${EXTTEMP}/${PATCH_PATH}-xdc
	( cd ${EXTTEMP}/${PATCH_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr --bindir=/bin \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed 's%$${prefix}%$${DESTDIR}/$${prefix}%' \
			> Makefile || exit 1 \
	) || exit 1


# ,-----
# |	Build [htc, xdc]
# +-----

${EXTTEMP}/${PATCH_PATH}-htc/patch: ${EXTTEMP}/${PATCH_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${PATCH_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1
	touch ${EXTTEMP}/${PATCH_PATH}-htc/.built

${EXTTEMP}/${PATCH_PATH}-xdc/patch: ${EXTTEMP}/${PATCH_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${PATCH_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1
	touch ${EXTTEMP}/${PATCH_PATH}-xdc/.built


# ,-----
# |	Install [htc, xdc]
# +-----

${HTC_ROOT}/bin/patch:
	${MAKE} ${EXTTEMP}/${PATCH_PATH}-htc/patch
	( cd ${EXTTEMP}/${PATCH_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${PATCH_PKG} ${PATCH_VER}
endif

${XDC_INSTTEMP}/usr/bin/patch:
	${MAKE} ${EXTTEMP}/${PATCH_PATH}-xdc/patch
	( cd ${EXTTEMP}/${PATCH_PATH}-xdc || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install || exit 1 \
	) || exit 1

${TOPLEV}/${PATCH_PKG}-${PATCH_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/usr/bin/patch
#	tar cvzf ${PATCH_PKG}-${PATCH_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create ${PATCH_PKG}-${PATCH_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: htc-patch
htc-patch: ${HTC_ROOT}/bin/patch

.PHONY: xdc-patch
ifeq (${MAKE_CHROOT},y)
xdc-patch: ${XDC_INSTTEMP}/usr/bin/patch
else
xdc-patch: ${TOPLEV}/${PATCH_PKG}-${PATCH_VER}.egp
endif
