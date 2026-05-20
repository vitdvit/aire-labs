#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="${SCRIPT_DIR}/../manifests"
export KUBECONFIG="${SCRIPT_DIR}/../../kubeadm/Proxmox/kubeconfig/config"

echo "=== Lab-1: agentgateway + kagent ==="

# 1. Gateway API CRDs
echo ">>> Installing Gateway API CRDs..."
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

# 2. agentgateway CRDs
echo ">>> Installing agentgateway CRDs..."
kubectl create namespace agentgateway-system --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install agentgateway-crds \
  oci://ghcr.io/kgateway-dev/charts/agentgateway-crds \
  --version v2.2.1 \
  --namespace agentgateway-system \
  --wait

# 3. agentgateway
echo ">>> Installing agentgateway..."
helm upgrade --install agentgateway \
  oci://ghcr.io/kgateway-dev/charts/agentgateway \
  --version v2.2.1 \
  --namespace agentgateway-system \
  --wait

# 4. Gateway resource + Gemini backend
echo ">>> Applying Gateway, Secret, Backend, HTTPRoute..."
kubectl apply -f "${MANIFESTS}/lab-1/00-gateway.yaml"
kubectl apply -f "${MANIFESTS}/lab-1/01-secret-gemini.yaml"

# Wait for Gateway API CRDs
sleep 5
kubectl apply -f "${MANIFESTS}/lab-1/02-backend-gemini.yaml"
kubectl apply -f "${MANIFESTS}/lab-1/03-httproute-gemini.yaml"

# 5. kagent CRDs
echo ">>> Installing kagent CRDs..."
kubectl create namespace kagent --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install kagent-crds \
  oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
  --namespace kagent \
  --wait

# 6. kagent
echo ">>> Installing kagent..."
helm upgrade --install kagent \
  oci://ghcr.io/kagent-dev/kagent/helm/kagent \
  --version 0.7.23 \
  --namespace kagent \
  --set providers.default=openAI \
  --set providers.openAI.apiKey=dummy \
  --wait

# 7. Gemini ModelConfig for kagent
echo ">>> Applying kagent Gemini ModelConfig..."
kubectl apply -f "${MANIFESTS}/lab-1/04-kagent.yaml"

echo ""
echo "=== Lab-1 done! ==="
echo "Port-forward commands:"
echo "  kubectl port-forward -n agentgateway-system svc/agentgateway-proxy 8080:80"
echo "  kubectl port-forward -n kagent svc/kagent-ui 8082:8080"
echo ""
echo "Access:"
echo "  agentgateway proxy: http://localhost:8080"
echo "  kagent UI:          http://localhost:8082"
