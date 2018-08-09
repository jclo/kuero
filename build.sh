#!/bin/bash
#
# Script to build Kuero Server.
#
# Copyright (c) 2018 jclo <jclo@mobilabs.fr> (http://www.mobilabs.fr/)
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
  . ./build.conf

echo ''
echo 'This script configures SpineOS to support LXC Containers.'
echo ''
echo 'It adds dnsmasq to become a DNS cache and DHCP server for the'
echo 'LXC containers. It adds Open vSwitch to route internal network.'
echo 'SpineOS internal address is 192.168.1.1. The containers'
echo 'receive addresses starting from 192.168.1.10. And finally,'
echo 'it installs LXC Package with a script to build a minimal'
echo 'slackware container.'
echo ''
echo 'This script relies on: '
echo '  . add-dnsmasq.sh to install and configure Dnsmasq,'
echo '  . add-lxc_container.sh to install and configure LXC,'
echo '  . add-openvswitch.sh to install and configure openvSwitch.'
echo '  . add-git.sh to install git.'
echo '  . add-runscripts.sh to install kuero scripts allowing remote control.'
echo '  . add-packages.sh to install predefined web services (html, node, php).'
echo ''
echo 'These scripts must be executed in this order.'
echo ''

# Ask to confirm installation:
while true; do
  read -p 'Shall we continue [Y/n]?' yn
  case $yn in
    [Yy]* ) echo "Ok, let's go!";
            break;;
    [Nn]* ) echo 'Aborting ...';
            echo ' ';
            exit 0;
            break;;
    * ) echo 'Please answer Yes or No.';;
  esac
done
echo ' '


# Ok. Download scripts.
cd /tmp

# Download add-dnsmasq.sh:
wget ${S_OPTIONS} ${S_SERVER}/buildscripts/add-dnsmasq.sh
if [[ $? -ne 0 ]]; then
  echo 'add-dnsmasq.sh not found!. Process aborted ...'
  exit 1
fi
chmod +x ./add-dnsmasq.sh

# Download add-lxc_container.sh:
wget ${S_OPTIONS} ${S_SERVER}/buildscripts/add-lxc_container.sh
if [[ $? -ne 0 ]]; then
  echo 'add-lxc_container.sh not found!. Process aborted ...'
  exit 1
fi
chmod +x ./add-lxc_container.sh

# Download add-openvswitch.sh:
wget ${S_OPTIONS} ${S_SERVER}/buildscripts/add-openvswitch.sh
if [[ $? -ne 0 ]]; then
  echo 'add-openvswitch.sh not found! Process aborted ...'
  exit 1
fi
chmod +x ./add-openvswitch.sh

# Download add-git.sh:
wget ${S_OPTIONS} ${S_SERVER}/buildscripts/add-git.sh
if [[ $? -ne 0 ]]; then
  echo 'add-git.sh not found! Process aborted ...'
  exit 1
fi
chmod +x ./add-git.sh

# Download add-runscripts.sh:
wget ${S_OPTIONS} ${S_SERVER}/buildscripts/add-runscripts.sh
if [[ $? -ne 0 ]]; then
  echo 'add-runscripts.sh not found! Process aborted ...'
  exit 1
fi
chmod +x ./add-runscripts.sh

# Download add-packages.sh:
wget ${S_OPTIONS} ${S_SERVER}/buildscripts/add-packages.sh
if [[ $? -ne 0 ]]; then
  echo 'add-packages.sh not found! Process aborted ...'
  exit 1
fi
chmod +x ./add-packages.sh

# Download add-core-container.sh:
wget ${S_OPTIONS} ${S_SERVER}/buildscripts/add-core-container.sh
if [[ $? -ne 0 ]]; then
  echo 'add-core-container.sh not found! Process aborted ...'
  exit 1
fi
chmod +x ./add-core-container.sh

# Download postinstall.sh:
wget ${S_OPTIONS} ${S_SERVER}/buildscripts/postinstall.sh
if [[ $? -ne 0 ]]; then
  echo 'postinstall.sh not found! Process aborted ...'
  exit 1
fi
chmod +x ./postinstall.sh


# Install now.
echo 'Ok add-dnsmasq.sh, add-lxc_container.sh, add-openvswitch.sh, add-git.sh, add-runscripts.sh and  add-packages.sh are here.'

# Install Dnsmasq:
cd /tmp
( ./add-dnsmasq.sh ) &
wait
if [[ $? -ne 0 ]]; then
  echo './add-dnsmasq.sh failed. Process aborted ...'
  exit 1
fi
sleep 2

# Install LXC:
cd /tmp
( ./add-lxc_container.sh ) &
wait
if [[ $? -ne 0 ]]; then
  echo './add-lxc_container.sh failed. Process aborted ...'
  exit 1
fi
sleep 2

# Install OpenvSwitch:
cd /tmp
( ./add-openvswitch.sh ) &
wait
if [[ $? -ne 0 ]]; then
  echo './add-openvswitch.sh failed. Process aborted ...'
  exit 1
fi

# Install git:
cd /tmp
( ./add-git.sh 'client') &
wait
if [[ $? -ne 0 ]]; then
  echo './add-git.sh failed. Process aborted ...'
  exit 1
fi

# Install kuero-srv-* scripts:
cd /tmp
( ./add-runscripts.sh ) &
wait
if [[ $? -ne 0 ]]; then
  echo './add-runscripts.sh failed. Process aborted ...'
  exit 1
fi

# Install microservices predefined packages:
cd /tmp
( ./add-packages.sh ) &
wait
if [[ $? -ne 0 ]]; then
  echo './add-packages.sh failed. Process aborted ...'
  exit 1
fi

# Force postinstall.sh script to be executed automatically after the reboot:
cat > /root/.bash_profile <<EOF
sh /tmp/postinstall.sh
EOF
chmod +x /root/.bash_profile


# Add startup and shutdown scripts:

# rc.local
cat >> /etc/rc.d/rc.local <<EOF
# Start openvswitch
if [ -x /etc/rc.d/rc.openvswitch ]; then
        /etc/rc.d/rc.openvswitch start

        # startup br0 (it replaces rc.lxc-bridge)
        /sbin/ifconfig br0 192.168.1.1 netmask 255.255.255.0 promisc up
fi

# Start Lxc Containers
if [ -x /etc/rc.d/rc.lxc ]; then
        /etc/rc.d/rc.lxc start
fi
EOF

# rc.local_shutdown
# We suppose there is no rc.local_shutdown script yet!
# Otherwise the previous one is overwritten.
cat > /etc/rc.d/rc.local_shutdown <<EOF
#!/bin/sh
#
# /etc/rc.d/rc.local_shutdown:  Local system stop script.
#
# Put any local shutdown commands in here.

# Stop Lxc Containers
if [ -x /etc/rc.d/rc.lxc ]; then
        /etc/rc.d/rc.lxc stop
fi

# Stop openvswitch
if [ -x /etc/rc.d/rc.openvswitch ]; then
        /etc/rc.d/rc.openvswitch stop
fi
EOF
chmod +x /etc/rc.d/rc.local_shutdown

# Well done!
echo 'Installation almost complete ...'
echo 'A reboot is required ...'
echo 'After the reboot, you need to login. Then, postinstall.sh script is launched'
echo 'to finalyze the installation.'
echo 'Reboot now!'
exit 0
