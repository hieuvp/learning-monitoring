#!/usr/bin/env bash
# shellcheck disable=SC1004

set -eou pipefail

readonly WORKING_DIR="/tmp/monitoring-tools"

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
