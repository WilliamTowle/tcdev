# isofs.mak 20070312		[ since 20070312 ]
# last mod WmT, 2007-07-30	[ STUBS/tcdev (c) and GPLv2 1999-2007 ]

USAGE_RULES+= "isofs (build ISO image)"

#

ISOFS_FSNAME=fs.iso
DEVDIR=${EXTTEMP}/dev

ifeq (${FAKEWITH},)
FAKEWITH:=fakeroot
endif

ifeq (${FAKEWITH},rootpretender)
ROOTPRETENDERDIR=${EXTTEMP}/rootpretender
ROOTPRETENDERLIB=${TOPLEV}/rootpretender-0.71/librootpretender.so
endif
ifeq (${FAKEWITH},pretendroot)
PRETENDROOTDIR=${EXTTEMP}/pretendroot
PRETENDROOTLIB=${TOPLEV}/pretendroot-0.7/libpretendroot.so
endif


##
#
#.PHONY: initrd-mntpt
#initrd-mntpt: ${INITRD_MNTPT}
#
#${INITRD_MNTPT}:
#	mkdir -p ${INITRD_MNTPT}
#
##

.PHONY: roottemp-devnodes
roottemp-devnodes:
	mkdir -p ${DEVDIR}
	mknod ${DEVDIR}/null c 1 3
	mknod ${DEVDIR}/console c 5 1

##
#
#.PHONY: initrd-sume
#initrd-sume:
#	[ -z "${UID}" ] || [ "${UID}" = '0' ]
#	dd if=/dev/zero of=${INITRD_FSNAME} count=${INITRD_FSSIZE} bs=1k
#	/sbin/mkfs -t ${INITRD_FSTYPE} -F ${INITRD_FSNAME}
#	mount -o loop ${INITRD_FSNAME} ${INITRD_MNTPT}
#	${MAKE} initrd-devnodes
#	cp -ar ${XDC_ROOT} ${INITRD_MNTPT}
#	umount ${INITRD_MNTPT}
#	rmdir ${INITRD_MNTPT}
#
##

ifeq (${FAKEWITH},fakeroot)
${HTC_ROOT}/usr/bin/fakeroot:
	( cd ${TOPLEV}/fakeroot-1.5.10ubuntu1/ && ./configure --prefix=${HTC_ROOT}/usr && make && make install )
endif

###${INITRD_FSNAME}: xdc initrd-mntpt ${HTC_ROOT}/usr/bin/fakeroot
###	echo "UID ${UID} USERNAME ${USERNAME}"
###	whoami
###	echo "...fakeroot next...? ..." ; exit 1
###	${HTC_ROOT}/usr/bin/fakeroot -l ${HTC_ROOT}/usr/lib/libfakeroot-0.so -- \
###		${MAKE} initrd-sume
##${INITRD_FSNAME}: xdc initrd-mntpt
##	echo "UID ${UID} USERNAME ${USERNAME}"
##	whoami
##	PRETENDROOTDIR=${EXTTEMP}/pretendroot LD_PRELOAD="${TOPLEV}/pretendroot-0.7/libpretendroot.so ${LD_PRELOAD}" \
##		${MAKE} initrd-sume
#${INITRD_FSNAME}: xdc initrd-mntpt
#	echo "UID ${UID} USERNAME ${USERNAME}"
#	whoami
#	PRETENDROOTDIR=${EXTTEMP}/rootpretender LD_PRELOAD="${TOPLEV}/rootpretender-0.71/librootpretender.so ${LD_PRELOAD}" \
#		${MAKE} initrd-sume
#
##
#
#${INITRD_FSNAME}.gz: ${INITRD_FSNAME}
#	${MAKE} gzip -9 ${INITRD_FSNAME}

${ISOFS_FSNAME}: ${TOPLEV}/dvdrtools-0.3.1/mkisofs/mkisofs ${TOPLEV}/syslinux-3.36/isolinux.bin
	mkdir -p ${XDC_ROOT}/boot
	cp ${XTC_ROOT}/etc/sencha/vmlinuz-2.2.26 ${XDC_ROOT}/boot/vmlinuz
	cp ${TOPLEV}/syslinux-3.36/isolinux.bin ${XDC_ROOT}/boot/
	echo -e "TIMEOUT 100\n\nDEFAULT vmlinuz root=/dev/cdrom boot=/dev/cdrom,iso9660\n\nLABEL foo\n\tKERNEL /boot/vmlinuz" \
		> ${XDC_ROOT}/boot/isolinux.cfg
	${TOPLEV}/dvdrtools-0.3.1/mkisofs/mkisofs -r -o ${ISOFS_FSNAME} -b boot/isolinux.bin -c boot/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -graft-points ${XDC_ROOT} dev=${DEVDIR}

.PHONY: isofs
isofs: dvdrtools-0.3.1/mkisofs/mkisofs xdc
ifeq (${FAKEWITH},rootpretender)
	mkdir -p ${ROOTPRETENDERDIR}
	LD_PRELOAD="${ROOTPRETENDERLIB} ${LD_PRELOAD}" \
		${MAKE} roottemp-devnodes ${ISOFS_FSNAME}
endif
ifeq (${FAKEWITH},pretendroot)
	mkdir -p ${PRETENDROOTDIR}
	LD_PRELOAD="${PRETENDROOTLIB} ${LD_PRELOAD}" \
		${MAKE} roottemp-devnodes ${ISOFS_FSNAME}
endif
ifeq (${FAKEWITH},fakeroot)
	[ -r ${HTC_ROOT}/usr/bin/fakeroot ] || ${MAKE} ${HTC_ROOT}/usr/bin/fakeroot
	${HTC_ROOT}/usr/bin/fakeroot -- \
		${MAKE} roottemp-devnodes ${ISOFS_FSNAME}
endif
