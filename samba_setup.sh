#!/bin/bash
# created by: Richard Gillespie
# purpose: CSC-364 Final Project - Samba Setup and Default Configuration


# install samba
dnf install -y samba samba-common samba-client

# move default smb config to a .orig
mv /etc/samba/smb.conf /etc/samba/smb.conf.orig

# Set File Server NETBIOS name
echo "NETBIOS name: "
read NETBIOS

# Setup the smb configuration file
touch /etc/samba/smb.conf
echo "[global]" >> /etc/samba/smb.conf
echo "workgroup = WORKGROUP" >> /etc/samba/smb.conf
echo "server string = Samba Server %v" >> /etc/samba/smb.conf
echo "netbios name = $NETBIOS" >> /etc/samba/smb.conf
echo "security = user" >> /etc/samba/smb.conf
echo "map to guest = never" >> /etc/samba/smb.conf
echo "dns proxy = no" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf

# run test on the the configuration file
testparm

# add samba service to the firewall
firewall-cmd --permanent --add-service=samba
# reload firewall rules
firewall-cmd --reload

# start the smb/nmb service
systemctl start smb
systemctl start nmb

# enable smb/nmb service on startup
systemctl enable nmb
systemctl enable smb

# systemctl status smb
# systemctl status nmb

# Get smb username
echo "Samba Username: "
read USER

# create the first secure group
groupadd smbgrp
# assign samba user to group
usermod -aG smbgrp $USER
# create the smb password for user
smbpasswd -a $USER

# Get secure folder name
echo "Initial Share Name: "
read FOLDER

# create initial share folder
mkdir -p /share/samba/$FOLDER
# set the permissions to the share location
chmod -R 0770 /share/samba/$FOLDER
# change ownership of the share location
chown -R root:secure_group /share/samba/$FOLDER
# change SELinux security context for the directory
chcon -t samba_share_t /share/samba/$FOLDER

# append folder configuration to smb config.
echo "[$FOLDER]" >> /etc/samba/smb.conf
echo "path = /share/samba/$FOLDER" >> /etc/samba/smb.conf
echo "valid users = @smbgrp" >> /etc/samba/smb.conf
echo "browsable = yes" >> /etc/samba/smb.conf
echo "writable = yes" >> /etc/samba/smb.conf
echo "guest ok = no" >> /etc/samba/smb.conf

# restart smb/nmb service
systemctl restart smb
systemctl restart nmb



