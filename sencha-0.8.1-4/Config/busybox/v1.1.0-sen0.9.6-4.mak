# busybox 1.1.0			[ since 0.60.5, c. 2006-06-17 ]
# last mod WmT, 2011-01-19	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

BUSYBOX_PKG:=busybox
#BUSYBOX_VER:=0.60.5
BUSYBOX_VER:=1.1.0
#BUSYBOX_VER:=1.1.3
#BUSYBOX_VER:=1.2.2.1
#BUSYBOX_VER:=1.4.1
#BUSYBOX_VER:=1.5.0

BUSYBOX_SRC:=
BUSYBOX_SRC+=${SOURCEROOT}/b/busybox-${BUSYBOX_VER}.tar.bz2

BUSYBOX_PATH:=busybox-${BUSYBOX_VER}
BUSYBOX_INSTTEMP:=${EXTTEMP}/${BUSYBOX_PATH}-insttemp
BUSYBOX_EGPNAME:=${BUSYBOX_PKG}-${BUSYBOX_VER}

#URLS+=http://www.busybox.net/downloads/legacy/busybox-0.60.5.tar.bz2
URLS+=http://busybox.net/downloads/busybox-${BUSYBOX_VER}.tar.bz2

#DEPS:=

# ,-----
# |	Configure [xdc]
# +-----

