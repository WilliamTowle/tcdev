# syslinux 3.86			[ since v1.76, c.2002-10-31 ]
# last mod WmT, 2011-01-18	[ (c) and GPLv2 1999-2011 ]

# ,-----
# |	Settings
# +-----

SYSLINUX_PKG:=syslinux
#SYSLINUX_VER:=3.80
#SYSLINUX_VER:=3.84
SYSLINUX_VER:=3.86

SYSLINUX_SRC:=
SYSLINUX_SRC+=${SOURCEROOT}/s/syslinux-${SYSLINUX_VER}.tar.bz2

SYSLINUX_PATH:=syslinux-${SYSLINUX_VER}

URLS+= http://www.mirrorservice.org/sites/ftp.kernel.org/pub/linux/boot/syslinux/syslinux-${SYSLINUX_VER}.tar.bz2


#DEPS:=

# ,-----
# |	Configure [htc]
# +-----


${EXTTEMP}/${SYSLINUX_PATH}-htc/Makefile:
	[ ! -d ${EXTTEMP}/${SYSLINUX_PATH} ] || rm -rf ${EXTTEMP}/${SYSLINUX_PATH}
	${MAKE} extract LIST="$(strip ${SYSLINUX_SRC})"
	[ ! -d ${EXTTEMP}/${SYSLINUX_PATH}-htc ] || rm -rf ${EXTTEMP}/${SYSLINUX_PATH}-htc
	mv ${EXTTEMP}/${SYSLINUX_PATH} ${EXTTEMP}/${SYSLINUX_PATH}-htc


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${SYSLINUX_PATH}-htc/core/isolinux.bin: ${EXTTEMP}/${SYSLINUX_PATH}-htc/Makefile
	( cd ${EXTTEMP}/${SYSLINUX_PATH}-htc || exit 1 ;\
		make core/isolinux.bin || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/etc/syslinux/isolinux.bin:
	${MAKE} ${EXTTEMP}/${SYSLINUX_PATH}-htc/core/isolinux.bin
	( cd ${EXTTEMP}/${SYSLINUX_PATH}-htc || exit 1 ;\
		mkdir -p ${HTC_ROOT}/etc/syslinux || exit 1 ;\
		cp core/isolinux.bin ${HTC_ROOT}/etc/syslinux/ ;\
	) || exit 1


# ,-----
# |	Entry points [htc]
# +-----

.PHONY: htc-syslinux
htc-syslinux: ${HTC_ROOT}/etc/syslinux/isolinux.bin
