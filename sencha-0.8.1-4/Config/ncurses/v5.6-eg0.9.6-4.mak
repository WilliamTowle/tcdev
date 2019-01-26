# ncurses 5.6			[ since v5.2, c.2007-01-20 ]
# last mod WmT, 2011-01-19	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

NCURSES_PKG:=ncurses
NCURSES_VER:=5.6

NCURSES_SRC+=${SOURCEROOT}/n/${NCURSES_PKG}-${NCURSES_VER}.tar.gz
#NCURSES_SRC+=${SOURCEROOT}/n/${NCURSES_PKG}-5.5-fixes-1.patch

NCURSES_PATH:=${NCURSES_PKG}-${NCURSES_VER}
NCURSES_INSTTEMP:=${EXTTEMP}/${NCURSES_PATH}-insttemp
NCURSES_EGPNAME:=${NCURSES_PKG}-${NCURSES_VER}

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

${NCURSES_INSTTEMP}/usr/include/ncurses.h:
	${MAKE} ${EXTTEMP}/${NCURSES_PATH}-xdc/lib/libncurses.a
ifeq (${HAVE_GLIBC5_SYSTEM}${HAVE_GLIBC_SYSTEM},nn)
	( cd ${EXTTEMP}/${NCURSES_PATH}-xdc || exit 1 ;\
		make DESTDIR=${NCURSES_INSTTEMP} install.libs || exit 1 ;\
		[ -r  misc/run_tic.sh.OLD ] || mv misc/run_tic.sh misc/run_tic.sh.OLD || exit 1 ;\
		cat misc/run_tic.sh.OLD \
			| sed 's%LIB tic%LIB ../progs/tic%' \
			> misc/run_tic.sh || exit 1 ;\
		( cd progs ; rm tic ../objects/tic.o ../objects/dump_entry.o ; make CC=${HTC_GCC} tic ) || exit 1 ;\
		make DESTDIR=${NCURSES_INSTTEMP} install.data || exit 1 \
	) || exit 1
else
	( cd ${EXTTEMP}/${NCURSES_PATH}-xdc || exit 1 ;\
		make DESTDIR=${NCURSES_INSTTEMP} install.libs || exit 1 ;\
		make DESTDIR=${NCURSES_INSTTEMP} install.data || exit 1 \
	) || exit 1
endif

${TOPLEV}/${NCURSES_EGPNAME}.egp: ${NCURSES_INSTTEMP}/usr/include/ncurses.h
	${PCREATE_SCRIPT} create ${TOPLEV}/${NCURSES_EGPNAME}.egp ${NCURSES_INSTTEMP}

# ncurses: 'egp' maintains the dates from the archive
${XDC_ROOT}/usr/include/ncurses.h: ${TOPLEV}/${NCURSES_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	STRIP=${TARGET_SPEC}-strip ${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${NCURSES_EGPNAME}.egp
	touch $@

REALCLEAN_TARGETS+= ${TOPLEV}/${NCURSES_EGPNAME}.egp


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-ncurses
ifeq (${MAKE_CHROOT},y)
xdc-ncurses: ${XDC_ROOT}/usr/include/ncurses.h
else
xdc-ncurses: ${TOPLEV}/${NCURSES_EGPNAME}.egp
endif
