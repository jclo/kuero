#!/bin/bash
#
# Script to build the LXC core container.
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

echo ''
echo 'This script creates a LXC core container. This container is a minimalist'
echo 'Linux server with a shell and a SSH connection capability.'
echo ''
echo 'All the containers are derived from this core container.'
echo ''

# Leave him time to read the message.
sleep 3


# Create the reference container:
echo "Creating the core container ..."
( lxc-create -n core -t slackware -B btrfs ) &
wait
if [[ $? -ne 0 ]]; then
  echo 'Failed to create the core container. Process aborted ...'
  exit 1
fi

# Call timeconfig:
echo "Setting timezone for the core container ..."
cd /lxc/core
chroot rootfs/ timeconfig

# Done:
echo 'LXC core container created and configured... successfully!'
echo ' '
exit 0
