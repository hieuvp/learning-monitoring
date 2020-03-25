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

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction to Prometheus

## Prometheus Installation

## Demo: Prometheus Installation

```shell script
ps aux | grep prometheus
```

- <http://prometheus.shopback.engineering:9090/graph>

## Demo: Grafana with Prometheus Installation

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
