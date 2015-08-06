#!/bin/bash

EXTIFACE=${EXTIFACE:-eth0}
INTIFACE=${INTIFACE:-docker0}

grep -e "^EXTIFACE=" /etc/default/linux-igd || \
  echo "EXTIFACE=${EXTIFACE}" >> /etc/default/linux-igd

grep -e "^INTIFACE=" /etc/default/linux-igd || \
  echo "INTIFACE=${INTIFACE}" >> /etc/default/linux-igd

sed -i -e "s/^EXTIFACE=.*\$/EXTIFACE=${EXTIFACE}/" \
       -e "s/^INTIFACE=.*\$/INTIFACE=${INTIFACE}/" \
       /etc/default/linux-igd

. /etc/default/linux-igd

# This is needed to keep running in the foreground in debug mode
exec /usr/sbin/upnpd -f ${EXTIFACE} ${INTIFACE}
