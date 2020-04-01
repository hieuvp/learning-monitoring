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

- In Prometheus we talk about **Dimensional Data**: time series are identified
  by metric name and a set of key/value pairs.

| Metric Name |      Label       | Sample |
| :---------: | :--------------: | :----: |
| Temperature | location=outside |   90   |

- Prometheus includes a Flexible Query Language.
- Visualizations can be shown using a built-in expression browser
  or with integrations like Grafana.
- It stores metrics in memory and local disk in an own custom, efficient format
- It is written in Go.
- Many client libraries and integrations available.

How does Prometheus work?

- Prometheus collects metrics from monitored targets by scraping metrics HTTP endpoints.

<div align="center"><img src="assets/scraping-metrics.png" width="600"></div>

- This is fundamentally different than other monitoring and alerting systems,
  (except this is also how Google's Borgmon works).
- Rather than using custom scripts that check on particular services and systems,
  the monitoring data itself is used.
- Scraping endpoints is much more efficient than other mechanisms,
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

- `systemctl`: control the `systemd` system and service manager.
- `journalctl`: query the `systemd` journal.
- `ps`: information about running processes.

## Demo: Prometheus Installation

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/install-prometheus.sh) -->
<!-- The below code snippet is automatically added from labs/install-prometheus.sh -->

```sh
#!/usr/bin/env bash
# shellcheck disable=SC1004

set -eou pipefail

readonly WORKING_DIR="/tmp/monitoring-tools"

# Verify the current effective user
if [[ "$(whoami)" != "root" ]]; then
  printf "\e[31m"
  echo "ERROR: You must execute this script as the superuser (root)"
  printf "\e[0m"

  exit 1
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prepare the package
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

readonly PACKAGE_REPO="prometheus/prometheus"
readonly PACKAGE_TARGET="\.linux-amd64\.tar\.gz"
readonly PACKAGE_FILENAME_PATTERN="^.+\"name\": \"(.+${PACKAGE_TARGET})\".*$"
readonly PACKAGE_URL_PATTERN="^.+\"browser_download_url\": \"(.+${PACKAGE_TARGET})\".*$"

readonly PACKAGE_LATEST_RELEASE=$(
  curl --silent "https://api.github.com/repos/${PACKAGE_REPO}/releases/latest"
)

readonly PACKAGE_URL=$(
  echo "$PACKAGE_LATEST_RELEASE" \
    | grep -E "$PACKAGE_URL_PATTERN" \
    | sed -E "s/${PACKAGE_URL_PATTERN}/\1/g"
)

readonly PACKAGE_FILENAME=$(
  echo "$PACKAGE_LATEST_RELEASE" \
    | grep -E "$PACKAGE_FILENAME_PATTERN" \
    | sed -E "s/${PACKAGE_FILENAME_PATTERN}/\1/g"
)

readonly PACKAGE_DIRNAME="${PACKAGE_FILENAME%.tar.gz}"

printf "\n"
echo "+ Package : ${PACKAGE_FILENAME}"
echo "+ URL     : ${PACKAGE_URL}"
printf "\n"

set -x

## Make a clean working directory
rm -rf "$WORKING_DIR"
mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR"

## Download the package
wget "$PACKAGE_URL"

## Extract it afterwards
tar -xzvf "$PACKAGE_FILENAME"

pwd
tree -a
cd "$PACKAGE_DIRNAME"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stop the service if is running
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if systemctl stop prometheus.service; then
  systemctl status prometheus.service || true
  systemctl disable prometheus.service
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a user if not exists
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ! id -u prometheus; then
  useradd --no-create-home --shell /bin/false prometheus
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create Prometheus directories
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rm -rf /etc/prometheus
mkdir -p /etc/prometheus
chown prometheus:prometheus /etc/prometheus

rm -rf /var/lib/prometheus
mkdir -p /var/lib/prometheus
chown prometheus:prometheus /var/lib/prometheus

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copy Prometheus binaries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cp prometheus /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus

cp promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/promtool

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copy Prometheus files
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cp -r consoles /etc/prometheus
cp -r console_libraries /etc/prometheus
cp prometheus.yml /etc/prometheus/prometheus.yml

chown -R prometheus:prometheus /etc/prometheus

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Setup systemd
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    --storage.tsdb.path /var/lib/prometheus \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus.service
systemctl start prometheus.service
```

<!-- AUTO-GENERATED-CONTENT:END -->

```shell script
cd ~/learning-monitoring/prometheus-introduction/labs
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
```

<!-- AUTO-GENERATED-CONTENT:END -->

```shell script
ps aux | grep grafana
```

- <http://prometheus.shopback.engineering:3000/login>
  `admin`/`admin`

## Basic Concepts

- All data is stored as time series.
- Every time series is identified by the **metric name**
  and a set of **key-value pairs**, called **labels**.

