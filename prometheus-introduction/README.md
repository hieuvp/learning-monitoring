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

- A multi-dimensional data model with time series data
  identified by **metric name** and **key/value pairs**.

  | Metric Name |      Label       | Sample |
  | :---------: | :--------------: | :----: |
  | Temperature | location=outside |   90   |

- `PromQL` (Prometheus Query Language),
  a flexible query language to leverage this dimensionality.

- It is inspired by Google's Borgmon,
  which uses time-series data as a datasource,
  to then send alerts based on this data.
- It fits very well in the cloud native infrastructure.

- Visualizations can be shown using a built-in expression browser
  or with integrations like Grafana.
- It stores metrics in memory and local disk in an own custom, efficient format
- It is written in Go.
- Many client libraries and integrations available.

<div align="center"><img src="assets/graph-go-memstats-alloc-bytes.png" width="900"></div>
<br />

- All data is stored as time series.
- Every time series is identified by the **metric name**
  and a set of **key-value pairs**, called **labels**.

- Metric: `go_memstats_alloc_bytes`
- Labels:

  - `instance="localhost:9100"`
  - `job="node_exporter"`

  - `instance="localhost:9090"`
  - `job="prometheus"`

<br />
<div align="center"><img src="assets/console-go-memstats-alloc-bytes.png" width="820"></div>

- The time series data also consists of the **actual data**, called **Samples**:

  - It can be a **float64** value
  - or a **millisecond-precision timestamp**

- The notation of time series is often using this **notation**:

  - `<metric name>{<label name>=<label value>,...}`

- For example:
  - `node_boot_time_seconds{instance="localhost:9100",job="node_exporter"}`

## Collecting Metrics

> Time series collection happens via a **pull model** over **HTTP**.

<div align="center">
  <img src="assets/collecting-metrics.png" width="550">
  <br />
  <em>
    <strong>Prometheus</strong> collects metrics from monitored targets by
    <strong>scraping metrics HTTP endpoints</strong>
  </em>
  <br />
</div>
<br />

- **Rather than using custom scripts** that check on particular services and systems,
  the **monitoring data itself is used**.
- Scraping endpoints is much more efficient than other mechanisms (e.g. 3rd party agents).
- A single prometheus server is able to ingest
  up to one million samples per second as several million time series.

## Components and Architecture

<div align="center"><img src="assets/architecture.png" width="900"></div>
<br />

- No reliance on distributed storage; single server nodes are autonomous.
- Pushing time series is supported via an intermediary gateway.
- Targets are discovered via service discovery or static configuration.
- Multiple modes of graphing and dashboarding support.

The Prometheus ecosystem consists of multiple components, many of which are optional:

- The main **Prometheus Server** which scrapes and stores time series data.
- **Client Libraries** for instrumenting application code.
- A **Push Gateway** for supporting **Short-lived Jobs**.
- Special-purpose **Exporters** for services like HAProxy, StatsD, Graphite, etc.
- An **Alert Manager** to handle alerts.
- Various support tools.

Most Prometheus components are written in Go, making them easy to build and deploy as static binaries.

## References

- [Prometheus Overview](https://prometheus.io/docs/introduction/overview/)
- [Exposing and Collecting Metrics](https://blog.pvincent.io/2017/12/prometheus-blog-series-part-3-exposing-and-collecting-metrics/)