# (19/12/2006) need CONFIG_MKTEMP for lxsource-2.6.x
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
		(	case ${BUSYBOX_VER} in \
			1.1.0) \
				echo 'USING_CROSS_COMPILER=y' ;\
				echo 'PREFIX="'${BUSYBOX_INSTTEMP}'"' ;\
				echo 'CROSS_COMPILER_PREFIX="'${XTC_ROOT}'/usr/bin/'${TARGET_SPEC}'-"' ;\
				echo 'CONFIG_LOGIN=y' ;\
				echo 'CONFIG_USE_BB_PWD_GRP=y' ;\
				echo 'CONFIG_FEATURE_SHADOWPASSWDS=y' ;\
				echo 'CONFIG_USE_BB_SHADOW=y' ;\
				echo 'CONFIG_FEATURE_COMMAND_EDITING=y' ;\
				echo 'CONFIG_FEATURE_COMMAND_TAB_COMPLETION=y' \
			;; \
			1.2.2.1) \
				echo 'USING_CROSS_COMPILER=y' ;\
				echo 'PREFIX="'${BUSYBOX_INSTTEMP}'"' ;\
				echo 'CROSS_COMPILER_PREFIX="'${XTC_ROOT}'/usr/bin/'${TARGET_SPEC}'-"' ;\
 				echo 'CONFIG_FEATURE_COMMAND_EDITING=y' ;\
				echo 'CONFIG_FEATURE_COMMAND_TAB_COMPLETION=y' \
			;; \
			1.4.1) \
				echo 'CONFIG_PREFIX="'${BUSYBOX_INSTTEMP}'"' ;\
	 			echo 'CONFIG_FEATURE_COMMAND_EDITING=y' ;\
				echo 'CONFIG_FEATURE_COMMAND_TAB_COMPLETION=y' \
			;; \
			1.5.0) \
				echo 'CONFIG_PREFIX="'${BUSYBOX_INSTTEMP}'"' ;\
				echo 'CONFIG_FEATURE_EDITING=y' ;\
				echo 'CONFIG_FEATURE_TAB_COMPLETION=y' \
			;; \
			*) \
				echo "busybox: CONFIGURE: Unexpected BUSYBOX_VER ${BUSYBOX_VER}" 1>&2 ;\
				exit 1 \
			;; \
			esac ;\
			echo '# CONFIG_STATIC is not set' ;\
			echo 'CONFIG_FEATURE_SH_IS_ASH=y' ;\
			echo 'CONFIG_ASH=y' ;\
			echo '# CONFIG_FEATURE_SH_IS_HUSH is not set' ;\
			echo '# CONFIG_HUSH is not set' ;\
			echo '# CONFIG_FEATURE_SH_IS_LASH is not set' ;\
			echo '# CONFIG_LASH is not set' ;\
			echo '# CONFIG_FEATURE_SH_IS_MSH is not set' ;\
			echo '# CONFIG_MSH is not set' ;\
			echo 'CONFIG_BASENAME=y' ;\
			echo 'CONFIG_DATE=y' ;\
			echo 'CONFIG_DIRNAME=y' ;\
			echo 'CONFIG_CAT=y' ;\
			echo 'CONFIG_CHGRP=y' ;\
			echo 'CONFIG_CHMOD=y' ;\
			echo 'CONFIG_CHOWN=y' ;\
			echo 'CONFIG_CHROOT=y' ;\
			echo 'CONFIG_CP=y' ;\
			echo 'CONFIG_DD=y' ;\
			echo 'CONFIG_DF=y' ;\
			echo 'CONFIG_DU=y' ;\
			echo 'CONFIG_ECHO=y' ;\
			echo 'CONFIG_ENV=y' ;\
			echo 'CONFIG_EXPR=y' ;\
			echo 'CONFIG_EXPR=y' ;\
			echo 'CONFIG_FALSE=y' ;\
			echo 'CONFIG_TRUE=y' ;\
			echo 'CONFIG_FDFORMAT=y' ;\
			echo 'CONFIG_FDISK=y' ;\
			echo '# FDISK_SUPPORT_LARGE_DISKS is not set' ;\
			echo 'CONFIG_FEATURE_FDISK_WRITABLE=y' ;\
			echo 'CONFIG_FEATURE_FDISK_ADVANCED=y' ;\
			echo 'CONFIG_GREP=y' ;\
			echo '# CONFIG_GZIP is not set' ;\
			echo 'CONFIG_HALT=y' ;\
			echo 'CONFIG_REBOOT=y' ;\
			echo 'CONFIG_HEAD=y' ;\
			echo 'CONFIG_TAIL=y' ;\
			echo 'CONFIG_HOSTNAME=y' ;\
			echo 'CONFIG_INIT=y' ;\
			echo 'CONFIG_FEATURE_USE_INITTAB=y' ;\
			echo 'CONFIG_LN=y' ;\
			echo 'CONFIG_LS=y' ;\
			echo 'CONFIG_MKDIR=y' ;\
			echo '# CONFIG_MKE2FS is not set' ;\
			echo '# CONFIG_E2FSCK is not set' ;\
			echo 'CONFIG_MKFS_MINIX=y' ;\
			echo 'CONFIG_FSCK_MINIX=y' ;\
			echo 'CONFIG_MKNOD=y' ;\
			echo 'CONFIG_MKSWAP=y' ;\
			echo 'CONFIG_SWAPONOFF=y' ;\
			echo 'CONFIG_MKTEMP=y' ;\
			echo 'CONFIG_MORE=y' ;\
			echo 'CONFIG_MOUNT=y' ;\
			echo 'CONFIG_UMOUNT=y' ;\
			echo 'CONFIG_FEATURE_MOUNT_LOOP=y' ;\
			echo 'CONFIG_LOSETUP=y' ;\
			echo 'CONFIG_MV=y' ;\
			echo 'CONFIG_PS=y' ;\
			echo 'CONFIG_PWD=y' ;\
			echo 'CONFIG_RM=y' ;\
			echo 'CONFIG_RMDIR=y' ;\
			echo '# CONFIG_SED is not set' ;\
			echo 'CONFIG_SLEEP=y' ;\
			echo 'CONFIG_SORT=y' ;\
			[ "${BUSYBOX_VER}" = '1.1.0' ] && echo '# CONFIG_FEATURE_SORT_BIG is not set' ;\
			echo 'CONFIG_STTY=y' ;\
			echo 'CONFIG_TTY=y' ;\
			echo 'CONFIG_SYNC=y' ;\
			echo '# CONFIG_TAR is not set' ;\
			echo 'CONFIG_FEATURE_TAR_GZIP=y' ;\
			echo 'CONFIG_TEE=y' ;\
			echo 'CONFIG_TEST=y' ;\
			echo 'CONFIG_TOP=y' ;\
			echo 'CONFIG_TOUCH=y' ;\
			echo 'CONFIG_TR=y' ;\
			echo 'CONFIG_UNAME=y' ;\
			echo 'CONFIG_UNIQ=y' ;\
			echo 'CONFIG_VI=y' ;\
			echo 'CONFIG_WHOAMI=y' ;\
			echo 'CONFIG_YES=y' ;\
			echo '# CONFIG_HALT is not set' ;\
			echo '# CONFIG_MESG is not set' ;\
			echo '# CONFIG_POWEROFF is not set' ;\
			echo '# CONFIG_REBOOT is not set' ;\
			echo '# CONFIG_START_STOP_DAEMON is not set' ;\
			echo 'CONFIG_INSTALL_APPLET_SYMLINKS=y' \
		) > .config || exit 1 ;\
		yes '' | ( make \
			HOSTCC=${HTC_GCC} \
			oldconfig ) || exit 1 ;\
		case ${BUSYBOX_VER} in \
		1.1.0|1.2.2.1) \
			[ -r Rules.mak.OLD ] || mv Rules.mak Rules.mak.OLD ;\
			cat Rules.mak.OLD \
				| sed	' /HOSTCC/	s%g*cc%'${HTC_GCC}'% ; /[(]CROSS[)]/	s%$$(CROSS)%$$(shell if [ -n "$${CROSS}" ] ; then echo $${CROSS} ; else echo "'`echo ${HTC_GCC} | sed 's/gcc$$//'`'" ; fi)% ' > Rules.mak || exit 1 ;\
			[ -r applets/busybox.mkll.OLD ] || mv applets/busybox.mkll applets/busybox.mkll.OLD ;\
			cat applets/busybox.mkll.OLD \
				| sed	' /.HOSTCC/	s%.HOSTCC%'${NATIVE_GCC}'% ' \
				> applets/busybox.mkll \
				|| exit 1 \
		;; \
		1.4.1) \
			[ -r scripts/trylink.OLD ] || mv scripts/trylink scripts/trylink.OLD || exit 1 ;\
			cat scripts/trylink.OLD \
				| sed 's/function try/try()/' \
				> scripts/trylink || exit 1 ;\
			chmod a+x scripts/trylink || exit 1 \
		;; \
		esac \
 	) || exit 1
 
 
	

