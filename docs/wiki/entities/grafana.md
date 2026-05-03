---
title: Grafana
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [grafana, dashboards, observability]
---

# Grafana

## Overview

Grafana is the visualization layer for the observability stack, providing dashboards for metrics (Prometheus), logs (Loki), and traces (Tempo).

## Configuration

- **Image:** `grafana/grafana-enterprise:13.1.0-25196703233`
- **Port:** 3000 (http, NodePort)
- **Storage:** shared NFS PVC (`subPath: grafana`)
- **Resources:** 100m-250m CPU, 256Mi-512Mi memory

## Provisioned Datasources

| Name | Type | URL | Notes |
|------|------|-----|-------|
| Prometheus | prometheus | `http://prometheus:9090` | Default datasource |
| Loki | loki | `http://loki:3100` | Derived TraceID fields → Tempo |
| Tempo | tempo | `http://tempo:3200` | UID: `tempo` |

The Loki datasource has a derived field that extracts trace IDs from log lines matching `traceID=(\w+)` and links them to the Tempo datasource.

## Ingress

`grafana.nhome.local` → port 3000 via Higress

## Related
- [LGTM Stack](concepts/lgtm-stack.md)
- [Prometheus](entities/prometheus.md)
- [Loki](entities/loki.md)
- [Tempo](entities/tempo.md)
