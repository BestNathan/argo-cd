# Observability GitOps Repo Initialization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize the GitOps repository with ArgoCD App-of-Apps pattern, deploying Prometheus, Loki, and Grafana into the `observability` namespace using plain Kubernetes YAML manifests.

**Architecture:** Two-layer structure — `apps/` contains ArgoCD Application resources, `components/observability/` contains namespace-level grouped Kubernetes manifests. Bootstrap via `app-of-apps.yaml`.

**Tech Stack:** Kubernetes YAML, ArgoCD Applications

---

### File Structure

| File | Purpose |
|---|---|
| `components/observability/namespace.yaml` | Namespace definition for `observability` |
| `components/observability/prometheus/serviceaccount.yaml` | Prometheus RBAC service account |
| `components/observability/prometheus/clusterrole.yaml` | Cluster-level read permissions for scraping |
| `components/observability/prometheus/clusterrolebinding.yaml` | Bind clusterrole to serviceaccount |
| `components/observability/prometheus/configmap.yaml` | Prometheus scrape configuration |
| `components/observability/prometheus/pvc.yaml` | Persistent storage for Prometheus data |
| `components/observability/prometheus/deployment.yaml` | Prometheus server deployment |
| `components/observability/prometheus/service.yaml` | ClusterIP service for Prometheus API |
| `components/observability/loki/configmap.yaml` | Loki configuration file |
| `components/observability/loki/deployment.yaml` | Loki server deployment |
| `components/observability/loki/service.yaml` | ClusterIP service for Loki API |
| `components/observability/grafana/configmap-datasource.yaml` | Auto-configure Prometheus + Loki datasources |
| `components/observability/grafana/deployment.yaml` | Grafana dashboard deployment |
| `components/observability/grafana/service.yaml` | ClusterIP service for Grafana UI |
| `components/observability/grafana/ingress.yaml` | External access to Grafana |
| `apps/prometheus.yaml` | ArgoCD Application for Prometheus |
| `apps/loki.yaml` | ArgoCD Application for Loki |
| `apps/grafana.yaml` | ArgoCD Application for Grafana |
| `apps/app-of-apps.yaml` | Root ArgoCD Application that bootstraps all others |

---

### Task 1: Create namespace manifest

**Files:**
- Create: `components/observability/namespace.yaml`

- [ ] **Step 1: Create the namespace manifest**

```yaml
# components/observability/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: observability
  labels:
    app.kubernetes.io/part-of: observability
```

- [ ] **Step 2: Validate with dry-run**

```bash
kubectl apply --dry-run=client -f components/observability/namespace.yaml
```

Expected: `namespace/observability created (dry run)`

- [ ] **Step 3: Commit**

```bash
git add components/observability/namespace.yaml
git commit -m "feat: add observability namespace"
```

---

### Task 2: Create Prometheus RBAC manifests

**Files:**
- Create: `components/observability/prometheus/serviceaccount.yaml`
- Create: `components/observability/prometheus/clusterrole.yaml`
- Create: `components/observability/prometheus/clusterrolebinding.yaml`

- [ ] **Step 1: Create ServiceAccount**

```yaml
# components/observability/prometheus/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: observability
  labels:
    app: prometheus
```

- [ ] **Step 2: Create ClusterRole**

```yaml
# components/observability/prometheus/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
  labels:
    app: prometheus
rules:
  - apiGroups: [""]
    resources: ["nodes", "nodes/metrics", "services", "endpoints", "pods"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get"]
  - apiGroups:
    - discovery.k8s.io
    resources:
    - endpointslices
    verbs:
    - get
    - list
    - watch
  - apiGroups:
    - networking.k8s.io
    resources:
    - ingresses
    verbs:
    - get
    - list
    - watch
  - nonResourceURLs: ["/metrics"]
    verbs: ["get"]
```

- [ ] **Step 3: Create ClusterRoleBinding**

```yaml
# components/observability/prometheus/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
  labels:
    app: prometheus
subjects:
  - kind: ServiceAccount
    name: prometheus
    namespace: observability
roleRef:
  kind: ClusterRole
  name: prometheus
  apiGroup: rbac.authorization.k8s.io
```

- [ ] **Step 4: Validate with dry-run**

```bash
kubectl apply --dry-run=client -f components/observability/prometheus/serviceaccount.yaml
kubectl apply --dry-run=client -f components/observability/prometheus/clusterrole.yaml
kubectl apply --dry-run=client -f components/observability/prometheus/clusterrolebinding.yaml
```

- [ ] **Step 5: Commit**

```bash
git add components/observability/prometheus/serviceaccount.yaml components/observability/prometheus/clusterrole.yaml components/observability/prometheus/clusterrolebinding.yaml
git commit -m "feat: add Prometheus RBAC manifests"
```

---

### Task 3: Create Prometheus configmap, PVC, deployment, and service

**Files:**
- Create: `components/observability/prometheus/configmap.yaml`
- Create: `components/observability/prometheus/pvc.yaml`
- Create: `components/observability/prometheus/deployment.yaml`
- Create: `components/observability/prometheus/service.yaml`

- [ ] **Step 1: Create ConfigMap with prometheus.yml**

```yaml
# components/observability/prometheus/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: observability
  labels:
    app: prometheus
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
      - job_name: "prometheus"
        static_configs:
          - targets: ["localhost:9090"]
```

- [ ] **Step 2: Create PVC**

```yaml
# components/observability/prometheus/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-data
  namespace: observability
  labels:
    app: prometheus
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

- [ ] **Step 3: Create Deployment**

```yaml
# components/observability/prometheus/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: observability
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      containers:
        - name: prometheus
          image: prom/prometheus:latest
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
            - "--storage.tsdb.path=/prometheus"
            - "--storage.tsdb.retention.time=15d"
          ports:
            - containerPort: 9090
              name: metrics
          volumeMounts:
            - name: config
              mountPath: /etc/prometheus
            - name: data
              mountPath: /prometheus
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1Gi"
              cpu: "500m"
      volumes:
        - name: config
          configMap:
            name: prometheus-config
        - name: data
          persistentVolumeClaim:
            claimName: prometheus-data
```

- [ ] **Step 4: Create Service**

```yaml
# components/observability/prometheus/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: observability
  labels:
    app: prometheus
spec:
  type: ClusterIP
  ports:
    - port: 9090
      targetPort: 9090
      protocol: TCP
      name: metrics
  selector:
    app: prometheus
```

- [ ] **Step 5: Validate all Prometheus manifests**

```bash
kubectl apply --dry-run=client -f components/observability/prometheus/
```

Expected: All resources created (dry run) without errors.

- [ ] **Step 6: Commit**

```bash
git add components/observability/prometheus/
git commit -m "feat: add Prometheus deployment, service, config, and storage"
```

---

### Task 4: Create Loki manifests

**Files:**
- Create: `components/observability/loki/configmap.yaml`
- Create: `components/observability/loki/deployment.yaml`
- Create: `components/observability/loki/service.yaml`

- [ ] **Step 1: Create Loki ConfigMap**

```yaml
# components/observability/loki/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: loki-config
  namespace: observability
  labels:
    app: loki
data:
  loki.yaml: |
    auth_enabled: false

    server:
      http_listen_port: 3100

    common:
      path_prefix: /loki
      storage:
        filesystem:
          chunks_directory: /loki/chunks
          rules_directory: /loki/rules
      replication_factor: 1
      ring:
        kvstore:
          store: inmemory

    schema_config:
      configs:
        - from: "2020-10-24"
          store: boltdb-shipper
          object_store: filesystem
          schema: v11
          index:
            prefix: index_
            period: 24h

    limits_config:
      reject_old_samples: true
      reject_old_samples_max_age: 168h
```

- [ ] **Step 2: Create Loki Deployment**

```yaml
# components/observability/loki/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki
  namespace: observability
  labels:
    app: loki
