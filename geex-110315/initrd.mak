# initrd.mak 20090122		[ since 2007-03-09 ]
# last mod WmT, 2009-01-22	[ STUBS/tcdev (c) and GPLv2 1999-2009 ]

USAGE_RULES+= "initrd (install to ramdisk from [some] packages)"

#

INITRD_FSNAME:=iramdisk
#ifeq (${TARGET_CPU},i386)
#INITRD_FSSIZE:=1536
#else
# genext2fs: blocks
INITRD_FSSIZE:=1024
#INITRD_FSSIZE:=180000
#endif
ifeq (${MF_HAVE_GENEXT2FS},y)
else
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
endif

#

ifeq (${MF_HAVE_GENEXT2FS},y)
else
.PHONY: initrd-mntpt
initrd-mntpt: ${INITRD_MNTPT}

${INITRD_MNTPT}:
	mkdir -p ${INITRD_MNTPT}
endif

#

## device nodes
## NB. busybox complains if /dev/tty5 (used for logging) is missing

ifeq (${MF_HAVE_GENEXT2FS},y)
${INITRD_FSNAME}.txt: ${INITRD_CFG}
	echo '# name		type mode uid gid major minor start inc count' > ${INITRD_FSNAME}.txt
	echo '/dev		d    755  0    0    -    -    -    -    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/console	c    600  0    0    5    1    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/null		c    666  0    0    1    3    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/ram0		c    660  0    0    1    0    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/tty		c    660  0    0    5    0    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/tty0		c    660  0    0    4    0    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/tty1		c    660  0    0    4    1    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/tty2		c    660  0    0    4    2    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/tty3		c    660  0    0    4    3    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/tty4		c    660  0    0    4    4    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/tty5		c    660  0    0    4    5    0    0    -' >> ${INITRD_FSNAME}.txt
	echo '/dev/zero		c    666  0    0    1    5    0    0    -' >> ${INITRD_FSNAME}.txt

else
.PHONY: initrd-devnodes
initrd-devnodes:
	mkdir -p ${INITRD_MNTPT}/dev
	mknod -m 600 ${INITRD_MNTPT}/dev/console c 5 1
	mknod -m 666 ${INITRD_MNTPT}/dev/null c 1 3
	echo "?! /dev/ram0 required?" 1>&2 ; exit 1
	mknod -m 666 ${INITRD_MNTPT}/dev/tty c 5 0
	mknod -m 660 ${INITRD_MNTPT}/dev/tty0 c 4 0
	mknod -m 660 ${INITRD_MNTPT}/dev/tty1 c 4 1
	mknod -m 660 ${INITRD_MNTPT}/dev/tty2 c 4 2
	mknod -m 660 ${INITRD_MNTPT}/dev/tty3 c 4 3
	mknod -m 666 ${INITRD_MNTPT}/dev/zero c 1 5
endif

#

ifeq (${MF_HAVE_GENEXT2FS},y)
else
${XDC_ROOT}/bin/sh:
	${MAKE} xdc MAKE_CHROOT=y
endif


ifeq (${MF_HAVE_GENEXT2FS},y)
INITRD_EGP_TARGETS:=
INITRD_EGP_TARGETS+= ${TOPLEV}/${BUSYBOX_PKG}-${BUSYBOX_VER}.egp
INITRD_EGP_TARGETS+= ${TOPLEV}/uClibc-rt-${UCLIBC_RT_VER}.egp

.PHONY: initrd-content
initrd-content: ${INITRD_EGP_TARGETS}
	mkdir ${XDC_ROOT}
	./scripts/egp install ${XDC_ROOT} ${INITRD_EGP_TARGETS}

else
.PHONY: initrd-content
initrd-content: ${XDC_ROOT}/bin/sh
	${MAKE} initrd-devnodes
	cp -ar ${XDC_ROOT}/*bin ${XDC_ROOT}/*lib ${INITRD_MNTPT}
	mkdir -p ${INITRD_MNTPT}/usr/bin ${INITRD_MNTPT}/usr/sbin
	cp -ar ${XDC_ROOT}/usr/bin/[[befhtuwy]* ${INITRD_MNTPT}/usr/bin/
	[ ! -d ${XDC_ROOT}/usr/sbin ] || cp -ar ${XDC_ROOT}/usr/sbin/* ${INITRD_MNTPT}/usr/sbin/
endif

ifeq (${MF_HAVE_GENEXT2FS},y)
else

/proc/mounts:
	[ -d /proc ] || mkdir /proc
	[ -r /proc/version ] || mount -t proc none /proc

.PHONY: initrd-sume
initrd-sume: /proc/mounts
	dd if=/dev/zero of=${INITRD_FSNAME} count=${INITRD_FSSIZE} bs=1k
	ROOTDIR=${HTC_ROOT} ./scripts/mkfs ${MKFS_OPTS} ${INITRD_FSNAME}
	mount -o loop ${INITRD_FSNAME} ${INITRD_MNTPT}
	${MAKE} initrd-content || ( umount ${INITRD_MNTPT} ; rmdir ${INITRD_MNTPT} ; echo "*** ERROR! SEE ABOVE ***" 1>&2 ; exit 1 )
	umount ${INITRD_MNTPT}
	rmdir ${INITRD_MNTPT}
endif

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

##

.PHONY: initrd-archive
initrd-archive: ${INITRD_FSNAME}.gz

ifeq (${MF_HAVE_GENEXT2FS},y)
${INITRD_FSNAME}: ${INITRD_FSNAME}.txt
	${HTC_ROOT}/bin/genext2fs -d ${XDC_ROOT} -D ${INITRD_FSNAME}.txt -b ${INITRD_FSSIZE} -q -m 5 ${INITRD_FSNAME}
else
${INITRD_FSNAME}: initrd-content initrd-mntpt
	echo "Doing 'sume' bit: UID=${UID} USERNAME=${USERNAME} AM_ROOT=${AM_ROOT}"
	${SUDO} ${MAKE} initrd-sume
endif

${INITRD_FSNAME}.gz: ${INITRD_FSNAME}
	cat ${INITRD_FSNAME} | gzip -9 > ${INITRD_FSNAME}.gz


##

.PHONY: initrd-sanity
ifeq (${MF_HAVE_GENEXT2FS},y)
else
initrd-sanity: initrd-type-sanity
initrd-type-sanity:
	[ "${INITRD_FSTYPE}" ] || ( echo "INITRD_FSTYPE unset" 1>&2 ; exit 1)
endif


.PHONY: initrd
ifeq (${MF_HAVE_GENEXT2FS},y)
initrd: htc-genext2fs initrd-content initrd-archive
else
ifeq (${INITRD_FSTYPE},ext2)
initrd: initrd-sanity htc-e2fsprogs ${INITRD_FSNAME}.gz
else
initrd: initrd-sanity ${INITRD_FSNAME}.gz
endif
endif

CLEAN_TARGETS+= ${INITRD_FSNAME} ${INITRD_FSNAME}.txt
REALCLEAN_TARGETS+= ${INITRD_FSNAME}.txt ${INITRD_FSNAME}.gz ${INITRD_EGP_TARGETS}
