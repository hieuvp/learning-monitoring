# Prometheus Introduction

> Prometheus collects metrics from configured targets at given intervals,
> evaluates rule expressions, displays the results,
> and can trigger alerts if some condition is observed to be true.

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Basic Concepts](#basic-concepts)
- [Collecting Metrics](#collecting-metrics)
- [Components and Architecture](#components-and-architecture)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Basic Concepts

> Prometheus fundamentally stores all data as **time series**.

1. A multi-dimensional data model with **time series data**
   identified by **metric name** and **key/value pairs** (called **labels**).
1. `PromQL` (**Prometheus Query Language**),
   a flexible query language to leverage this dimensionality.

<br />

<div align="center"><img src="assets/graph-go-memstats-alloc-bytes.png" width="895"></div>

- **Notation**: `<metric name>{<label name>=<label value>, ...}`.
- **Metric name**: `go_memstats_alloc_bytes`.
- **Labels**: `instance="localhost:9100"`, `job="node_exporter"`, `instance="localhost:9090"`, `job="prometheus"`.

<br />

<div align="center"><img src="assets/console-go-memstats-alloc-bytes.png" width="810"></div>
<div align="center"><img src="assets/console-time-picker.png" width="680"></div>

**Samples** form the actual time series data. Each **sample** consists of:

1. A **float64 value**.
1. A **millisecond-precision timestamp**.

## Collecting Metrics

> Time series collection happens via a **pull model** over **HTTP**.

<div align="center">
  <img src="assets/collecting-metrics.png" width="530">
  <br />
  <em>
    Prometheus collects metrics from monitored targets
    by scraping /metrics HTTP endpoints
  </em>
  <br />
</div>
<br />

- **Rather than using custom scripts** that check on particular services and systems,
  the **monitoring data itself is used**.
- **Scraping endpoints** is much more efficient than other mechanisms (e.g. 3rd-party agents).
- A single Prometheus server is able to
  ingest up to one million samples per second as several million time series.

## Components and Architecture

<div align="center"><img src="assets/architecture.png" width="900"></div>
<br />

- No reliance on distributed storage; single server nodes are autonomous.
- Pushing time series is supported via an intermediary gateway.
- Targets are discovered via service discovery or static configuration.
- Multiple modes of graphing and dashboarding support.

- Visualizations can be shown using a built-in expression browser
  or with integrations like Grafana.
- It stores metrics in memory and local disk in an own custom, efficient format.

- Use time-series data as a datasource, to then send alerts based on this data.

The Prometheus ecosystem consists of multiple components, many of which are optional:

- The main **Prometheus Server** which scrapes and stores time series data.
- **Client Libraries** for instrumenting application code.
- A **Push Gateway** for supporting **Short-lived Jobs**.
- Special-purpose **Exporters** for services like HAProxy, StatsD, Graphite, etc.
- An **Alert Manager** to handle alerts.
- Various support tools.

Most Prometheus components are written in Go, making them easy to build and deploy as static binaries.

Prometheus

- It is written in Go.
- Many client libraries and integrations available.

## References

- [Prometheus Overview](https://prometheus.io/docs/introduction/overview/)
- [Exposing and Collecting Metrics](https://blog.pvincent.io/2017/12/prometheus-blog-series-part-3-exposing-and-collecting-metrics/)
