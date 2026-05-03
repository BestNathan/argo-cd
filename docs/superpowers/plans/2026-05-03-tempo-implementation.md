# Tempo Tracing Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Grafana Tempo as a distributed tracing backend to the LGTM stack, coexisting with Jaeger. Tempo uses MinIO S3 for storage and integrates with Grafana for unified querying.

**Architecture:** Tempo all-in-one mode in the `observability` namespace. Receives traces via OTLP gRPC/HTTP, Jaeger gRPC/HTTP, and Zipkin. Stores traces in MinIO S3 (`tempo` bucket). Grafana datasources updated to include Tempo with Loki→Tempo derived fields.

**Tech Stack:** Kubernetes YAML, Grafana Tempo, MinIO S3, ArgoCD

**Status:** Already implemented in commit `ecaecd8`. This plan documents the work for reference.

---

### File Structure

| File | Purpose | Status |
|---|---|---|
| `components/observability/tempo/configmap.yaml` | Tempo configuration (receivers, S3 storage, metrics generator) | Done |
| `components/observability/tempo/deployment.yaml` | Tempo all-in-one deployment with shared NFS PVC | Done |
| `components/observability/tempo/service.yaml` | ClusterIP service exposing all receiver ports | Done |
| `apps/tempo.yaml` | ArgoCD Application for Tempo | Done |
| `components/observability/grafana/configmap-datasources.yaml` | Grafana datasources (Prometheus + Loki + Tempo) | Done |
| `components/observability/grafana/deployment.yaml` | Updated to mount datasource configmap | Done |
| `docs/superpowers/specs/2026-05-03-tempo-design.md` | Design spec | Done |

---

### Task 1: Create Tempo ConfigMap

**Files:**
- Create: `components/observability/tempo/configmap.yaml`

- [x] **Step 1: Create the ConfigMap**

Content at `components/observability/tempo/configmap.yaml`:
- `tempo.yaml` configuration with:
  - HTTP listener on port 3200
  - Receivers: OTLP gRPC (4317), OTLP HTTP (4318), Jaeger gRPC (14250), Jaeger HTTP (14268), Zipkin (9411)
  - S3 storage backend pointing to `minio.minio.svc:9000`, bucket `tempo`, credentials `admin`/`minioadmin`, insecure `true`
  - Compactor with 72h block retention
  - Metrics generator with service-graphs and span-metrics processors
  - Override defaults to enable both processors

- [x] **Step 2: Commit**

```bash
git commit -m "feat: add Tempo tracing backend for LGTM stack"
```

---

### Task 2: Create Tempo Deployment

**Files:**
- Create: `components/observability/tempo/deployment.yaml`

- [x] **Step 1: Create the Deployment**

Content at `components/observability/tempo/deployment.yaml`:
- Image: `grafana/tempo:latest`
- Single replica
- All 6 receiver ports exposed (3200, 4317, 4318, 14250, 14268, 9411)
- Volume mounts:
  - `/etc/tempo` → `tempo-config` ConfigMap
  - `/var/tempo` → `shared-nfs` PVC (for WAL and generator data)
- Resource limits: 1Gi memory, 500m CPU

- [x] **Step 2: Validate with dry-run**

```bash
kubectl apply --dry-run=client -f components/observability/tempo/deployment.yaml
```

Expected: `deployment.apps/tempo created (dry run)`

- [x] **Step 3: Commit** — included in `ecaecd8`

---

### Task 3: Create Tempo Service

**Files:**
- Create: `components/observability/tempo/service.yaml`

- [x] **Step 1: Create the Service**

Content at `components/observability/tempo/service.yaml`:
- Type: ClusterIP
- All 6 ports mapped (3200, 4317, 4318, 14250, 14268, 9411)
- Selector: `app: tempo`

No ingress — Tempo has no Web UI, queried via Grafana.

- [x] **Step 2: Commit** — included in `ecaecd8`

---

### Task 4: Create Tempo ArgoCD Application

**Files:**
- Create: `apps/tempo.yaml`

- [x] **Step 1: Create the ArgoCD Application**

Content at `apps/tempo.yaml`:
- Name: `tempo`
- Source path: `components/observability/tempo`
- Destination: `observability` namespace
- `syncPolicy.automated` with `prune: true` and `selfHeal: true`

- [x] **Step 2: Commit** — included in `ecaecd8`

---

### Task 5: Create Grafana Datasources ConfigMap

**Files:**
- Create: `components/observability/grafana/configmap-datasources.yaml`

- [x] **Step 1: Create the ConfigMap**

Content at `components/observability/grafana/configmap-datasources.yaml`:
- Prometheus datasource: `http://prometheus:9090`, default
- Loki datasource: `http://loki:3100`, with derived field `traceID` → Tempo (UID `tempo`)
- Tempo datasource: `http://tempo:3200`, UID `tempo`

The Loki derived field enables log-to-trace jumping: when a log line contains `traceID=<value>`, Grafana renders it as a clickable link to the corresponding Tempo trace.

- [x] **Step 2: Commit** — included in `ecaecd8`

---

### Task 6: Update Grafana Deployment

**Files:**
- Modify: `components/observability/grafana/deployment.yaml`

- [x] **Step 1: Add datasource volume mount**

Changes to `components/observability/grafana/deployment.yaml`:
- Add volume mount: `/etc/grafana/provisioning/datasources` → `grafana-datasources` ConfigMap
- Add volume: `datasources` ConfigMap → `grafana-datasources`

Before: Grafana had no datasource provisioning (admin credentials only via env vars).
After: Grafana auto-configures Prometheus, Loki, and Tempo on startup.

- [x] **Step 2: Validate**

```bash
kubectl apply --dry-run=client -f components/observability/grafana/deployment.yaml
```

Expected: `deployment.apps/grafana configured (dry run)`

- [x] **Step 3: Commit** — included in `ecaecd8`

---

### Task 7: Final Validation

- [ ] **Step 1: Validate all Tempo manifests**

```bash
kubectl apply --dry-run=client -f components/observability/tempo/
```

Expected: All resources create successfully (dry run).

- [ ] **Step 2: Validate Grafana manifests**

```bash
kubectl apply --dry-run=client -f components/observability/grafana/
```

Expected: All resources create successfully (dry run).

- [ ] **Step 3: Verify directory structure**

```bash
find components/observability/tempo/ -type f | sort
```

Expected:
```
components/observability/tempo/configmap.yaml
components/observability/tempo/deployment.yaml
components/observability/tempo/service.yaml
```

- [ ] **Step 4: Verify ArgoCD sync**

```bash
argocd app list | grep tempo
```

Expected: `tempo` app appears in ArgoCD, syncs to `Synced` and `Healthy`.

---

## Spec Coverage Check

| Spec requirement | Task |
|---|---|
| Tempo all-in-one mode | Task 2 |
| MinIO S3 storage (bucket `tempo`) | Task 1 |
| OTLP/Jaeger/Zipkin receivers | Task 1, 3 |
| Shared NFS PVC for WAL | Task 2 |
| Grafana Tempo datasource | Task 5 |
| Loki→Tempo derived fields | Task 5 |
| Coexistence with Jaeger | All tasks (independent namespace paths) |
| ArgoCD Application | Task 4 |

All spec requirements covered. No placeholders, no contradictions, scope is focused.
