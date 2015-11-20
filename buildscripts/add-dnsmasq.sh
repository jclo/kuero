#!/bin/bash
#
# Slackware script to add DNS and DHCP capabilities to SpineOS.
# 
# Copyright (c) 2015 jclo <jclo@mobilabs.fr> (http://www.mobilabs.fr/)
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# Load configuration file.
  . /tmp/build.conf

# List of Slackware packages to install.
TEMPLATE=${TEMPLATE:-dnsmasq}
PACKAGES=${PACKAGES:-"dnsmasq"}


echo ''
echo "This script installs Dnsmasq and it configures"
echo 'SpineOS to become a DNS cache and DHCP Server.'
echo ''

# Leave him time to read the message.
sleep 3

# Install and configure dnsmasq
echo 'Installing and configuring Dnsmasq ...'


# Check if there are traces of a previous installation
if [[ -x /usr/sbin/dnsmasq ]]; then
  echo '/usr/sbin/dnsmasq exists! Dnsmasq is already installed! Process aborted ...'
  exit 1
fi

# Install slackware packages
if [[ ! -f /etc/slackpkg/mirrors-dist ]]; then
  mv /etc/slackpkg/mirrors /etc/slackpkg/mirrors-dist
fi
echo ${MIRROR}/${SUITE}/ > /etc/slackpkg/mirrors
slackpkg -batch=on update

echo ${PACKAGES} > ${TPATH}/${TEMPLATE}.template
slackpkg -batch=on -default_answer=y install-template ${TEMPLATE}


# Configure dnsmasq.conf
echo 'Configuring /etc/dnsmasq.conf ...'
mv /etc/dnsmasq.conf /etc/dnsmasq-dist.conf
cat > /etc/dnsmasq.conf <<EOF
# I/F to listen
interface=br0

domain-needed
bogus-priv
 
domain=mycompany.org
expand-hosts
local=/mycompany.org/

# Google and OpenDNS DNS
server=8.8.8.8
server=8.8.4.4
server=208.67.220.220
 
dhcp-lease-max=255
dhcp-authoritative
 
# DHCP Range for Virtual Servers
dhcp-range=br0,192.168.1.10,192.168.1.199,4h
 
#Virtual Servers
dhcp-host=core
# end
EOF
chmod ugo+x /etc/rc.d/rc.dnsmasq

# Configure /etc/hosts
echo 'Configuring /etc/hosts ...'
cp /etc/hosts /etc/hosts-dist
sed -i '14,+5d' /etc/hosts

cat >> /etc/hosts <<EOF
# For loopbacking.
127.0.0.1        localhost
192.168.1.1      HOSTNAME.mycompany.org HOSTNAME
192.168.1.99     core

# Services
#192.168.1.10    server
#192.168.1.11    server
#192.168.1.12    server
#192.168.1.13    server
#192.168.1.14    server
#192.168.1.15    server
#192.168.1.16    server
#192.168.1.17    server
#192.168.1.18    server
#192.168.1.19    server
# End of hosts.
EOF
# Update 'hostname'
sed -i "s/HOSTNAME/`hostname`/g" /etc/hosts 

# Done:
echo 'Dnsmasq configuration completed... successfully!'
echo ' '
exit 0
