---
title: OTel Unified Pipelines
type: concept
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [otel, telemetry, architecture]
---

# OTel Unified Pipelines

## Overview

The OTel Collector implements a three-pipeline architecture that receives all telemetry data via OTLP and routes it to the appropriate backend (Tempo for traces, Prometheus for metrics, Loki for logs).

## Architecture

```
                    OTel Collector
              ┌─────────────────────────┐
              │   Receivers: OTLP       │
              │   (gRPC:4317, HTTP:4318)│
              └───────────┬─────────────┘
                          │
              ┌───────────┴─────────────┐
              │   Processors            │
              │   memory_limiter, batch │
              └───────┬─────┬─────┬─────┘
                      │     │     │
              ┌───────┘     │     └───────┐
              ▼             ▼             ▼
          Traces        Metrics        Logs
              │             │             │
              ▼             ▼             ▼
         otlphttp/     prometheus    otlphttp/
          tempo       (0.0.0.0:8889)   loki
              │             │             │
              ▼             ▼             ▼
           Tempo        Prometheus      Loki
```

## Pipeline Details

| Pipeline | Exporter | Target | Protocol |
|----------|----------|--------|----------|
| traces | otlphttp/tempo | `http://tempo:4318` | OTLP HTTP |
| metrics | prometheus | `0.0.0.0:8889` | Prometheus scrape |
| logs | otlphttp/loki | `http://loki:3100/otlp/v1/logs` | OTLP HTTP |

All pipelines also export to `debug` (basic verbosity) for troubleshooting.

## Memory Protection

The `memory_limiter` processor protects against memory spikes:
- **Check interval:** 5s
- **Limit:** 400 MiB
- **Spike limit:** 100 MiB

## Prometheus Integration

The metrics pipeline exposes a Prometheus scrape endpoint at port 8889. Prometheus is configured to scrape this endpoint with:
- **Namespace label:** `otel`
- **Constant label:** `cluster=k8s`

## Related
- [OTel Collector](entities/otel-collector.md)
- [LGTM Stack](concepts/lgtm-stack.md)
- [Tempo](entities/tempo.md)
- [Loki](entities/loki.md)
- [Prometheus](entities/prometheus.md)
