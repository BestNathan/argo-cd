---
title: ArgoCD
type: entity
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [argocd, gitops, kubernetes]
---

# ArgoCD

## Overview

ArgoCD is the GitOps orchestrator for the nitops project. All Kubernetes manifests are managed as ArgoCD Application resources deployed into the `argocd` namespace. Changes are driven by the git repository at `https://github.com/BestNathan/nitops`.

## Configuration

All Applications share the same pattern:
- **Project:** `default`
- **Repo:** `https://github.com/BestNathan/nitops.git`
- **Target revision:** `main`
- **Sync policy:** `automated` with `prune: true` and `selfHeal: true`
- **Destination server:** `https://kubernetes.default.svc`

## Applications

| Name | Source Path | Namespace | Purpose |
|------|-------------|-----------|---------|
| `apps` | `apps` (dir, excludes app-of-apps.yaml) | argocd | Deploys all child Application resources |
| `apps-mcp` | `apps-mcp` (dir, recurse) | (varies) | MCP sub-app-of-apps: namespace + service Applications |
| `observability-cluster` | `components/cluster` | (cluster-scoped) | Shared NFS PersistentVolume |
| `observability-namespace` | `components/observability/namespace` | observability | Namespace + shared PVC |
| `prometheus` | `components/observability/prometheus` | observability | Metrics |
| `loki` | `components/observability/loki` | observability | Logs |
| `grafana` | `components/observability/grafana` | observability | Dashboards |
| `tempo` | `components/observability/tempo` | observability | Tracing |
| `jaeger` | `components/observability/jaeger` | observability | Legacy tracing UI |
| `otel-collector` | `components/observability/otel-collector` | observability | Telemetry gateway |
| `minio` | `components/minio` | (none specified — manifests include namespace) | S3 storage |
| `redis` | `components/redis` | (none specified — manifests include namespace) | Cache |
| `docs-rs-mcp` | `components/mcp/docs-rs-mcp` | mcp | MCP service |

## Bootstrap Flow

1. `kubectl apply -f apps/app-of-apps.yaml` — creates the root Application
2. ArgoCD syncs the `apps` directory, creating all child Applications
3. Each child Application syncs its component manifests into the cluster

## Admin Access

Password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`

## Related
- [App-of-Apps Pattern](concepts/app-of-apps-pattern.md)
- [GitOps Workflow](concepts/gitops-workflow.md)
- [Observability Namespace](entities/observability-namespace.md)
- [MCP Services](entities/mcp-services.md)
