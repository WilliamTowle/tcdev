# bzip2 1.0.5			[ since v1.0.2, c. 2006-04-08 ]
# last mod WmT, 2011-01-19	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

BZIP2_PKG:=bzip2
BZIP2_VER:=1.0.5

BZIP2_SRC+=${SOURCEROOT}/b/bzip2-${BZIP2_VER}.tar.gz

BZIP2_PATH:=bzip2-${BZIP2_VER}
BZIP2_INSTTEMP:=${EXTTEMP}/${BZIP2_PATH}-insttemp
BZIP2_EGPNAME:=bzip2-${BZIP2_VER}

URLS+=http://www.bzip.org/${BZIP2_VER}/bzip2-${BZIP2_VER}.tar.gz

#DEPS:=

# ,-----
# |	Configure [xdc]
# +-----


${EXTTEMP}/${BZIP2_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${BZIP2_PATH} ] || rm -rf ${EXTTEMP}/${BZIP2_PATH}
	${MAKE} extract LIST="$(strip ${BZIP2_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${BZIP2_PKG}*patch ; do \
#			cat $${PF} | ( cd ${BZIP2_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${BZIP2_PATH}-xdc ] || rm -rf ${EXTTEMP}/${BZIP2_PATH}-xdc
	mv ${EXTTEMP}/${BZIP2_PATH} ${EXTTEMP}/${BZIP2_PATH}-xdc
	( cd ${EXTTEMP}/${BZIP2_PATH}-xdc || exit 1 ;\
		find ./ -name "Makefile*" | while read MF ; do \
			[ -r $${MF}.OLD ] || mv $${MF} $${MF}.OLD || exit 1 ;\
			cat $${MF}.OLD \
				| sed	' /^CC=/	s%g*cc%'${XTC_ROOT}'/usr/bin/'${TARGET_SPEC}'-gcc%' \
				| sed	' /^AR=/	s%ar%'`echo ${XTC_ROOT}'/usr/bin/'${TARGET_SPEC}'-gcc' | sed 's/gcc$$/ar/'`'%' \
				| sed	' /^RANLIB=/	s%ranlib%'`echo ${XTC_ROOT}'/usr/bin/'${TARGET_SPEC}'-gcc' | sed 's/gcc$$/ranlib/'`'%' \
				| sed	' /^BIGFILES=/	s/^/#/' \
				| sed	' /^CFLAGS=/	s/ -g / /' \
				| sed	' /^PREFIX=/	s%=.*%= '${BZIP2_INSTTEMP}'/usr%' \
				| sed	' /^all:/	s/test//' \
				> $${MF} || exit 1 ;\
		done \
	) || exit 1


# ,-----
# |	Build [xdc]
# +-----

${EXTTEMP}/${BZIP2_PATH}-xdc/bzip2: ${EXTTEMP}/${BZIP2_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${BZIP2_PATH}-xdc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [xdc]
# +-----

${BZIP2_INSTTEMP}/usr/bin/bzip2:
	${MAKE} ${EXTTEMP}/${BZIP2_PATH}-xdc/bzip2
	( cd ${EXTTEMP}/${BZIP2_PATH}-xdc || exit 1 ;\
		mkdir -p ${BZIP2_INSTTEMP} || exit 1 ;\
		make DESTDIR=${BZIP2_INSTTEMP} install || exit 1 \
	) || exit 1
	( cd ${BZIP2_INSTTEMP}/usr/bin || exit 1 ;\
		ln -sf bzdiff bzcmp || exit 1 ;\
		ln -sf bzmore bzless || exit 1 ;\
		ln -sf bzgrep bzegrep || exit 1 ;\
		ln -sf bzgrep bzfgrep || exit 1 \
	) || exit 1

${TOPLEV}/${BZIP2_EGPNAME}.egp: ${BZIP2_INSTTEMP}/usr/bin/bzip2
	${PCREATE_SCRIPT} create ${TOPLEV}/${BZIP2_EGPNAME}.egp ${BZIP2_INSTTEMP}

${XDC_ROOT}/usr/bin/bzip2: ${TOPLEV}/${BZIP2_EGPNAME}.egp
	STRIP=${TARGET_SPEC}-strip ${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${BZIP2_EGPNAME}.egp

REALCLEAN_TARGETS+= ${TOPLEV}/${BZIP2_EGPNAME}.egp


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-bzip2
ifeq (${MAKE_CHROOT},y)
xdc-bzip2: ${XDC_ROOT}/usr/bin/bzip2
else
xdc-bzip2: ${TOPLEV}/${BZIP2_EGPNAME}.egp
endif
