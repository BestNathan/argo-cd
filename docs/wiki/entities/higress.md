---
title: Higress
type: entity
created: 2026-05-03
updated: 2026-05-04
sources: [bootstrap-nitops]
tags: [ingress, networking, higress, envoy, istio]
---

# Higress

## Overview

Higress is the ingress controller for the cluster, built on Envoy proxy with Istio's pilot as the control plane. It manages all external access to services via Ingress resources. Installed via Helm into the `higress-system` namespace (v2.2.0).

## Architecture

Three components:

| Component | Replicas | Role |
|-----------|----------|------|
| higress-gateway | 2 | Envoy proxy (data plane), handles actual traffic |
| higress-controller | 1 | Control plane (higress-core + discovery/pilot), manages config |
| higress-console | 1 | Web UI for management |

## Images

| Component | Image |
|-----------|-------|
| gateway | `higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/gateway:2.2.0` |
| controller (higress-core) | `higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/higress:2.2.0` |
| controller (discovery) | `higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/pilot:2.2.0` |
| console | `higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/console:2.2.0` |

## Resources

| Component | CPU | Memory |
|-----------|-----|--------|
| gateway | 2 (req+limit) | 2Gi (req+limit) |
| controller (higress-core) | 500m-1 | 2Gi |
| controller (discovery) | 500m | 2Gi |
| console | 250m | 512Mi |

## Services

| Service | Type | Ports |
|---------|------|-------|
| higress-gateway | NodePort | 80→31693, 443→32077 |
| higress-controller | ClusterIP | 8888, 8889, 15051, 15010, 15012, 443, 15014 |
| higress-console | NodePort | 8080→31287 |

## IngressClass

```yaml
name: higress
controller: higress.io/higress-controller
```

## Gateway Configuration (higress-config)

### Downstream

| Setting | Value |
|---------|-------|
| Connection buffer limit | 32768 |
| Idle timeout | 180s |
| Max request headers | 60KB |
| Route timeout | 0 (no timeout) |
| HTTP/2 max concurrent streams | 100 |

### Upstream

| Setting | Value |
|---------|-------|
| Connection buffer limit | 10485760 (10MB) |
| Idle timeout | 10s |

### Gzip

- **Enabled:** true
- **Compression level:** BEST_COMPRESSION
- **Min content length:** 1024 bytes
- **Content types:** text/html, text/css, text/plain, text/xml, application/json, application/javascript, application/xhtml+xml, image/svg+xml

### Mesh

- **Access log:** JSON format to stdout
- **Ingress controller mode:** OFF (uses Ingress resources, not Istio sidecars)
- **Root namespace:** higress-system
- **Auto mTLS:** disabled

## Access

| Interface | Address |
|-----------|---------|
| Gateway HTTP | `http://<node-ip>:31693` |
| Gateway HTTPS | `https://<node-ip>:32077` |
| Console UI | `http://<node-ip>:31287` |

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

## Related
- [Higress Ingress Convention](concepts/higress-ingress-convention.md)
