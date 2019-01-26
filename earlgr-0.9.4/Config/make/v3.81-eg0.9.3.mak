# make 3.81			[ EARLIEST v3.79.1 ]
# last mod WmT, 04/02/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

MAKE_PKG:=make
#MAKE_VER:=3.79.1
MAKE_VER:=3.81

MAKE_SRC+=${SOURCEROOT}/m/${MAKE_PKG}-${MAKE_VER}.tar.bz2
URLS+=	http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/make/${MAKE_PKG}-${MAKE_VER}.tar.bz2

MAKE_PATH:=${MAKE_PKG}-${MAKE_VER}


#DEPS:=

# ,-----
# |	Configure [htc, xdc]
# +-----


${EXTTEMP}/${MAKE_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${MAKE_PATH} ] || rm -rf ${EXTTEMP}/${MAKE_PATH}
	${MAKE} extract LIST="$(strip ${MAKE_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${MAKE_PKG}*patch ; do \
#			cat $${PF} | ( cd ${MAKE_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${MAKE_PATH}-htc ] || rm -rf ${EXTTEMP}/${MAKE_PATH}-htc
	mv ${EXTTEMP}/${MAKE_PATH} ${EXTTEMP}/${MAKE_PATH}-htc
	( cd ${EXTTEMP}/${MAKE_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)	|| exit 1


${EXTTEMP}/${MAKE_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${MAKE_PATH} ] || rm -rf ${EXTTEMP}/${MAKE_PATH}
	${MAKE} extract LIST="$(strip ${MAKE_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${MAKE_PKG}*patch ; do \
#			cat $${PF} | ( cd ${MAKE_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${MAKE_PATH}-xdc ] || rm -rf ${EXTTEMP}/${MAKE_PATH}-xdc
	mv ${EXTTEMP}/${MAKE_PATH} ${EXTTEMP}/${MAKE_PATH}-xdc
	( cd ${EXTTEMP}/${MAKE_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
		  ac_cv_func_setvbuf_reversed=no \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)	|| exit 1


# ,-----
# |	Build [htc, xdc]
# +-----


${EXTTEMP}/${MAKE_PATH}-htc/make: ${EXTTEMP}/${MAKE_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${MAKE_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


${EXTTEMP}/${MAKE_PATH}-xdc/make: ${EXTTEMP}/${MAKE_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${MAKE_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

${HTC_ROOT}/usr/bin/make:
	${MAKE} ${EXTTEMP}/${MAKE_PATH}-htc/make
	( cd ${EXTTEMP}/${MAKE_PATH}-htc || exit 1 ;\
		make install || exit 1 ;\
		cd ${HTC_ROOT}/usr/bin && ln -sf make gmake \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${MAKE_PKG} ${MAKE_VER}
endif

${XDC_INSTTEMP}/usr/bin/make:
	${MAKE} ${EXTTEMP}/${MAKE_PATH}-xdc/make
	( cd ${EXTTEMP}/${MAKE_PATH}-xdc || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install || exit 1 ;\
		cd ${XDC_INSTTEMP}/usr/bin && ln -sf make gmake \
	) || exit 1

${TOPLEV}/${MAKE_PKG}-${MAKE_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/usr/bin/make
#	tar cvzf ${MAKE_PKG}-${MAKE_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create ${MAKE_PKG}-${MAKE_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}

# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-make
htc-make: ${HTC_ROOT}/usr/bin/make

.PHONY: xdc-make
ifeq (${MAKE_CHROOT},y)
xdc-make: ${XDC_INSTTEMP}/usr/bin/make
else
xdc-make: ${TOPLEV}/${MAKE_PKG}-${MAKE_VER}.egp
endif
