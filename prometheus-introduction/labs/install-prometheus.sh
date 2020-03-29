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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Download The Package
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

# If you just want to start prometheus as root
#./prometheus --config.file=prometheus.yml

# Create user if not exists
if ! id -u prometheus; then
  useradd --no-create-home --shell /bin/false prometheus
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create Directories and Set Ownership
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rm -rf /etc/prometheus
mkdir -p /etc/prometheus
chown prometheus:prometheus /etc/prometheus

rm -rf /var/lib/prometheus
mkdir -p /var/lib/prometheus
chown prometheus:prometheus /var/lib/prometheus

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copy Binaries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cp prometheus /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus

cp promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/promtool

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copy Config
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
WantedBy=multi-user.target' > "/etc/systemd/system/${SYSTEMD_UNIT_NAME}"

systemctl daemon-reload
systemctl enable "$SYSTEMD_UNIT_NAME"
systemctl start "$SYSTEMD_UNIT_NAME"
