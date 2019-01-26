# busybox 0.60.5		[ since 0.60.5]
# last mod WmT, 02/04/2007	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Settings
# +-----

BUSYBOX_PKG:=busybox
BUSYBOX_VER:=0.60.5
#BUSYBOX_VER:=1.0.1
#BUSYBOX_VER:=1.1.3
#BUSYBOX_VER:=1.2.2.1

BUSYBOX_SRC:=
BUSYBOX_SRC+=${SOURCEROOT}/b/busybox-${BUSYBOX_VER}.tar.bz2

BUSYBOX_PATH:=busybox-${BUSYBOX_VER}

URLS+=http://www.busybox.net/downloads/legacy/busybox-0.60.5.tar.bz2
#URLS+=http://busybox.net/downloads/busybox-${BUSYBOX_VER}.tar.bz2

#DEPS:=

# ,-----
# |	Configure [xdc]
# +-----


${EXTTEMP}/${BUSYBOX_PATH}-xdc/Makefile:
	[ ! -d ${EXTTEMP}/${BUSYBOX_PATH} ] || rm -rf ${EXTTEMP}/${BUSYBOX_PATH}
	${MAKE} extract LIST="$(strip ${BUSYBOX_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${BUSYBOX_PKG}*patch ; do \
#			cat $${PF} | ( cd ${BUSYBOX_PATH} && patch -Np1 -i - ) ;\
#			rm -f $${PF} ;\
#		done \
#	) || exit 1
	[ ! -d ${EXTTEMP}/${BUSYBOX_PATH}-xdc ] || rm -rf ${EXTTEMP}/${BUSYBOX_PATH}-xdc
	mv ${EXTTEMP}/${BUSYBOX_PATH} ${EXTTEMP}/${BUSYBOX_PATH}-xdc
	( cd ${EXTTEMP}/${BUSYBOX_PATH}-xdc || exit 1 ;\
		[ -r Config.h.OLD ] || mv Config.h Config.h.OLD || exit 1 ;\
		cat Config.h.OLD \
			| sed 's%#define BB_CHVT%//#define BB_CHVT	/* WmT, 0.60.5-5 */%' \
			| sed 's%//#define BB_EXPR$$%#define BB_EXPR	/* WmT */%' \
			| sed 's%#define BB_FIND$$%//#define BB_FIND	/* WmT */%' \
			| sed 's%//#define BB_FDFLUSH$$%#define BB_FDFLUSH	/* WmT */%' \
			| sed 's%//#define BB_FSCK_MINIX$$%#define BB_FSCK_MINIX	/* WmT */%' \
			| sed 's%#define BB_GUNZIP$$%//#define BB_GUNZIP	/* WmT */%' \
			| sed 's%#define BB_GZIP$$%//#define BB_GZIP	/* WmT */%' \
			| sed 's%//#define BB_HOSTNAME$$%#define BB_HOSTNAME	/* WmT */%' \
			| sed 's%#define BB_ID$$%//#define BB_ID	/* WmT */%' \
			| sed 's%//#define BB_IFCONFIG$$%#define BB_IFCONFIG	/* WmT */%' \
			| sed 's%//#define BB_INSMOD$$%#define BB_INSMOD	/* WmT, for 0.2.5 */%' \
			| sed 's%#define BB_KLOGD$$%//#define BB_KLOGD	/* WT */%' \
			| sed 's%#define BB_LOGGER$$%//#define BB_LOGGER	/* WmT */%' \
			| sed 's%//#define BB_MKTEMP$$%#define BB_MKTEMP	/* WmT, for e3 */%' \
			| sed 's%//#define BB_MKFS_MINIX$$%#define BB_MKFS_MINIX	/* WmT */%' \
			| sed 's%#define BB_MODPROBE$$%//#define BB_MODPROBE	/* WmT */%' \
			| sed 's%//#define BB_PING$$%#define BB_PING	/* WmT */%' \
			| sed 's%//#define BB_RMMOD$$%#define BB_RMMOD	/* WmT, for 0.2.5 */%' \
			| sed 's%//#define BB_ROUTE$$%#define BB_ROUTE	/* WmT, for 0.2.5 */%' \
			| sed 's%#define BB_SED$$%//#define BB_SED	/* WmT - we use GNU */%' \
			| sed 's%//#define BB_STTY$$%#define BB_STTY	/* WmT */%' \
			| sed 's%#define BB_SYSLOGD$$%//#define BB_SYSLOGD	/* WmT */%' \
			| sed 's%#define BB_TAR$$%//#define BB_TAR	/* WmT */%' \
			| sed 's%//#define BB_TEE$$%#define BB_TEE	/* WmT */%' \
			| sed 's%//#define BB_TEST$$%#define BB_TEST	/* WmT */%' \
			| sed 's%//#define BB_TR$$%#define BB_TR	/* WmT (not sure why) */%' \
			| sed 's%//#define BB_TRACEROUTE$$%#define BB_TRACEROUTE	/* WmT, for 0.2.5 */%' \
			| sed 's%#define BB_TTY$$%//#define BB_TTY	/* WmT */%' \
			| sed 's%//#define BB_VI$$%#define BB_VI	/* WmT, for 0.3.1 */%' \
			| sed 's%#define BB_WC$$%//#define BB_WC	/* WmT */%' \
			| sed 's%#define BB_XARGS$$%//#define BB_XARGS	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_USE_TERMIOS$$%#define BB_FEATURE_USE_TERMIOS	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_MTAB_SUPPORT$$%#define BB_FEATURE_MTAB_SUPPORT	/* WmT */%' \
			| sed 's%#define BB_FEATURE_NEW_MODULE_INTERFACE$$%//#define BB_FEATURE_NEW_MODULE_INTERFACE	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_OLD_MODULE_INTERFACE$$%#define BB_FEATURE_OLD_MODULE_INTERFACE	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_INSMOD_VERSION_CHECKING$$%#define BB_FEATURE_INSMOD_VERSION_CHECKING	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_IFCONFIG_STATUS$$%#define BB_FEATURE_IFCONFIG_STATUS	/* WmT */%' \
			| sed 's%//#define BB_FEATURE_GREP_EGREP_ALIAS$$%#define BB_FEATURE_GREP_EGREP_ALIAS	/* WmT */%' \
		> Config.h || exit 1 ;\
		[ -r Makefile.OLD ] || mv Makefile Makefile.OLD || exit 1 ;\
		cat Makefile.OLD \
			| sed '/^CROSS/ s%$$%$$(shell if [ -n "$${CROSS_PREFIX}" ] ; then echo $${CROSS_PREFIX} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ' \
			> Makefile || exit 1 ;\
		[ -r busybox.mkll.OLD ] || mv busybox.mkll busybox.mkll.OLD || exit 1 ;\
		cat busybox.mkll.OLD \
			| sed	's%^gcc%'${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc'%' \
			> busybox.mkll || exit 1 \
	) || exit 1


# ,-----
# |	Build [xdc]
# +-----

${EXTTEMP}/${BUSYBOX_PATH}-xdc/busybox:
	${MAKE} ${EXTTEMP}/${BUSYBOX_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${BUSYBOX_PATH}-xdc || exit 1 ;\
		make CROSS_PREFIX=`echo ${XTC_ROOT}/usr/bin/${TARGET_SPEC}-gcc | sed 's/gcc$$//'` \
			|| exit 1 \
	) || exit 1


# ,-----
# |	Install [xdc]
# +-----

${XDC_INSTTEMP}/bin/busybox:
	${MAKE} ${EXTTEMP}/${BUSYBOX_PATH}-xdc/busybox
	mkdir -p ${XDC_INSTTEMP}
	( cd ${EXTTEMP}/${BUSYBOX_PATH}-xdc || exit 1 ;\
		make PREFIX=${XDC_INSTTEMP} install || exit 1 \
	) || exit 1

${TOPLEV}/${BUSYBOX_PKG}-${BUSYBOX_VER}.egp:
	${MAKE} ${XDC_INSTTEMP}/bin/busybox
#	tar cvzf ${BUSYBOX_PKG}-${BUSYBOX_VER}.tgz -C ${INSTTEMP} ./
	${PCREATE_SCRIPT} create ${BUSYBOX_PKG}-${BUSYBOX_VER}.egp ${INSTTEMP}
	rm -rf ${INSTTEMP}

# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-busybox
ifeq (${MAKE_CHROOT},y)
xdc-busybox: ${XDC_INSTTEMP}/bin/busybox
else
xdc-busybox: ${TOPLEV}/${BUSYBOX_PKG}-${BUSYBOX_VER}.egp
endif
