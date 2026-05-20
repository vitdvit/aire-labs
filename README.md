# AIRe — Agentic Infrastructure on Kubernetes

Розгортання AI Agent Infrastructure на kubeadm-кластері (9 нод на Proxmox VE).
Покриває Labs 1–5 на рівні **Experienced** (включає Beginners).

---

## Архітектура стеку

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                        │
│                                                             │
│  ┌─────────────────┐    ┌──────────────────────────────┐   │
│  │  agentgateway   │    │         kagent               │   │
│  │  (Gateway API)  │◄───│  (AI agent orchestrator)    │   │
│  │  port 80        │    │  UI: :8082 (port-forward)   │   │
│  └────────┬────────┘    └──────────────────────────────┘   │
│           │                                                  │
│           ├──► /v1/chat → Gemini (gemini-2.0-flash)         │
│           ├──► /mcp    → devops-tools MCP Server            │
│           └──► /a2a    → a2a Agent                          │
│                                                             │
│  ┌──────────────────┐  ┌──────────┐  ┌────────────────┐   │
│  │ devops-tools-mcp │  │  qdrant  │  │ Arize Phoenix  │   │
│  │ (FastMCP/Python) │  │ (vector) │  │ (observability)│   │
│  │ ns: mcp-system   │  │ ns:qdrant│  │ ns: phoenix    │   │
│  └──────────────────┘  └──────────┘  └────────────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Flux CD (GitOps)  — namespace: flux-system          │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Кластер

| Роль | IP | Ресурси |
|---|---|---|
| Control Plane (×3) | 10.10.40.181–183 | 2c/4GB/60GB |
| Worker (×3) | 10.10.40.191–193 | 4c/8GB/100GB |
| Worker Heavy (×3) | 10.10.40.201–203 | 16c/64GB/1TB |

```sh
export KUBECONFIG=/path/to/k8s/kubeadm/Proxmox/kubeconfig/config
kubectl get nodes -o wide
```

---

## Що розгорнуто

| Компонент | Namespace | Версія | Статус |
|---|---|---|---|
| agentgateway | agentgateway-system | v2.2.1 | ✅ |
| Gemini backend | agentgateway-system | gemini-2.0-flash | ✅ |
| kagent | kagent | 0.7.23 | ✅ |
| Gemini ModelConfig | kagent | gemini-2.5-flash | ✅ |
| devops-assistant Agent | kagent | — | ✅ |
| devops-tools MCP server | mcp-system | FastMCP 1.27.1 | ✅ |
| a2a Agent | a2a-system | FastAPI | ✅ |
| qdrant | qdrant | v1.18.0 | ✅ |
| Arize Phoenix | phoenix | 7.0.12 | ✅ |
| Flux CD | flux-system | 2.x | ✅ |

---

## Lab-1: agentgateway + kagent (Helm на k8s)

### Що зроблено
- Gateway API CRDs (v1.3.0) + agentgateway CRDs/chart (v2.2.1) через Helm OCI
- `Gateway` resource → GatewayClass `agentgateway` → proxy pod автоматично
- `Secret gemini-secret` → `AgentgatewayBackend` → `HTTPRoute` → Gemini
- kagent v0.7.23 + `ModelConfig` для Gemini (gemini-2.5-flash)

### Доступ

```sh
# kagent UI
kubectl port-forward -n kagent svc/kagent-ui 8082:8080
# http://localhost:8082

# agentgateway proxy (OpenAI-compatible endpoint)
kubectl port-forward -n agentgateway-system svc/agentgateway-proxy 8080:80

# Тест Gemini через agentgateway
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gemini-2.0-flash","messages":[{"role":"user","content":"Hello"}]}'
```

### Маніфести

```
manifests/lab-1/
├── 00-gateway.yaml          # Gateway resource (GatewayClass: agentgateway)
├── 01-secret-gemini.yaml    # Secret з Gemini API key
├── 02-backend-gemini.yaml   # AgentgatewayBackend CRD
├── 03-httproute-gemini.yaml # HTTPRoute → Gemini backend
└── 04-kagent.yaml           # Namespace + Secret + ModelConfig
```

---

## Lab-2: GitOps з Flux CD

### Що зроблено
- Flux Operator + Flux Instance через Helm OCI (`ghcr.io/controlplaneio-fluxcd/charts`)
- Flux CD controllers: source, kustomize, helm, notification
- Майбутні deployments керуються через OCIRepository + HelmRelease

### Статус

```sh
kubectl get pods -n flux-system
kubectl get helmreleases,ocirepositories -A
```

### Маніфести

```
manifests/lab-2/flux/
└── flux-resources.yaml   # OCIRepository + HelmRelease для agentgateway/kagent (Flux-managed варіант)
```

---

## Lab-3: MCP Server + kagent Agent

### Що зроблено
- **devops-tools MCP server** (Python + FastMCP 1.27.1)
  - Transport: `streamable-http`, порт 8000, хост `0.0.0.0`
  - Endpoint: `POST /mcp`
  - Деплой через ConfigMap + `python:3.12-slim` (без окремого реєстру)
- **RemoteMCPServer** CRD у kagent → ACCEPTED: True
- **devops-assistant Agent** у kagent — Gemini + MCP tools
- HTTPRoute через agentgateway на шлях `/mcp`

### MCP Tools

| Tool | Опис |
|---|---|
| `get_time` | Поточний UTC час |
| `echo` | Echo повідомлення |
| `get_env_info` | Pod name, namespace, hostname |
| `list_tools` | Список tools |

### Тест з MCP Inspector

```sh
kubectl port-forward -n mcp-system svc/devops-tools-mcp 8000:80
npx @modelcontextprotocol/inspector@0.21.1
# → Connect to: http://localhost:8000/mcp (Streamable HTTP)
```

