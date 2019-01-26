# diffutils 2.8.7		[ since v2.8.1, c.2002-10-30 ]
# last mod WmT, 2011-01-19	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

DIFFUTILS_PKG:=diffutils
DIFFUTILS_VER:=2.8.7

DIFFUTILS_SRC:=
DIFFUTILS_SRC+=${SOURCEROOT}/d/diffutils-${DIFFUTILS_VER}.tar.gz

DIFFUTILS_PATH:=diffutils-${DIFFUTILS_VER}
DIFFUTILS_INSTTEMP:=${EXTTEMP}/${DIFFUTILS_PATH}-insttemp
DIFFUTILS_EGPNAME:=diffutils-${DIFFUTILS_VER}

URLS+=http://www.mirrorservice.org/sites/alpha.gnu.org/gnu/diffutils/diffutils-2.8.7.tar.gz
#URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/diffutils/diffutils-${DIFFUTILS_VER}.tar.gz

#DEPS:=
#DEPS+=cmp

# ,-----
# |	Configure [htc]
# +-----

${EXTTEMP}/${DIFFUTILS_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${DIFFUTILS_PATH} ] || rm -rf ${EXTTEMP}/${DIFFUTILS_PATH}
	${MAKE} extract LIST="$(strip ${DIFFUTILS_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${DIFFUTILS_PKG}*patch ; do \
#			cat $${PF} | ( cd ${DIFFUTILS_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	touch ${EXTTEMP}/${DIFFUTILS_PATH}/.extracted


${EXTTEMP}/${DIFFUTILS_PATH}-htc/Makefile:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${DIFFUTILS_PATH}-htc ] || rm -rf ${EXTTEMP}/${DIFFUTILS_PATH}-htc
	mv ${EXTTEMP}/${DIFFUTILS_PATH} ${EXTTEMP}/${DIFFUTILS_PATH}-htc
	(  cd ${EXTTEMP}/${DIFFUTILS_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	)	|| exit 1

${EXTTEMP}/${DIFFUTILS_PATH}-xdc/Makefile:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}/.extracted
	[ ! -d ${EXTTEMP}/${DIFFUTILS_PATH}-xdc ] || rm -rf ${EXTTEMP}/${DIFFUTILS_PATH}-xdc
	mv ${EXTTEMP}/${DIFFUTILS_PATH} ${EXTTEMP}/${DIFFUTILS_PATH}-xdc
	( cd ${EXTTEMP}/${DIFFUTILS_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr \
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

${EXTTEMP}/${DIFFUTILS_PATH}-htc/src/diff:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${DIFFUTILS_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1

${EXTTEMP}/${DIFFUTILS_PATH}-xdc/src/diff:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${DIFFUTILS_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

${HTC_ROOT}/usr/bin/diff:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}-htc/src/diff
	( cd ${EXTTEMP}/${DIFFUTILS_PATH}-htc || exit 1 ;\
		make install-exec-recursive || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${DIFFUTILS_PKG} ${DIFFUTILS_VER}
endif

${DIFFUTILS_INSTTEMP}/usr/bin/diff:
	${MAKE} ${EXTTEMP}/${DIFFUTILS_PATH}-xdc/src/diff
	( cd ${EXTTEMP}/${DIFFUTILS_PATH}-xdc || exit 1 ;\
		make DESTDIR=${DIFFUTILS_INSTTEMP} install || exit 1 \
	) || exit 1

${TOPLEV}/${DIFFUTILS_EGPNAME}.egp: ${DIFFUTILS_INSTTEMP}/usr/bin/diff
	${PCREATE_SCRIPT} create ${TOPLEV}/${DIFFUTILS_EGPNAME}.egp ${DIFFUTILS_INSTTEMP}

${XDC_ROOT}/usr/bin/diff: ${TOPLEV}/${DIFFUTILS_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	STRIP=${TARGET_SPEC}-strip ${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${DIFFUTILS_EGPNAME}.egp

REALCLEAN_TARGETS+= ${TOPLEV}/${DIFFUTILS_EGPNAME}.egp



# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-diffutils
htc-diffutils: ${HTC_ROOT}/usr/bin/diff

.PHONY: xdc-diffutils
ifeq (${MAKE_CHROOT},y)
xdc-patch: ${XDC_ROOT}/usr/bin/diff
else
xdc-patch: ${TOPLEV}/${DIFFUTILS_EGPNAME}.egp
endif
