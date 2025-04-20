# MinIO Deployment on Kubernetes

This project configures MinIO to run on a cluster with 1 master and 3 workers in a Kubernetes environment. MinIO is an S3 compliant object storage system and important steps are being taken in terms of security and privacy of data. In this project, Traefik ingress controller was used to securely access MinIO's S3 API and dashboard services.

As done in the RabbitMQ file in the DevOps-Lab repo, you can access the services you have sent to Traefik as **IngressRoute** through the IP address received by the Traefik service in the **host** file. This method provides secure access to MinIO via the IP received with the Traefik service and MetalLB that you have previously stood up.


## Getting Started

You can follow the steps below to deploy MinIO to your Kubernetes environment.

### Necessary Steps

#### 1. Deployment Using MinIO YAML File

To deploy MinIO to your Kubernetes cluster, you can use the following command:

```bash
kubectl apply -f minio.yaml