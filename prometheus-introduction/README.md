# Prometheus Introduction

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Introduction to Prometheus](#introduction-to-prometheus)
- [Prometheus Installation](#prometheus-installation)
- [Demo: Prometheus Installation](#demo-prometheus-installation)
- [Demo: Grafana with Prometheus Installation](#demo-grafana-with-prometheus-installation)
- [Basic Concepts](#basic-concepts)
- [Prometheus Configuration](#prometheus-configuration)
- [Demo: Prometheus Config file](#demo-prometheus-config-file)
- [Monitoring Nodes (Servers) with Prometheus](#monitoring-nodes-servers-with-prometheus)
- [Demo: node exporter for Linux](#demo-node-exporter-for-linux)
- [Node Exporter for Windows (WMI Exporter)](#node-exporter-for-windows-wmi-exporter)
- [Prometheus Architecture](#prometheus-architecture)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction to Prometheus

- Prometheus is an Open source monitoring solution.
- Started at SoundCloud around 2012-2013,
  and was made public in early 2015.
- Prometheus provides Metrics & Alerting.
- It is inspired by Google's Borgmon,
  which uses time-series data as a datasource,
  to then send alerts based on this data.
- It fits very well in the cloud native infrastructure.
- Prometheus is also a member of the CNCF (Cloud Native Foundation).

- In Prometheus we talk about Dimensional Data: time series are identified
  by metric name and a se of key/value pairs.
- Prometheus includes a Flexible Query Language.
- Visualizations can be shown using a built-in expression browser
  or with integrations like Grafana.
- It stores metrics in memory and local disk in an own custom, efficient format
- It is written in Go.
- Many client libraries and integrations available.

- Prometheus collects metrics from monitored targets by scraping metrics HTTP endpoints.

<div align="center"><img src="assets/scraping-metrics.png" width="600"></div>

- This is fundamentally different than other monitoring and alerting systems,
  (except this is also how Google's Borgmon works).
- Rather than using custom scripts that check on particular services and systems,
  the monitoring data itself is used.
- Scraping endpoints is much more effiecient than other mechanisms,
  like 3rd party agents.
- A single prometheus server is able to ingest up to one million samples
  per second as several million time series.

## Prometheus Installation

```shell script
make prometheus-terraform-plan
make prometheus-terraform-apply
make prometheus-terraform-destroy
make prometheus-terraform-reset
```

## Demo: Prometheus Installation

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/install-prometheus.sh) -->
<!-- The below code snippet is automatically added from labs/install-prometheus.sh -->

```sh
#!/usr/bin/env bash
# shellcheck disable=SC1004

set -eou pipefail

readonly SYSTEMD_UNIT_NAME="prometheus.service"

readonly WORKING_DIR="/tmp/learning-monitoring"
readonly GITHUB_REPO="prometheus/prometheus"

readonly PACKAGE_TARGET="\.linux-amd64\.tar\.gz"
readonly PACKAGE_NAME_PATTERN="^.+\"name\": \"(.+${PACKAGE_TARGET})\".*$"
readonly PACKAGE_URL_PATTERN="^.+\"browser_download_url\": \"(.+${PACKAGE_TARGET})\".*$"

set -x

readonly PACKAGE_NAME=$(
  curl --silent "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
    | grep -E "$PACKAGE_NAME_PATTERN" \
    | sed -E "s/${PACKAGE_NAME_PATTERN}/\1/g"
)

readonly PACKAGE_URL=$(
  curl --silent "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
    | grep -E "$PACKAGE_URL_PATTERN" \
    | sed -E "s/${PACKAGE_URL_PATTERN}/\1/g"
)

# Stop the service
systemctl stop "$SYSTEMD_UNIT_NAME"
systemctl status "$SYSTEMD_UNIT_NAME" || true

rm -rf "$WORKING_DIR"
mkdir "$WORKING_DIR"
cd "$WORKING_DIR"

wget "$PACKAGE_URL"
tar -xzvf "$PACKAGE_NAME"
cd "${PACKAGE_NAME%.tar.gz}"

# if you just want to start prometheus as root
#./prometheus --config.file=prometheus.yml

# Create a user if not exists
readonly USERNAME="prometheus"
if ! id -u "$USERNAME"; then
  useradd --no-create-home --shell /bin/false "$USERNAME"
fi

# Create directories
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

# Set ownership
chown "${USERNAME}:${USERNAME}" /etc/prometheus
chown "${USERNAME}:${USERNAME}" /var/lib/prometheus

# Copy binaries
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/
chown "${USERNAME}:${USERNAME}" /usr/local/bin/prometheus
chown "${USERNAME}:${USERNAME}" /usr/local/bin/promtool

# Copy config
cp -r consoles /etc/prometheus
cp -r console_libraries /etc/prometheus
cp prometheus.yml /etc/prometheus/prometheus.yml

chown -R "${USERNAME}:${USERNAME}" /etc/prometheus/consoles
chown -R "${USERNAME}:${USERNAME}" /etc/prometheus/console_libraries

# Setup systemd
echo '[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target' > "/etc/systemd/system/${SYSTEMD_UNIT_NAME}"

systemctl daemon-reload
systemctl enable "$SYSTEMD_UNIT_NAME"
systemctl start "$SYSTEMD_UNIT_NAME"
```

<!-- AUTO-GENERATED-CONTENT:END -->

```shell script
cd /home/ec2-user/learning-monitoring/prometheus-introduction/labs
sudo ./install-prometheus.sh
```

```shell script
ps aux | grep prometheus
```

- <http://prometheus.shopback.engineering:9090/graph>

``

## Demo: Grafana with Prometheus Installation

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/install-grafana.sh) -->
<!-- The below code snippet is automatically added from labs/install-grafana.sh -->

```sh
#!/usr/bin/env bash

set -eou pipefail

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

systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service
```

<!-- AUTO-GENERATED-CONTENT:END -->

```shell script
ps aux | grep grafana
```

- <http://prometheus.shopback.engineering:3000/login>
  `admin`/`admin`

## Basic Concepts

## Prometheus Configuration

```shell script
# A reload can be done by executing
kill -SIGHUP <pid>
```

## Demo: Prometheus Config file

## Monitoring Nodes (Servers) with Prometheus

## Demo: node exporter for Linux

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/install-node-exporter.sh) -->
<!-- The below code snippet is automatically added from labs/install-node-exporter.sh -->

```sh
#!/usr/bin/env bash

set -eou pipefail

readonly NODE_EXPORTER_VERSION="1.0.0-rc.0"

wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar -xzvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cd node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64
cp node_exporter /usr/local/bin

# create user
useradd --no-create-home --shell /bin/false node_exporter

chown node_exporter:node_exporter /usr/local/bin/node_exporter

echo '[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/node_exporter.service

# Enable node_exporter in systemctl
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

echo "Setup complete.
Add the following lines to /etc/prometheus/prometheus.yml:

  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
"
```

<!-- AUTO-GENERATED-CONTENT:END -->

```shell script
vi /etc/prometheus/prometheus.yml

curl localhost:9100
curl localhost:9100/metrics

ps aux | grep prometheus
systemctl reload prometheus
kill -SIGHUP <pid>
journalctl -n100
```

- <http://prometheus.shopback.engineering:9090/targets>

## Node Exporter for Windows (WMI Exporter)

## Prometheus Architecture

<div align="center"><img src="assets/architecture.png" width="900"></div>

## References

- [Prometheus Overview](https://prometheus.io/docs/introduction/overview/)
- [Exposing and Collecting Metrics](https://blog.pvincent.io/2017/12/prometheus-blog-series-part-3-exposing-and-collecting-metrics/)
