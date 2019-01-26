# bin86 0.16.17			[ since 0.16.0 ]
# last mod WmT, 20/03/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

BIN86_PKG:=bin86
BIN86_VER:=0.16.17

BIN86_SRC+=${SOURCEROOT}/b/bin86-0.16.17.tar.gz

BIN86_PATH:=bin86-${BIN86_VER}

URLS+= http://homepage.ntlworld.com/robert.debath/dev86/bin86-0.16.17.tar.gz


# ,-----
# |	Configure [xdc]
# +-----

${EXTTEMP}/${BIN86_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${BIN86_PATH} ] || rm -rf ${EXTTEMP}/${BIN86_PATH}
	${MAKE} extract LIST="$(strip ${BIN86_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${BIN86_PKG}*patch ; do \
#			cat $${PF} | ( cd ${BIN86_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${BIN86_PATH}-htc ] || rm -rf ${EXTTEMP}/${BIN86_PATH}-htc
	mv ${EXTTEMP}/${BIN86_PATH} ${EXTTEMP}/${BIN86_PATH}-htc
	( cd ${EXTTEMP}/${BIN86_PATH}-htc || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed '/^CFLAGS/	s%^%CC='${HTC_GCC}'\n%' \
			| sed '/^PREFIX/	s%/usr.*%/usr%' \
			| sed '/^...DIR=/	s%=%= $${DESTDIR}%' \
			> Makefile || exit 1 \
	) || exit 1


# ,-----
# |	Build [xdc]
# +-----

${EXTTEMP}/${BIN86_PATH}-htc/as/as86: ${EXTTEMP}/${BIN86_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${BIN86_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [xdc]
# +-----

${HTC_ROOT}/usr/bin/as86:
	${MAKE} ${EXTTEMP}/${BIN86_PATH}-htc/as/as86
	( cd ${EXTTEMP}/${BIN86_PATH}-htc || exit 1 ;\
		make DESTDIR=${HTC_ROOT} install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${BIN86_PKG} ${BIN86_VER}
endif

# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: htc-bin86
htc-bin86: ${HTC_ROOT}/usr/bin/as86
