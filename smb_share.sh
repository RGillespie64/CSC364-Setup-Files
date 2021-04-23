#!/bin/bash
# created by: Richard Gillespie
# purpose: CSC-364 Final Project - Create a Samba share
#########################################

echo "Share Name: "
read FOLDER

# make share name
mkdir -p /share/samba/$FOLDER
# set folder permissions
chmod -R 0770 /share/samba/$FOLDER
# change ownership group on folder
chown -R root:smbgrp /share/samba/$FOLDER
# change SELinux security context on folder
chcon -t samba_share_t /share/samba/$FOLDER

# append folder configuration to smb config.
echo "[$FOLDER]" >> /etc/samba/smb.conf
echo "path = /share/samba/$FOLDER" >> /etc/samba/smb.conf
echo "valid users = @smbgrp" >> /etc/samba/smb.conf
echo "guest ok = no" >> /etc/samba/smb.conf
echo "writable = yes" >> /etc/samba/smb.conf
echo "browsable = yes" >> /etc/samba/smb.conf

# restart the smb/nmb service
systemctl restart smb
systemctl restart nmb
