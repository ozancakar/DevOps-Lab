# Traefik Ingress Controller Configuration

This folder contains the Kubernetes manifests and instructions necessary to deploy [Traefik](https://traefik.io/) as an Ingress Controller.

## 📦 Contents

- `traefik.yaml`: Full configuration including:
  - ServiceAccount
  - ClusterRole and ClusterRoleBinding
  - Deployment
  - LoadBalancer Service
  - Middleware for Basic Auth
  - Secret with htpasswd credentials
  - IngressRoute for dashboard access via HTTPS

- `traefik-first-settings.txt`: Initial setup commands for Traefik CRDs and RBAC.

---

## ✅ Prerequisites

Before applying the main Traefik manifest (`traefik.yaml`), you must first apply the required CRDs and RBAC for custom Traefik resources:

```bash
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml
