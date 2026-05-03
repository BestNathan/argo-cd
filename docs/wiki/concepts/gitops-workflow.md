---
title: GitOps Workflow
type: concept
created: 2026-05-03
updated: 2026-05-03
sources: [bootstrap-nitops]
tags: [gitops, workflow, argocd]
---

# GitOps Workflow

## Overview

All infrastructure in nitops is managed through GitOps — the git repository is the source of truth. ArgoCD continuously syncs the cluster state with the manifests in the `main` branch of `https://github.com/BestNathan/nitops`.

## Workflow

1. **Edit** — Modify YAML manifests in the repository
2. **Commit & Push** — Changes land on `main`
3. **ArgoCD Auto-Sync** — Detects the change and applies the manifests
4. **Self-Heal** — If the cluster drifts from git, ArgoCD re-applies

## Key Principles

- **Plain YAML only** — no Helm, no Kustomize. Manifests are direct Kubernetes YAML.
- **One resource per file** — manifests are not merged. Each Kubernetes resource lives in its own file.
- **Automated sync** — all Applications use `syncPolicy.automated` with `prune` and `selfHeal`.

## Repository Structure

```
nitops/
├── apps/                    # ArgoCD Application resources
│   ├── app-of-apps.yaml     # Root bootstrap
│   └── ...                  # Component Applications
├── components/              # Kubernetes manifests
│   ├── cluster/             # Cluster-scoped (PVs)
│   ├── observability/       # Observability namespace
│   ├── minio/               # MinIO namespace
│   └── redis/               # Redis namespace
└── CLAUDE.md                # Project documentation
```

## Useful Commands

| Command | Purpose |
|---------|---------|
| `kubectl apply -f apps/app-of-apps.yaml` | Bootstrap |
| `argocd app list` | Check app status |
| `argocd app rollback <app>` | Rollback an app |
| `kubectl apply --dry-run=client -f components/` | Validate manifests |

## Related
- [App-of-Apps Pattern](concepts/app-of-apps-pattern.md)
- [ArgoCD](entities/argocd.md)
