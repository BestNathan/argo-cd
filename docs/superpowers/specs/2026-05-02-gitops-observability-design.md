# GitOps Repository Initialization — Observability Stack

## Overview

Initialize this repository as a GitOps control plane for observability components, managed by ArgoCD using the App-of-Apps pattern. Components use plain Kubernetes YAML manifests (no Helm, no Kustomize).

**Components:** Prometheus, Loki, Grafana
**Namespace:** `observability`
**Target platform:** ArgoCD

## Architecture

Two-layer structure:

1. **Application Layer** (`apps/`) — ArgoCD `Application` resources. `app-of-apps.yaml` bootstraps all others.
2. **Component Layer** (`components/`) — Plain Kubernetes manifests grouped by namespace, then by component.

**Bootstrap flow:** `kubectl apply apps/app-of-apps.yaml` → ArgoCD creates child Applications → each Application syncs its component manifests.

All observability components deploy to the `observability` namespace, which has its own directory under `components/`. The app-of-apps lives in the `argocd` namespace.

## Components

### Prometheus

| Resource | Purpose |
|---|---|
| ServiceAccount + ClusterRole + ClusterRoleBinding | Grant Prometheus cluster-wide scraping permissions |
| ConfigMap `prometheus.yml` | Scrape configs (self-scrape, node targets) |
| Deployment | `prom/prometheus` image with PVC for data persistence |
| Service (ClusterIP:9090) | Internal Prometheus API access |

### Loki

| Resource | Purpose |
|---|---|
| ConfigMap `loki.yaml` | Loki config (local storage, retention) |
| Deployment | `grafana/loki` image |
| Service (ClusterIP:3100) | Internal Loki API access |

**Out of scope:** Promtail/DaemonSet for log collection (requires cluster-specific node config, can be added later).

### Grafana

| Resource | Purpose |
|---|---|
| ConfigMap (datasource) | Auto-configure Prometheus and Loki as datasources |
| Deployment | `grafana/grafana` image, admin credentials in ConfigMap |
| Service (ClusterIP:3000) | Internal Grafana access |
| Ingress | External access at `grafana.<your-domain>` (placeholder host) |

## Directory Structure

```
nitops/
├── apps/
│   ├── app-of-apps.yaml
│   ├── prometheus.yaml
│   ├── loki.yaml
│   └── grafana.yaml
├── components/
│   └── observability/                    # namespace-level grouping
│       ├── namespace.yaml
│       ├── prometheus/
│       │   ├── serviceaccount.yaml
│       │   ├── clusterrole.yaml
│       │   ├── clusterrolebinding.yaml
│       │   ├── configmap.yaml
│       │   ├── pvc.yaml
│       │   ├── deployment.yaml
│       │   └── service.yaml
│       ├── loki/
│       │   ├── configmap.yaml
│       │   ├── deployment.yaml
│       │   └── service.yaml
│       └── grafana/
│           ├── configmap-datasource.yaml
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ingress.yaml
└── test/
```

## Sync Strategy

- Each Application uses `syncPolicy.automated` with `prune: true` and `selfHeal: true`.
- `targetRevision: main` — always sync from the main branch.
- `repoURL`: placeholder, to be filled with actual repo URL after init.
- Each component is independently synced — failures in one don't block others.
- Rollback via `argocd app rollback <app-name>`.

## Validation

- Pre-commit: `kubectl apply --dry-run=client -f components/`
- Post-deploy: verify via ArgoCD UI or `argocd app list`
