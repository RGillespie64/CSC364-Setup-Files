#!/bin/bash
# created by: Richard Gillespie
# purpose: CSC-364 Final Project - Basic BIND DNS Setup

# install bind DNS
dnf install bind bind-utils -y

# move default configuration to backup
mv /etc/named.conf /etc/named.conf.orig

# set ip subnet
echo "IP Network: (ex. 192.168.20.0)"
read IPNET

# set CIDR notation subnet
echo "Subnet in CIDR Notation: (ex. 24)"
read CIDR

# set DNS zone
echo "Enter Zone Name: (ex. csc364.lan)"
read ZONE

# set DNS File name for forward zone
echo "Enter Filename for DNS Forward Zone: (ex. csc.lan.db)"
read FZONENAME

# set reverse zone name
echo "Enter Reverse Zone: (ex. 20.168.192.in-addr.arpa)"
read RZONE

# set DNS File name for reverse zone
echo "Enter Filename for DNS Reverse Zone: (ex. csc364.lan.rev)"
read RZONENAME

# named.conf file
touch /etc/named.conf
echo -e "//" >> /etc/named.conf
echo -e "// named.conf" >> /etc/named.conf
echo -e "// Provided by Red hat bind package to configure the ISC BIND named(8) DNS" >> /etc/named.conf
echo -e "// server as acaching only nameserver (as a localhost DNS reolver only)" >> /etc/named.conf
echo -e "//" >> /etc/named.conf
echo -e "// see /usr/share/doc/bind*/sample for example named configuration files." >> /etc/named.conf

echo -e "" >> /etc/named.conf
echo -e "options {" >> /etc/named.conf
echo -e "\t#listen-on port 53 { 127.0.0.1; };" >> /etc/named.conf
echo -e "\t#listen-on-v6 port 53 { ::1; };" >> /etc/named.conf
echo -e "\tdirectory \"/var/named\";" >> /etc/named.conf
echo -e "\tdump-file \"/var/named/data/cache_dump.db\";" >> /etc/named.conf
echo -e "\tstatistics-file \"/var/named/data/named_stats.txt\";" >> /etc/named.conf
echo -e "\tmemstatistics-file \"/var/named/data/named_mem_stats.txt\";" >> /etc/named.conf
echo -e "\tsecroots-file \"/var/named/data/named.secroots\";" >> /etc/named.conf
echo -e "\trecursing-file \"/var/named/data/named.recursing\";" >> /etc/named.conf
echo -e "\tallow-query { localhost; $IPNET/$CIDR; };" >> /etc/named.conf
echo -e "\trecursion yes;" >> /etc/named.conf
echo -e "\tdnssec-enable yes;" >> /etc/named.conf
echo -e "\tdnssec-validation yes;" >> /etc/named.conf
echo -e "\tmanaged-keys-directory \"/var/named/dynamic\";" >> /etc/named.conf
echo -e "\tpid-file \"/run/named/named.pid\";" >> /etc/named.conf
echo -e "\tsession-keyfile \"/run/named/session.key\";" >> /etc/named.conf
echo -e "\tinclude \"/etc/crypto-policies/back-ends/bind.config\";" >> /etc/named.conf
echo -e "};" >> /etc/named.conf

echo -e "" >> /etc/named.conf
echo -e "logging {" >> /etc/named.conf
echo -e "\tchannel default_debug {" >> /etc/named.conf
echo -e "\t\tfile \"data/named.run\";" >> /etc/named.conf
echo -e "\t\tseverity	dynamic;" >> /etc/named.conf
echo -e "\t};" >> /etc/named.conf
echo -e "};" >> /etc/named.conf

echo -e "" >> /etc/named.conf
echo -e "zone \".\" IN {" >> /etc/named.conf
echo -e "\ttype hint;" >> /etc/named.conf
echo -e "\tfile "named.ca";" >> /etc/named.conf
echo -e "};" >> /etc/named.conf

echo -e "" >> /etc/named.conf
echo -e "include \"/etc/named.rfc1912.zones\";" >> /etc/named.conf
echo -e "include \"/etc/named.root.key\";" >> /etc/named.conf

