# gzip 1.3.12			[ since 1.2.4a, c. 2007-04-18 ]
# last mod WmT, 2011-01-19	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

GZIP_PKG:=gzip
#GZIP_VER:=1.2.4a
GZIP_VER:=1.3.12

GZIP_SRC+=${SOURCEROOT}/g/gzip-${GZIP_VER}.tar.gz

GZIP_PATH:=gzip-${GZIP_VER}
GZIP_INSTTEMP:=${EXTTEMP}/${GZIP_PATH}-insttemp
GZIP_EGPNAME:=gzip-${GZIP_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/gzip/gzip-${GZIP_VER}.tar.gz

#DEPS:=

# ,-----
# |	Configure [htc, xdc]
# +-----

#${EXTTEMP}/${GZIP_PATH}-htc/.configured:
#	[ ! -d ${EXTTEMP}/${GZIP_PATH} ] || rm -rf ${EXTTEMP}/${GZIP_PATH}
#	${MAKE} extract LIST="$(strip ${GZIP_SRC})"
##	echo "*** PATCHING ***"
##	( cd ${EXTTEMP} || exit 1 ;\
##		for PF in ${GZIP_PKG}*patch ; do \
##			cat $${PF} | ( cd ${GZIP_PATH} && patch -Np1 -i - ) ;\
##			rm -f $${PF} ;\
##		done \
##	) || exit 1
#	[ ! -d ${EXTTEMP}/${GZIP_PATH}-htc ] || rm -rf ${EXTTEMP}/${GZIP_PATH}-htc
#	mv ${EXTTEMP}/${GZIP_PATH} ${EXTTEMP}/${GZIP_PATH}-htc
#	( cd ${EXTTEMP}/${GZIP_PATH}-htc || exit 1 ;\
#	  	CC=${NATIVE_GCC} \
#	    	  CFLAGS=-O2 \
#			./configure \
#			  --prefix=${HTC_ROOT}/usr \
#			  --disable-largefile --disable-nls \
#			  || exit 1 \
#	) || exit 1
#	touch ${EXTTEMP}/${GZIP_PATH}-htc/.configured

${EXTTEMP}/${GZIP_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${GZIP_PATH} ] || rm -rf ${EXTTEMP}/${GZIP_PATH}
	${MAKE} extract LIST="$(strip ${GZIP_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${GZIP_PKG}*patch ; do \
#			cat $${PF} | ( cd ${GZIP_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${GZIP_PATH}-xdc ] || rm -rf ${EXTTEMP}/${GZIP_PATH}-xdc
	mv ${EXTTEMP}/${GZIP_PATH} ${EXTTEMP}/${GZIP_PATH}-xdc
	( cd ${EXTTEMP}/${GZIP_PATH}-xdc || exit 1 ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=/usr \
			  --host=$(shell echo ${NATIVE_SPEC} | sed 's/-gnulibc1//') \
			  --build=${TARGET_SPEC} \
			  --disable-largefile --disable-nls \
			  --without-included-regex \
			  || exit 1 ;\
		case ${GZIP_VER} in \
		1.2.4*) \
			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
			cat Makefile.OLD \
				| sed '/^	/ s%$$(prefix)%$${DESTDIR}/$$(prefix)%g' \
				| sed '/^	/ s%$$(bindir)%$${DESTDIR}/$$(bindir)%g' \
				| sed '/^	/ s%$$(mandir)%$${DESTDIR}/$$(mandir)%g' \
				| sed '/^	/ s%$$(infodir)%$${DESTDIR}/$$(infodir)%g' \
				| sed '/^	/ s%$$(scriptdir)%$${DESTDIR}/$$(scriptdir)%g' \
				| sed '/^	/ s%$$$${dir}%$${DESTDIR}/$${dir}%' \
				> Makefile || exit 1 \
		;; \
		esac \
	) || exit 1


# ,-----
# |	Build [xdc]
# +-----

${EXTTEMP}/${GZIP_PATH}-xdc/gzip: ${EXTTEMP}/${GZIP_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${GZIP_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

${GZIP_INSTTEMP}/usr/bin/gzip:
	${MAKE} ${EXTTEMP}/${GZIP_PATH}-xdc/gzip
	mkdir -p ${GZIP_INSTTEMP}/usr/bin
	mkdir -p ${GZIP_INSTTEMP}/usr/info
	mkdir -p ${GZIP_INSTTEMP}/usr/man/man1
	( cd ${EXTTEMP}/${GZIP_PATH}-xdc || exit 1 ;\
		make DESTDIR=${GZIP_INSTTEMP} install || exit 1 \
	) || exit 1
	( cd ${GZIP_INSTTEMP} || exit 1 ;\
		for F in usr/bin/gunzip usr/bin/gzexe \
			usr/bin/uncompress usr/bin/zcat usr/bin/zcmp \
			usr/bin/zdiff usr/bin/zegrep usr/bin/zfgrep \
			usr/bin/zforce usr/bin/zgrep usr/bin/zless \
			usr/bin/zmore usr/bin/znew ; do \
			mv $${F} ${EXTTEMP}/${GZIP_PATH}-xdc/`basename $$F`.orig || exit 1 ;\
			sed 's%'${HTC_ROOT}'%% ; T a ; s%/bin/bash%/bin/sh% ; :a' ${EXTTEMP}/${GZIP_PATH}-xdc/`basename $$F`.orig > $${F} ;\
			chmod a+x $${F} || exit 1 ;\
		done \
	) || exit 1

${TOPLEV}/${GZIP_EGPNAME}.egp: ${GZIP_INSTTEMP}/usr/bin/gzip
	${PCREATE_SCRIPT} create ${TOPLEV}/${GZIP_EGPNAME}.egp ${GZIP_INSTTEMP}

${XDC_ROOT}/usr/bin/gzip: ${TOPLEV}/${GZIP_EGPNAME}.egp
	STRIP=${TARGET_SPEC}-strip ${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${GZIP_EGPNAME}.egp

REALCLEAN_TARGETS+= ${TOPLEV}/${GZIP_EGPNAME}.egp


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-gzip
ifeq (${MAKE_CHROOT},y)
xdc-gzip: ${XDC_ROOT}/usr/bin/gzip
else
xdc-gzip: ${TOPLEV}/${GZIP_EGPNAME}.egp
endif
