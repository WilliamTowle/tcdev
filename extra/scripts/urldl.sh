#!/bin/sh

do_download()
{
	if [ -z "$1" ] ; then
		echo "$0: Expected SOURCEDIR" 1>&2
		exit 1
	fi
	SOURCEDIR=$1
	shift

	FAILS=n
	while read INPUTLINE ; do
		case ${INPUTLINE} in
		make:*) # ignore
		;;
		*)
			URL=`echo ${INPUTLINE} | sed 's/.* //'`
			case ${URL} in
			*.bz2|*.gz|*.tgz|*.zip|*.exe|*.patch|*-[0-9][0-9][0-9])
				ARCHIVE=`basename $URL`
			;;
			*.zip?*)
				ARCHIVE=`basename \`echo $URL | sed 's/?.*//'\``
			;;
			*)
				echo "$0: Unhandled URL format: ${URL}" 1>&2
				exit 1
			;;
			esac

			SUBDIR=${SOURCEDIR}/`echo ${ARCHIVE} | sed 's/\(.\).*/\1/'`

			[ -d ${SUBDIR} ] || mkdir -p ${SUBDIR}
			[ -r ${SUBDIR}/${ARCHIVE} ] || wget ${URL} -O ${SUBDIR}/${ARCHIVE} || FAILS=y
		;;
		esac
	done

	if [ "${FAILS}" != 'n' ] ; then
		echo "$0: WARNING: Some downloads failed" 1>&2
		find ${SOURCEDIR} -empty | while read FILE ; do
			echo "$0: WARNING: ${FILE} is zero bytes" 1>&2
		done
		exit 1
	fi
}

if [ -t 0 ] ; then
	# isatty - not allowed
	echo "$0: Need URLs on STDIN" 1>&2
	exit 1
fi

do_download ${1+"$@"}
echo "Done"
