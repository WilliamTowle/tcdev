# gcc 4.2.0
# last mod WmT, 2007-08-06	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

KGCC_PKG:=gcc
KGCC_VER:=4.1.2
#KGCC_VER:=4.2.0
KGCC_PATH:=gcc-${KGCC_VER}

KGCC_SRC:=

#KGCC_SRC+=${SOURCEROOT}/g/gcc-${KGCC_VER}.tar.bz2
KGCC_SRC+=${SOURCEROOT}/g/gcc-core-${KGCC_VER}.tar.bz2
URLS+= http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/gcc-${KGCC_VER}/gcc-core-${KGCC_VER}.tar.bz2

ifeq (${KGCC_VER},4.1.1)
KGCC_SRC+=${SOURCEROOT}/g/gcc-4.1.1-uclibc-patches-1.1.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.1.1-uclibc-patches-1.1.tar.bz2
endif
ifeq (${KGCC_VER},4.1.2)
KGCC_SRC+=${SOURCEROOT}/g/gcc-4.1.2-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.1.2-uclibc-patches-1.0.tar.bz2
endif
ifeq (${KGCC_VER},4.1.2)
KGCC_SRC+=${SOURCEROOT}/g/gcc-4.1.2-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.1.2-uclibc-patches-1.0.tar.bz2
endif
ifeq (${KGCC_VER},4.2.0)
KGCC_SRC+=${SOURCEROOT}/g/gcc-4.2.0-uclibc-patches-1.0.tar.bz2
URLS+=http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/gcc-4.2.0-uclibc-patches-1.0.tar.bz2
endif

#DEPS:=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [xtc]
# +-----

#ifeq (${TARGET_CPU},mipsel)
#KGCC_ARCH_OPTS:=--with-arch=mips32
#endif
#ifeq (${TARGET_CPU},mips)
#KGCC_ARCH_OPTS:=--with-arch=mips32
#endif

KGCC_NATIVE_SPEC:=$(shell echo ${NATIVE_SPEC} | sed 's/-host-/-pc-/')
KGCC_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/')

# --with-newlib is a hack for GCC <= 3.3.x
${EXTTEMP}/kgcc-${KGCC_VER}-xtc/Makefile:
	[ ! -d ${EXTTEMP}/${KGCC_PATH} ] || rm -rf ${EXTTEMP}/${KGCC_PATKGCC_PATH}
	${MAKE} extract LIST="$(strip ${KGCC_SRC})"
	echo "*** PATCHING ***"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in uclibc/*patch ; do \
			patch --batch -d ${KGCC_PATH} -Np1 < $${PF} ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	[ ! -d ${EXTTEMP}/kgcc-${KGCC_VER}-xtc ] || rm -rf ${EXTTEMP}/kgcc-${KGCC_VER}-xtc
	mv ${EXTTEMP}/${KGCC_PATH} ${EXTTEMP}/kgcc-${KGCC_VER}-xtc
	( cd ${EXTTEMP}/kgcc-${KGCC_VER}-xtc || exit 1 ;\
		CC=${HTC_GCC} \
			./configure -v \
			  --prefix=${XTC_ROOT}/usr \
			  --target=`echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'` \
			  ${KGCC_ARCH_OPTS} \
			  --enable-languages=c \
			  --disable-nls \
			  --disable-shared \
			  --disable-threads \
			  --without-headers \
			  --with-gnu-ld \
			  --with-gnu-as \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [xtc]
# +-----

${EXTTEMP}/kgcc-${KGCC_VER}-xtc/host-${KGCC_NATIVE_SPEC}/libiberty/libiberty.a: ${EXTTEMP}/kgcc-${KGCC_VER}-xtc/Makefile
	( cd ${EXTTEMP}/kgcc-${KGCC_VER}-xtc || exit 1 ;\
		make all-gcc || exit 1 \
	) || exit 1


# ,-----
# |	Install [xtc]
# +-----

#	${XTC_ROOT}/bin/${TARGET_SPEC}-gcc -dM -E - < /dev/null
${XTC_ROOT}/usr/bin/${KGCC_TARGET_SPEC}-gcc:
	${MAKE} ${EXTTEMP}/kgcc-${KGCC_VER}-xtc/host-${KGCC_NATIVE_SPEC}/libiberty/libiberty.a
	mkdir -p ${XTC_ROOT}/usr/`echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`/bin
	( cd ${EXTTEMP}/kgcc-${KGCC_VER}-xtc || exit 1 ;\
	  	make install-gcc || exit 1 ;\
		for EXE in addr2line ar as c++filt ld nm \
			objcopy objdump ranlib readelf size \
			strings strip ; do \
			( cd ${XTC_ROOT}/usr/bin && ln -sf ${TARGET_SPEC}-$${EXE} `echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`-$${EXE} ) || exit 1 ;\
			( cd ${XTC_ROOT}/usr/`echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/'`/bin && ln -sf ../../${TARGET_SPEC}/bin/$${EXE} ./ ) || exit 1 ;\
		done \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade kgcc ${KGCC_VER}
endif

# ,-----
# |	Entry points [htc]
# +-----

#	${XTC_ROOT}/bin/${TARGET_SPEC}-gcc -dM -E - < /dev/null
.PHONY: xtc-kgcc
xtc-kgcc: ${XTC_ROOT}/usr/bin/${KGCC_TARGET_SPEC}-gcc
