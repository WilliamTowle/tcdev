# initrd.mak 20070820		[ since 2007-03-09 ]
# last mod WmT, 2007-08-20	[ STUBS/tcdev (c) and GPLv2 1999-2007 ]

USAGE_RULES+= "initrd (build ramdisk)"

#

INITRD_FSNAME:=iramdisk
ifeq (${TARGET_CPU},i386)
INITRD_FSSIZE:=1536
else
INITRD_FSSIZE:=1800
endif
INITRD_FSTYPE:=ext2
#INITRD_FSTYPE:=minix
INITRD_MNTPT:=/var/tmp/tmp.$$

MKFS_OPTS:= -t ${INITRD_FSTYPE} -F
ifeq (${INITRD_FSTYPE},ext2)
MKFS_OPTS+= -F
endif

AM_ROOT=$(shell if [ "${UID}" = '0' -o "${USERNAME}" = 'root' -o "${USERNAME}" = '' ] ; then echo y ; else echo n ; fi)
ifeq (${AM_ROOT},y)
SUDO:=
else
SUDO:= sudo
endif

#

.PHONY: initrd-mntpt
initrd-mntpt: ${INITRD_MNTPT}

${INITRD_MNTPT}:
	mkdir -p ${INITRD_MNTPT}

#

.PHONY: initrd-devnodes
initrd-devnodes:
	mkdir -p ${INITRD_MNTPT}/dev
	mknod -m 600 ${INITRD_MNTPT}/dev/console c 5 1
	mknod -m 666 ${INITRD_MNTPT}/dev/null c 1 3
	mknod -m 666 ${INITRD_MNTPT}/dev/tty c 5 0
	mknod -m 660 ${INITRD_MNTPT}/dev/tty0 c 4 0
	mknod -m 660 ${INITRD_MNTPT}/dev/tty1 c 4 1
	mknod -m 660 ${INITRD_MNTPT}/dev/tty2 c 4 2
	mknod -m 660 ${INITRD_MNTPT}/dev/tty3 c 4 3
	mknod -m 666 ${INITRD_MNTPT}/dev/zero c 1 5

#

/proc/mounts:
	[ -d /proc ] || mkdir /proc
	[ -r /proc/version ] || mount -t proc none /proc

.PHONY: initrd-sume
initrd-sume: /proc/mounts
	dd if=/dev/zero of=${INITRD_FSNAME} count=${INITRD_FSSIZE} bs=1k
	ROOTDIR=${HTC_ROOT} ./scripts/mkfs ${MKFS_OPTS} ${INITRD_FSNAME}
	mount -o loop ${INITRD_FSNAME} ${INITRD_MNTPT}
	${MAKE} initrd-devnodes
	cp -ar ${XDC_ROOT}/*bin ${XDC_ROOT}/*lib ${INITRD_MNTPT}
	mkdir -p ${INITRD_MNTPT}/usr/bin ${INITRD_MNTPT}/usr/sbin
	cp -ar ${XDC_ROOT}/usr/bin/[[befhtuwy]* ${INITRD_MNTPT}/usr/bin/
	[ ! -d ${XDC_ROOT}/usr/sbin ] || cp -ar ${XDC_ROOT}/usr/sbin/* ${INITRD_MNTPT}/usr/sbin/
	umount ${INITRD_MNTPT}
	rmdir ${INITRD_MNTPT}

#${HTC_ROOT}/usr/bin/fakeroot:
#	( cd ${EXTTEMP}/fakeroot-1.5.10ubuntu1/ && ./configure --prefix=${HTC_ROOT}/usr && make && make install )
#
##${INITRD_FSNAME}: xdc initrd-mntpt ${HTC_ROOT}/usr/bin/fakeroot
##	echo "UID ${UID} USERNAME ${USERNAME}"
##	whoami
##	echo "...fakeroot next...? ..." ; exit 1
##	${HTC_ROOT}/usr/bin/fakeroot -l ${HTC_ROOT}/usr/lib/libfakeroot-0.so -- \
##		${MAKE} initrd-sume
#${INITRD_FSNAME}: xdc initrd-mntpt
#	echo "UID ${UID} USERNAME ${USERNAME}"
#	whoami
#	PRETENDROOTDIR=${EXTTEMP}/pretendroot LD_PRELOAD="${TOPLEV}/pretendroot-0.7/libpretendroot.so ${LD_PRELOAD}" \
#		${MAKE} initrd-sume
#	## PRETENDROOTDIR=${EXTTEMP}/rootpretender LD_PRELOAD="${TOPLEV}/rootpretender-0.71/librootpretender.so ${LD_PRELOAD}" \

${XDC_ROOT}/bin/sh:
	${MAKE} xdc MAKE_CHROOT=y

${INITRD_FSNAME}: ${XDC_ROOT}/bin/sh initrd-mntpt
	echo "Doing 'sume' bit: UID=${UID} USERNAME=${USERNAME} AM_ROOT=${AM_ROOT}"
	${SUDO} ${MAKE} initrd-sume

#

${INITRD_FSNAME}.gz: ${INITRD_FSNAME}
	gzip -9f ${INITRD_FSNAME}

#

initrd-sanity: initrd-type-sanity
initrd-type-sanity:
	[ "${INITRD_FSTYPE}" ] || ( echo "INITRD_FSTYPE unset" 1>&2 ; exit 1)


.PHONY: initrd
ifeq (${INITRD_FSTYPE},ext2)
initrd: initrd-sanity htc-e2fsprogs ${INITRD_FSNAME}.gz
else
initrd: initrd-sanity ${INITRD_FSNAME}.gz
endif

CLEAN_TARGETS+= ${INITRD_FSNAME} insttemp
REALCLEAN_TARGETS+= ${INITRD_FSNAME}.gz
