---
title: Loki
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [loki, logs, observability, s3]
---

# Loki

## Overview

Loki provides log aggregation for the observability stack. It uses MinIO S3 as the primary object store with boltdb-shipper for index management, and NFS for local path prefix.

## Configuration

- **Image:** `grafana/loki:main-d8f4d0f`
- **Port:** 3100 (http)
- **Storage:** shared NFS PVC (`subPath: loki`) + MinIO S3
- **Resources:** 100m-250m CPU, 256Mi-512Mi memory

## S3 Backend

| Property | Value |
|----------|-------|
| Endpoint | `minio.minio.svc:9000` |
| Access Key | `admin` |
| Secret Key | `minioadmin` |
| Insecure | true |
| Bucket | `loki` |
| Force path style | true |

## Schema

- **Store:** boltdb-shipper
- **Object store:** s3
- **Schema:** v11
- **Index prefix:** `index_`
- **Index period:** 24h

## Limits

- Reject old samples: true (max age: 168h / 7 days)
- Structured metadata: disabled

## Related
- [LGTM Stack](concepts/lgtm-stack.md)
- [MinIO](entities/minio.md)
- [Shared NFS](entities/shared-nfs.md)
- [OTel Collector](entities/otel-collector.md)
