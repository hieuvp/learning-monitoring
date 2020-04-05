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
