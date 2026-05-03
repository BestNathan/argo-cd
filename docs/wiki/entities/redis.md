---
title: Redis
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [redis, cache]
---

# Redis

## Overview

Standalone Redis cache running in its own namespace. Currently not used by any observability component but available as infrastructure.

## Configuration

- **Image:** `redis:7-alpine`
- **Port:** 6379
- **Resources:** 100m-200m CPU, 64Mi-128Mi memory
- **Replicas:** 1

## Probes

| Probe | Method | Initial | Period |
|-------|--------|---------|--------|
| Liveness | TCP socket 6379 | 10s | 10s |
| Readiness | TCP socket 6379 | 5s | 5s |

## Services

| Name | Type | Port |
|------|------|------|
| redis-clusterip | ClusterIP | 6379 |
| redis-nodeport | NodePort | 6379 → nodePort 30379 |

## Related
- [Observability Namespace](entities/observability-namespace.md)
