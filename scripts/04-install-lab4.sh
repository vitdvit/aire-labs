#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="${SCRIPT_DIR}/../manifests"
export KUBECONFIG="${SCRIPT_DIR}/../../kubeadm/Proxmox/kubeconfig/config"

echo "=== Lab-4: qdrant + a2a Agent ==="

# 1. qdrant
echo ">>> Installing qdrant..."
helm repo add qdrant https://qdrant.github.io/qdrant-helm 2>/dev/null || true
helm repo update
kubectl create namespace qdrant --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install qdrant qdrant/qdrant \
  --namespace qdrant \
  --values "${MANIFESTS}/lab-4/qdrant/values.yaml" \
  --wait

# 2. a2a Agent
echo ">>> Deploying a2a agent..."
kubectl apply -f "${MANIFESTS}/lab-4/a2a-agent/k8s/00-namespace.yaml"
kubectl apply -f "${MANIFESTS}/lab-4/a2a-agent/k8s/01-configmap.yaml"
kubectl apply -f "${MANIFESTS}/lab-4/a2a-agent/k8s/02-deployment.yaml"

echo ">>> Waiting for a2a agent to be ready..."
kubectl rollout status deployment/a2a-agent -n a2a-system --timeout=120s

echo ""
echo "=== Lab-4 done! ==="
echo "Test Agent Card:"
echo "  kubectl port-forward -n a2a-system svc/a2a-agent 8001:80"
echo "  curl http://localhost:8001/.well-known/agent.json"
echo ""
echo "qdrant UI:"
echo "  kubectl port-forward -n qdrant svc/qdrant 6333:6333"
echo "  http://localhost:6333/dashboard"
