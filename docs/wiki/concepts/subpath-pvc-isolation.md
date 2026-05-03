---
title: SubPath PVC Isolation
type: concept
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [storage, kubernetes, pvc]
---

# SubPath PVC Isolation

## Overview

Rather than creating individual PVCs for each component, the observability stack uses a single shared PVC (`shared-nfs`, 100Gi) with `subPath` mounts to isolate each component's data directory on the underlying NFS volume.

## How It Works

1. A single `PersistentVolume` (`shared-nfs`, 100Gi) is provisioned on the NFS server
2. A single `PersistentVolumeClaim` (`shared-nfs`) in the `observability` namespace binds to it
3. Each component mounts the same PVC but with a different `subPath`:

```yaml
volumeMounts:
  - name: data
    mountPath: /prometheus     # component-specific path
    subPath: prometheus        # isolates to /mnt/share/k8s/prometheus on NFS
```

## SubPath Mapping

| Component | subPath | Mount Path | Data |
|-----------|---------|------------|------|
| Prometheus | `prometheus` | `/prometheus` | TSDB data |
| Loki | `loki` | `/loki` | Local files |
| Grafana | `grafana` | `/var/lib/grafana` | Dashboards, plugins |
| Jaeger | `jaeger` | `/badger` | Badger KV data |
| Tempo | (none) | `/var/tempo` | Direct mount (full PVC root) |

## Benefits

- **Single PV to manage** — one NFS export, one PVC
- **Automatic isolation** — each component writes to its own subPath directory
- **ReadWriteMany** — multiple pods can mount the same PVC simultaneously
- **Cost efficient** — shared capacity rather than over-provisioning per-component PVs

## Caveat

Tempo mounts the PVC directly without a subPath, meaning it has access to the full PVC root. This differs from other components and should be noted.

## Related
- [Shared NFS](entities/shared-nfs.md)
