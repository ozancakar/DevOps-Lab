
# Elasticsearch and Kibana on Kubernetes

This repository provides Kubernetes configurations to deploy a secure, clustered Elasticsearch and Kibana setup on a Kubernetes cluster using a declarative YAML file.

## Overview

- **Elasticsearch**: A distributed, RESTful search and analytics engine deployed as a 3-node cluster (using a StatefulSet) for high availability and scalability.
- **Kibana**: A visualization and exploration tool that connects to Elasticsearch to help users analyze and view data in an intuitive web interface.

In this setup:

- Elasticsearch is deployed as a **cluster with 3 replicas** to ensure data redundancy and fault tolerance.
- **TLS (SSL)** is configured to secure internal and external communication within the Elasticsearch cluster and between Kibana and Elasticsearch.
- **Kubernetes Secrets** are used to securely store credentials (`admin` / `admin` by default — should be changed in production).
- Kibana is configured to connect securely to Elasticsearch using HTTPS.

## Prerequisites

Before applying the configuration, ensure you have:

- A Kubernetes cluster up and running.
- `kubectl` access to the cluster with appropriate permissions.
- MetalLB or any other LoadBalancer implementation available to expose external services.
- DNS management capability for registering service domains (e.g., through internal or public DNS).

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/elasticsearch-kibana-k8s.git
cd elasticsearch-kibana-k8s
```

### 2. Apply the YAML Configuration

This manifest deploys Elasticsearch and Kibana, configures TLS, and sets up services:

```bash
kubectl apply -f elasticsearch-kibana.yaml
```

## Key Features in the YAML Configuration

### Clustered Elasticsearch with StatefulSet

- Ensures stable network identities for pods (`elasticsearch-0`, `elasticsearch-1`, etc.).
- Persistent volumes (via `hostPath` or PVC in production) retain data across pod restarts.
- Enables internal peer discovery using stable DNS naming.

### Secure Communication with TLS

- SSL certificates are mounted into the pods from a predefined host path (e.g., `/path/to/volumefor/certs/`).
- TLS is enforced for both HTTP and transport layers.
- This setup prevents man-in-the-middle attacks and protects data in transit.

### LoadBalancer and DNS Integration

- The Elasticsearch and Kibana services are exposed externally using Kubernetes `Service` resources of type `LoadBalancer`.
- MetalLB assigns static internal IPs from a pre-defined pool.
- **To avoid IP-based service discovery in applications**, a proper DNS record (e.g., `elasticsearch.company.local`) should point to the assigned LoadBalancer IP.  
  This ensures that services are accessed via **DNS instead of hardcoded IPs**, improving maintainability and flexibility in enterprise environments.

## Access

After deployment:

- Access **Kibana** via the LoadBalancer IP or the associated DNS name.
- Ensure DNS records are created in your internal/external DNS server pointing to the MetalLB-assigned IPs.
- Default credentials can be changed by modifying the Secret in the YAML file.

## Notes

- This setup is suitable for development and testing. For production environments:
  - Replace `hostPath` with proper Persistent Volume Claims (PVCs) and a StorageClass.
  - Store secrets in a more secure way (e.g., using a secrets manager).
  - Use ingress controllers with proper TLS termination and authentication.
  - Ensure resource limits and liveness/readiness probes are configured.
