#!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for SUSE based
#               : operating systems
#               :
#               :
# STATUS        : BETA
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct

#======================================
# Add missing gpg keys to rpm
#--------------------------------------
suseImportBuildKey

#======================================
# Activate services
#--------------------------------------
suseInsertService sshd
suseInsertService munge
suseInsertService slurmd
suseInsertService slurmctld
suseInsertService nfs-server

#======================================
# Setup default target, multi-user
#--------------------------------------
baseSetRunlevel 3

# add local repo
mkdir /root/local
zypper ar -p10 /root/local/ local

#======================================
#fix ssh key
#--------------------------------------
chmod 600 /root/.ssh/id_rsa

#======================================
# have a seperate user
#--------------------------------------
useradd -m auser
cp -r /root/.ssh /home/auser
chown -R  auser:users /home/auser

#======================================
# munge key
#--------------------------------------
#groupadd -r munge
#useradd -r -g munge -d /run/munge -s /bin/false -c "MUNGE user" munge
#chown -R munge:munge /etc/munge
#/usr/sbin/mungekey -c -b 8192
#chmod 600 /etc/munge/munge.key

#======================================
# nfs settings
#--------------------------------------
cat >> /etc/exports <<EOF
/srv/home *(rw,no_subtree_check,sync,no_root_squash)
EOF
mkdir -p /srv/home
mv /home/auser /srv/home

#======================================
# Get hostname from dhcp
#--------------------------------------
sed -i 's/DHCLIENT_SET_HOSTNAME="no"/DHCLIENT_SET_HOSTNAME="yes"/' /etc/sysconfig/network/dhcp

#======================================
# fix motd
#--------------------------------------
source /etc/os-release
echo $PRETTY_NAME >> /etc/motd
