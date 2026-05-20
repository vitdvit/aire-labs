# _CONTEXT_AIRe

## Кластер Kubernetes

| Параметр | Значення |
|---|---|
| Control Plane endpoint | `10.10.40.181:6443` |
| Control Plane nodes | `10.10.40.181–183` |
| Worker nodes | `10.10.40.191–193` |
| Worker Heavy nodes | `10.10.40.201–203` (64GB RAM / 1TB disk) |
| Pod CIDR | `10.244.0.0/16` |
| Service CIDR | `10.96.0.0/12` |
| CNI | Flannel |
| CRI | CRI-O |
| StorageClass | `local-path` (default) |
| Kubernetes version | v1.30 |

```sh
export KUBECONFIG=/Users/vitalik/Documents/learn-devops-main/k8s/kubeadm/Proxmox/kubeconfig/config
kubectl get nodes -o wide
```

## Структура проекту

```
AIRe/
├── _CONTEXT_AIRe.md     # цей файл
├── _TASKS_AIRe.md       # беклог і статус задач
├── README.md            # опис проекту
├── manifests/           # Kubernetes YAML маніфести
└── Notes/               # атомарні нотатки
```

## Архітектура

> Буде заповнено після визначення задач.

## Нотатки / Нюанси

> Буде заповнено в процесі роботи.
