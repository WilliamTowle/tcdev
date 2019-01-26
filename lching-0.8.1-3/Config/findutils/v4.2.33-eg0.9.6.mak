# findutils 4.2.33
# last mod WmT, 2009-03-03	[ (c) and GPLv2 1999-2009 ]

# ,-----
# |	Settings
# +-----

FINDUTILS_PKG:=findutils
#FINDUTILS_VER:=4.2.29
FINDUTILS_VER:=4.2.33
#FINDUTILS_VER:=4.4.0

FINDUTILS_SRC:=
FINDUTILS_SRC+=${SOURCEROOT}/f/findutils-${FINDUTILS_VER}.tar.gz

FINDUTILS_PATH:=findutils-${FINDUTILS_VER}
FINDUTILS_INSTTEMP:=${EXTTEMP}/${FINDUTILS_PATH}-insttemp
FINDUTILS_EGPNAME:=findutils-${FINDUTILS_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/findutils/findutils-${FINDUTILS_VER}.tar.gz

#DEPS:=

# ,-----
# |	Configure [htc, xdc]
# +-----

#ifeq (${HAVE_GLIBC_SYSTEM},y)
${EXTTEMP}/${FINDUTILS_PATH}/Makefile:
	[ ! -d ${EXTTEMP}/${FINDUTILS_PATH} ] || rm -rf ${EXTTEMP}/${FINDUTILS_PATH}
	${MAKE} extract LIST="$(strip ${FINDUTILS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${FINDUTILS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${FINDUTILS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
#else
#${EXTTEMP}/${FINDUTILS_PATH}/Makefile:
#	[ ! -d ${EXTTEMP}/${FINDUTILS_PATH} ] || rm -rf ${EXTTEMP}/${FINDUTILS_PATH}
#	${MAKE} extract LIST="$(strip ${FINDUTILS_SRC})"
##	echo "*** PATCHING ***"
##	( cd ${EXTTEMP} || exit 1 ;\
##		for PF in ${FINDUTILS_PKG}*patch ; do \
##			cat $${PF} | ( cd ${FINDUTILS_PATH} && patch -Np1 - ) || exit 1 ;\
##			rm -f $${PF} ;\
##		done \
##	) || exit 1
#	( cd ${EXTTEMP}/${FINDUTILS_PATH} || exit 1 ;\
#		[ -r xargs/xargs.c.OLD ] || mv xargs/xargs.c xargs/xargs.c.OLD || exit 1 ;\
#		cat xargs/xargs.c.OLD \
#			| sed '/LINE_MAX/ { s/^/#ifdef LINE_MAX\n/ ; s/$$/\n#endif/ }' \
#			>  xargs/xargs.c || exit 1 \
#	) || exit 1
#endif

${EXTTEMP}/${FINDUTILS_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${FINDUTILS_PATH}/Makefile
	[ ! -d ${EXTTEMP}/${FINDUTILS_PATH}-htc ] || rm -rf ${EXTTEMP}/${FINDUTILS_PATH}-htc
	mv ${EXTTEMP}/${FINDUTILS_PATH} ${EXTTEMP}/${FINDUTILS_PATH}-htc
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-htc || exit 1 ;\
		case $(shell ${NATIVE_GCC} -v 2>&1 | sed '/specs/ s/.* // ; t ; d') in \
		*-earlgrey-*|*-senban-*) \
			for SF in freadahead.c freading.c fseeko.c ; do \
		 	 	[ -r gnulib/lib/$${SF}.OLD ] || mv gnulib/lib/$${SF} gnulib/lib/$${SF}.OLD || exit 1 ;\
		 	 	cat gnulib/lib/$${SF}.OLD \
		 	 	 	| sed 's/__modeflags/modeflags/' \
		 	 	 	| sed 's/__bufpos/bufpos/' \
		 	 	 	| sed 's/__bufread/bufread/' \
		 	 	 	| sed 's/__bufstart/bufstart/' \
		 	 	 	| sed 's%def __STDIO_BUFFERS% 0 /* __STDIO_BUFFERS */%' \
		 	 	 	> gnulib/lib/$${SF} || exit 1 ;\
			done \
		;; \
		esac ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1 \
	) || exit 1

${EXTTEMP}/${FINDUTILS_PATH}-xdc/Makefile:
	${MAKE} ${EXTTEMP}/${FINDUTILS_PATH}/Makefile
	[ ! -d ${EXTTEMP}/${FINDUTILS_PATH}-xdc ] || rm -rf ${EXTTEMP}/${FINDUTILS_PATH}-xdc
	mv ${EXTTEMP}/${FINDUTILS_PATH} ${EXTTEMP}/${FINDUTILS_PATH}-xdc
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-xdc || exit 1 ;\
		case $(shell ${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc -v 2>&1 | sed '/specs/ s/.* // ; t ; d') in \
		*-earlgrey-*|*-senban-*) \
			for SF in freadahead.c freading.c fseeko.c ; do \
		 	 	[ -r gnulib/lib/$${SF}.OLD ] || mv gnulib/lib/$${SF} gnulib/lib/$${SF}.OLD || exit 1 ;\
		 	 	cat gnulib/lib/$${SF}.OLD \
		 	 	 	| sed 's/__modeflags/modeflags/' \
		 	 	 	| sed 's/__bufpos/bufpos/' \
		 	 	 	| sed 's/__bufread/bufread/' \
		 	 	 	| sed 's/__bufstart/bufstart/' \
		 	 	 	| sed 's%def __STDIO_BUFFERS% 0 /* __STDIO_BUFFERS */%' \
		 	 	 	> gnulib/lib/$${SF} || exit 1 ;\
			done \
		;; \
		esac ;\
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

${FINDUTILS_INSTTEMP}/usr/bin/find:
	${MAKE} ${EXTTEMP}/${FINDUTILS_PATH}-xdc/find
	( cd ${EXTTEMP}/${FINDUTILS_PATH}-xdc || exit 1 ;\
		make DESTDIR=${FINDUTILS_INSTTEMP} install-exec-recursive || exit 1 \
	) || exit 1
	( cd ${FINDUTILS_INSTTEMP} || exit 1 ;\
		for F in usr/bin/updatedb ; do \
			mv $${F} ${EXTTEMP}/${FINDUTILS_PATH}-xdc/`basename $${F}`.orig || exit 1 ;\
			sed 's%'${HTC_ROOT}'%%' ${EXTTEMP}/${FINDUTILS_PATH}-xdc/`basename $${F}`.orig > $${F} ;\
			chmod a+x $${F} || exit 1 ;\
		done \
	) || exit 1

${TOPLEV}/${FINDUTILS_EGPNAME}.egp: ${FINDUTILS_INSTTEMP}/usr/bin/find
	${PCREATE_SCRIPT} create ${TOPLEV}/${FINDUTILS_EGPNAME}.egp ${FINDUTILS_INSTTEMP}

${XDC_ROOT}/usr/bin/find: ${TOPLEV}/${FINDUTILS_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${FINDUTILS_EGPNAME}.egp

REALCLEAN_TARGETS+= ${TOPLEV}/${FINDUTILS_EGPNAME}.egp


# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-findutils
htc-findutils: ${HTC_ROOT}/usr/bin/find

.PHONY: xdc-findutils
ifeq (${MAKE_CHROOT},y)
xdc-findutils: ${XDC_ROOT}/usr/bin/find
else
xdc-findutils: ${TOPLEV}/${FINDUTILS_EGPNAME}.egp
endif
