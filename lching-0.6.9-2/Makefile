#!/usr/bin/make
# last mod WmT, 20/12/2006	[ (c) and GPLv2 1999-2006 ]

# ,-----
# |	Assistance
# +-----

CONFIG:=config.mak
MF_HAVE_CONFIG:=$(shell [ -r ${CONFIG} ] && echo y)
PACKAGES:=package.mak
MF_HAVE_PACKAGES:=$(shell [ -r ${PACKAGES} ] && echo y)

.PHONY: default help
default: help

help:
ifneq (${MF_HAVE_CONFIG},y)
	@echo "WARNING - Configuration file '${CONFIG}' is missing" 1>&2
endif
	@echo "This 'Makefile' has rules for:"
	@for R in ${USAGE_RULES} ; do echo -e "\t$$R" ; done


# ,-----
# |	Configuration
# +-----

HAVE_GLIBC_SYSTEM:=$(shell if [ -r /lib/libc.so.6 ] ; then echo y ; else echo n ; fi)
HAVE_GLIBC5_SYSTEM:=$(shell if [ -r /lib/ld-linux.so.1 ] ; then echo y ; else echo n ; fi)

NATIVE_CPU:=$(shell uname -m)
#TARGET_SUFFIX:=gnu
TARGET_SUFFIX:=uclibc

# ,-----
# |	Build
# +-----

RULES:=

# acquire {HTC|XTC|XDC}_TARGETS
TOPLEV:=$(shell pwd)
ifeq (${MF_HAVE_CONFIG},y)
include ${CONFIG}
endif
ifeq (${MF_HAVE_PACKAGES},y)
include ${PACKAGES}
endif


USAGE_RULES+= "htc (build host toolchain)"
.PHONY: htc
ifeq ($(strip ${HTC_TARGETS}),)
htc:
	@echo "No HTC_TARGETS list" 1>&2 ; exit 1
else
htc: htc-sanity ${HTC_TARGETS}
endif

USAGE_RULES+= "xtc (build cross toolchain)"
.PHONY: xtc
ifeq ($(strip ${XTC_TARGETS}),)
xtc:
	@echo "No XTC_TARGETS list" 1>&2 ; exit 1
else
xtc: xtc-sanity htc ${XTC_TARGETS}
endif

USAGE_RULES+= "xdc (build cross environment [distro])"
.PHONY: xdc
ifeq ($(strip ${XDC_TARGETS}),)
xdc:
	@echo "No XDC_TARGETS list" 1>&2 ; exit 1
else
xdc: xdc-sanity xtc ${XDC_TARGETS}
endif

ifeq ($(shell [ -r initrd.mak ] && echo y),y)
include initrd.mak
endif

USAGE_RULES+= "all (build all toolchains)"
.PHONY: all
ifeq ($(strip ${HTC_TARGETS}${XTC_TARGETS}${XDC_TARGETS}),)
all:
	[ "${HTC_TARGETS}" ] || echo "No HTC_TARGETS"
	[ "${XTC_TARGETS}" ] || echo "No XTC_TARGETS"
	[ "${XDC_TARGETS}" ] || echo "No XDC_TARGETS"
else
all: htc-sanity xtc-sanity xdc-sanity htc xtc xdc
endif


# ,-----
# |	Extract
# +-----

.PHONY: extract
extract:
	[ "${LIST}" ] && echo "SOURCES ${LIST}..."
	mkdir -p ${EXTTEMP}
	for SOURCE in ${LIST} ; do \
		if [ ! -r ${SOURCE} ] ; then \
			echo "MISSING: SOURCE $${SOURCE}" 1>&2 ;\
			exit 1 ;\
		fi ;\
		case "$${SOURCE}" in \
		*bz2) \
			bzcat $${SOURCE} | ( cd ${EXTTEMP} && tar xvf - ) || exit 1 \
		;; \
                *gz) \
                        zcat $${SOURCE} | ( cd ${EXTTEMP} && tar xvf - ) || exit 1 \
		;; \
		*) \
			cp $${SOURCE} ${EXTTEMP} || exit 1 \
		;; \
		esac ;\
	done



# ,-----
# |	Clean
# +-----

.PHONY: clean
clean:
ifneq (${MF_HAVE_CONFIG},y)
	@echo "WARNING - Configuration file '${CONFIG}' is missing" 1>&2
endif
	[ "${EXTTEMP}" ] && /bin/rm -rf ${EXTTEMP}

realclean:
ifneq (${MF_HAVE_CONFIG},y)
	@echo "WARNING - Configuration file '${CONFIG}' is missing" 1>&2
endif
	-[ -z "${EXTTEMP}" ] || /bin/rm -rf ${EXTTEMP}
	-[ -z "${HTC_ROOT}${XTC_ROOT}" ] || /bin/rm -rf ${HTC_ROOT} ${XTC_ROOT}
	-[ -z "${XDC_ROOT}" ] || /bin/rm -rf ${XDC_ROOT}
