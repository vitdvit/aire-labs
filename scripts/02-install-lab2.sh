#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export KUBECONFIG="${SCRIPT_DIR}/../../kubeadm/Proxmox/kubeconfig/config"

echo "=== Lab-2: Flux CD (GitOps) ==="

# 1. Flux Operator
echo ">>> Installing Flux Operator..."
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install flux-operator \
  oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --namespace flux-system \
  --wait

# 2. Flux Instance
echo ">>> Installing Flux Instance..."
helm upgrade --install flux-instance \
  oci://ghcr.io/controlplaneio-fluxcd/charts/flux-instance \
  --namespace flux-system \
  --set distribution.version="=2.x" \
  --wait

echo ""
echo "=== Lab-2 done! ==="
echo "Flux status:"
echo "  kubectl get gitrepositories,kustomizations,helmreleases -A"
echo "  kubectl get pods -n flux-system"
