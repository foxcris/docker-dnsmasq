#!/bin/bash

info() { logger "DOCKER_DNSMASQ: $*"; }

/etc/init.d/rsyslog start
/etc/init.d/cron start

if [ ! -f /etc/dnsmasq.conf  ]
then
  cp -r /etc/dnsmasq.conf_default /etc/dnsmasq.conf
fi

if [ `cat /etc/dnsmasq.conf | wc -l` -eq 0 ]
then
  cp -r /etc/dnsmasq.conf_default /etc/dnsmasq.conf
fi

cp -r /etc/dnsmasq.conf_default /etc/dnsmasq.d/dnsmasq.conf

#fix permissions for config files
chmod -R a+r /etc/dnsmasq.d

#adapt config
sed -i 's/#no-resolv/no-resolv/' /etc/dnsmasq.d/dnsmasq.conf
sed -i 's/#no-hosts/no-hosts/' /etc/dnsmasq.d/dnsmasq.conf
if [ "${DOCKER_DNSMASQ_DOMAIN}" != "" ]
then
  info "Configure: domain=${DOCKER_DNSMASQ_DOMAIN}"
  sed -i "s/#domain=thekelleys.org.uk/domain=${DOCKER_DNSMASQ_DOMAIN}/" /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_LISTENADDRESS}" != "" ]
then
  info "Configure: listen-address=${DOCKER_DNSMASQ_LISTENADDRESS}"
  sed -i "s/#listen-address=/listen-address=${DOCKER_DNSMASQ_LISTENADDRESS}/" /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_INTERFACE}" != "" ]
then
  info "Configure: interface=${DOCKER_DNSMASQ_INTERFACE}"
  sed -i "s/#interface=/interface=${DOCKER_DNSMASQ_INTERFACE}/" /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_INTERFACE}" != "" ] || [ "${DOCKER_DNSMASQ_LISTENADDRESS}" != "" ]
then
  info "Configure: bind-interfaces"
  sed -i "s/#bind-interfaces/bind-interfaces/" /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_DHCPRANGE_IPSTART}" != "" ] && [ "${DOCKER_DNSMASQ_DHCPRANGE_IPEND}" != "" ] && [ "${DOCKER_DNSMASQ_DHCPRANGE_NETMASK}" != "" ] && [ "${DOCKER_DNSMASQ_DHCPRANGE_LEASETIME}" != "" ]
then
  info "Configure: dhcp-range=${DOCKER_DNSMASQ_DHCPRANGE_IPSTART},${DOCKER_DNSMASQ_DHCPRANGE_IPEND},${DOCKER_DNSMASQ_DHCPRANGE_NETMASK},${DOCKER_DNSMASQ_DHCPRANGE_LEASETIME}"
  echo dhcp-range=${DOCKER_DNSMASQ_DHCPRANGE_IPSTART},${DOCKER_DNSMASQ_DHCPRANGE_IPEND},${DOCKER_DNSMASQ_DHCPRANGE_NETMASK},${DOCKER_DNSMASQ_DHCPRANGE_LEASETIME} >> /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_DEBUG}" = "true" ]
then
  info "Configure: log-queries"
  info "Configure: log-dhcp"
  sed -i "s/#log-queries/log-queries/" /etc/dnsmasq.d/dnsmasq.conf
  sed -i "s/#log-dhcp/log-dhcp/" /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_DNSFORWARD}" != "" ]
then
  info "Configure: server=${DOCKER_DNSMASQ_DNSFORWARD}"
  sed -i "s/#server=.*/server=${DOCKER_DNSMASQ_DNSFORWARD}/" /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_DNS_PORT}" != "" ]
then
  info "Configure: port=${DOCKER_DNSMASQ_DNS_PORT}"
  sed -i "s/#port=.*/port=${DOCKER_DNSMASQ_DNS_PORT}/" /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_DHCP_GATEWAY}" != "" ]
then
  info "Configure: dhcp-option=3,${DOCKER_DNSMASQ_DHCP_GATEWAY}"
  echo "dhcp-option=3,${DOCKER_DNSMASQ_DHCP_GATEWAY}" >> /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_DHCP_DNS}" != "" ]
then
  info "Configure: dhcp-option=6,${DOCKER_DNSMASQ_DHCP_DNS}"
  echo "dhcp-option=6,${DOCKER_DNSMASQ_DHCP_DNS}" >> /etc/dnsmasq.d/dnsmasq.conf
fi
if [ "${DOCKER_DNSMASQ_DHCP_NTP}" != "" ]
then
  info "Configure: dhcp-option=42,${DOCKER_DNSMASQ_DHCP_NTP}"
  echo "dhcp-option=42,${DOCKER_DNSMASQ_DHCP_NTP}" >> /etc/dnsmasq.d/dnsmasq.conf
fi

/etc/init.d/dnsmasq start

while [ ! -f /var/log/syslog ]
do
  sleep 1s
done

tail -f /var/log/syslog