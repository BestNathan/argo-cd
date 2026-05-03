---
title: Higress
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [ingress, networking, higress]
---

# Higress

## Overview

Higress is the ingress controller used for all external access to the observability stack. It runs as a NodePort service on the cluster.

## Access

| Port | Protocol |
|------|----------|
| 31693 | HTTP (NodePort) |
| 32077 | HTTPS (NodePort) |

## Ingress Convention

All ingresses follow the standard pattern:
- `ingressClassName: higress`
- `nginx.ingress.kubernetes.io/ssl-redirect: "false"`
- `higress.io/domain: "<app>.nhome.local"`
- Domain pattern: `<app>.nhome.local`

## Managed Routes

| Service | Domain | Backend Port |
|---------|--------|--------------|
| Prometheus | prometheus.nhome.local | 9090 |
| Grafana | grafana.nhome.local | 3000 |
| Jaeger | jaeger.nhome.local | 16686 |
| MinIO API | api.minio.nhome.local | 9000 |
| MinIO Console | console.minio.nhome.local | 9001 |

## External Access

For external access, either:
1. Configure DNS to point `*.nhome.local` to the cluster node IP, or
2. Set up router port forwarding: external 80 → node IP:31693

## Related
- [Higress Ingress Convention](concepts/higress-ingress-convention.md)
