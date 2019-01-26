# gzip 1.3.12			[ 1.2.4a ]
# last mod WmT, 18/04/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

GZIP_PKG:=gzip
#GZIP_VER:=1.2.4a
GZIP_VER:=1.3.12

GZIP_SRC+=${SOURCEROOT}/g/gzip-${GZIP_VER}.tar.gz

GZIP_PATH:=gzip-${GZIP_VER}

URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/pub/gnu/gzip/gzip-${GZIP_VER}.tar.gz

#DEPS:=

# ,-----
# |	Configure [htc, xdc]
# +-----

#${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc/.configured:
#	[ ! -d ${EXTTEMP}/${GZIP_PATH} ] || rm -rf ${EXTTEMP}/${GZIP_PATH}
#	${MAKE} extract LIST="$(strip ${GZIP_SRC})"
##	echo "*** PATCHING ***"
##	( cd ${EXTTEMP} || exit 1 ;\
##		for PF in ${GZIP_PKG}*patch ; do \
##			cat $${PF} | ( cd ${GZIP_PATH} && patch -Np1 -i - ) ;\
##			rm -f $${PF} ;\
##		done \
##	) || exit 1
#	[ ! -d ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc ] || rm -rf ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc
#	mv ${EXTTEMP}/${GZIP_PATH} ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc
#	( cd ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc || exit 1 ;\
#	  	CC=${NATIVE_GCC} \
#	    	  CFLAGS=-O2 \
#			./configure \
#			  --prefix=${HTC_ROOT}/usr \
#			  --disable-largefile --disable-nls \
#			  || exit 1 \
#	) || exit 1
#	touch ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc/.configured

${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${GZIP_PATH} ] || rm -rf ${EXTTEMP}/${GZIP_PATH}
	${MAKE} extract LIST="$(strip ${GZIP_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${GZIP_PKG}*patch ; do \
#			cat $${PF} | ( cd ${GZIP_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc ] || rm -rf ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc
	mv ${EXTTEMP}/${GZIP_PATH} ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc
	( cd ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc || exit 1 ;\
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
# |	Build [htc, xdc]
# +-----

#${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc/.built: ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc/.configured
#	( cd ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc || exit 1 ;\
#		make || exit 1 \
#	) || exit 1

${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc/gzip: ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc/Makefile
	( cd ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc, xdc]
# +-----

#.PHONY: htc-gzip
#htc-gzip: ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc/.built
#	( cd ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc || exit 1 ;\
#		make installdirs installbin || exit 1 \
#	) || exit 1

${XDC_INSTTEMP}/usr/bin/gzip:
	${MAKE} ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc/gzip
	mkdir -p ${XDC_INSTTEMP}/usr/bin
	mkdir -p ${XDC_INSTTEMP}/usr/info
	mkdir -p ${XDC_INSTTEMP}/usr/man/man1
	( cd ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-xdc || exit 1 ;\
		make DESTDIR=${XDC_INSTTEMP} install || exit 1 \
	) || exit 1

${TOPLEV}/${GZIP_PKG}-${GZIP_VER}.tgz:
	${MAKE} ${XDC_INSTTEMP}/usr/bin/gzip
#	tar cvzf ${GZIP_PKG}-${GZIP_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create ${GZIP_PKG}-${GZIP_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}


# ,-----
# |	Entry points [xdc]
# +-----

#.PHONY: htc-gzip
#htc-gzip: ${EXTTEMP}/${GZIP_PKG}-${GZIP_VER}-htc/.built

.PHONY: xdc-gzip
ifeq (${MAKE_CHROOT},y)
xdc-gzip: ${XDC_INSTTEMP}/usr/bin/gzip
else
xdc-gzip: ${TOPLEV}/${GZIP_PKG}-${GZIP_VER}.tgz
endif
