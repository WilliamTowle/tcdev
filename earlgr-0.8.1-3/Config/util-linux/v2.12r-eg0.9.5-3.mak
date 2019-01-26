# util-linux 2.12r		[ since 2005-11-29 ]
# last mod WmT, 2009-02-12	[ (c) and GPLv2 1999-2009 ]

# ,-----
# |	Settings
# +-----

UTILLX_PKG:=util-linux
UTILLX_VER:=2.12r

UTILLX_SRC:=
UTILLX_SRC+=${SOURCEROOT}/u/util-linux-${UTILLX_VER}.tar.bz2

UTILLX_PATH:=util-linux-${UTILLX_VER}
UTILLX_INSTTEMP:=${EXTTEMP}/${UTILLX_PATH}-insttemp
UTILLX_EGPNAME:=${UTILLX_PKG}-${UTILLX_VER}

URLS+=http://ftp.kernel.org/pub/linux/utils/util-linux/util-linux-${UTILLX_VER}.tar.bz2

#DEPS:=

# ,-----
# |	Configure [xdc]
# +-----


${EXTTEMP}/${UTILLX_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${UTILLX_PATH} ] || rm -rf ${EXTTEMP}/${UTILLX_PATH}
	${MAKE} extract LIST="$(strip ${UTILLX_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${UTILLX_PKG}*patch ; do \
#			cat $${PF} | ( cd ${UTILLX_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${UTILLX_PATH}-xdc ] || rm -rf ${EXTTEMP}/${UTILLLX}-xdc
	mv ${EXTTEMP}/${UTILLX_PATH} ${EXTTEMP}/${UTILLX_PATH}-xdc
	( cd ${EXTTEMP}/${UTILLX_PATH}-xdc || exit 1 ;\
		[ -r MCONFIG.OLD ] || mv MCONFIG MCONFIG.OLD || exit 1 ;\
		grep -v _FILE_OFFSET_BITS MCONFIG.OLD \
			| sed 's/uname -m/echo '${TARGET_CPU}'/' \
			| sed 's/ -o root//' \
			> MCONFIG || exit 1 ;\
		for MF in `find ./ -name Makefile` ; do \
			[ -r $${MF}.OLD ] || mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed '/^	hwclock/ s/hwclock //' \
				| sed '/^	mount/ s/mount //' \
				| sed 's/ mkswap / /' \
				| sed 's/ mkswap.8 / /' \
				> $${MF} || exit 1 ;\
		done ;\
		CC=${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc \
		  CFLAGS=-Os \
			./configure --prefix=/ \
			  --host=${NATIVE_SPEC} \
			  --build=${TARGET_SPEC} \
			  --disable-nls --disable-largefile \
			  || exit 1 \
	) || exit 1


# ,-----
# |	Build [xdc]
# +-----

${EXTTEMP}/${UTILLX_PATH}-xdc/fdisk/fdisk:
	${MAKE} ${EXTTEMP}/${UTILLX_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${UTILLX_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [xdc]
# +-----

${UTILLX_INSTTEMP}/sbin/fdisk:
	${MAKE} ${EXTTEMP}/${UTILLX_PATH}-xdc/fdisk/fdisk
	mkdir -p ${UTILLX_INSTTEMP}
	( cd ${EXTTEMP}/${UTILLX_PATH}-xdc || exit 1 ;\
		mkdir -p instttemp/etc ;\
		mkdir -p insttemp/sbin ;\
		mkdir -p insttemp/usr/bin ;\
		make DESTDIR=${EXTTEMP}/${UTILLX_PATH}-xdc/insttemp \
			USE_TTY_GROUP=no \
			install || exit 1 ;\
		mkdir -p ${UTILLX_INSTTEMP}/etc ;\
		cp insttemp/etc/fdprm ${UTILLX_INSTTEMP}/etc/ ;\
		mkdir -p ${UTILLX_INSTTEMP}/usr/bin ;\
		cp insttemp/usr/bin/setfdprm ${UTILLX_INSTTEMP}/usr/bin/ ;\
		cp insttemp/usr/bin/fdformat ${UTILLX_INSTTEMP}/usr/bin/ ;\
		mkdir -p ${UTILLX_INSTTEMP}/sbin ;\
		cp insttemp/sbin/fdisk ${UTILLX_INSTTEMP}/sbin/ \
	) || exit 1

${TOPLEV}/${UTILLX_EGPNAME}.egp: ${UTILLX_INSTTEMP}/sbin/fdisk
	${PCREATE_SCRIPT} create ${TOPLEV}/${UTILLX_EGPNAME}.egp ${UTILLX_INSTTEMP}

${XDC_ROOT}/sbin/fdisk: ${TOPLEV}/${UTILLX_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${UTILLX_EGPNAME}.egp

REALCLEAN_TARGETS+= ${XDC_ROOT} ${TOPLEV}/${UTILLX_EGPNAME}.egp


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-util-linux
ifeq (${MAKE_CHROOT},y)
xdc-util-linux: ${XDC_ROOT}/sbin/fdisk
else
xdc-util-linux: ${TOPLEV}/${UTILLX_EGPNAME}.egp
endif
