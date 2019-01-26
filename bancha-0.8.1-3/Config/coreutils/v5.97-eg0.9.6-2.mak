# coreutils 5.97
# last mod WmT, 09/02/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

COREUTILS_PKG:=coreutils
#COREUTILS_VER:=5.2.1
COREUTILS_VER:=5.97

COREUTILS_SRC:=
COREUTILS_SRC+=${SOURCEROOT}/c/coreutils-${COREUTILS_VER}.tar.bz2

COREUTILS_PATH:=coreutils-${COREUTILS_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/coreutils/coreutils-${COREUTILS_VER}.tar.bz2

#DEPS:=

# ,-----
# |	Configure [htc]
# +-----

${EXTTEMP}/${COREUTILS_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${COREUTILS_PATH} ] || rm -rf ${EXTTEMP}/${COREUTILS_PATH}
	${MAKE} extract LIST="$(strip ${COREUTILS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${COREUTILS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${COREUTILS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	touch ${EXTTEMP}/${COREUTILS_PATH}/.extracted


# ? ac_cv_func_getloadavg=no
# ? ac_list_mounted_fs=no
# ? gl_cv_list_mounted_fs=no
# ? build with seq_LDADD="-lm -L../lib -lfetish" [Willow?]
# [2009-04-28] lib/Makefile no futimens() due to libc clash
# [2009-04-28] src/Makefile no cp/ginstall/mv/touch due to libc clash
ifeq (${HAVE_GLIBC_SYSTEM},y)
${EXTTEMP}/${COREUTILS_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${COREUTILS_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${COREUTILS_PATH}-htc ] || rm -rf ${EXTTEMP}/${COREUTILS_PATH}-htc
	mv ${EXTTEMP}/${COREUTILS_PATH} ${EXTTEMP}/${COREUTILS_PATH}-htc
	(  cd ${EXTTEMP}/${COREUTILS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
		ac_cv_func_getloadavg=no \
		ac_cv_func_working_mktime=no \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  --disable-largefile --disable-nls \
			  --disable-dependency-tracking \
			  || exit 1 ;\
		[ -r lib/Makefile.OLD ] || mv lib/Makefile lib/Makefile.OLD || exit 1 ;\
		cat lib/Makefile.OLD \
			| sed 's/[^ ]*utime[^ ]*//g' \
			> lib/Makefile ;\
		[ -r src/Makefile.OLD ] || mv src/Makefile src/Makefile.OLD || exit 1 ;\
		cat src/Makefile.OLD \
			| sed '/bin_PROGRAMS/,+20 { s/[ 	]cp[^ ]*/	/ ; s/[ 	]ginstall[^ ]*/	/ ; s/[ 	]mv[^ ]*/	/ ; s/[ 	]touch[^ ]*/	/ } ' \
			> src/Makefile ;\
		[ -r po/Makefile.OLD ] || mv po/Makefile po/Makefile.OLD || exit 1 ;\
		cat po/Makefile.OLD \
			| sed '/yes.c$$/ { N ; s/\n/ / }' \
			> po/Makefile \
	) || exit 1
else
${EXTTEMP}/${COREUTILS_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${COREUTILS_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${COREUTILS_PATH}-htc ] || rm -rf ${EXTTEMP}/${COREUTILS_PATH}-htc
	mv ${EXTTEMP}/${COREUTILS_PATH} ${EXTTEMP}/${COREUTILS_PATH}-htc
	(  cd ${EXTTEMP}/${COREUTILS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
		ac_cv_func_getloadavg=no \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT} \
			  --without-included-regex \
			  --disable-largefile --disable-nls \
			  --disable-dependency-tracking \
			  || exit 1 ;\
		[ -r po/Makefile.OLD ] || mv po/Makefile po/Makefile.OLD || exit 1 ;\
		cat po/Makefile.OLD \
			| sed '/yes.c$$/ { N ; s/\n/ / }' \
			> po/Makefile \
	) || exit 1
endif

# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${COREUTILS_PATH}-htc/src/ls: ${EXTTEMP}/${COREUTILS_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${COREUTILS_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

# BAD?  make install-exec-recursive || exit 1
${HTC_ROOT}/bin/ls:
	${MAKE} ${EXTTEMP}/${COREUTILS_PATH}-htc/src/ls
	( cd ${EXTTEMP}/${COREUTILS_PATH}-htc || exit 1 ;\
		make install-exec-recursive || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${COREUTILS_PKG} ${COREUTILS_VER}
endif

# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: htc-coreutils
htc-coreutils: ${HTC_ROOT}/bin/ls
