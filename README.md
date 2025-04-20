# DevOps Lab

This repository documents the installation and configuration of services used in professional Kubernetes environments using YAML files. It contains examples ranging from Ingress configurations to deploying stateful services.

## Overview

The goal of this project is to build an infrastructure with the following order of services:

1. **Traefik**  
   Used as the Kubernetes Ingress Controller, supporting HTTPS and certificate management via ACME.

2. **MetalLB**  
   Provides Layer 2 IP distribution for LoadBalancer-type services, enabling external access through Traefik.

3. **Service Deployments**  
   The following services are deployed with Traefik through `IngressRoute`:
   - RabbitMQ
   - Redis Sentinel
   - MinIO
   - Elasticsearch + Kibana

## Configuration Folders

Each service has a dedicated folder containing its YAML files. These folders contain:
- Deployment (or StatefulSet)
- Service
- ConfigMap/Secret (if applicable)
- IngressRoute (for Traefik)

## Notes
- Certificates are manually created and added to Traefik.
- Persistent Volumes are configured using HostPath instead of PVC.
- YAML files are created manually for each service rather than using Helm, focusing on a declarative approach.

## Service List

| Service             | Description                                   |
|---------------------|-----------------------------------------------|
| **Traefik**          | Ingress Controller, TLS termination, ACME     |
| **MetalLB**          | Layer 2 LoadBalancer IP distribution          |
| **RabbitMQ**         | StatefulSet-based message queue               |
| **Redis Sentinel**   | High Availability Redis setup                 |
| **MinIO**            | S3-compatible object storage                  |
| **Elasticsearch + Kibana** | Log analysis and visualization tools   |

## Objective

This project serves as both a personal portfolio and a real-world example. Each service is configured using simple, easy-to-understand YAML files and is open to contributions from anyone.

## Contact

- GitHub: [ozancakar](https://github.com/ozancakar)
- Email: ozancakar49@gmail.com
- LinkedIn: [ozan-çakar](https://www.linkedin.com/in/ozan-çakar-651490228)
