---
title: LGTM Stack
type: concept
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [lgtm, observability, architecture]
---

# LGTM Stack

## Overview

LGTM stands for **Loki, Grafana, Tempo, and Metrics (Prometheus)** — a unified observability stack. The nitops project implements all four components plus an OTel Collector gateway for unified telemetry ingestion.

## Components

| Component | Signal | Role |
|-----------|--------|------|
| **Loki** | Logs | Log aggregation, S3-backed |
| **Grafana** | Visualization | Dashboards, multi-datasource queries |
| **Tempo** | Traces | Distributed tracing backend, S3-backed |
| **Prometheus** | Metrics | Metrics collection and storage |
| **OTel Collector** | Ingestion | Unified OTLP gateway |

## Data Flow

```
Application → OTel Collector (OTLP) → Tempo (traces)
                                  → Prometheus (metrics)
                                  → Loki (logs)

Grafana → Prometheus (metrics queries)
        → Loki (log queries)
        → Tempo (trace queries, traceID links from Loki)
```

## Cross-Component Links

- **Grafana datasources:** Provisioned with Prometheus (default), Loki, and Tempo
- **Loki → Tempo:** Loki's derived fields extract `traceID` from log lines and link to Tempo datasource
- **Prometheus → OTel Collector:** Scrapes the OTel Collector's metrics endpoint (port 8889)
- **OTel Collector → Tempo/Loki/Prometheus:** Routes traces, logs, and metrics respectively

## Storage

| Component | Primary | Secondary |
|-----------|---------|-----------|
| Prometheus | NFS (subPath: prometheus) | — |
| Loki | MinIO S3 | NFS (subPath: loki) |
| Grafana | NFS (subPath: grafana) | — |
| Tempo | MinIO S3 | NFS (local) |
| OTel Collector | — | — (stateless) |

## Legacy: Jaeger

Jaeger all-in-one is kept alongside Tempo as a legacy trace UI. It uses Badger storage on NFS. The OTel Collector does NOT route to Jaeger — Tempo is the primary tracing backend.

## Related
- [Prometheus](entities/prometheus.md)
- [Loki](entities/loki.md)
- [Grafana](entities/grafana.md)
- [Tempo](entities/tempo.md)
- [OTel Collector](entities/otel-collector.md)
- [Jaeger](entities/jaeger.md)
- [OTel Unified Pipelines](concepts/otel-unified-pipelines.md)
