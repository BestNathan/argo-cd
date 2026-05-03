---
title: OTel Collector
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [otel, telemetry, ingestion]
---

# OTel Collector

## Overview

OpenTelemetry Collector serves as the unified telemetry ingestion gateway for the LGTM stack. It receives OTLP data and routes it through three separate pipelines to Tempo (traces), Prometheus (metrics), and Loki (logs).

## Configuration

- **Image:** `otel/opentelemetry-collector:latest`
- **Resources:** 100m-250m CPU, 256Mi-512Mi memory
- **Replicas:** 1

## Ports

| Port | Name | Purpose |
|------|------|---------|
| 4317 | otlp-grpc | OTLP gRPC receiver |
| 4318 | otlp-http | OTLP HTTP receiver |
| 8889 | prom-metrics | Prometheus scrape endpoint |

## Processors

| Processor | Config |
|-----------|--------|
| memory_limiter | check: 5s, limit: 400 MiB, spike: 100 MiB |
| batch | default |

## Pipelines

| Pipeline | Receivers | Processors | Exporters |
|----------|-----------|------------|-----------|
| traces | otlp | memory_limiter, batch | otlphttp/tempo, debug |
| metrics | otlp | memory_limiter, batch | prometheus, debug |
| logs | otlp | memory_limiter, batch | otlphttp/loki, debug |

## Exporters

| Exporter | Target | Purpose |
|----------|--------|---------|
| otlphttp/tempo | `http://tempo:4318` | Forward traces |
| otlphttp/loki | `http://loki:3100/otlp/v1/logs` | Forward logs |
| prometheus | `0.0.0.0:8889` | Metrics scrape endpoint (namespace: `otel`, label: `cluster=k8s`) |
| debug | basic | Debug logging |

## Related
- [LGTM Stack](concepts/lgtm-stack.md)
- [OTel Unified Pipelines](concepts/otel-unified-pipelines.md)
- [Tempo](entities/tempo.md)
- [Loki](entities/loki.md)
- [Prometheus](entities/prometheus.md)