# ,-----
# |	Build [xdc]
# +-----

${EXTTEMP}/${BUSYBOX_PATH}-xdc/busybox: ${EXTTEMP}/${BUSYBOX_PATH}-xdc/Makefile
	( cd ${EXTTEMP}/${BUSYBOX_PATH}-xdc || exit 1 ;\
		case ${BUSYBOX_VER} in \
		1.1.0|1.2.2.1) \
			make VERBOSE=y \
		;; \
		1.5.0) \
			make KBUILD_VERBOSE=1 || exit 1 \
		;; \
		*) \
			echo "BUILD: Unexpected BUSYBOX_VER ${BUSYBOX_VER}" 1>&2 ;\
			exit 1 \
		;; \
		esac \
	) || exit 1


# ,-----
# |	Install [xdc]
# +-----

${BUSYBOX_INSTTEMP}/bin/busybox:
	${MAKE} ${EXTTEMP}/${BUSYBOX_PATH}-xdc/busybox
	mkdir -p ${BUSYBOX_INSTTEMP}
	( cd ${EXTTEMP}/${BUSYBOX_PATH}-xdc || exit 1 ;\
		make install || exit 1 \
	) || exit 1

${TOPLEV}/${BUSYBOX_EGPNAME}.egp: ${BUSYBOX_INSTTEMP}/bin/busybox
	${PCREATE_SCRIPT} create ${TOPLEV}/${BUSYBOX_EGPNAME}.egp ${BUSYBOX_INSTTEMP}

${XDC_ROOT}/bin/busybox: ${TOPLEV}/${BUSYBOX_EGPNAME}.egp
	mkdir -p ${XDC_ROOT}
	STRIP=${TARGET_SPEC}-strip ${PCREATE_SCRIPT} install ${XDC_ROOT} ${TOPLEV}/${BUSYBOX_EGPNAME}.egp

REALCLEAN_TARGETS+= ${TOPLEV}/${BUSYBOX_EGPNAME}.egp


# ,-----
# |	Entry points [xdc]
# +-----

.PHONY: xdc-busybox
ifeq (${MAKE_CHROOT},y)
xdc-busybox: ${XDC_ROOT}/bin/busybox
else
xdc-busybox: ${TOPLEV}/${BUSYBOX_EGPNAME}.egp
endif