spec:
  replicas: 1
  selector:
    matchLabels:
      app: loki
  template:
    metadata:
      labels:
        app: loki
    spec:
      containers:
        - name: loki
          image: grafana/loki:latest
          args:
            - "--config.file=/etc/loki/loki.yaml"
          ports:
            - containerPort: 3100
              name: http
          volumeMounts:
            - name: config
              mountPath: /etc/loki
            - name: data
              mountPath: /loki
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "250m"
      volumes:
        - name: config
          configMap:
            name: loki-config
        - name: data
          emptyDir: {}
```

- [ ] **Step 3: Create Loki Service**

```yaml
# components/observability/loki/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: loki
  namespace: observability
  labels:
    app: loki
spec:
  type: ClusterIP
  ports:
    - port: 3100
      targetPort: 3100
      protocol: TCP
      name: http
  selector:
    app: loki
```

- [ ] **Step 4: Validate all Loki manifests**

```bash
kubectl apply --dry-run=client -f components/observability/loki/
```

Expected: All resources created (dry run) without errors.

- [ ] **Step 5: Commit**

```bash
git add components/observability/loki/
git commit -m "feat: add Loki deployment, service, and config"
```

---

### Task 5: Create Grafana manifests

**Files:**
- Create: `components/observability/grafana/configmap-datasource.yaml`
- Create: `components/observability/grafana/deployment.yaml`
- Create: `components/observability/grafana/service.yaml`
- Create: `components/observability/grafana/ingress.yaml`

- [ ] **Step 1: Create Grafana datasource ConfigMap**

```yaml
# components/observability/grafana/configmap-datasource.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: observability
  labels:
    app: grafana
data:
  datasources.yaml: |
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://prometheus:9090
        isDefault: true
      - name: Loki
        type: loki
        access: proxy
        url: http://loki:3100
```

- [ ] **Step 2: Create Grafana Deployment**

```yaml
# components/observability/grafana/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: observability
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
        - name: grafana
          image: grafana/grafana:latest
          ports:
            - containerPort: 3000
              name: http
          env:
            - name: GF_SECURITY_ADMIN_USER
              value: "admin"
            - name: GF_SECURITY_ADMIN_PASSWORD
              value: "admin"
          volumeMounts:
            - name: datasources
              mountPath: /etc/grafana/provisioning/datasources
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "250m"
      volumes:
        - name: datasources
          configMap:
            name: grafana-datasources
```

- [ ] **Step 3: Create Grafana Service**

```yaml
# components/observability/grafana/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: observability
  labels:
    app: grafana
spec:
  type: ClusterIP
  ports:
    - port: 3000
      targetPort: 3000
      protocol: TCP
      name: http
  selector:
    app: grafana
```

- [ ] **Step 4: Create Grafana Ingress**

```yaml
# components/observability/grafana/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: observability
  labels:
    app: grafana
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: grafana.example.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  number: 3000
```

- [ ] **Step 5: Validate all Grafana manifests**

```bash
kubectl apply --dry-run=client -f components/observability/grafana/
```

Expected: All resources created (dry run) without errors.

- [ ] **Step 6: Commit**

```bash
git add components/observability/grafana/
git commit -m "feat: add Grafana deployment, service, datasources, and ingress"
```

---

### Task 6: Create ArgoCD Application manifests

**Files:**
- Create: `apps/prometheus.yaml`
- Create: `apps/loki.yaml`
- Create: `apps/grafana.yaml`
- Create: `apps/app-of-apps.yaml`

- [ ] **Step 1: Create Prometheus ArgoCD Application**

Note: Replace `REPO_URL_PLACEHOLDER` with the actual git repo URL.

```yaml
# apps/prometheus.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prometheus
  namespace: argocd
  labels:
    app: prometheus
spec:
  project: default
  source:
    repoURL: REPO_URL_PLACEHOLDER
    targetRevision: main
    path: components/observability/prometheus
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

