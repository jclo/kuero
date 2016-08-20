#!/bin/bash
#
# Slackware script to add Git client or server capabilities to SpineOS.
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

# List of Slackware packages to install.
TEMPLATE=${TEMPLATE:-git}
PACKAGES=${PACKAGES:-"git"}

# Global variables
GIT_VERSION='client'
GIT_PROTOCOL='disabled'


echo ''
echo 'This script installs Git as a client or a server. By default, Git is'
echo 'installed as a client.'
echo ''
echo 'If you want to install the server version, you need to call the script'
echo 'with one or two arguments:'
echo ''
echo '  . the first argument must be "server".'
echo '  . the second argument must be "enabled" to enable Git protocol.'
echo ''
echo 'Without arguments, the client version is installed.'
echo ''
echo 'If the second argument is missing, Git protocol will NOT be enabled'
echo '(port 9418 not opened).'
echo ''

# Leave him time to read the message.
sleep 3


# Check if there are traces of a previous installation
echo 'Installing and configuring Git ...'
if [[ -x /usr/bin/git ]]; then
  echo '/usr/bin/git exists! Git is already installed! Process aborted ...'
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


# Server or Client?
if [[ $1 != 'server' ]]; then
  echo 'Configuring Git client ...'
  # Git client. Nothing more to do.
  echo 'Done.'
  exit 0
fi


# Ok for Git Server.
echo 'Configuring Git Server ...'
GIT_VERSION='server'
# Create Git group and user
groupadd -g 210 git
useradd -u 210 -g 210 -d /var/lib/git git
# Create Git repository
mkdir -p /git
chown -R git:git /git


# Git protocol?
if [[ $2 == 'enabled' ]]; then
  echo 'Enabling Git protocol ...'
  GIT_PROTOCOL='enabled'
else
  echo 'Done.'
  exit 0
fi
sleep 1

# Configure the Firewall to open git port
#
# You need to add the following rules to 'input chain' of '/etc/rc.d/rc.firewall':
#
# This rule to open port 9418:
#   $IPT -A INPUT -p TCP -i $INET_IFACE --destination-port 9418 -j ACCEPT
#
sed -i '/# Inbound Internet Packet Rules/a $IPT -A INPUT -p TCP -i $INET_IFACE --destination-port 9418 -j ACCEPT' /etc/rc.d/rc.firewall;


#Add Daemon script
cat > /etc/rc.d/rc.git-daemon <<'EOF'
#!/bin/bash

# Slackware GNU/Linux git daemon control script.
# By Mykyta Solomko <sev (at) nix.org.ua>


############### !! DO NOT EDIT !! #################
#
# To override some/all of these values, copy needed
# variable declarations into /etc/default/git-daemon
# and set desired values.
#
GITBIN="/usr/bin/git"
REPOROOT="/git"
PIDFILE="/var/run/git.pid"
DMNUSR="git"
DMNGRP="git"
#DMNUSR="root"
#DMNGRP="root"
GITD_EXTRAARGS=''

[[ -f /etc/default/git-daemon ]] \
    && (source /etc/default/git-daemon)

# Pre-run checks
git_prerun() {

    [[ ! -x ${GITBIN} ]] \
        && (echo "$0 error: ${GITBIN} not found or missing executable flag!"; exit 1)

    [[ ! -d ${REPOROOT} ]] \
        && (echo "$0 error: repository root ${REPOROOT} does not exist!"; exit 1)

}

# Start:
git_daemon_start() {

    git_prerun

    echo "Starting git daemon: ${GITBIN} daemon --user=${DMNUSR} --group=${DMNGRP} \\"
    echo "                           --pid-file=${PIDFILE} --syslog --reuseaddr \\"
#    echo "                           --base-path=${REPOROOT} ${GITD_EXTRAARGS} ${REPOROOT} \\"
    echo "                           --base-path=${REPOROOT} \\"
    echo "           --export-all \\"
    echo "           --verbose \\"
    echo "           --enable=receive-pack &"
    ${GITBIN} daemon \
         --user=${DMNUSR} \
         --group=${DMNGRP} \
         --pid-file=${PIDFILE} \
         --reuseaddr \
         --base-path=${REPOROOT} \
   --export-all \
   --verbose \
   --enable=receive-pack &

}

# Stop:
git_daemon_stop() {

    echo "Shutting down git daemon."
    [[ -f ${PIDFILE} ]] \
        && kill -TERM "$(cat ${PIDFILE})" &> /dev/null

}

# Restart:
git_daemon_restart() {

  git_daemon_stop
  sleep 1
  git_daemon_start

}

case "$1" in
'start')
  git_daemon_start
  ;;
'stop')
  git_daemon_stop
  ;;
'restart')
  git_daemon_restart
  ;;
*)
  echo "usage $0 start|stop|restart"
esac
EOF

# Enable it
chmod +x /etc/rc.d/rc.git-daemon

# Initialize firewall with updated rules
/etc/rc.d/rc.firewall restart

# Done:
echo 'Git installed and configured... successfully!'
echo ' '
exit 0
