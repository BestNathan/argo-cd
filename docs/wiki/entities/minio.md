---
title: MinIO
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [minio, s3, storage]
---

# MinIO

## Overview

MinIO provides S3-compatible object storage for Loki and Tempo. It runs in its own `minio` namespace with dedicated NFS storage.

## Configuration

- **Image:** `minio/minio:RELEASE.2025-09-07T16-13-09Z-cpuv1`
- **API Port:** 9000 (ClusterIP)
- **Console Port:** 9001 (ClusterIP)
- **Strategy:** Recreate
- **Resources:** 250m-500m CPU, 512Mi-1Gi memory
- **Credentials:** admin / minioadmin

## Storage

| Resource | Size | NFS Path |
|----------|------|----------|
| PV (minio-pv) | 500Gi | `/mnt/share/minio` on `192.168.2.105` |
| PVC (minio-pvc) | 50Gi | StorageClass: `nfs`, selector: `app=minio` |

## Buckets

| Bucket | Consumer |
|--------|----------|
| `loki` | Loki log storage |
| `tempo` | Tempo trace storage |

## Ingress

| Name | Domain | Backend Port |
|------|--------|--------------|
| minio-api | `api.minio.nhome.local` | 9000 (S3 API) |
| minio-console | `console.minio.nhome.local` | 9001 (Web UI) |

## Related
- [Loki](entities/loki.md)
- [Tempo](entities/tempo.md)
- [Shared NFS](entities/shared-nfs.md)
