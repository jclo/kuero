#!/bin/bash
#
# Script to finalyze the installation of Kuero Server.
#
# Copyright (c) 2015-2016 jclo <jclo@mobilabs.fr> (http://www.mobilabs.fr/)
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

##
# Force the root password to be changed at the first login.
#
function _force_update_root_password() {
  echo "Installing a script to force updating root password at the first login..."
  cat > /root/.bash_profile <<EOF
#
# This script forces the admin user to change the admin password after the login.
#

echo ' '
echo 'You MUST immediately change your password.'
echo 'Otherwise you CANNOT login anymore!'
echo ' '

# Copy the rsa certificates to 'root'
mkdir -p /root/.ssh
cp /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
cp /etc/ssh/ssh_host_rsa_key.pub /root/.ssh/id_rsa.pub

# Force root password to expire
passwd -e root

# Display status to user
chage -l root

# Delete the script
rm /root/.bash_profile

# end
EOF
  chmod +x /root/.bash_profile

}


#
# -- Main
#

# Build the LXC core container:
cd /tmp
( ./add-core-container.sh ) &
wait
if [[ $? -ne 0 ]]; then
  echo './add-core-container.sh failed. Process aborted ...'
  exit 1
fi

# Install a script to force changing the root password at first login:
_force_update_root_password

# Update version
echo "Kuero Server ${VERSION}" >> /etc/slackware-version

# Change the name from spineos to kuero:
sed -i "s/spineos/kuero/"  /etc/HOSTNAME
sed -i "s/spineos/kuero/g" /etc/hosts

# Change the root password to kuero
echo "root:kuero" | chpasswd


# Some cleanup operations.

# Flush the caches:
if [[ -d "/var/cache/slackware" ]]; then
  echo "Flushing the cache /var/cache/slackware ..."
  rm -R "/var/cache/slackware"
fi

if [[ -d "/var/cache/lxc" ]]; then
  echo "Flushing the cache /var/cache/lxc ..."
  rm -R "/var/cache/lxc"
fi

# Delete the curent certificates:
echo "Deleting the current certificates..."
cd /etc/ssh
rm *.pub
rm *_key
mv ssh_config.new ssh_config &> /dev/null
mv sshd_config.new sshd_config &> /dev/null
rm /root/.ssh/* &> /dev/null

# Delete unusefull doc. and config files:
rm -R /usr/doc/* &> /dev/null
rm -R /usr/share/locale/* &> /dev/null
rm -R /usr/man/* &> /dev/null

# Cleanup log messages:
cd /var/log
rm dmesg ; touch dmesg
rm lastlog ; touch lastlog
rm messages ; touch messages
rm syslog ; touch syslog
rm wtmp ; touch wtmp

# Delete the history:
echo "Deleting the bash history..."
rm /root/.bash_history

# Delete /tmp content:
cd /tmp
find "/tmp" -type f -exec rm {} \;

# Shrink disk if vmware-toolbox-cmd tool is installed:
if [[ -x "/usr/bin/vmware-toolbox-cmd" ]]; then
  echo "Shrinking the disk 3 times ..."
  vmware-toolbox-cmd disk shrink /
  vmware-toolbox-cmd disk shrink /
  vmware-toolbox-cmd disk shrink /
fi

# Done:
echo 'Kuero Server is now installed and configured... successfully!'
echo 'Your credentials for the next login are root with the password "kuero".'
echo 'This password expires after the first login. You need to change it'
echo 'otherwise you cannot log in to the server anymore!'
echo ''
sleep 5
halt
exit 0
