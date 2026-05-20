#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="${SCRIPT_DIR}/../manifests"
export KUBECONFIG="${SCRIPT_DIR}/../../kubeadm/Proxmox/kubeconfig/config"

echo "=== Lab-3: MCP Server + kagent Agent ==="

# 1. Deploy MCP server
echo ">>> Deploying devops-tools MCP server..."
kubectl apply -f "${MANIFESTS}/lab-3/mcp-server/k8s/00-namespace.yaml"
kubectl apply -f "${MANIFESTS}/lab-3/mcp-server/k8s/01-configmap.yaml"
kubectl apply -f "${MANIFESTS}/lab-3/mcp-server/k8s/02-deployment.yaml"
kubectl apply -f "${MANIFESTS}/lab-3/mcp-server/k8s/03-service.yaml"
kubectl apply -f "${MANIFESTS}/lab-3/mcp-server/k8s/04-httproute.yaml"

# 2. Wait for MCP server
echo ">>> Waiting for MCP server to be ready..."
kubectl rollout status deployment/devops-tools-mcp -n mcp-system --timeout=120s

# 3. Deploy kagent Agent
echo ">>> Creating kagent Agent..."
kubectl apply -f "${MANIFESTS}/lab-3/kagent-agent/agent.yaml"

echo ""
echo "=== Lab-3 done! ==="
echo "MCP server SSE endpoint (via agentgateway proxy):"
echo "  http://<gateway-ip>/mcp/sse"
echo ""
echo "Test MCP with inspector:"
echo "  npx @modelcontextprotocol/inspector@0.21.1"
echo ""
echo "kagent Agent:"
echo "  kubectl get agents -n kagent"
