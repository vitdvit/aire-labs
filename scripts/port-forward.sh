#!/usr/bin/env bash
# Port-forward all UIs in background.
# Usage: ./port-forward.sh [stop]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export KUBECONFIG="${SCRIPT_DIR}/../../kubeadm/Proxmox/kubeconfig/config"
PID_FILE="/tmp/aire-port-forwards.pid"

stop() {
  if [[ -f "$PID_FILE" ]]; then
    while IFS= read -r pid; do
      kill "$pid" 2>/dev/null && echo "Killed PID $pid" || true
    done < "$PID_FILE"
    rm -f "$PID_FILE"
  fi
  echo "Port-forwards stopped."
}

start() {
  echo "Starting port-forwards..."
  > "$PID_FILE"

  kubectl port-forward -n agentgateway-system svc/agentgateway-proxy 8080:80 &>/dev/null &
  echo $! >> "$PID_FILE"
  echo "  agentgateway proxy  → http://localhost:8080"

  kubectl port-forward -n kagent svc/kagent-ui 8082:8080 &>/dev/null &
  echo $! >> "$PID_FILE"
  echo "  kagent UI           → http://localhost:8082"

  kubectl port-forward -n a2a-system svc/a2a-agent 8001:80 &>/dev/null &
  echo $! >> "$PID_FILE"
  echo "  a2a Agent Card      → http://localhost:8001/.well-known/agent.json"

  kubectl port-forward -n qdrant svc/qdrant 6333:6333 &>/dev/null &
  echo $! >> "$PID_FILE"
  echo "  qdrant dashboard    → http://localhost:6333/dashboard"

  kubectl port-forward -n phoenix svc/phoenix 6006:6006 &>/dev/null &
  echo $! >> "$PID_FILE"
  echo "  Arize Phoenix       → http://localhost:6006"

  echo ""
  echo "PIDs saved to $PID_FILE"
  echo "Stop with: ./port-forward.sh stop"
}

case "${1:-start}" in
  stop) stop ;;
  start) start ;;
  *) echo "Usage: $0 [start|stop]" ;;
esac
