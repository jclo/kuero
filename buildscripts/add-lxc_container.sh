#!/bin/bash
#
# Slackware script to add LXC container capabilities to SpineOS.
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
  . /tmp/build.conf

# List of Slackware packages to install.
TEMPLATE=${TEMPLATE:-lxc}
PACKAGES=${PACKAGES:-"lxc libnih cgmanager btrfs-progs lzo rsync"}

# Extra slackware packages.
#readonly EX_PACK="lxc-1.0.8-x86_64-2.txz"

# Scripts and configuration files.
readonly S_LXC_TEMPLATE="lxc-slackware.patch"
readonly S_LXC_CONF="lxc.conf"
readonly S_LXC_CONT="container.conf"
readonly S_LXC_RC="rc.lxc"

echo ''
echo "This script installs $EX_PACK package and its"
echo 'associated scripts and templates.'
echo ''
echo 'This script does not configure any bridge. It is'
echo 'supposed to work with OpenvSwitch. So, it is to the'
echo 'OpenvSwitch installation script to set a bridge to'
echo 'work with LXC. Otherwise, the installation remains'
echo 'incomplete!'
echo ' '

# Leave him time to read the message.
sleep 3

# Check if there are traces of a previous installation.
if [[ -x /usr/bin/lxc-start ]]; then
  echo '/usr/bin/lxc-start exist! LXC is already installed! Process aborted ...'
  exit 1
fi


# Download and install the slackware packages.
if [[ ! -f /etc/slackpkg/mirrors-dist ]]; then
  mv /etc/slackpkg/mirrors /etc/slackpkg/mirrors-dist
fi
echo ${MIRROR}/${SUITE}/ > /etc/slackpkg/mirrors
slackpkg -batch=on update

echo ${PACKAGES} > ${TPATH}/${TEMPLATE}.template
slackpkg -batch=on -default_answer=y install-template ${TEMPLATE}


# Download and install the extra slackware packages.
#cd /tmp
#wget ${S_OPTIONS} ${EX_PATH}/${EX_PACK}
#if [[ $? -ne 0 ]]; then
#  echo "Failed to download $EX_PACK. Process aborted ..."
#  exit 1
#fi
#installpkg ${EX_PACK}
# Blacklist it to prevent 'kuero upgrade server' to replace it by
# the old lxc package (v0.9) from Slackware 14.1.
#slackpkg -batch=on -default_answer=y blacklist lxc


# Download and install the LXC Template.
#wget ${S_OPTIONS} ${S_OPTIONS} ${S_SERVER}/lxc/${S_LXC_TEMPLATE}
#if [[ $? -ne 0 ]]; then
#  echo "Failed to download $S_LXC_TEMPLATE. Process aborted ..."
#  exit 1
#fi
#mv ${S_LXC_TEMPLATE} /usr/share/lxc/templates/.
#chmod +x /usr/share/lxc/templates/${S_LXC_TEMPLATE}

# Download the patch template and apply it:
wget ${S_OPTIONS} ${S_OPTIONS} ${S_SERVER}/lxc/${S_LXC_TEMPLATE}
if [[ $? -ne 0 ]]; then
  echo "Failed to download $S_LXC_TEMPLATE. Process aborted ..."
  exit 1
fi
cd /usr/share/lxc/templates/
cp lxc-slackware lxc-slackware-distrib
patch < /tmp/$S_LXC_TEMPLATE
cd /tmp

# Download and install the LXC System Configuration files.
wget ${S_OPTIONS} ${S_SERVER}/lxc/${S_LXC_CONF}
if [[ $? -ne 0 ]]; then
  echo "Failed to download $S_LXC_CONF. Process aborted ..."
  exit 1
fi
mv ${S_LXC_CONF} /etc/lxc/.

wget ${S_OPTIONS} ${S_OPTIONS} ${S_SERVER}/lxc/${S_LXC_CONT}
if [[ $? -ne 0 ]]; then
  echo "Failed to download $S_LXC_CONT. Process aborted ..."
  exit 1
fi
mv ${S_LXC_CONT} /etc/lxc/.


# Download and install LXC Startup and Shutdown script
# This script is launched by 'rc.local' and 'rc.local_shutdown'.
# It has to be declared in these two files.
wget ${S_OPTIONS} ${S_OPTIONS} ${S_SERVER}/lxc/${S_LXC_RC}
if [[ $? -ne 0 ]]; then
  echo "Failed to download $S_LXC_RC. Process aborted ..."
  exit 1
fi
mv ${S_LXC_RC} /etc/rc.d/.
chmod +x /etc/rc.d/${S_LXC_RC}


# CONFIGURE
# Create /cgroup.
mkdir /cgroup

# Create data and lxc logical volumes.
mkdir -p /data /lxc
# Create Logical Volumes.
lvcreate -L 1G -n data vg0
lvcreate -L 1G -n lxc vg0
# Format them.
mkfs.ext4  /dev/vg0/data
mkfs.btrfs /dev/vg0/lxc
# Add them to fstab.
sed -i '1a\/dev/vg0/data    /data            ext4        defaults         0   0' /etc/fstab
sed -i '2a\/dev/vg0/lxc     /lxc             btrfs       defaults         0   0' /etc/fstab

#
# Done:
echo 'LXC installed and configured... successfully!'
echo ' '
exit 0
