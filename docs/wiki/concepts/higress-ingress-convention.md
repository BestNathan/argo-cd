---
title: Higress Ingress Convention
type: concept
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [ingress, networking, higress]
---

# Higress Ingress Convention

## Overview

All external-facing services in nitops follow a standardized ingress pattern using the Higress ingress controller. This ensures consistent access, domain naming, and annotation usage across all components.

## Standard Pattern

Every ingress manifest follows this template:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <service-name>
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    higress.io/domain: "<service>.nhome.local"
spec:
  ingressClassName: higress
  rules:
    - host: <service>.nhome.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <service-name>
                port:
                  number: <port>
```

## Required Annotations

| Annotation | Value | Purpose |
|------------|-------|---------|
| `nginx.ingress.kubernetes.io/ssl-redirect` | `"false"` | Disable HTTPS redirect |
| `higress.io/domain` | `<app>.nhome.local` | Domain registration |

## Domain Scheme

- **Pattern:** `<app>.nhome.local`
- **Namespace:** All domains end in `.nhome.local`
- **External ports:** HTTP 31693, HTTPS 32077 (Higress NodePort)

## Current Routes

| Ingress Name | Domain | Service | Port |
|--------------|--------|---------|------|
| prometheus | prometheus.nhome.local | prometheus | 9090 |
| grafana | grafana.nhome.local | grafana | 3000 |
| jaeger | jaeger.nhome.local | jaeger | 16686 |
| minio-api | api.minio.nhome.local | minio | 9000 |
| minio-console | console.minio.nhome.local | minio | 9001 |

## MinIO Exception

MinIO uses two separate ingresses (API and Console) with different subdomains and backend ports. This is the only service with multiple ingress routes.

## Related
- [Higress](entities/higress.md)
