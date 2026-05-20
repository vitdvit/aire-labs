#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="${SCRIPT_DIR}/../manifests"
export KUBECONFIG="${SCRIPT_DIR}/../../kubeadm/Proxmox/kubeconfig/config"

echo "=== Lab-5: Arize Phoenix ==="

echo ">>> Installing Arize Phoenix..."
kubectl create namespace phoenix --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install phoenix \
  oci://registry-1.docker.io/arizephoenix/phoenix-helm \
  --version 7.0.12 \
  --namespace phoenix \
  --values "${MANIFESTS}/lab-5/phoenix/values.yaml" \
  --wait

echo ""
echo "=== Lab-5 done! ==="
echo "Phoenix UI:"
echo "  kubectl port-forward -n phoenix svc/phoenix 6006:6006"
echo "  http://localhost:6006"
echo ""
echo "OTLP endpoint for tracing:"
echo "  http://phoenix.phoenix.svc.cluster.local:6006/v1/traces"
