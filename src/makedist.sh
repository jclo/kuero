#!/bin/bash
#
# Kuero build
#
# This script builds the distribution version of Kuero scripts.
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
  . ../build.conf
  . ./server/kuero.conf

# Constants
readonly ROOT='..'
readonly DIST='runscripts'
readonly PACKAGES='packages'
readonly SERVER='server'
readonly CLIENT='client'
readonly CLIENT_IN='kuero'
readonly CLIENT_OUT='kuero'
readonly PATTERN='#@libs12345@#'
readonly CLIENT_OUT_TEMP='temp'
readonly KUERO_CONF="kuero.conf"

readonly RELEASE=${VERSION}


# Check if 'dist' folder exists. If it exists, delete it first.
if [[ -d $ROOT/$DIST ]] ; then
  while true; do
    read -p "$DIST already exists. Do you want do delete it? Please confirm [Y/n]?" yn
    case $yn in
      [Yy]* ) rm -R $ROOT/$DIST
              echo "$DIST deleted."
              break;;
      [Nn]* ) echo 'Aborting ...';
              echo ' ';
              exit 0;
              break;;
      * ) echo 'Please answer Yes or No.';;
    esac
  done
fi
# Create 'dist' folder.
mkdir -p $DIST

# Copy 'package' to dist.
if [[ ! -d $PACKAGES ]] ; then
  echo "folder $PACKAGES does not exist! Aborting ..."
  exit 1
fi
echo "Copying $PACKAGES folder to $DIST ..."
cp -R $PACKAGES $DIST/.
# Cleanup
rm -Rf $DIST/$PACKAGES/nginx/nginx.SlackBuilds


# Server
# Copy 'server scripts' to 'dist'.
#
echo "Copying $SERVER scripts to $DIST and updating the release number ..."
mkdir -p $DIST/$SERVER
sed "s/@#Release#@/$RELEASE/" $SERVER/${KUERO_SRV} > $DIST/$SERVER/${KUERO_SRV}
sed "s/@#Release#@/$RELEASE/" $SERVER/${KUERO_SRV_VM} > $DIST/$SERVER/${KUERO_SRV_VM}
sed "s/@#Release#@/$RELEASE/" $SERVER/${KUERO_SRV_USR} > $DIST/$SERVER/${KUERO_SRV_USR}
sed "s/@#Release#@/$RELEASE/" $SERVER/${KUERO_VM} > $DIST/$SERVER/${KUERO_VM}
sed "s/@#Release#@/$RELEASE/" $SERVER/${KUERO_VM_USR} > $DIST/$SERVER/${KUERO_VM_USR}
cp $SERVER/${KUERO_CONF} $DIST/$SERVER/${KUERO_CONF}


# Client
# Build and copy client script to 'dist'.

# Merge kuero-*.sh files and Kuero to one file.
# Read File line by line
# Nota:
#   The read command automatically trims leading and trailing whitespace;
#   this can be fixed by changing its definition of whitespace by setting
#   the IFS variable to blank. 
#   'r' option avoid interpreting '\' in a line sequence.

echo "Merging $CLIENT/kuero and its lib in one file ..."
mkdir -p $DIST/$CLIENT
#touch $DIST/$CLIENT/$CLIENT_OUT
#chmod +x $DIST/$CLIENT/$CLIENT_OUT

while IFS='' read -r line; do
  printf "%s\n" "$line" >> $DIST/$CLIENT/$CLIENT_OUT
  if [[ $line == $PATTERN ]]; then

    # Insert now libraries
    for CMD in $CLIENT/lib/kuero-*.sh
    do
      cat $CMD >> $DIST/$CLIENT/$CLIENT_OUT
    done

  fi
  
done < $CLIENT/$CLIENT_IN

# Set Production version to true
sed 's/PRODUCTION=false/PRODUCTION=true/' $DIST/$CLIENT/$CLIENT_OUT > $DIST/$CLIENT/$CLIENT_OUT_TEMP
mv $DIST/$CLIENT/$CLIENT_OUT_TEMP $DIST/$CLIENT/$CLIENT_OUT

# Update Release
sed "s/@#Release#@/$RELEASE/" $DIST/$CLIENT/$CLIENT_OUT > $DIST/$CLIENT/$CLIENT_OUT_TEMP
mv $DIST/$CLIENT/$CLIENT_OUT_TEMP $DIST/$CLIENT/$CLIENT_OUT

# Make Output file executable
chmod +x $DIST/$CLIENT/$CLIENT_OUT

# move 'dist' to 'root'
mv $DIST $ROOT/$DIST

echo "Done!"
#
