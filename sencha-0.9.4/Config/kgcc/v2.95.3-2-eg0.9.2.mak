# gcc 2.95.3-2
# last mod WmT, 21/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

KGCC_PKG:=gcc
KGCC_VER:=2.95.3
#KGCC_VER:=4.1.1

KGCC_SRC+=${SOURCEROOT}/g/gcc-${KGCC_VER}.tar.gz
KGCC_SRC+=${SOURCEROOT}/g/gcc-${KGCC_VER}-2.patch
#KGCC_SRC+=${SOURCEROOT}/g/gcc-core-${KGCC_VER}.tar.bz2
#KGCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/10_uclibc-conf.diff
#KGCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/20_uclibc-locale.diff
#KGCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/21_uclibc-locale-snprintf-c99-fix.diff
#KGCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/22_libstdc-index-macro.diff
#KGCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/30_fastmath-fxsave.diff

KGCC_PATH:=gcc-${KGCC_VER}

URLS+=?
URLS+=http://www.linuxfromscratch.org/patches/downloads/gcc/gcc-2.95.3-2.patch
#URLS+= http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/gcc-4.1.1/gcc-core-4.1.1.tar.bz2


#DEPS:=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [xtc]
# +-----

ifeq (${TARGET_CPU},mipsel)
KGCC_ARCH_OPTS:=--with-arch=mips32
endif
ifeq (${TARGET_CPU},mips)
KGCC_ARCH_OPTS:=--with-arch=mips32
endif

KGCC_TARGET_SPEC:=$(shell echo ${TARGET_SPEC} | sed 's/-[^-]*-/-xnc_k-/')

# --with-newlib is a hack for GCC <= 3.3.x
${EXTTEMP}/kgcc-${KGCC_VER}-xtc/Makefile:
	[ ! -d ${EXTTEMP}/${KGCC_PATH} ] || rm -rf ${EXTTEMP}/${KGCC_PATH}
	${MAKE} extract LIST="$(strip ${KGCC_SRC})"
	( cd ${EXTTEMP} || exit 1 ;\
		for PF in gcc*patch ; do \
			cat $${PF} | ( cd ${KGCC_PATH} && patch -Np1 -i - ) ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	mkdir -p ${EXTTEMP}/kgcc-${KGCC_VER}-xtc
	( cd ${EXTTEMP}/kgcc-${KGCC_VER}-xtc || exit 1 ;\
		CC=${HTC_GCC} \
			../${KGCC_PATH}/configure -v \
			  --prefix=${XTC_ROOT}/usr \
			  --target=${KGCC_TARGET_SPEC} \
			  ${KGCC_ARCH_OPTS} \
			  --enable-languages=c \
			  --disable-nls \
			  --enable-shared \
			  --without-headers \
			  --with-newlib \
			  || exit 1\
	) || exit 1


# ,-----
# |	Build [xtc]
# +-----

${EXTTEMP}/kgcc-${KGCC_VER}-xtc/libiberty/libiberty.a: ${EXTTEMP}/kgcc-${KGCC_VER}-xtc/Makefile
	( cd ${EXTTEMP}/kgcc-${KGCC_VER}-xtc || exit 1 ;\
		make all-gcc || exit 1 \
	) || exit 1


# ,-----
# |	Install [xtc]
# +-----

${XTC_ROOT}/usr/bin/${KGCC_TARGET_SPEC}-gcc:
	${MAKE} ${EXTTEMP}/kgcc-${KGCC_VER}-xtc/libiberty/libiberty.a
	mkdir -p ${XTC_ROOT}/usr/${KGCC_TARGET_SPEC}/bin
	( cd ${EXTTEMP}/kgcc-${KGCC_VER}-xtc || exit 1 ;\
	  	make install-gcc || exit 1 ;\
		for EXE in addr2line ar as c++filt ld nm \
			objcopy objdump ranlib readelf size \
			strings strip ; do \
			( cd ${XTC_ROOT}/usr/bin && ln -sf ${TARGET_SPEC}-$${EXE} ${KGCC_TARGET_SPEC}-$${EXE} ) || exit 1 ;\
			( cd ${XTC_ROOT}/usr/${KGCC_TARGET_SPEC}/bin && ln -sf ../../${TARGET_SPEC}/bin/$${EXE} ./ ) || exit 1 ;\
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
