# gcc 2.95.3-2
# last mod WmT, 21/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

HOST_GCC_PKG:=gcc
HOST_GCC_VER:=2.95.3
#HOST_GCC_VER:=4.1.1

HOST_GCC_SRC+=${SOURCEROOT}/g/gcc-${HOST_GCC_VER}.tar.gz
HOST_GCC_SRC+=${SOURCEROOT}/g/gcc-${HOST_GCC_VER}-2.patch
#HOST_GCC_SRC+=${SOURCEROOT}/g/gcc-core-${HOST_GCC_VER}.tar.bz2
#HOST_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/10_uclibc-conf.diff
#HOST_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/20_uclibc-locale.diff
#HOST_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/21_uclibc-locale-snprintf-c99-fix.diff
#HOST_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/22_libstdc-index-macro.diff
#HOST_GCC_SRC+=${TOPLEV}/gb-patches/gcc/patches/30_fastmath-fxsave.diff

HOST_GCC_PATH:=gcc-${HOST_GCC_VER}

URLS+=?
URLS+=http://www.linuxfromscratch.org/patches/downloads/gcc/gcc-2.95.3-2.patch
#URLS+= http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/gcc-4.1.1/gcc-core-4.1.1.tar.bz2

#DEPS:=
#DEPS+=cmp, diff
#DEPS+=mawk
#DEPS+=bison, yacc

# ,-----
# |	Configure [htc, xdc]
# +-----

ifeq (${TARGET_CPU},mipsel)
HOST_GCC_ARCH_OPTS:=--with-arch=mips32
endif
ifeq (${TARGET_CPU},mips)
HOST_GCC_ARCH_OPTS:=--with-arch=mips32
endif


${EXTTEMP}/${HOST_GCC_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${HOST_GCC_PATH} ] || rm -rf ${EXTTEMP}/${HOST_GCC_PATH}
	${MAKE} extract LIST="$(strip ${HOST_GCC_SRC})"
	( cd ${EXTTEMP}/ || exit 1 ;\
		for PF in gcc*patch ; do \
			cat $${PF} | ( cd ${HOST_GCC_PATH} && patch -Np1 -i - ) ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	mkdir -p ${EXTTEMP}/${HOST_GCC_PATH}-htc
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-htc || exit 1 ;\
		CC=${NATIVE_GCC} \
			../${HOST_GCC_PATH}/configure -v \
			  --prefix=${HTC_ROOT}/usr \
			  --host=${NATIVE_SPEC} \
			  --target=${NATIVE_SPEC} \
			  --with-local-prefix=${HTC_ROOT}/usr \
			  --enable-languages=c \
			  --disable-nls \
			  --enable-shared \
			  || exit 1 \
	) || exit 1


# --with-headers and --with-libs specify dirs to copy FROM
${EXTTEMP}/${HOST_GCC_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${HOST_GCC_PATH} ] || rm -rf ${EXTTEMP}/${HOST_GCC_PATH}
	${MAKE} extract LIST="$(strip ${HOST_GCC_SRC})"
	( cd ${EXTTEMP}/${HOST_GCC_PATH} || exit 1 ;\
		for PF in gcc*patch ; do \
			cat $${PF} | ( cd ${KGCC_PATH} && patch -Np1 -i - ) ;\
			rm -f $${PF} ;\
		done \
	) || exit 1
	mkdir -p ${EXTTEMP}/${HOST_GCC_PATH}-xdc
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
		  CC_FOR_BUILD=${HTC_GCC} \
		  HOSTCC=${HTC_GCC} \
		  GCC_FOR_TARGET=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
	  	  AR=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ar \
	  	  AS=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-as \
	  	  LD=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ld \
	  	  NM=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-nm \
	  	  RANLIB=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ranlib \
	    	  CFLAGS=-O2 \
			../${HOST_GCC_PATH}/configure -v \
			  --prefix=${XDC_INSTTEMP}/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${TARGET_SPEC} \
			  --target=${TARGET_SPEC} \
			  ${HOST_GCC_ARCH_OPTS} \
			  --disable-multilib \
			  --with-headers=${XDC_INSTTEMP}'/usr/'${TARGET_SPEC}'/usr/include' \
			  --with-libs=${XDC_INSTTEMP}'/usr/'${TARGET_SPEC}'/usr/lib' \
			  --program-transform-cross-name='s,x,x,' \
			  --with-sysroot=/ \
			  --with-build-sysroot=/ \
			  --enable-languages=c \
			  --disable-nls \
			  --enable-shared \
			  --with-gnu-as \
			  --with-gnu-ld \
			  || exit 1 ;\
		find ./ -name Makefile | while read MF ; do \
			mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed ' /LANGUAGES=/	s/ c++// ; /^gcc_tooldir/ s%..target_alias.%% ; /^SYSTEM_HEADER_DIR/ s%..tooldir./sys%/usr/% ' \
				| sed ' /^MAKEINFO[ 	]*=/	s/makeinfo/echo/' \
				| sed ' /INSTALL_DATA.*info/	s/;/; true;/' \
				> $${MF} || exit 1 ;\
		done \
	) || exit 1


