# ncurses 5.6			[ EARLIEST v5.2 ]
# last mod WmT, 21/05/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

NCURSES_PKG:=ncurses
NCURSES_VER:=5.6

NCURSES_SRC+=${SOURCEROOT}/n/${NCURSES_PKG}-${NCURSES_VER}.tar.gz
#NCURSES_SRC+=${SOURCEROOT}/n/${NCURSES_PKG}-5.5-fixes-1.patch

NCURSES_PATH:=${NCURSES_PKG}-${NCURSES_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/ncurses/${NCURSES_PKG}-${NCURSES_VER}.tar.gz
#URLs+=http://www.linuxfromscratch.org/patches/downloads/ncurses/${NCURSES_PKG}-5.5-fixes-1.patch

# ,-----
# |	Configure [xdc]
# +-----


${EXTTEMP}/${NCURSES_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${NCURSES_PATH} ] || rm -rf ${EXTTEMP}/${NCURSES_PATH}
	${MAKE} extract LIST="$(strip ${NCURSES_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${NCURSES_PKG}*patch ; do \
#			cat $${PF} | ( cd ${NCURSES_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${NCURSES_PATH}-xdc ] || rm -rf ${EXTTEMP}/${NCURSES_PATH}-xdc
	mv ${EXTTEMP}/${NCURSES_PATH} ${EXTTEMP}/${NCURSES_PATH}-xdc
	( cd ${EXTTEMP}/${NCURSES_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
	  	  AR=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-ar \
		  ac_cv_func_nanosleep=no \
		  ac_cv_func_setvbuf_reversed=no \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${TARGET_SPEC} \
			  --target=${TARGET_SPEC} \
			  --with-build-cc=${HTC_GCC} \
			  --with-build-cflags='' --with-build-ldflags='' \
			  --with-build-libs='' \
			  --without-ada --without-debug --without-cxx-binding \
			  --disable-largefile --disable-nls \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [xdc]
# +-----

${EXTTEMP}/${NCURSES_PATH}-xdc/lib/libncurses.a: ${EXTTEMP}/${NCURSES_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${NCURSES_PATH}-xdc || exit 1 ;\
		make all || exit 1 \
	) || exit 1

# ,-----
# |	Install [xdc]
# +-----

${XDC_INSTTEMP}/usr/lib/libncurses.a:
ifeq (${HAVE_GLIBC5_SYSTEM}${HAVE_GLIBC_SYSTEM},nn)
	${MAKE} ${EXTTEMP}/${NCURSES_PATH}-xdc/lib/libncurses.a
	( cd ${EXTTEMP}/${NCURSES_PATH}-xdc || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install.libs || exit 1 ;\
		[ -r  misc/run_tic.sh.OLD ] || mv misc/run_tic.sh misc/run_tic.sh.OLD || exit 1 ;\
		cat misc/run_tic.sh.OLD \
			| sed 's%LIB tic%LIB ../progs/tic%' \
			> misc/run_tic.sh || exit 1 ;\
		( cd progs ; rm tic ; make CC=${HTC_GCC} tic ) || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install.data || exit 1 \
	) || exit 1
else
	${MAKE} ${EXTTEMP}/${NCURSES_PATH}-xdc/lib/libncurses.a
	( cd ${EXTTEMP}/${NCURSES_PATH}-xdc || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install.libs || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install.data || exit 1 \
	) || exit 1
endif

${TOPLEV}/${NCURSES_PKG}-${NCURSES_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/usr/lib/libncurses.a
#	tar cvzf ${NCURSES_PKG}-${NCURSES_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create ${NCURSES_PKG}-${NCURSES_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-ncurses
ifeq (${MAKE_CHROOT},y)
xdc-ncurses: ${XDC_INSTTEMP}/usr/lib/libncurses.a
else
xdc-ncurses: ${TOPLEV}/${NCURSES_PKG}-${NCURSES_VER}.egp
endif
