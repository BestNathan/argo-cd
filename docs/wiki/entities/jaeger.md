---
title: Jaeger
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [jaeger, tracing, legacy]
---

# Jaeger

## Overview

Jaeger all-in-one provides legacy trace visualization. It uses Badger (embedded key-value store) on NFS for persistence. Kept alongside [Tempo](entities/tempo.md) as the legacy tracing UI, not removed during the Tempo migration.

## Configuration

- **Image:** `jaegertracing/all-in-one:1.76.0`
- **Storage:** Badger on NFS (`subPath: jaeger`)
- **Resources:** 100m-250m CPU, 256Mi-512Mi memory
- **Max traces:** 50,000 (MEMORY_MAX_TRACES)

## Ports

| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 16686 | query | TCP | UI (primary access) |
| 14250 | grpc | TCP | gRPC ingest |
| 14268 | http | TCP | HTTP ingest |
| 5778 | admin | TCP | Admin |
| 5775 | zipkin-thrift | UDP | Zipkin thrift |
| 6831 | jaeger-thrift | UDP | Jaeger thrift compact |
| 6832 | jaeger-binary | UDP | Jaeger binary thrift |
| 14269 | admin-http | TCP | Admin HTTP |

## Badger Storage

| Env Var | Value |
|---------|-------|
| SPAN_STORAGE_TYPE | badger |
| BADGER_EPHEMERAL | false |
| BADGER_DIRECTORY_VALUE | /badger/data |
| BADGER_DIRECTORY_KEY | /badger/key |

## Ingress

`jaeger.nhome.local` → port 16686 via Higress

## Related
- [Tempo](entities/tempo.md)
- [LGTM Stack](concepts/lgtm-stack.md)
- [Shared NFS](entities/shared-nfs.md)
