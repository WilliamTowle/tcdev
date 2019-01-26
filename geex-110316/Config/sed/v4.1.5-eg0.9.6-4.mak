# sed 4.1.5			[ since v4.1.2, c.2006-02-22 ]
# last mod WmT, 2011-01-19	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

SED_PKG:=sed
SED_VER:=4.1.5

SED_SRC+=${SOURCEROOT}/s/sed-${SED_VER}.tar.gz
##ifneq (${ETCDIR},${XTC_ROOT}/etc/earlgr)
#SED_SRC+=${SOURCEROOT}/s/sed-4.1.5-fixes-1.patch
##endif

SED_PATH:=sed-${SED_VER}
SED_INSTTEMP:=${EXTTEMP}/${SED_PATH}-insttemp
SED_EGPNAME:=sed-${SED_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/sed/sed-${SED_VER}.tar.gz
##ifneq (${ETCDIR},${XTC_ROOT}/etc/earlgr)
#URLS+=http://www.linuxfromscratch.org/patches/downloads/sed/sed-4.1.5-fixes-1.patch
##endif

#DEPS=

# ,-----
# |	Configure [htc, xdc]
# +-----


# ac_cv_have_mbstate_t=no
${EXTTEMP}/${SED_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${SED_PATH} ] || rm -rf ${EXTTEMP}/${SED_PATH}
	${MAKE} extract LIST="$(strip ${SED_SRC})"
##ifneq (${ETCDIR},${XTC_ROOT}/etc/earlgr)
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${SED_PKG}*patch ; do \
#			cat $${PF} | ( cd ${SED_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
##endif
	[ ! -d ${EXTTEMP}/${SED_PATH}-htc ] || rm -rf ${EXTTEMP}/${SED_PATH}-htc
	mv ${EXTTEMP}/${SED_PATH} ${EXTTEMP}/${SED_PATH}-htc
ifeq (${HAVE_GLIBC5_SYSTEM},y)
	( cd ${EXTTEMP}/${SED_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  --disable-largefile --disable-nls \
			  --with-included-regex \
			  || exit 1 ;\
		[ -r config.h.OLD ] || mv config.h config.h.OLD || exit 1 ;\
		cat config.h.OLD \
			| sed '/define HAVE_MBRTOWC/	{ s/ 1// ; s/define/undef/ } ' \
			| sed '/define HAVE_MBSTATE_T/	{ s/ 1// ; s/define/undef/ } ' \
			| sed '/define HAVE_WCHAR_H/	{ s/ 1// ; s/define/undef/ } ' \
			| sed '/undef mbstate_t/	{ s/_t.*/_t char/ ; s/.*undef/#define/ } ' \
			| sed '/define ENABLE_NLS/	{ s/ 1// ; s/define/undef/ } ' \
			> config.h || exit 1 \
	) || exit 1
else
ifeq (${HAVE_GLIBC_SYSTEM},y)
	( cd ${EXTTEMP}/${SED_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	) || exit 1
else
	( cd ${EXTTEMP}/${SED_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1 \
	) || exit 1
endif
endif


# ac_cv_have_mbstate_t=no
${EXTTEMP}/${SED_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${SED_PATH} ] || rm -rf ${EXTTEMP}/${SED_PATH}
	${MAKE} extract LIST="$(strip ${SED_SRC})"
##ifneq (${ETCDIR},${XTC_ROOT}/etc/earlgr)
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${SED_PKG}*patch ; do \
#			cat $${PF} | ( cd ${SED_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
##endif
	[ ! -d ${EXTTEMP}/${SED_PATH}-xdc ] || rm -rf ${EXTTEMP}/${SED_PATH}-xdc
	mv ${EXTTEMP}/${SED_PATH} ${EXTTEMP}/${SED_PATH}-xdc
	( cd ${EXTTEMP}/${SED_PATH}-xdc || exit 1 ;\
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

${EXTTEMP}/${SED_PATH}-htc/sed/sed: ${EXTTEMP}/${SED_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${SED_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1

${EXTTEMP}/${SED_PATH}-xdc/sed/sed: ${EXTTEMP}/${SED_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${SED_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

${HTC_ROOT}/bin/sed:
	${MAKE} ${EXTTEMP}/${SED_PATH}-htc/sed/sed
	( cd ${EXTTEMP}/${SED_PATH}-htc || exit 1 ;\
		make install-exec-recursive || exit 1 \
	) || exit 1

${SED_INSTTEMP}/bin/sed:
	${MAKE} ${EXTTEMP}/${SED_PATH}-xdc/sed/sed
	( cd ${EXTTEMP}/${SED_PATH}-xdc || exit 1 ;\
		make DESTDIR=${SED_INSTTEMP} install-exec-recursive || exit 1 \
	) || exit 1

${TOPLEV}/${SED_EGPNAME}.egp: ${SED_INSTTEMP}/bin/sed
	${PCREATE_SCRIPT} create ${TOPLEV}/${SED_EGPNAME}.egp ${SED_INSTTEMP}

${XDC_ROOT}/bin/sed: ${TOPLEV}/${SED_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	STRIP=${TARGET_SPEC}-strip ${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${SED_EGPNAME}.egp

REALCLEAN_TARGETS+= ${TOPLEV}/${SED_EGPNAME}.egp


# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-sed
htc-sed: ${HTC_ROOT}/bin/sed

.PHONY: xdc-sed
ifeq (${MAKE_CHROOT},y)
xdc-sed: ${XDC_ROOT}/bin/sed
else
xdc-sed: ${TOPLEV}/${SED_EGPNAME}.egp
endif
