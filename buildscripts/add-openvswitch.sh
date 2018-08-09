#!/bin/bash
#
# Slackware script to install Open vSwitch into SpineOS.
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
TEMPLATE=${TEMPLATE:-openvswitch}
PACKAGES=${PACKAGES:-"gcc libcap-ng"}

# Extra slackware packages.
EX_PACK="openvswitch-utils-2.5.0-x86_64-1_SBo.tgz"
V_vSWITCH="2.5.0"


echo ''
echo "This script installs the package $EX_PACK and its"
echo 'associated scripts.'
echo 'It creates an internal bridge "br0" starting at the'
echo 'address 192.168.1.1'
echo ''

# Leave him time to read the message.
sleep 3


# Check if there are traces of a previous installation.
if [[ -x /usr/bin/ovs-vsctl ]]; then
  echo '/usr/bin/ovs-vsctl exist! Open vSwitch is already installed! Process aborted ...'
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


# Download and install Open vSwitch Package.
cd /tmp
echo 'Downloading and installing Open vSwitch ...'
wget ${S_OPTIONS} ${EX_PATH}/${EX_PACK}
if [[ $? -ne 0 ]]; then
  echo "Failed to download $P_vSWITCH. Process aborted ..."
  exit 1
fi
installpkg ${EX_PACK}

# Download and install libatomic.so.1.0.0
#-rw-r--r-- 1 root root 123450 Oct 20 22:16 libatomic.a
#-rwxr-xr-x 1 root root    964 Oct 20 22:16 libatomic.la*
#lrwxrwxrwx 1 root root     18 Apr  3 10:44 libatomic.so -> libatomic.so.1.0.0*
#lrwxrwxrwx 1 root root     18 Apr  3 10:44 libatomic.so.1 -> libatomic.so.1.0.0*
#-rwxr-xr-x 1 root root  23608 Oct 20 22:16 libatomic.so.1.0.0*

# Enable 'rc.openvswitch'
# 'rc.openvswitch' is launched by 'rc.local' and 'rc.local_shutdown'. It
# has to be declared in these two files.
echo 'Activating rc.openvswitch ...'
chmod +x /etc/rc.d/rc.openvswitch


# Create the database
echo 'Creating an initial Open vSwitch database ...'
/sbin/modprobe openvswitch
if [[ $? -ne 0 ]]; then
  echo "Failed to load openvswitch.ko module. Process aborted ..."
  exit 1
fi

ovsdb-tool create /etc/openvswitch/ovs-vswitchd.conf.db /usr/share/openvswitch/vswitch.ovsschema
if [[ $? -ne 0 ]]; then
  echo "Failed to create database. Process aborted ..."
  exit 1
fi


# Add a script for running with LXC containers.
if [[ ! -d /etc/lxc ]]; then
  mkdir /etc/lxc
fi

cat > /etc/lxc/ovsup <<'EOF'
#!/bin/bash

BRIDGE="br0"
ovs-vsctl --may-exist add-br $BRIDGE
ovs-vsctl --if-exists del-port $BRIDGE $5
ovs-vsctl --may-exist add-port $BRIDGE $5

EOF
chmod +x /etc/lxc/ovsup

cat > /etc/lxc/ovsdown <<'EOF'
#!/bin/bash

BRIDGE="br0"
ovs-vsctl --if-exists del-port $BRIDGE $5

EOF
chmod +x /etc/lxc/ovsdown


# And finally, create the bridge.
/etc/rc.d/rc.openvswitch start
ovs-vsctl --may-exist add-br 'br0'
if [[ $? -ne 0 ]]; then
  echo 'Failed to create "br0" bridge! Process aborted ...'
  exit 1
fi

# Done:
echo 'Open vSwitch installed and configured... successfully!'
echo ' '
exit 0
