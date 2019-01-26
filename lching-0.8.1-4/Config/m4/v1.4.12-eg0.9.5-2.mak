# m4 1.4.12
# last mod WmT, 2008-10-13	[ (c) and GPLv2 1999-2008 ]

# ,-----
# |	Settings
# +-----

M4_PKG:=m4
#M4_VER:=1.4.8
M4_VER:=1.4.12
# 1.4.9 broken wchar support w/uClibc?

M4_SRC:=
M4_SRC+=${SOURCEROOT}/m/m4-${M4_VER}.tar.bz2

M4_PATH:=m4-${M4_VER}

##	ftp://ftp.seindal.dk/gnu/m4-${M4_VER}.tar.gz	# v1.4[a-z]
URLS+=http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/m4/m4-${M4_VER}.tar.bz2

#DEPS:=
#DEPS+=m4

# ,-----
# |	Configure [htc]
# +-----


${EXTTEMP}/${M4_PATH}/Makefile:
	[ ! -d ${EXTTEMP}/${M4_PATH} ] || rm -rf ${EXTTEMP}/${M4_PATH}
	${MAKE} extract LIST="$(strip ${M4_SRC})"
#	echo "*** PATCHING ***"
#	( cd ${EXTTEMP} || exit 1 ;\
#		for PF in ${M4_PKG}*patch ; do \
#			cat $${PF} | ( cd ${M4_PATH} && patch -Np1 - ) || exit 1 ;\
#			rm -f $${PF} ;\
#		done
	( cd ${EXTTEMP}/${M4_PATH} || exit 1 ;\
		case $(shell gcc -v 2>&1 | sed '/specs/ s/.* // ; t ; d') in \
		*-earlgrey-*|*-senban-*) \
			for SF in freadahead.c freading.c fseeko.c ; do \
		 	 	[ -r lib/$${SF}.OLD ] || mv lib/$${SF} lib/$${SF}.OLD || exit 1 ;\
		 	 	cat lib/$${SF}.OLD \
		 	 	 	| sed 's/__modeflags/modeflags/' \
		 	 	 	| sed 's/__bufpos/bufpos/' \
		 	 	 	| sed 's/__bufread/bufread/' \
		 	 	 	| sed 's/__bufstart/bufstart/' \
		 	 	 	| sed 's%def __STDIO_BUFFERS% 0 /* __STDIO_BUFFERS */%' \
		 	 	 	> lib/$${SF} || exit 1 ;\
			done \
		;; \
		esac \
	) || exit 1


${EXTTEMP}/${M4_PATH}-htc/config.status:
	${MAKE} ${EXTTEMP}/${M4_PATH}/Makefile
	[ ! -d ${EXTTEMP}/${M4_PATH}-htc ] || rm -rf ${EXTTEMP}/${M4_PATH}-htc
	mv ${EXTTEMP}/${M4_PATH} ${EXTTEMP}/${M4_PATH}-htc
	( cd ${EXTTEMP}/${M4_PATH}-htc || exit 1 ;\
	  	CC=${NATIVE_GCC} \
	  	  AS=$(shell echo ${NATIVE_GCC} | sed 's/gcc$$/as/') \
	    	  CFLAGS=-O2 \
			./configure \
			  --prefix=${HTC_ROOT}/usr \
			  --disable-largefile \
			  --without-included-regex \
			  || exit 1 \
	)	|| exit 1


# ,-----
# |	Build [htc]
# +-----

${EXTTEMP}/${M4_PATH}-htc/src/m4: ${EXTTEMP}/${M4_PATH}-htc/config.status
	( cd ${EXTTEMP}/${M4_PATH}-htc || exit 1 ;\
		make || exit 1 \
	) || exit 1


# ,-----
# |	Install [htc]
# +-----

${HTC_ROOT}/usr/bin/m4:
	${MAKE} ${EXTTEMP}/${M4_PATH}-htc/src/m4
	( cd ${EXTTEMP}/${M4_PATH}-htc || exit 1 ;\
		make install || exit 1 \
	) || exit 1
ifeq (${HAVE_PTRACKING},y)
	DBROOT=${HTC_ROOT} ${PTRACK_SCRIPT} upgrade ${M4_PKG} ${M4_VER}
endif

# ,-----
# |	Entry points [htc, xdc]
# +-----

.PHONY: htc-m4
htc-m4: ${HTC_ROOT}/usr/bin/m4
