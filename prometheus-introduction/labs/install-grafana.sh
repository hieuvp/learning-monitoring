#!/usr/bin/env bash

set -eou pipefail

# Verify the current effective user
if [[ "$(whoami)" != "root" ]]; then
  printf "\e[31m"
  echo "ERROR: You must execute this script as the superuser (root)"
  printf "\e[0m"

  exit 1
fi

# Add Grafana RPM repository to YUM
echo '[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt' > /etc/yum.repos.d/grafana.repo

set -x

yum -y update
yum -y install grafana

find /usr/lib/systemd/system -name '*grafana*'
# Created symlink
# from /etc/systemd/system/multi-user.target.wants/grafana-server.service
# to /usr/lib/systemd/system/grafana-server.service

systemctl daemon-reload
systemctl enable grafana-server.service
systemctl start grafana-server.service
