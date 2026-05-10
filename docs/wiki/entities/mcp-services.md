---
title: MCP Services
type: entity
created: 2026-05-10
updated: 2026-05-10
sources: [bootstrap-nitops]
tags: [argocd, mcp, kubernetes]
---

# MCP Services

## Overview

The `mcp` namespace hosts a unified platform for MCP (Model Context Protocol) services. Each service is managed by its own ArgoCD Application, orchestrated through a sub-app-of-apps pattern under `apps-mcp/`.

## Architecture

Three-layer nesting within the root app-of-apps:

```
apps/mcp.yaml              → ArgoCD Application pointing to apps-mcp/ (directory recurse)
apps-mcp/
├── namespace.yaml         → mcp namespace definition
└── docs-rs-mcp.yaml       → ArgoCD Application managing docs-rs-mcp service
components/mcp/
└── docs-rs-mcp/
    ├── deployment.yaml    → Deployment manifest
    └── service.yaml       → ClusterIP Service
```

## Services

| Service | Namespace | Image | Port | Purpose |
|---------|-----------|-------|------|---------|
| docs-rs-mcp | mcp | vol-monitor:docs-rs-mcp | 8080 | Docs.rs/crates.io MCP server |

## Adding a New MCP Service

1. Create `components/mcp/<name>/` with `deployment.yaml` and `service.yaml`
2. Create `apps-mcp/<name>.yaml` — an ArgoCD Application pointing to the component path
3. The `apps/mcp.yaml` app-of-apps automatically discovers it via `directory: recurse: true`

## Configuration

- **Image registry:** `crpi-ck06yio90i1ttwlz.cn-beijing.personal.cr.aliyuncs.com/n_common/vol-monitor`
- **Image pull secret:** none (public registry)
- **Node selector:** `kubernetes.io/arch: amd64`
- **Proxy:** HTTP/HTTPS proxy via `192.168.2.98:8890`
- **Health probes:** HTTP GET `/` on port 8080

## Related
- [ArgoCD](entities/argocd.md)
- [App-of-Apps Pattern](concepts/app-of-apps-pattern.md)