# ,-----
# |	Build [htc, xdc]
# +-----

${EXTTEMP}/${HOST_GCC_PATH}-htc/libiberty/libiberty.a: ${EXTTEMP}/${HOST_GCC_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1

${EXTTEMP}/${HOST_GCC_PATH}-xdc/libiberty/libiberty.a: ${EXTTEMP}/${HOST_GCC_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-xdc || exit 1 ;\
		make all-gcc prefix=/usr || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

ifeq (${HAVE_GLIBC_SYSTEM},y)
${HTC_ROOT}/usr/bin/${NATIVE_SPEC}-gcc:
	${MAKE} ${EXTTEMP}/${HOST_GCC_PATH}-htc/libiberty/libiberty.a
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-htc || exit 1 ;\
		make install-gcc || exit 1 \
	) || exit 1
else
${HTC_ROOT}/usr/bin/${NATIVE_SPEC}-gcc:
	${MAKE} ${EXTTEMP}/${HOST_GCC_PATH}-htc/libiberty/libiberty.a
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-htc || exit 1 ;\
		make install-gcc || exit 1 ;\
		cat gcc/specs \
			| sed	'	s/ld-linux.so.2/ld-uClibc.so.0/ ; /cross_compile/,+2 s/1/0/ ' > ${XTC_ROOT}/usr/lib/gcc-lib/`echo ${NATIVE_SPEC} | sed 's/-gnulibc1//'`/${HOST_GCC_VER}/specs || exit 1 ;\
	) || exit 1
endif
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade host-gcc ${HOST_GCC_VER}
endif

${XDC_INSTTEMP}/usr/bin/gcc:
	${MAKE} ${EXTTEMP}/${HOST_GCC_PATH}-xdc/libiberty/libiberty.a
	( cd ${EXTTEMP}/${HOST_GCC_PATH}-xdc || exit 1 ;\
		make install prefix=${XDC_INSTTEMP}/usr || exit 1 ;\
		cat gcc/specs \
			| sed	'	s/ld-linux.so.2/ld-uClibc.so.0/ ; /cross_compile/,+2 s/1/0/ ' > ${XDC_INSTTEMP}/usr/lib/gcc-lib/${TARGET_SPEC}/${HOST_GCC_VER}/specs || exit 1 ;\
	) || exit 1

${TOPLEV}/${HOST_GCC_PKG}-${HOST_GCC_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/usr/bin/gcc
#	tar cvzf ${HOST_GCC_PKG}-${HOST_GCC_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create gcc-${HOST_GCC_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}


# ,-----
# |	Entry points [htc]
# +-----

#	${HTC_ROOT}/bin/${TARGET_SPEC}-gcc -dM -E - < /dev/null
.PHONY: htc-host-gcc
htc-host-gcc: ${HTC_ROOT}/usr/bin/${NATIVE_SPEC}-gcc

.PHONY: xdc-host-gcc
ifeq (${MAKE_CHROOT},y)
xdc-host-gcc: ${XDC_INSTTEMP}/usr/bin/gcc
else
xdc-host-gcc: ${TOPLEV}/${HOST_GCC_PKG}-${HOST_GCC_VER}.egp
endif
