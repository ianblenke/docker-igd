EXTIFACE:=eth0
INTIFACE:=docker0
INTADDR:=172.17.42.1
INTNET:=172.17.0.0/16

#!/usr/bin/make -f
all:
	# Update index
	apt-get update
	# Add Ian
	id icblenke || make icblenke
	# Install docker
	which docker || make docker
	# Install minissdpd / upnpd
	which minissdpd || make minissdpd
	which upnpd || make upnpd
	# Install Internet Gateway Device daemon
	which linux-igd || make linux-igd

minissdpd:
	apt-get install -y minissdpd
	grep -e '^START_DAEMON=' /etc/default/minissdpd || \
	echo "START_DAEMON=1" >> /etc/default/minissdpd
	grep -e '^MiniSSDPd_INTERFACE_ADDRESS=' /etc/default/minissdpd || \
	echo "MiniSSDPd_INTERFACE_ADDRESS=$(EXTIFACE)" >> /etc/default/minissdpd
	sed -i -e 's/^MiniSSDPd_INTERFACE_ADDRESS=.*$$/MiniSSDPd_INTERFACE_ADDRESS=$(INTIFACE)/' \
       	       -e 's/^START_DAEMON=.*$$/START_DAEMON=1/' \
	       /etc/default/minissdpd
	/etc/init.d/minissdpd restart

miniupnpd:
	DEBIAN_FRONTEND=noninteractive apt-get install -y miniupnpd
	grep -e '^START_DAEMON=' /etc/default/miniupnpd || \
	echo "START_DAEMON=1" >> /etc/default/miniupnpd
	grep -e '^MiniUPnPd_EXTERNAL_INTERFACE=' /etc/default/miniupnpd || \
	echo "MiniUPnPd_EXTERNAL_INTERFACE=$(EXTIFACE)" >> /etc/default/miniupnpd
	grep -e '^MiniUPnPd_LISTENING_IP=$(INTIFACE)' /etc/default/miniupnpd || \
	echo "MiniUPnPd_LISTENING_IP=$(INTIFACE)" >> /etc/default/miniupnpd
	sed -i -e 's/^iniUPnPd_ip6tables_enable=.*$$/iniUPnPd_ip6tables_enable=yes/' \
	       -e 's/^MiniUPnPd_EXTERNAL_INTERFACE=.*$$/MiniUPnPd_EXTERNAL_INTERFACE=$(EXTIFACE)/' \
	       -e 's/^MiniUPnPd_LISTENING_IP=.*$$/MiniUPnPd_LISTENING_IP=$(INTIFACE)/' \
	       -e 's/^START_DAEMON=.*$$/START_DAEMON=1/' \
	       /etc/default/miniupnpd
	sed -i -e 's/^ext_ifname=.*$$/ext_ifname=$(EXTIFACE)/' \
	       -e 's/^listening_ip=.*$$/listening_ip=$(INTIFACE)/' \
	       -e 's/^enable_natpmp=.*$$/enable_natpmp=yes/' \
	       -e 's/^enable_upnp=.*$$/enable_upnp=yes/' \
	       -e 's%192\.168\.1\.0/24%$(INTNET)%' \
	       /etc/miniupnpd/miniupnpd.conf
	/etc/init.d/miniupnpd restart

linux-igd:
	apt-get install -y linux-igd
	grep -e '^EXTIFACE=' /etc/default/linux-igd || \
	echo EXTIFACE=$(EXTIFACE) >> /etc/default/linux-igd
	grep -e '^INTIFACE=' /etc/default/linux-igd || \
	echo INTIFACE=$(INTIFACE) >> /etc/default/linux-igd
	sed -i -e 's/^EXTIFACE=.*$$/EXTIFACE=$(EXTIFACE)/' \
	       -e 's/^INTIFACE=.*$$/INTIFACE=$(INTIFACE)/' \
	       /etc/default/linux-igd
	/etc/init.d/linux-igd restart

icblenke:
	groupadd -g 1000 icblenke
	useradd -g 1000 -u 1000 -d /home/icblenke -s /bin/bash -c 'Ian Blenke' -m icblenke
	usermod -aG docker icblenke
	usermod -aG sudo icblenke
	[ -d /home/icblenke/.ssh ] || ( \
		rsync -aq /root/.ssh/ /home/icblenke/.ssh ; \
		chown -R icblenke:icblenke /home/icblenke/.ssh ; \
	)

docker:
	wget -qO- https://get.docker.com/ | sh