echo -e "" >> /etc/named.conf
echo -e "zone \"$ZONE\" IN {" >> /etc/named.conf
echo -e "\ttype master;" >> /etc/named.conf
echo -e "\tfile \"$FZONENAME\";" >> /etc/named.conf
echo -e "\tallow-update { none; };" >> /etc/named.conf
echo -e "\tallow-query { any; };" >> /etc/named.conf
echo -e "};" >> /etc/named.conf

echo -e "" >> /etc/named.conf
echo -e "zone \"$RZONE\" IN {" >> /etc/named.conf
echo -e "\ttype master;" >> /etc/named.conf
echo -e "\tfile \"$RZONENAME\";" >> /etc/named.conf
echo -e "\tallow-update { none; };" >> /etc/named.conf
echo -e "\tallow-query { any; };" >> /etc/named.conf
echo -e "};" >> /etc/named.conf

# forward zone file

# get DNS Server IP
echo "Enter DNS Server IP: (ex. 192.168.20.1)"
read DNSIP

# get DNS server NETBIOS Name
echo "Enter NETBIOS Name of DNS Server: (ex. example01)"
read NETNAME

touch /var/named/$FZONENAME
echo -e "\$TTL 86400" >> /var/named/$FZONENAME
echo -e "@ IN SOA $ZONE. root.$ZONE. (" >> /var/named/$FZONENAME
echo -e "1 ;Serial" >> /var/named/$FZONENAME
echo -e "3600 ;Refresh" >> /var/named/$FZONENAME
echo -e "1800 ;Retry" >> /var/named/$FZONENAME
echo -e "604800 ;Expire" >> /var/named/$FZONENAME
echo -e "86400 ;Minimum TTL" >> /var/named/$FZONENAME
echo -e ")" >> /var/named/$FZONENAME

echo -e ";Name Server Information" >> /var/named/$FZONENAME
echo -e "@ IN NS $NETNAME.$ZONE." >> /var/named/$FZONENAME
echo -e "@ IN A $DNSIP" >> /var/named/$FZONENAME

echo -e ";A Record for IP address to Hostname " >> /var/named/$FZONENAME
echo -e "" >> /var/named/$FZONENAME


# get the last octect number of the IP Address
echo "Enter Last octect IP for DNS Server: (ex. 1)"
read ENDOCT

# reverse zone file
touch /var/named/$RZONENAME
echo -e "\$TTL 86400" >> /var/named/$RZONENAME
echo -e "@ IN SOA $ZONE. root.$ZONE. (" >> /var/named/$RZONENAME
echo -e "1 ;Serial" >> /var/named/$RZONENAME
echo -e "3600 ;Refresh" >> /var/named/$RZONENAME
echo -e "1800 ;Retry" >> /var/named/$RZONENAME
echo -e "604800 ;Expire" >> /var/named/$RZONENAME
echo -e "86400 ;Minimum TTL" >> /var/named/$RZONENAME
echo -e ")" >> /var/named/$RZONENAME
echo -e ";Name Server Information" >> /var/named/$RZONENAME
echo -e "@ IN NS $NETNAME.$ZONE." >> /var/named/$RZONENAME

echo -e ";Reverse lookup for Name Server" >> /var/named/$RZONENAME
echo -e "$ENDOCT IN PTR $NETNAME.$ZONE." >> /var/named/$RZONENAME

echo -e ";PTR Record IP address to HostName" >> /var/named/$RZONENAME

# check configuration and zones
named-checkconf
named-checkzone $ZONE /var/named/$FZONENAME
named-checkzone $DNSIP /var/named/$RZONENAME

# start bind dns and enable it for startup
systemctl start named
systemctl enable named
systemctl status named

# firewall commands
firewall-cmd --permanent --add-service=dns
firewall-cmd --reload


# add DNS Server IP to resolv.conf
echo "nameserver $DNSIP" >> /etc/resolv.conf

# restart the network service
systemctl restart NetworkManager.service

# test DNS server
dig zues01.csc364.lan
nslookup zues01.csc364.lan

echo "Please make sure to edit you /etc/sysconfig/network-scripts/ifcfg-xxxx file with the following setting: DNS=$DNSIP"
echo ""
echo "Please add $DNSIP to you client DNS server list as well!"

