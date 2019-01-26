#!/usr/bin/make
# last mod WmT, 2007-08-22	[ (c) and GPLv2 1999-2007 ]

# ,-----
# |	Assistance
# +-----

CONFIG:=config.mak
MF_HAVE_CONFIG:=$(shell if [ -r ${CONFIG} ] ; then echo y ; else echo n ; fi)

PACKAGE_CFG:=package.mak
MF_HAVE_PACKAGES:=$(shell if [ -r ${PACKAGE_CFG} ] ; then echo y ; else echo n ; fi)

INITRD_CFG:=initrd.mak
MF_HAVE_INITRD:=$(shell if [ -r ${INITRD_CFG} ] ; then echo y ; else echo n ; fi)

ISOFS_CFG:=isofs.mak
MF_HAVE_ISOFS:=$(shell if [ -r ${ISOFS_CFG} ] ; then echo y ; else echo n ; fi)

.PHONY: default help
default: help

help:
ifneq (${MF_HAVE_CONFIG},y)
	@echo "WARNING - Configuration file '${CONFIG}' is missing" 1>&2
endif
	@echo "This 'Makefile' has rules for:"
	@for R in ${USAGE_RULES} ; do echo -e "\t$$R" ; done


# ,-----
# |	Initialisation
# +-----

NATIVE_CPU:=$(shell uname -m)
TARGET_SUFFIX:=gnu
#!! not sen/ban!! TARGET_SUFFIX:=uclibc

HAVE_GLIBC_SYSTEM:=$(shell if [ -r /lib/libc.so.6 ] ; then echo y ; else echo n ; fi)
HAVE_GLIBC5_SYSTEM:=$(shell if [ -r /lib/ld-linux.so.1 ] ; then echo y ; else echo n ; fi)

# initialisation; append to these elsewhere
USAGE_RULES:=
CLEAN_TARGETS:=
REALCLEAN_TARGETS:=


TOPLEV:=$(shell pwd)
ifeq (${MF_HAVE_CONFIG},y)
include ${CONFIG}
CLEAN_TARGETS+= ${EXTTEMP} ${INSTTEMP}
REALCLEAN_TARGETS+= ${XDC_ROOT}
ifneq (${HTC_ROOT}${XTC_ROOT},)
REALCLEAN_TARGETS+= ${HTC_ROOT} ${XTC_ROOT}
endif
endif


# ,-----
# |	Configuration
# +-----

# acquire {HTC|XTC|XDC}_TARGETS et al
ifeq (${MF_HAVE_INITRD},y)
include ${INITRD_CFG}
endif
ifeq (${MF_HAVE_ISOFS},y)
include ${ISOFS_CFG}
endif
ifeq (${MF_HAVE_PACKAGES},y)
include ${PACKAGE_CFG}
endif

USAGE_RULES+= "urls - show download URLs"
.PHONY: urls
ifeq (${URLS},)
urls:
	echo "No URLs"
else
urls:
	@for URL in ${URLS} ; do echo $${URL} ; done
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

USAGE_RULES+= "all (build all toolchains)"
.PHONY: all
ifeq ($(strip ${HTC_TARGETS}${XTC_TARGETS}${XDC_TARGETS}),)
all:
	[ "${HTC_TARGETS}" ] || echo "No HTC_TARGETS"
	[ "${XTC_TARGETS}" ] || echo "No XTC_TARGETS"
	[ "${XDC_TARGETS}" ] || echo "No XDC_TARGETS"
	@exit 1
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
	[ -z "${CLEAN_TARGETS}" ] || rm -rf ${CLEAN_TARGETS}

realclean:
ifneq (${MF_HAVE_CONFIG},y)
	@echo "WARNING - Configuration file '${CONFIG}' is missing" 1>&2
endif
	${MAKE} clean
	[ -z "${REALCLEAN_TARGETS}" ] || rm -rf ${REALCLEAN_TARGETS}