- [ ] **Step 2: Create Loki ArgoCD Application**

```yaml
# apps/loki.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: loki
  namespace: argocd
  labels:
    app: loki
spec:
  project: default
  source:
    repoURL: REPO_URL_PLACEHOLDER
    targetRevision: main
    path: components/observability/loki
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

- [ ] **Step 3: Create Grafana ArgoCD Application**

```yaml
# apps/grafana.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: grafana
  namespace: argocd
  labels:
    app: grafana
spec:
  project: default
  source:
    repoURL: REPO_URL_PLACEHOLDER
    targetRevision: main
    path: components/observability/grafana
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

- [ ] **Step 4: Create app-of-apps**

```yaml
# apps/app-of-apps.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-apps
  namespace: argocd
  labels:
    app: observability-apps
spec:
  project: default
  source:
    repoURL: REPO_URL_PLACEHOLDER
    targetRevision: main
    path: apps
    directory:
      exclude: "app-of-apps.yaml"
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

- [ ] **Step 5: Commit**

```bash
git add apps/
git commit -m "feat: add ArgoCD app-of-apps and component applications"
```

---

### Task 7: Final validation

- [ ] **Step 1: Validate all components together**

```bash
kubectl apply --dry-run=client -f components/
```

Expected: All resources across all three components create successfully (dry run).

- [ ] **Step 2: Verify final directory structure**

```bash
find components/ apps/ -type f | sort
```

Expected output:
```
apps/app-of-apps.yaml
apps/grafana.yaml
apps/loki.yaml
apps/prometheus.yaml
components/observability/grafana/configmap-datasource.yaml
components/observability/grafana/deployment.yaml
components/observability/grafana/ingress.yaml
components/observability/grafana/service.yaml
components/observability/loki/configmap.yaml
components/observability/loki/deployment.yaml
components/observability/loki/service.yaml
components/observability/namespace.yaml
components/observability/prometheus/clusterrole.yaml
components/observability/prometheus/clusterrolebinding.yaml
components/observability/prometheus/configmap.yaml
components/observability/prometheus/deployment.yaml
components/observability/prometheus/pvc.yaml
components/observability/prometheus/service.yaml
components/observability/prometheus/serviceaccount.yaml
```

- [ ] **Step 3: Final commit if any remaining changes**

---

## Self-Review

**1. Spec coverage check:**

| Spec requirement | Task |
|---|---|
| Namespace `observability` | Task 1 |
| Prometheus: ServiceAccount + ClusterRole + ClusterRoleBinding | Task 2 |
| Prometheus: ConfigMap prometheus.yml | Task 3 |
| Prometheus: Deployment with PVC | Task 3 |
| Prometheus: Service ClusterIP:9090 | Task 3 |
| Loki: ConfigMap loki.yaml | Task 4 |
| Loki: Deployment | Task 4 |
| Loki: Service ClusterIP:3100 | Task 4 |
| Promtail out of scope | Not included (correct) |
| Grafana: datasource ConfigMap | Task 5 |
| Grafana: Deployment | Task 5 |
| Grafana: Service ClusterIP:3000 | Task 5 |
| Grafana: Ingress | Task 5 |
| App-of-Apps pattern | Task 6 |
| syncPolicy automated + prune + selfHeal | Task 6 |
| repoURL placeholder | Task 6 (REPO_URL_PLACEHOLDER) |
| Components grouped by namespace | All tasks use `components/observability/` |

All spec requirements covered.

**2. Placeholder scan:** Only intentional placeholder is `REPO_URL_PLACEHOLDER` — user needs to replace with actual repo URL. No TBDs or TODOs.

**3. Type consistency:** All resources consistently use `namespace: observability`, labels use `app: <component-name>`, service names match deployment references (prometheus, loki, grafana). Grafana datasource URLs reference `http://prometheus:9090` and `http://loki:3100` which match the Service names and ports.

Plan is consistent and complete.
