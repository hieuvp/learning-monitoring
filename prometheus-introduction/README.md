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

## Prometheus Installation

```shell script
make prometheus-terraform-plan
make prometheus-terraform-apply
make prometheus-terraform-destroy
make prometheus-terraform-reset
```

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

<div align="center"><img src="assets/architecture.png" width="900"></div>

## References

- [Prometheus Overview](https://prometheus.io/docs/introduction/overview/)
- [Exposing and Collecting Metrics](https://blog.pvincent.io/2017/12/prometheus-blog-series-part-3-exposing-and-collecting-metrics/)
