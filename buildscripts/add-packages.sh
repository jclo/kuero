#!/bin/bash
#
# Script installing predefined packages on Kuero Server.
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

readonly KUERO_CONF='kuero.conf'

# Load configuration files.
  . /tmp/build.conf
  . /etc/${KUERO_CONF}


# Go to root and create the folder packages:
cd /root
mkdir -p packages


# Add Nginx package:
cd /root/packages
mkdir -p nginx
cd nginx

# Download nginx extra slackware package:
wget ${EX_PATH}/${NGINX_PACK}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${NGINX_PACK}. Process aborted ..."
  exit 1
fi


# Add HTML package:
cd /root/packages
mkdir -p html
cd html

# Download html app:
wget ${EX_PATH}/${HTML_APP}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${HTML_APP}. Process aborted ..."
  exit 1
fi

# Download nginx.conf:
wget ${S_OPTIONS} ${S_SERVER}/runscripts/packages/html/nginx.conf
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${??????}. Process aborted ..."
  exit 1
fi

# Add link to nginx extra slackware package:
ln -s ../nginx/${NGINX_PACK} ${NGINX_PACK}


# Add Node.js package:
cd /root/packages
mkdir -p node
cd node

# Download node extra slackware package:
wget ${EX_PATH}/${NODE_PACK}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${NODE_PACK}. Process aborted ..."
  exit 1
fi

# Download node app:
wget ${EX_PATH}/${NODE_APP}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${NODE_APP}. Process aborted ..."
  exit 1
fi


# Add PHP package:
cd /root/packages
mkdir -p php
cd php

# Download php app:
wget ${EX_PATH}/${PHP_APP}
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${PHP_APP}. Process aborted ..."
  exit 1
fi

# Download nginx.conf:
wget ${S_OPTIONS} ${S_SERVER}/runscripts/packages/php/nginx.conf
if [[ $? -ne 0 ]]; then
  echo "Failed to download ${??????}. Process aborted ..."
  exit 1
fi

# Add link to nginx extra slackware package:
ln -s ../nginx/${NGINX_PACK} ${NGINX_PACK}

# Done:
echo 'Kuero packages installed... successfully!'
echo ' '
exit 0
