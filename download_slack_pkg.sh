#!/bin/bash
#
# 2021.10.13
# Removed lines like
# if [ ! -f ${FILE}*.t?z ]; then
# because they prevented packages with same prefix to be downloaded (i.e. glibc, glibc-i18n)
#
# 2020.11.04
# Do not download patches if version is -current
#
# 2016.06.08
# Now the script parses comments in the package list (thanks to Mark Colclough)

VERSION="14.2" # Slackware version
ARCH="64" # you can put 64 for 64b cpu just to separate 64/32 download folders

# Put here your favourite Slackware repository
SRC=ftp://ftp.gwdg.de/pub/linux/slackware/slackware${ARCH}-${VERSION}
#ftp://ftp.slackware.no/slackware/slackware${ARCH}-${VERSION}

# put here your pkg list
LIST=${PWD}/PKG_LIST_${VERSION}

# the directory where you unpacked slack_vserver.tar.gz
# $PWD should work, otherwise put /path/to/slack_vserver
SETUP=../ #$PWD

# the directory where you want to download the slackware packages
PACKAGES=${SETUP}/slackware${ARCH}-${VERSION}_pkg

# create the folder where the pkg will be downloaded
if [ ! -d $PACKAGES ]; then mkdir -p $PACKAGES; fi

# clean the $PACKAGES dir
rm -r ${PACKAGES}/*

# create the "patches" sub-folder
if [ ! -d ${PACKAGES}/patches ]; then mkdir -p ${PACKAGES}/patches; fi

# download
cd $PACKAGES

if [ -f $LIST ]; then
        while read LINE
            do
		[ "$LINE" ] || continue
		[ "${LINE#\#}" = "$LINE" ] || continue

		FILE=$(echo $LINE | sed -e "s/^.*\/\(.*\)/\1/")
		wget ${SRC}/slackware${ARCH}/${LINE}*.t?z
        done < $LIST
else
	echo "Can't find $LIST file."
	exit 1
fi

# download packages from the patches folder
if [ ${VERSION} != "current" ]; then
	cd ${PACKAGES}/patches

	if [ -f ${LIST} ]; then
        	while read LINE
		do
			IFS='/' read -ra PKG <<< "$LINE"
                	[ "${PKG#\#}" = "${PKG}" ] || continue
			PKG_LEN=${#PKG[@]}
        	        if [ $PKG_LEN == 2 ]; then wget ${SRC}/patches/packages/${PKG[1]}*.t?z; fi
        	done < $LIST
	else
		echo "Can't find $LIST file."
	        exit 1
	fi
fi
