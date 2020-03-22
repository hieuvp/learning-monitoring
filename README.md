# Learning Monitoring

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Prometheus and Its Ecosystem](#prometheus-and-its-ecosystem)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Prometheus and Its Ecosystem

- [Prometheus](https://prometheus.io/)
  is an open-source systems monitoring and alerting toolkit originally built at SoundCloud.
  It is now a standalone open source project and maintained independently of any company.
  Prometheus joined the [Cloud Native Computing Foundation](https://www.cncf.io/) (`CNCF`)
  in 2016 as the second hosted project, after Kubernetes.

- [Grafana](https://grafana.com/)
  is the open source analytics and monitoring solution for every database.

- [Node Exporter](https://github.com/prometheus/node_exporter)
  is a Prometheus exporter for hardware and OS metrics exposed by \*NIX kernels,
  written in Go with pluggable metric collectors.

- [Alertmanager](https://github.com/prometheus/alertmanager)
  handles alerts sent by client applications such as the Prometheus server.
  It takes care of deduplicating, grouping, and routing them
  to the correct receiver integrations such as email, PagerDuty, or OpsGenie.
  It also takes care of silencing and inhibition of alerts.

1. [ ] [Introduction](prometheus-introduction/README.md)
1. [ ] [Monitoring](prometheus-monitoring/README.md)
1. [ ] [Alerting](prometheus-alerting/README.md)
1. [ ] [Internals](prometheus-internals/README.md)
1. [ ] [Use Cases](prometheus-use-cases/README.md)
1. [ ] Thank You

## References

- [Monitoring and Alerting with Prometheus](https://www.udemy.com/course/monitoring-and-alerting-with-prometheus)
- [Course Files for Monitoring and Alerting with Prometheus](https://github.com/in4it/prometheus-course)
- [Managing Advanced Kubernetes Logging and Tracing](https://app.pluralsight.com/library/courses/managing-advanced-kubernetes-logging-tracing/table-of-contents)
