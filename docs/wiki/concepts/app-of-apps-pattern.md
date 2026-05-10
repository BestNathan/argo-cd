---
title: App-of-Apps Pattern
type: concept
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [argocd, architecture, gitops]
---

# App-of-Apps Pattern

## Overview

The nitops project uses a three-layer App-of-Apps pattern to bootstrap and manage all Kubernetes resources through ArgoCD. A single `kubectl apply` creates the root Application, which then creates all child Applications, each of which syncs its own component manifests.

## Layer 1: Root Application

`apps/app-of-apps.yaml` — a single ArgoCD Application that syncs the `apps/` directory. It excludes itself (`directory.exclude: "app-of-apps.yaml"`) to prevent recursion.

```
kubectl apply -f apps/app-of-apps.yaml
```

## Layer 2: Child Applications

The `apps/` directory contains ArgoCD Application manifests for each component:

```
apps/
├── app-of-apps.yaml           # Root (excluded from directory sync)
├── cluster.yaml               # Cluster-scoped resources (PVs)
├── observability-namespace.yaml  # Namespace + PVC
├── prometheus.yaml            # Prometheus
├── loki.yaml                  # Loki
├── grafana.yaml               # Grafana
├── minio.yaml                 # MinIO
├── redis.yaml                 # Redis
├── jaeger.yaml                # Jaeger
├── tempo.yaml                 # Tempo
├── otel-collector.yaml        # OTel Collector
└── mcp.yaml                   → apps-mcp/ sub-app-of-apps
```

## Layer 3: MCP Sub-App-of-Apps

The `apps/mcp.yaml` Application uses `directory: recurse: true` to scan `apps-mcp/`, enabling multiple MCP services to be managed independently:

```
apps-mcp/
├── namespace.yaml             # mcp namespace
└── docs-rs-mcp.yaml           # ArgoCD Application → components/mcp/docs-rs-mcp/
```

This keeps ArgoCD Applications (metadata) separate from Kubernetes manifests (resources), avoiding directory-scan conflicts.

## Sync Policy

All Applications use identical sync policies:
```yaml
syncPolicy:
  automated:
    prune: true      # Delete resources removed from git
    selfHeal: true   # Re-apply when cluster drifts from git
```

## Deployment Scope

| Application | Namespace Scope | Purpose |
|-------------|----------------|---------|
| `apps` | `argocd` | Creates child Applications |
| `apps-mcp` | `argocd` | MCP sub-app-of-apps: scans apps-mcp/ directory |
| `observability-cluster` | Cluster-scoped | Shared NFS PV |
| `observability-namespace` | `observability` | Namespace + PVC |
| Component apps | `observability` | Individual components |
| `minio`, `redis` | (from manifests) | Separate namespaces |
| `docs-rs-mcp` | `mcp` | MCP service |

## Related
- [ArgoCD](entities/argocd.md)
- [GitOps Workflow](concepts/gitops-workflow.md)
- [MCP Services](entities/mcp-services.md)
