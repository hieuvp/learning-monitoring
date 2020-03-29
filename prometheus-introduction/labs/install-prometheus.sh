#!/usr/bin/env bash
# shellcheck disable=SC1004

set -eou pipefail

readonly WORKING_DIR="/tmp/learning-monitoring"
readonly GITHUB_REPO="prometheus/prometheus"

readonly TARGET_PATTERN="\.linux-amd64\.tar\.gz"
readonly NAME_PATTERN="^.+\"name\": \"(.+${TARGET_PATTERN})\".*$"
readonly DOWNLOAD_URL_PATTERN="^.+\"browser_download_url\": \"(.+${TARGET_PATTERN})\".*$"

set -x

readonly PACKAGE_NAME=$(
  curl --silent "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
    | grep -E "$NAME_PATTERN" \
    | sed -E "s/${NAME_PATTERN}/\1/g"
)

readonly PACKAGE_URL=$(
  curl --silent "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
    | grep -E "$DOWNLOAD_URL_PATTERN" \
    | sed -E "s/${DOWNLOAD_URL_PATTERN}/\1/g"
)

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
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Copy binaries
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/

chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Copy config
cp -r consoles /etc/prometheus
cp -r console_libraries /etc/prometheus
cp prometheus.yml /etc/prometheus/prometheus.yml

chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

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
WantedBy=multi-user.target' > /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
