#!/usr/bin/env bash

set -eou pipefail

yum -y update
yum -y groupinstall "Development Tools"

## GitHub Repository
yum -y install git
(
  cd /home/ec2-user
  git clone https://github.com/hieuvp/learning-monitoring.git
)

## Bash 5.0
curl -O http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz
tar xf bash-5.0.tar.gz
(
  cd bash-5.0
  ./configure
  make
  make install
)
