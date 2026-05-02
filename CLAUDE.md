# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GitOps control plane for Kubernetes observability components, managed by ArgoCD. Repo: `https://github.com/BestNathan/nitops`

**Stack:** Prometheus (metrics), Loki (logs), Grafana (dashboards)
**Namespace:** `observability`
**Tech:** Plain Kubernetes YAML manifests — no Helm, no Kustomize.

## Architecture

Two-layer App-of-Apps pattern:

```
apps/                          # ArgoCD Application resources
├── app-of-apps.yaml           # Root app — bootstraps everything
├── cluster.yaml               # Cluster-level resources (PVs)
├── observability-namespace.yaml  # Namespace + PVC
├── prometheus.yaml            # ArgoCD app for Prometheus
├── loki.yaml                  # ArgoCD app for Loki
└── grafana.yaml               # ArgoCD app for Grafana

components/                    # Kubernetes manifests
├── cluster/                   # Cluster-scoped resources
│   └── shared-nfs-pv.yaml     # NFS PersistentVolume
└── observability/             # observability namespace resources
    ├── namespace/
    │   ├── namespace.yaml     # Namespace definition
    │   └── pvc.yaml           # PVC binding to shared NFS
    ├── prometheus/            # SA, RBAC, ConfigMap, Deployment, Service
    ├── loki/                  # ConfigMap, Deployment, Service
    └── grafana/               # Deployment, Service
```

**Bootstrap flow:** `kubectl apply -f apps/app-of-apps.yaml` → ArgoCD creates child Applications → each Application syncs its component manifests.

The `cluster.yaml` app deploys cluster-scoped resources (no namespace). The `observability-namespace.yaml` app creates the namespace and shared PVC. Component apps (prometheus, loki, grafana) deploy into the `observability` namespace.

## Key Conventions

- **One resource per file** — DO NOT merge different resources into one YAML file
- **NFS storage:** server=`192.168.2.105`, mount=`/mnt/share/k8s`
- All components share a single NFS-backed PVC (`shared-nfs`) with `subPath` isolation
- Loki uses MinIO S3 (`minio.minio.svc:9000`) for object storage
- Grafana uses NodePort (not Ingress) for external access
- ArgoCD apps use `syncPolicy.automated` with `prune: true` and `selfHeal: true`

## Useful Commands

**Get ArgoCD admin password:**
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

**Validate manifests (dry-run):**
```sh
kubectl apply --dry-run=client -f components/
```

**Check ArgoCD app status:**
```sh
argocd app list
```

**Rollback an app:**
```sh
argocd app rollback <app-name>
```

## Storage Model

All observability components use a shared NFS PersistentVolume (`shared-nfs`, 100Gi) with subPath isolation:
- Prometheus → `subPath: prometheus`
- Loki → `subPath: loki`
- Grafana → `subPath: grafana`

The PV is defined in `components/cluster/shared-nfs-pv.yaml`, the PVC in `components/observability/namespace/pvc.yaml`. Loki additionally stores data in MinIO S3.
