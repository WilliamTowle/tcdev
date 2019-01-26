# e2fsprogs 1.40.11		[ since v1.38, 2007-03-13 ]
# last mod WmT, 2010-03-26	[ (c) and GPLv2 1999-2010 ]

# ,-----
# |	Settings
# +-----

E2FSPROGS_PKG:=e2fsprogs
#E2FSPROGS_VER:=1.38
#E2FSPROGS_VER:=1.39
#E2FSPROGS_VER:=1.40.2
E2FSPROGS_VER:=1.40.11

E2FSPROGS_SRC:=
E2FSPROGS_SRC+=${SOURCEROOT}/e/e2fsprogs-${E2FSPROGS_VER}.tar.gz

E2FSPROGS_PATH:=e2fsprogs-${E2FSPROGS_VER}

URLS+= http://kent.dl.sourceforge.net/e2fsprogs/e2fsprogs-${E2FSPROGS_VER}.tar.gz


#DEPS:=

# ,-----
# |	Configure [htc, xdc]
# +-----


${EXTTEMP}/${E2FSPROGS_PATH}/Makefile:
	[ ! -d ${EXTTEMP}/${E2FSPROGS_PATH} ] || rm -rf ${EXTTEMP}/${E2FSPROGS_PATH}
	${MAKE} extract LIST="$(strip ${E2FSPROGS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${E2FSPROGS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${E2FSPROGS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1

E2FSPROGS_ACOPTS:=
ifeq (${HAVE_GLIBC_SYSTEM},n)
# (2007-08-20, v1.38/uClibc 0.9.26) lacks constants in sys/prctl.h
E2FSPROGS_ACOPTS+= ac_cv_header_sys_prctl_h=no
# (2007-08-20, v1.38/uClibc 0.9.26) need to lie about lseek64()
E2FSPROGS_ACOPTS+= ac_cv_have_decl_lseek64=no 
endif
E2FSPROGS_CONFIG:=
#E2FSPROGS_CONFIG+= --disable-largefile --disable-nls
# (2007-08-20, v1.38/uClibc 0.9.26) filefrag.c uses O_LARGEFILE :(
${EXTTEMP}/${E2FSPROGS_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${E2FSPROGS_PATH}/Makefile
	[ ! -d ${EXTTEMP}/${E2FSPROGS_PATH}-htc ] || rm -rf ${EXTTEMP}/${E2FSPROGS_PATH}-htc
	mv ${EXTTEMP}/${E2FSPROGS_PATH} ${EXTTEMP}/${E2FSPROGS_PATH}-htc
	( cd ${EXTTEMP}/${E2FSPROGS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	${E2FSPROGS_ACOPTS} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  ${E2FSPROGS_CONFIG} \
			  || exit 1 \
	) || exit 1

#${EXTTEMP}/${E2FSPROGS_PATH}-xdc/Makefile:
#	${MAKE} ${EXTTEMP}/${E2FSPROGS_PATH}/Makefile
#	[ ! -d ${EXTTEMP}/${E2FSPROGS_PATH}-xdc ] || rm -rf ${EXTTEMP}/${E2FSPROGS_PATH}-xdc
#	mv ${EXTTEMP}/${E2FSPROGS_PATH} ${EXTTEMP}/${E2FSPROGS_PATH}-xdc
#	( cd ${EXTTEMP}/${E2FSPROGS_PATH}-xdc || exit 1 ;\
#		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
#	    	  CFLAGS=-O2 \
#			./configure --prefix=/ \
#			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
#			  --build=${TARGET_SPEC} \
#			  --disable-largefile --disable-nls \
#			  --without-included-regex \
#			  || exit 1 \
#	) || exit 1


# ,-----
# |	Build [htc, xdc]
# +-----

${EXTTEMP}/${E2FSPROGS_PATH}-htc/misc/mke2fs: ${EXTTEMP}/${E2FSPROGS_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${E2FSPROGS_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1

#${EXTTEMP}/${E2FSPROGS_PATH}-xdc/misc/mke2fs: ${EXTTEMP}/${E2FSPROGS_PATH}-xdc/Makefile
#	( cd ${EXTTEMP}/${E2FSPROGS_PATH}-xdc || exit 1 ;\
#		make || exit 1 \
#	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

${HTC_ROOT}/sbin/mke2fs: 
	${MAKE} ${EXTTEMP}/${E2FSPROGS_PATH}-htc/misc/mke2fs
	( cd ${EXTTEMP}/${E2FSPROGS_PATH}-htc || exit 1 ;\
		mkdir -p ${HTC_ROOT}/etc || exit 1 ;\
		make install || exit 1 \
	) || exit 1

#${XDC_ROOT}/sbin/mke2fs:
#	${MAKE} ${EXTTEMP}/${E2FSPROGS_PATH}-xdc/e2fsprogs
#	( cd ${EXTTEMP}/${E2FSPROGS_PATH}-xdc || exit 1 ;\
#		make DESTDIR=${XDC_ROOT} install || exit 1 \
#	) || exit 1

# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-e2fsprogs
htc-e2fsprogs: ${HTC_ROOT}/sbin/mke2fs

#.PHONY: xdc-e2fsprogs
#xdc-e2fsprogs: ${XDC_ROOT}/sbin/mke2fs
