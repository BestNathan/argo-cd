# Tempo Tracing Backend — Design Spec

## Overview

Add Grafana Tempo as a distributed tracing backend to the LGTM stack, coexisting with the existing Jaeger deployment. Tempo uses MinIO S3 for trace storage and integrates with Grafana for unified querying.

## Architecture

- **Component:** `components/observability/tempo/` (configmap, deployment, service)
- **Storage:** MinIO S3 (`minio.minio.svc:9000`), bucket `tempo`
- **Data persistence:** Shared NFS PVC (`shared-nfs`) for Tempo WAL and generator data
- **Receivers:** OTLP gRPC/HTTP, Jaeger gRPC/HTTP, Zipkin

## Grafana Integration

- New `grafana-datasources` ConfigMap with Prometheus + Loki + Tempo
- Loki derived fields: `traceID` → Tempo datasource (log-to-trace jumping)
- Tempo datasource UID: `tempo`
- Grafana deployment updated to mount the datasource configmap

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 3200 | TCP | HTTP API (Grafana queries) |
| 4317 | TCP | OTLP gRPC |
| 4318 | TCP | OTLP HTTP |
| 14250 | TCP | Jaeger gRPC |
| 14268 | TCP | Jaeger HTTP |
| 9411 | TCP | Zipkin |

## Coexistence with Jaeger

Both Jaeger and Tempo run independently in the `observability` namespace. Jaeger uses Badger + NFS; Tempo uses S3 + NFS. Applications can send traces to either backend via different receiver protocols.
