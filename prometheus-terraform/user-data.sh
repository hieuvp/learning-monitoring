#!/usr/bin/env bash

set -eou pipefail

readonly USERNAME="ec2-user"

set -x

## Working under the user home directory
cd "/home/${USERNAME}"
pwd

## Core Development Tools
yum -y update
yum -y group install "Development Tools"

## htop - Interactive Process Viewer
yum -y install htop

## Bash 5.0
curl -O http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz
tar xf bash-5.0.tar.gz
(
  cd bash-5.0
  ./configure
  make
  make install
)

## Set Locale
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment

## GitHub Repository
yum -y install git
git clone https://github.com/hieuvp/learning-monitoring.git
chown -R ${USERNAME}:${USERNAME} learning-monitoring

# If the instance does not behave the way you intended,
# debug the following cloud-init output log file
# $ tail -1000f /var/log/cloud-init-output.log
