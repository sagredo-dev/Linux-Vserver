#!/bin/bash
#
# v. 2011.04.28
# Author: Roberto Puzzanghera
#
# This script installs a Slackware guest into a linux-vserver host (http://linux-vserver.org)
#
# Comments are welcome :-)
# More info here: https://notes.sagredo.eu/other-contents-186/slackware-guest-on-linux-vserver-7.html

if [ $# != 1 ]; then
  echo "usage: $0 <server-name>"
  exit 1
fi

NAME=$1
HOSTNAME=$NAME.YOURDOMAIN.XY
IP=10.0.0.188
INTERFACE=eth0:$IP/24
IP6=fec0::4
INTERFACE6=eth0:$IP6/64
CONTEXT=7001

vserver ${NAME} build -m skeleton \
        --hostname ${HOSTNAME} \
        --interface ${INTERFACE} \
	--interface ${INTERFACE6} \
        --context ${CONTEXT} \
        --flags lock,virt_mem,virt_uptime,virt_cpu,virt_load,sched_hard,hide_netif \
        --initstyle sysv
