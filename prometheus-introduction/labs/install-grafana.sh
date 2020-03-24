#!/usr/bin/env bash

set -eoux pipefail

yum -y update
yum -y install grafana

systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service
