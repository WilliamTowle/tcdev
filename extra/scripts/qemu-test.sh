#!/bin/sh

TARGET=$1
shift
KERNEL=$1
shift
INITRD=$1
shift

if [ -z "${INITRD}" ] ; then
	echo "$0: Expected TARGET, KERNEL, INITRD" 1>&2
	exit 1
fi

case ${TARGET} in
mips)	## or others?
	QEMU_EXE=qemu-system-${TARGET}
;;
x86)
	QEMU_EXE=qemu
;;
*)
	echo "$0: Unexpected TARGET ${TARGET}" 1>&2
	exit 1
esac

if [ "${QEMU_DIR}" ] ; then
	if [ ! -d ${QEMU_DIR} ] ; then
		echo "$0: QEMU_DIR ${QEMU_DIR} not directory" 1>&2
		exit 1
	fi
	QEMU_EXE=${QEMU_DIR}/usr/bin/${QEMU_EXE}
else
	which ${QEMU_EXE} || echo "$0: WARNING: QEMU_DIR may need to be set" 1>&2
fi

${QEMU_EXE} -kernel ${KERNEL} -append "root=/dev/hda boot=/dev/ram" -hda ${INITRD} ${*}
