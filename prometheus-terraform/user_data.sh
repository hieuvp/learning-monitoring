#!/usr/bin/env bash

set -eou pipefail

cd /home/ec2-user
yum -y update
yum -y groupinstall "Development Tools"

## GitHub Repository
yum -y install git
git clone https://github.com/hieuvp/learning-monitoring.git
chown -R ec2-user:ec2-user learning-monitoring

## Bash 5.0
curl -O http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz
tar xf bash-5.0.tar.gz
(
  cd bash-5.0
  ./configure
  make
  make install
)
env bash

# If the instance does not behave the way you intended,
# debug the following cloud-init output log file
# $ tail -1000f /var/log/cloud-init-output.log
