# Wiki Index

## Entities
- [ArgoCD](entities/argocd.md) — GitOps orchestrator managing all Application resources
- [MCP Services](entities/mcp-services.md) — Unified MCP service platform (docs-rs-mcp, etc.)
- [Prometheus](entities/prometheus.md) — Metrics collection and storage (v3.11.3)
- [Loki](entities/loki.md) — Log aggregation backend, S3-backed via MinIO
- [Grafana](entities/grafana.md) — Dashboard UI, provisioned with Prometheus/Loki/Tempo datasources
- [MinIO](entities/minio.md) — S3-compatible object storage for Loki and Tempo
- [Redis](entities/redis.md) — Standalone Redis cache in its own namespace
- [Jaeger](entities/jaeger.md) — Legacy all-in-one tracing UI (Badger storage on NFS)
- [Tempo](entities/tempo.md) — Modern tracing backend, S3-backed via MinIO
- [OTel Collector](entities/otel-collector.md) — Unified telemetry ingestion gateway (LGTM pipelines)
- [Higress](entities/higress.md) — Envoy-based ingress controller (v2.2.0), 2-gateway + controller + console
- [Shared NFS](entities/shared-nfs.md) — NFS PersistentVolume (100Gi) backing all observability data
- [Observability Namespace](entities/observability-namespace.md) — Kubernetes namespace for observability stack

## Concepts
- [App-of-Apps Pattern](concepts/app-of-apps-pattern.md) — Three-layer ArgoCD bootstrapping architecture
- [LGTM Stack](concepts/lgtm-stack.md) — Loki, Grafana, Tempo, Prometheus unified observability
- [GitOps Workflow](concepts/gitops-workflow.md) — Repository-driven deployments via ArgoCD
- [SubPath PVC Isolation](concepts/subpath-pvc-isolation.md) — Single shared PVC with per-component subPath mounts
- [Higress Ingress Convention](concepts/higress-ingress-convention.md) — Standardized ingress annotations and domain pattern
- [OTel Unified Pipelines](concepts/otel-unified-pipelines.md) — Three-pipeline OTel Collector architecture (traces/metrics/logs)

## Sources
- [Bootstrap Ingest — nitops codebase](sources/bootstrap-nitops.md) — Full project codebase ingest | ingested: 2026-05-03