### Маніфести

```
manifests/lab-3/
├── mcp-server/
│   ├── server.py              # FastMCP server (streamable-http, host=0.0.0.0)
│   ├── requirements.txt       # mcp[cli]>=1.9.0
│   ├── Dockerfile             # python:3.12-slim
│   └── k8s/
│       ├── 00-namespace.yaml
│       ├── 01-configmap.yaml  # Код сервера (ConfigMap-based deploy)
│       ├── 02-deployment.yaml # init container pip install + main container
│       ├── 03-service.yaml
│       └── 04-httproute.yaml  # /mcp через agentgateway
└── kagent-agent/
    └── agent.yaml             # RemoteMCPServer + Agent
```

---

## Lab-4: qdrant + a2a Agent

### Що зроблено
- **qdrant v1.18.0** — vector database, Helm chart, 10Gi PVC (local-path)
- **a2a Agent** — реалізує A2A Protocol специфікацію:
  - `GET /.well-known/agent.json` — Agent Card
  - `POST /tasks/send` — виконання task
  - HTTPRoute через agentgateway на `/a2a`

### Тест

```sh
# Agent Card
kubectl port-forward -n a2a-system svc/a2a-agent 8001:80
curl http://localhost:8001/.well-known/agent.json | python3 -m json.tool

# A2A task
curl -X POST http://localhost:8001/tasks/send \
  -H "Content-Type: application/json" \
  -d '{"id":"task-1","message":{"parts":[{"type":"text","text":"Hello agent!"}]}}'

# qdrant Dashboard
kubectl port-forward -n qdrant svc/qdrant 6333:6333
# http://localhost:6333/dashboard
```

### Маніфести

```
manifests/lab-4/
├── qdrant/
│   └── values.yaml
└── a2a-agent/
    ├── agent.py               # FastAPI: /.well-known/agent.json + /tasks/send
    ├── requirements.txt
    ├── Dockerfile
    └── k8s/
        ├── 00-namespace.yaml
        ├── 01-configmap.yaml
        └── 02-deployment.yaml # Deployment + Service + HTTPRoute + ReferenceGrant
```

---

## Lab-5: Arize Phoenix (Observability)

### Що зроблено
- Arize Phoenix 7.0.12 — Helm chart OCI (`registry-1.docker.io/arizephoenix/phoenix-helm`)
- SQLite storage, 10Gi PVC
- OTLP endpoint: `http://phoenix.phoenix.svc.cluster.local:4317`
- HTTP traces: `http://phoenix.phoenix.svc.cluster.local:6006/v1/traces`

### Phoenix UI

```sh
kubectl port-forward -n phoenix svc/phoenix-svc 6006:6006
# http://localhost:6006
```

### Інструментування MCP сервера

```python
# pip install opentelemetry-sdk arize-phoenix-otel
from phoenix.otel import register
register(
    project_name="devops-tools-mcp",
    endpoint="http://phoenix.phoenix.svc.cluster.local:6006/v1/traces",
)
```

### Маніфести

```
manifests/lab-5/phoenix/
└── values.yaml   # replicaCount, SQLite, 10Gi PVC
```

---

## Всі UIs одночасно

```sh
./scripts/port-forward.sh        # запустити всі
./scripts/port-forward.sh stop   # зупинити всі
```

| UI | URL | Namespace |
|---|---|---|
| kagent | http://localhost:8082 | kagent |
| agentgateway proxy | http://localhost:8080 | agentgateway-system |
| a2a Agent Card | http://localhost:8001/.well-known/agent.json | a2a-system |
| qdrant Dashboard | http://localhost:6333/dashboard | qdrant |
| Arize Phoenix | http://localhost:6006 | phoenix |

---

## Встановлення з нуля

```sh
cd k8s/AIRe/scripts
./01-install-lab1.sh   # agentgateway + kagent
./02-install-lab2.sh   # Flux CD
./03-install-lab3.sh   # MCP server + agent
./04-install-lab4.sh   # qdrant + a2a agent
./05-install-lab5.sh   # Phoenix
```

---

## Корисні команди

```sh
# Стан всіх компонентів
kubectl get pods -n agentgateway-system
kubectl get pods -n kagent
kubectl get pods -n mcp-system
kubectl get pods -n a2a-system
kubectl get pods -n qdrant
kubectl get pods -n phoenix
kubectl get pods -n flux-system

# Agents та MCP servers
kubectl get agents,modelconfigs,remotemcpservers -n kagent

# Gateway та Routes
kubectl get gateway,httproute -A

# Знести все
helm uninstall agentgateway agentgateway-crds -n agentgateway-system
helm uninstall kagent kagent-crds -n kagent
helm uninstall qdrant -n qdrant
helm uninstall phoenix -n phoenix
helm uninstall flux-operator flux-instance -n flux-system
kubectl delete ns agentgateway-system kagent mcp-system a2a-system qdrant phoenix flux-system
```

---

## Конфігурація

| Параметр | Значення |
|---|---|
| Gemini API Key | Secret `gemini-secret` (agentgateway-system), `kagent-gemini` (kagent) |
| LLM (agentgateway) | `gemini-2.0-flash` |
| LLM (kagent) | `gemini-2.5-flash` |
| MCP endpoint | `http://devops-tools-mcp.mcp-system.svc.cluster.local/mcp` |
| OTLP endpoint | `http://phoenix.phoenix.svc.cluster.local:4317` |
| qdrant gRPC | `qdrant.qdrant.svc.cluster.local:6334` |
| qdrant HTTP | `qdrant.qdrant.svc.cluster.local:6333` |
