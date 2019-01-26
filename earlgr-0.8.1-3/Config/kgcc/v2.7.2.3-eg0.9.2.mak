# gcc 2.7.2.3
# last mod WmT, 20/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

KGCC2723_PKG:=gcc
KGCC2723_VER:=2.7.2.3

KGCC2723_SRC:=
KGCC2723_SRC+=${SOURCEROOT}/g/gcc-${KGCC2723_VER}.tar.gz

KGCC2723_PATH:=gcc-${KGCC2723_VER}

URLS+= http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/gcc-2.7.2.3.tar.gz
#URLS+=http://www.linuxfromscratch.org/patches/downloads/gcc/gcc-2.95.3-2.patch

#DEPS:=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [xtc]
# +-----

#ifeq (${TARGET_CPU},mipsel)
#ARCH_OPTS:=--with-arch=mips32
#endif
#ifeq (${TARGET_CPU},mips)
#ARCH_OPTS:=--with-arch=mips32
#endif

${EXTTEMP}/${KGCC2723_PATH}/.extracted:
	[ ! -d ${EXTTEMP}/${KGCC2723_PATH} ] || rm -rf ${EXTTEMP}/${KGCC2723_PATH}
	${MAKE} extract LIST="$(strip ${KGCC2723_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in gcc*patch ; do \
#			cat $${PF} | ( cd ${KGCC2723_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	touch ${EXTTEMP}/${KGCC2723_PATH}/.extracted

${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc/Makefile:
	${MAKE} ${EXTTEMP}/${KGCC2723_PATH}/.extracted
	[ ! -d ${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc ] || rm -rf ${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc
	mv ${EXTTEMP}/${KGCC2723_PATH} ${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc
	( cd ${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc || exit 1 ;\
		CC=${HTC_GCC} \
			./configure \
			  --prefix=${XTC_ROOT}/usr \
			  --local-prefix=${XTC_ROOT}/usr \
			  --program-prefix=${TARGET_CPU}-linux-${KGCC2723_VER}-gnu-k \
		  	  --build=${TARGET_CPU}-linux \
		  	  --target=${TARGET_CPU}-linux \
			  --enable-languages=c \
			  --disable-shared \
			  --disable-__cxa_atexit \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [xtc]
# +-----

${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc/c++filt: ${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc/Makefile
	( cd ${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc || exit 1 ;\
		make CC=${HTC_GCC} OLDCC=${HTC_GCC} || exit 1 \
	) || exit 1


# ,-----
# |	Install [xtc]
# +-----

#	${XTC_ROOT}/bin/${TARGET_SPEC}-gcc -dM -E - < /dev/null
${XTC_ROOT}/usr/bin/i386-linux-2.7.2.3-gnu-kgcc:
	${MAKE} ${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc/c++filt
	( cd ${EXTTEMP}/kgcc-${KGCC2723_VER}-xtc || exit 1 ;\
		CDPATH='' make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade kgcc2723 ${KGCC2723_VER}
endif

# ,-----
# |	Entry points [xtc]
# +-----

#	${XTC_ROOT}/bin/${TARGET_SPEC}-gcc -dM -E - < /dev/null
.PHONY: xtc-kgcc2723
xtc-kgcc2723: ${XTC_ROOT}/usr/bin/i386-linux-2.7.2.3-gnu-kgcc
