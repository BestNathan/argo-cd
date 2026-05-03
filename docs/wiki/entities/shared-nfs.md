---
title: Shared NFS
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [storage, nfs, persistentvolume]
---

# Shared NFS

## Overview

A single NFS-backed PersistentVolume serves as the storage backbone for all observability components. Components isolate data via subPath mounts on a shared PVC.

## PV Configuration

| Property | Value |
|----------|-------|
| Name | `shared-nfs` |
| Capacity | 100Gi |
| Access Mode | ReadWriteMany |
| NFS Server | `192.168.2.105` |
| NFS Path | `/mnt/share/k8s` |

## PVC Configuration

| Property | Value |
|----------|-------|
| Name | `shared-nfs` |
| Namespace | observability |
| Capacity | 100Gi |
| Access Mode | ReadWriteMany |

## SubPath Allocation

| Component | subPath | Data Type |
|-----------|---------|-----------|
| Prometheus | `prometheus` | TSDB data |
| Loki | `loki` | Local path prefix |
| Grafana | `grafana` | Dashboards, plugins |
| Jaeger | `jaeger` | Badger KV store |
| Tempo | (none — direct mount) | Local data |

## MinIO Dedicated Storage

MinIO has its own separate NFS PV:
- **PV:** `minio-pv` (500Gi) → `/mnt/share/minio` on `192.168.2.105`
- **PVC:** `minio-pvc` (50Gi, StorageClass: `nfs`)

## Related
- [SubPath PVC Isolation](concepts/subpath-pvc-isolation.md)
- [MinIO](entities/minio.md)
