---
title: Tempo
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [tempo, tracing, s3]
---

# Tempo

## Overview

Tempo is the modern tracing backend for the LGTM stack. It accepts traces via multiple protocols (OTLP, Jaeger, Zipkin) and stores them in MinIO S3. Replaced Jaeger as the primary tracing backend but Jaeger was kept as a legacy UI.

## Configuration

- **Image:** `grafana/tempo:main-40b985c-amd64`
- **HTTP Port:** 3200 (query/health)
- **Storage:** shared NFS PVC + MinIO S3
- **Resources:** 250m-500m CPU, 512Mi-1Gi memory

## Receivers

| Protocol | Port | Endpoint |
|----------|------|----------|
| OTLP gRPC | 4317 | 0.0.0.0:4317 |
| OTLP HTTP | 4318 | 0.0.0.0:4318 |
| Jaeger gRPC | 14250 | 0.0.0.0:14250 |
| Jaeger HTTP | 14268 | 0.0.0.0:14268 |
| Zipkin | 9411 | 0.0.0.0:9411 |

## S3 Backend

| Property | Value |
|----------|-------|
| Bucket | `tempo` |
| Endpoint | `minio.minio.svc:9000` |
| Access Key | `admin` |
| Secret Key | `minioadmin` |
| Insecure | true |

## Related
- [LGTM Stack](concepts/lgtm-stack.md)
- [Jaeger](entities/jaeger.md)
- [MinIO](entities/minio.md)
- [OTel Collector](entities/otel-collector.md)
- [Shared NFS](entities/shared-nfs.md)
