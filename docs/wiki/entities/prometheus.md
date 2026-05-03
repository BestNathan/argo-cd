---
title: Prometheus
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [prometheus, metrics, observability]
---

# Prometheus

## Overview

Prometheus handles metrics collection and storage in the observability stack. It scrapes its own metrics and the OTel Collector's metrics endpoint.

## Configuration

- **Image:** `prom/prometheus:v3.11.3`
- **Port:** 9090 (metrics)
- **Scrape interval:** 15s
- **Retention:** 15 days
- **Storage:** shared NFS PVC (`subPath: prometheus`)
- **Resources:** 250m-500m CPU, 512Mi-1Gi memory

## RBAC

Uses a dedicated ServiceAccount (`prometheus`), ClusterRole, and ClusterRoleBinding. Permissions cover:
- Nodes, services, endpoints, pods (get/list/watch)
- ConfigMaps (get)
- EndpointSlices (get/list/watch)
- Ingresses (get/list/watch)
- `/metrics` non-resource URL (get)

## Scrape Targets

| Job | Target | Purpose |
|-----|--------|---------|
| `prometheus` | localhost:9090 | Self-monitoring |
| `otel-collector` | otel-collector:8889 | OTel Collector metrics |

## Ingress

`prometheus.nhome.local` → port 9090 via Higress

## Related
- [LGTM Stack](concepts/lgtm-stack.md)
- [OTel Collector](entities/otel-collector.md)
- [Shared NFS](entities/shared-nfs.md)
