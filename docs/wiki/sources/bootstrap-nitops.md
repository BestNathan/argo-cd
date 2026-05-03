---
title: Bootstrap Ingest — nitops codebase
type: source
created: 2026-05-03
updated: 2026-05-03
source: full-project-scan
tags: [bootstrap, gitops, observability, lgtm]
---

# Bootstrap Ingest — nitops Codebase

## Summary

Complete ingest of the nitops repository — a GitOps control plane for Kubernetes observability components managed by ArgoCD. The project uses plain Kubernetes YAML manifests (no Helm, no Kustomize) with a two-layer App-of-Apps pattern to deploy and manage the full LGTM stack (Loki, Grafana, Tempo, Prometheus) plus supporting infrastructure (MinIO, Redis).

## Architecture

Two-layer App-of-Apps pattern: `apps/app-of-apps.yaml` bootstralls all other ArgoCD Applications, each of which syncs a component directory under `components/`. All observability components share a single NFS-backed PVC with subPath isolation.

## Component Inventory

| Component | Namespace | Resources | Purpose |
|-----------|-----------|-----------|---------|
| Shared NFS | (cluster-scoped) | PersistentVolume (100Gi) | NFS storage backbone |
| Observability namespace | observability | Namespace, PVC | Namespace + shared PVC |
| Prometheus | observability | SA, ClusterRole, CRB, ConfigMap, Deployment, Service, Ingress | Metrics collection |
| Loki | observability | ConfigMap, Deployment, Service | Log aggregation, S3-backed |
| Grafana | observability | ConfigMap (datasources), Deployment, Service, Ingress | Dashboards |
| Tempo | observability | ConfigMap, Deployment, Service | Tracing backend, S3-backed |
| Jaeger | observability | Deployment, Service, Ingress | Legacy tracing UI |
| OTel Collector | observability | ConfigMap, Deployment, Service | Unified telemetry gateway |
| MinIO | minio | Namespace, PV, PVC, Deployment, Service, 2x Ingress | S3-compatible storage |
| Redis | redis | Namespace, Deployment, 2x Service | Cache layer |

## Key Decisions

- **No Helm/Kustomize** — plain YAML manifests only
- **Shared NFS PVC** — single 100Gi PV with subPath isolation per component
- **Loki + Tempo use MinIO S3** — object storage for logs and traces
- **Higress ingress** — all external access via `*.nhome.local` domain
- **OTel Collector as gateway** — unified ingestion for traces, metrics, logs
- **Jaeger kept alongside Tempo** — legacy UI, not removed during Tempo migration

## Storage Model

| Component | Storage | Type | Size |
|-----------|---------|------|------|
| Prometheus | shared-nfs (subPath: prometheus) | NFS | 100Gi shared |
| Loki | shared-nfs (subPath: loki) + MinIO S3 | NFS + S3 | 100Gi shared |
| Grafana | shared-nfs (subPath: grafana) | NFS | 100Gi shared |
| Jaeger | shared-nfs (subPath: jaeger) | NFS (Badger) | 100Gi shared |
| Tempo | shared-nfs + MinIO S3 | NFS + S3 | 100Gi shared |
| MinIO | dedicated NFS PV | NFS | 500Gi |

## Ingress Domains

| Service | Domain | Port |
|---------|--------|------|
| Prometheus | prometheus.nhome.local | 9090 |
| Grafana | grafana.nhome.local | 3000 |
| Jaeger | jaeger.nhome.local | 16686 |
| MinIO API | api.minio.nhome.local | 9000 |
| MinIO Console | console.minio.nhome.local | 9001 |

## Related
- [App-of-Apps Pattern](concepts/app-of-apps-pattern.md)
- [LGTM Stack](concepts/lgtm-stack.md)
- [GitOps Workflow](concepts/gitops-workflow.md)