metric: go_memstat_alloc_bytes
instance=localhost:9090
job=prometheus

instance=localhost:9100
job=node_exporter

- The time series data also consists of the **actual data**, called **Samples**:

  - It can be a **float64** value
  - or a **millisecond-precision timestamp**

- The notation of time series is often using this notation:

`<metric name>{<label name>=<label value>,...`

- For example:
- node_boot_time{instance="localhost:9100",job="node_exporter"}

## Prometheus Configuration

- The configuration is stored in the Prometheus configuration file, in yaml format.
- The configuration file can be changed and applied, without having to restart Prometheus.

- A reload can be done by executing:

```shell script
kill -SIGHUP <pid>
```

- You can also pass parameters (flags) at **startup time** to `./prometheus`
- Those parameters cannot be changed without restarting Prometheus.
- The configuration file is passed using the flag `--config.file`

- The default configuration looks like this:

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/prometheus.yml) -->
<!-- The below code snippet is automatically added from labs/prometheus.yml -->

```yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
        # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
# - "first_rules.yml"
# - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
```

<!-- AUTO-GENERATED-CONTENT:END -->

- To scape metrics, you need to add a configuration to the prometheus config file

- For example, to scape metrics from prometheus itself, the following code block is added by default.

## Demo: Prometheus Config file

```shell script
ps aux | grep prometheus
```

- <http://prometheus.shopback.engineering:9090/targets>
- <http://prometheus.shopback.engineering:9090/metrics>
- <http://prometheus.shopback.engineering:9090/config>

## Monitoring Nodes (Servers) with Prometheus

- To monitor nodes, you need to install the node-exporter
- The node exporter will expose machine metrics of Linux / \*Nix machines
- For example: CPU Usage, Memory Usage

- The node exporter can be used to monitor machines, and later on,
  you can create alerts based on these ingested metrics.

- For Windows, there's a WMI exporter (see <https://github.com/martinlindhe/wmi_exporter)>

## Demo: node exporter for Linux

<!-- AUTO-GENERATED-CONTENT:START (CODE:src=labs/install-node-exporter.sh) -->
<!-- The below code snippet is automatically added from labs/install-node-exporter.sh -->

```sh
#!/usr/bin/env bash

set -eou pipefail

readonly WORKING_DIR="/tmp/monitoring-tools"

# Verify the current effective user
if [[ "$(whoami)" != "root" ]]; then
  printf "\e[31m"
  echo "ERROR: You must execute this script as the superuser (root)"
  printf "\e[0m"

  exit 1
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prepare the package
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

readonly PACKAGE_REPO="prometheus/node_exporter"
readonly PACKAGE_TARGET="\.linux-amd64\.tar\.gz"
readonly PACKAGE_FILENAME_PATTERN="^.+\"name\": \"(.+${PACKAGE_TARGET})\".*$"
readonly PACKAGE_URL_PATTERN="^.+\"browser_download_url\": \"(.+${PACKAGE_TARGET})\".*$"

readonly PACKAGE_LATEST_RELEASE=$(
  curl --silent "https://api.github.com/repos/${PACKAGE_REPO}/releases/latest"
)

readonly PACKAGE_URL=$(
  echo "$PACKAGE_LATEST_RELEASE" \
    | grep -E "$PACKAGE_URL_PATTERN" \
    | sed -E "s/${PACKAGE_URL_PATTERN}/\1/g"
)

readonly PACKAGE_FILENAME=$(
  echo "$PACKAGE_LATEST_RELEASE" \
    | grep -E "$PACKAGE_FILENAME_PATTERN" \
    | sed -E "s/${PACKAGE_FILENAME_PATTERN}/\1/g"
)

readonly PACKAGE_DIRNAME="${PACKAGE_FILENAME%.tar.gz}"

printf "\n"
echo "+ Package : ${PACKAGE_FILENAME}"
echo "+ URL     : ${PACKAGE_URL}"
printf "\n"

set -x

## Make a clean working directory
rm -rf "$WORKING_DIR"
mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR"

## Download the package
wget "$PACKAGE_URL"

## Extract it afterwards
tar -xzvf "$PACKAGE_FILENAME"

pwd
tree -a
cd "$PACKAGE_DIRNAME"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Stop the service if is running
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if systemctl stop node_exporter.service; then
  systemctl status node_exporter.service || true
  systemctl disable node_exporter.service
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a user if not exists
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if ! id -u node_exporter; then
  useradd --no-create-home --shell /bin/false node_exporter
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copy Node Exporter binary
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cp node_exporter /usr/local/bin
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Setup systemd
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Final instruction
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set +x

echo "Setup is complete.
Add the following lines to /etc/prometheus/prometheus.yml:

  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
"
```

<!-- AUTO-GENERATED-CONTENT:END -->

```shell script
sudo vi /etc/prometheus/prometheus.yml

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
