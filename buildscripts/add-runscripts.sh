#!/bin/bash
#
# Script to install kuero-srv-* scripts on Kuero server.
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

# Scripts and configuration files.
readonly S_KUERO_SRV="kuero-srv"
readonly S_KUERO_SRV_VM="kuero-srv-vm"
readonly S_KUERO_SRV_USR="kuero-srv-usr"
readonly S_KUERO_VM="kuero-vm"
readonly S_KUERO_VM_USR="kuero-vm-usr"
readonly S_KUERO_CONF="kuero.conf"

echo ''
echo "This script installs Kuero scripts running inside"
echo 'the server and allowing its remote control.'
echo ''

# Leave him time to read the message.
sleep 3

# Install and configure dnsmasq
echo 'Installing kuero-srv-* scripts ...'

# Download to /root
cd /root

# Download and install kuero-srv
wget ${S_OPTIONS} ${S_SERVER}/runscripts/server/${S_KUERO_SRV}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${S_KUERO_SRV}. Process aborted ..."
  exit 1
fi
chmod +x ${S_KUERO_SRV}
mv ${S_KUERO_SRV} /usr/local/sbin/${S_KUERO_SRV}

# Download and install kuero-srv-vm
wget ${S_OPTIONS} ${S_SERVER}/runscripts/server/${S_KUERO_SRV_VM}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${S_KUERO_SRV_VM}. Process aborted ..."
  exit 1
fi
chmod +x ${S_KUERO_SRV_VM}
mv ${S_KUERO_SRV_VM} /usr/local/sbin/${S_KUERO_SRV_VM}


# Download and install kuero-srv-usr
wget ${S_OPTIONS} ${S_SERVER}/runscripts/server/${S_KUERO_SRV_USR}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${S_KUERO_SRV_USR}. Process aborted ..."
  exit 1
fi
chmod +x ${S_KUERO_SRV_USR}
mv ${S_KUERO_SRV_USR} /usr/local/bin/${S_KUERO_SRV_USR}


# Download and install kuero-vm
wget ${S_OPTIONS} ${S_SERVER}/runscripts/server/${S_KUERO_VM}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${S_KUERO_VM}. Process aborted ..."
  exit 1
fi
chmod +x ${S_KUERO_VM}


# Download and install kuero-vm-usr
wget ${S_OPTIONS} ${S_SERVER}/runscripts/server/${S_KUERO_VM_USR}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${S_KUERO_VM_USR}. Process aborted ..."
  exit 1
fi
chmod +x ${S_KUERO_VM_USR}


# Download and install kuero.conf
wget ${S_OPTIONS} ${S_SERVER}/runscripts/server/${S_KUERO_CONF}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${S_KUERO_CONF}. Process aborted ..."
  exit 1
fi
mv ${S_KUERO_CONF} /etc/.


# Done!
echo "kuero-* scripts installed... successfully!"
echo ' '
exit 0
