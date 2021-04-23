#!/bin/bash
# created by: Richard Gillespie
# purpose: CSC-364 Final Project - Basic DHCP Setup and Configuration
# Note: did not include how to add static ips on purpose. Little research and you will be able to figure it out.

# install dhcp server
dnf install -y dhcp-server

# copy the default config to .orig
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.orig

# set the domain name (ex: localdomain.lan)
echo "Domain Name: "
read DNAME

# set the default ns1 and ns2 servers
echo "Domain Name Server 1: (Do not include ns1)"
read NSERVER1

echo "Domain Name Server 2: (Do not include ns2)"
read NSERVER2

# set the subnet declaration
echo "Enter the subnet: (ex. 192.168.20.0)"
read SUBNET

# set the netmask
echo "Enter the Subnet Mask: (ex. 255.255.255.0)"
read SMASK

# set default router
echo "Enter default router: (ex. 192.168.20.1)"
read ROUTER

# set the beginning ip for the range
echo "Enter the Starting IP for the range: (ex. 192.168.20.20)"
read STARTIP
# set the end ip for the range
echo "Enter the End IP for the range: (ex. 192.168.20.40)"
read ENDIP

# write dhcpd.conf file
echo "option domain-name \"$DNAME\";" >> /etc/dhcp/dhcpd.conf
echo "option domain-name-servers ns1.$NSERVER1, ns2.$NSERVER2;" >> /etc/dhcp/dhcpd.conf
echo "default-lease-time 3600;" >> /etc/dhcp/dhcpd.conf
echo "max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
echo "authoritative;" >> /etc/dhcp/dhcpd.conf
echo "log-facility local7;" >> /etc/dhcp/dhcpd.conf
echo "subnet $SUBNET netmask $SMASK {" >> /etc/dhcp/dhcpd.conf
echo "option routers $ROUTER;" >> /etc/dhcp/dhcpd.conf
echo "option subnet-mask $SMASK;" >> /etc/dhcp/dhcpd.conf
echo "option domain-search \"$DNAME\";" >> /etc/dhcp/dhcpd.conf
echo "range $STARTIP $ENDIP;" >> /etc/dhcp/dhcpd.conf
echo "}" >> /etc/dhcp/dhcpd.conf
echo "" >> /etc/dhcp/dhcpd.conf

# add firewall rules for dhcp
firewall-cmd --add-service=dhcp --permanent
firewall-cmd --reload

# start the service
sytemctl start dhcpd
# enable the service to start on boot
systemctl enable dhcpd


