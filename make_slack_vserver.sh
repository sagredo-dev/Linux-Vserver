#!/bin/bash
#
# v. 2021.11.02
# Author: Roberto Puzzanghera
# Thanks to Mark Colclough for corrections
#
# Installs a Slackware guest into a linux-vserver host (http://linux-vserver.org)
# More info here: https://notes.sagredo.eu/other-contents-186/slackware-guest-on-linux-vserver-7.html
#

# adjust this to where your things live
NAME=php_old
HOSTNAME=$NAME.sagredo.eu
IPv4=10.0.0.22
IPv6=2001:41d0:1:c174::22
INTERFACE=eth0:$IPv4/24
INTERFACE6=eth0:$IPv6/64
CONTEXT=1022
VERSION=14.2 # Slackware version
ARCH=64 # you can put 64 for 64b cpu just to separate 64/32 download folders

# where is the vservers dir? default is /vservers
VDIR=/vservers

# the directory where you unpacked slack_vserver.tar.gz
# $PWD should work, otherwise put /path/to/slack_vserver
SETUP=$PWD

# the directory where you downloaded the slackware packages
PACKAGES=$SETUP/slackware${ARCH}-${VERSION}_pkg

# the path to rc script file (leave as is)
RC=$SETUP/rc

###################################################################################### end configuration
############################################################################ do not touch anything below

# sanity check

if [ ! -d "$VDIR" ]; then
        echo
        echo "Can't find VDIR dir: $VDIR"
        echo "Exiting"
	echo
        exit 1
fi
if [ ! -d "$SETUP" ]; then
        echo
        echo "Can't find SETUP dir: $SETUP"
        echo "Exiting"
	echo
        exit 1
fi
if [ ! -d "$PACKAGES" ]; then
        echo
        echo "Can't find PACKAGES dir: $PACKAGES"
        echo "Exiting"
        echo
        exit 1
fi
if [ ! -f "$RC" ]; then
        echo
        echo "Can't find RC path: $RC"
        echo "Exiting"
        echo
        exit 1
fi

# if everything is ok start the install

echo
echo "Making skeleton..."
vserver $NAME build -m skeleton \
        --hostname $HOSTNAME \
        --interface $INTERFACE \
        --interface $INTERFACE6 \
        --context $CONTEXT \
        --flags lock,virt_mem,virt_uptime,virt_cpu,virt_load,sched_hard,hide_netif \
        --initstyle sysv
echo "...done"
echo

echo "Moving the /dev folder to a temp dir the /dev folder..."
mv $VDIR/$NAME/dev $VDIR/$NAME/dev2
sleep 3
echo

echo "Installing packages..."
sleep 3
cd $PACKAGES
installpkg --root $VDIR/$NAME *.t?z;
# install patches if dir not empty
if [ "$(ls -A patches)" ]; then ROOT=$VDIR/$NAME upgradepkg patches/*.t?z; fi
echo

echo
echo "Installing the rc script to /etc/rc.d/init.d/rc ..."
cp $RC $VDIR/$NAME/etc/rc.d/init.d/
chown root:root $VDIR/$NAME/etc/rc.d/init.d/rc
chmod +x $VDIR/$NAME/etc/rc.d/init.d/rc
echo

echo "Removing x flag to rc.sshd, removing not needed rc scripts..."
chmod -x $VDIR/$NAME/etc/rc.d/rc.sshd
rm $VDIR/$NAME/etc/rc.d/rc.cpufreq $VDIR/$NAME/etc/rc.d/rc.modules* \
   $VDIR/$NAME/etc/rc.d/rc.setterm \
   $VDIR/$NAME/etc/rc.d/rc.inet1* $VDIR/$NAME/etc/rc.d/rc.loop \
   $VDIR/$NAME/etc/rc.d/rc.K $VDIR/$NAME/etc/rc.d/rc.0 \
   $VDIR/$NAME/etc/rc.d/rc.S $VDIR/$NAME/etc/rc.d/rc.4 \
   $VDIR/$NAME/etc/rc.d/rc.inetd
echo

echo "Adjusting HOSTNAME, hosts, resolv.conf, profile. Check them later..."
cp /etc/resolv.conf $VDIR/$NAME/etc/
cp /etc/localtime $VDIR/$NAME/etc/
rm $VDIR/$NAME/etc/profile
cp /etc/profile $VDIR/$NAME/etc/
echo $HOSTNAME > $VDIR/$NAME/etc/HOSTNAME
echo "127.0.0.1 localhost" > $VDIR/$NAME/etc/hosts
echo "$IP $HOSTNAME $NAME" >> $VDIR/$NAME/etc/hosts
touch $VDIR/$NAME/etc/mtab
touch $VDIR/$NAME/etc/fstab
echo

echo "Restoring /dev2 to /dev"
rm -r $VDIR/$NAME/dev
mv $VDIR/$NAME/dev2 $VDIR/$NAME/dev
echo

echo "Updating ca-certificates"
chroot $VDIR/$NAME usr/sbin/update-ca-certificates --fresh 1> /dev/null 2> /dev/null

echo
echo -n "Do you want that I apply the patch for you y/n? [y] "
read VAR_PATCH

if [ "$VAR_PATCH" = 'y' ] || [ "$VAR_PATCH" = 'Y' ] || [ "$VAR_PATCH" = '' ]; then

	if [ ! -f "${SETUP}/linux-vserver_slackware-${VERSION}.patch" ]; then
	      	echo
		echo "Can't find any PATCH here: ${SETUP}/linux-vserver_slackware-${VERSION}.patch"
		echo "Exiting"
		echo
		exit 1
	fi

        cd ${VDIR}/${NAME}/etc/rc.d
        patch -p1 < ${SETUP}/linux-vserver_slackware-${VERSION}.patch
        echo "patch applyed."
        echo
        echo "You can start and enter the virtual server typing: "
        echo
        echo "vserver $NAME start"
        echo "vserver $NAME enter"

else
        echo
        echo "DON'T FORGET to patch /etc/rc.d as follows: "
        echo
        echo "cd ${VDIR}/${NAME}/etc/rc.d"
        echo "patch -p1 < ${SETUP}/linux-vserver_slackware-${VERSION}.patch"
fi

echo
echo "More info at https://notes.sagredo.eu/other-contents-186/slackware-guest-on-linux-vserver-7.html"
echo
