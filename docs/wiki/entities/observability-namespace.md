---
title: Observability Namespace
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [namespace, kubernetes]
---

# Observability Namespace

## Overview

The `observability` namespace hosts the core LGTM stack components. It is created and managed as a dedicated ArgoCD Application.

## Configuration

| Property | Value |
|----------|-------|
| Name | `observability` |
| Label | `app.kubernetes.io/part-of: observability` |

## Resources

| Resource | Name | Purpose |
|----------|------|---------|
| Namespace | `observability` | Namespace definition |
| PVC | `shared-nfs` | 100Gi ReadWriteMany, bound to `shared-nfs` PV |

## Deployed Components

- [Prometheus](entities/prometheus.md)
- [Loki](entities/loki.md)
- [Grafana](entities/grafana.md)
- [Tempo](entities/tempo.md)
- [Jaeger](entities/jaeger.md)
- [OTel Collector](entities/otel-collector.md)

## Related
- [App-of-Apps Pattern](concepts/app-of-apps-pattern.md)
- [Shared NFS](entities/shared-nfs.md)
- [LGTM Stack](concepts/lgtm-stack.md)
