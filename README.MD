
# DevOps-Lab

A comprehensive DevOps and Kubernetes learning lab designed for modern cloud-native applications. This repository contains infrastructure components, observability tools, messaging systems, storage solutions, and real-world application examples — all ready to deploy on Kubernetes.

---

## 📌 Purpose

This repository serves as a hands-on guide for learning and building production-grade Kubernetes environments. It enables developers, DevOps engineers, and SREs to:

- Deploy microservices with proper observability
- Configure secure, reliable messaging systems
- Manage storage solutions for cloud-native apps
- Implement monitoring, tracing, and logging
- Apply GitOps and Infrastructure-as-Code best practices

---

## 🏗️ Repository Structure

```
DevOps-Lab/
├── infrastructure/             # Kubernetes Infrastructure Components
│   ├── core/                   # Core tools like Traefik, MetalLB, Cert-Manager
│   ├── observability/          # Prometheus, Grafana, OpenTelemetry, ELK Stack
│   ├── messaging/              # RabbitMQ, Redis Sentinel
│   ├── storage/                # MinIO
│   └── security/               # SonarQube, Certificate Managers
│
├── applications/               # Application demos with observability integrations
│   └── observability-demos/    # Example apps with OpenTelemetry, tracing, metrics
│       ├── dotnet-otel-complete/
│       ├── nodejs-distributed-tracing/
│       └── ...
│
├── .gitignore
├── README.md
└── LICENSE
```

---

## 🗺️ High-Level Architecture

```
                                         ┌────────────────────┐
                                         │  Clients / Users   │
                                         └─────────┬──────────┘
                                                   │
                                      ┌────────────▼─────────────┐
                                      │     Traefik Ingress      │
                                      └───────┬─────────┬────────┘
                                              │         │
                          ┌───────────────────▼─┐   ┌───▼────────────────────┐
                          │  Application Layer  │   │ Monitoring & Logging   │
                          │  - .NET             │   │  - Prometheus          │
                          │  - Java             │   │  - Grafana             │
                          │  - GoLang           │   │  - OpenTelemetry       │
                          └─────────┬───────────┘   └────────────────────────┘
                                    │                 
                        ┌───────────▼───────────────┐
                        │ Core Platform Services    │ 
                        │ - RabbitMQ                │                
                        │ - Redis Sentinel          │ 
                        │ - MinIO                   │
                        │ - ELK-Stack               │                        
                        │ - Any other services      │
                        └───────────────────────────┘ 
```

> ✅ **All components communicate securely via Kubernetes internal networking.**

---

## 🚀 Getting Started

### ✅ Prerequisites

- Kubernetes cluster is installed and running (e.g., minikube, kind, k3s, or production-grade cluster).

- **If you are running outside a cloud environment (e.g., on-premises or local VM):**

- `kubectl` CLI installed and configured to access your cluster.

- Optional but recommended: `helm` installed for easier package management.

  - Deploy **MetalLB** to provide LoadBalancer IPs in your cluster:
    ```bash
    kubectl apply -f infrastructure/core/metallb/
    ```

  - Deploy **Traefik** as your Ingress Controller to manage incoming traffic:
    ```bash
    kubectl apply -f infrastructure/core/traefik/
    ```

  - To access services routed by Traefik from your local machine, you need to update your OS's `hosts` file:

    1. Find the external IP assigned to Traefik LoadBalancer service:
       ```bash
       kubectl get svc -n traefik
       ```

    2. Edit the hosts file on your local machine:

       - **Windows:**  
         Edit `C:\Windows\System32\drivers\etc\hosts` as Administrator.

       - **Linux/macOS:**  
         Edit `/etc/hosts` with root privileges (e.g., `sudo nano /etc/hosts`).

    3. Add an entry like:
       ```
       <Traefik_LoadBalancer_IP>  your-service-hostname.local
       ```

    4. Save the file. Now you can access your services in the browser using `http://your-service-hostname.local`.


### 🔥 Deployment Steps

1. Clone the repository:

```bash
git clone https://github.com/ozancakar/DevOps-Lab.git
cd DevOps-Lab
```

2. Apply the core infrastructure:

```bash
kubectl apply -f infrastructure/core/
```

3. Deploy observability stack:

```bash
kubectl apply -f infrastructure/observability/
```

4. Deploy messaging systems:

```bash
kubectl apply -f infrastructure/messaging/
```

5. Deploy storage:

```bash
kubectl apply -f infrastructure/storage/
```

6. Deploy your applications:

```bash
kubectl apply -f applications/observability-demos/dotnet-otel-complete/k8s/
```

---

## 🧠 Learnings & Best Practices

- ✅ GitOps with clean directory structure
- ✅ Declarative Kubernetes YAML files
- ✅ Observability baked into the applications (tracing, metrics, logging)
- ✅ Microservices communication with Ingress Controller (Traefik)
- ✅ Secure and scalable message brokers (RabbitMQ, Redis Sentinel)
- ✅ Local or cloud-native storage with MinIO

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

---

---

> ✨ If you find this repository useful, give it a ⭐ star and share it!
