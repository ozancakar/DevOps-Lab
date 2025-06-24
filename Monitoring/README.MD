# DevOps Lab

## 1. Add and Update Helm Repositories

At the first step of the installation, we need to add and update Helm repositories:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

---

## 2. Disable Persistent Volume (PV) and Persistent Volume Claim (PVC) Usage

If your cluster does **not have local storage** or you don't want to use PV/PVC, you can disable these features in your `values.yaml` file as follows:

```yaml
alertmanager:
  persistence:
    enabled: false
  persistentVolume:
    enabled: false

server:
  persistence:
    enabled: false
  persistentVolume:
    enabled: false
```

---

## 3. Install Prometheus and Alertmanager

Use your prepared `prometheus-values.yaml` file to install or upgrade Prometheus with Helm:

```bash
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f prometheus-values.yaml
```

---

## 4. Delete Existing Persistent Volume Claims (Optional)

If there are previously created PVCs that may cause issues, you can delete all of them using:

```bash
kubectl delete pvc -n monitoring --all
```

---

## 5. Access with Your Own Certificate

To expose Prometheus and Grafana services externally with your own SSL certificate, use the following **IngressRoute** files:

- `grafana-ingressroute.yaml`
- `prometheus-ingressroute.yaml`

Update these files with your own certificate and domain information before applying them.

---

## 6. Check Pod Status

After installation, check the status of your pods:

```bash
kubectl get pods -n monitoring
```

Make sure the Alertmanager and Prometheus pods are in `Running` status.  
If pods are still `Pending`, describe the pod for troubleshooting:

```bash
kubectl describe pod <pod-name> -n monitoring
```

---

## 7. OpenTelemetry Collector Services and Prometheus Integration

To enable Prometheus to scrape metrics from OpenTelemetry Collector, you need to define specific services and update Prometheus configuration accordingly.

### 7.1. Prometheus ConfigMap Update

To enable Prometheus to scrape metrics from OpenTelemetry Collector, you only need to add the following scrape configurations inside the `scrape_configs` section of the `prometheus.yml` file within the `prometheus-server` ConfigMap.  
There is no need to modify other parts of the ConfigMap.

```yaml
- job_name: 'otel-collector'
  static_configs:
    - targets: ['otel-collector-prometheus.monitoring.svc.cluster.local:8889']

- job_name: 'otel-collector-self'
  static_configs:
    - targets: ['otel-collector-telemetry.monitoring.svc.cluster.local:8888']
```

---

### 7.2. OpenTelemetry Collector Kubernetes Services

You should have the following services defined in your repository to expose OpenTelemetry Collector endpoints:

**otel-collector-prometheus.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: otel-collector-prometheus
  namespace: monitoring
spec:
  selector:
    app.kubernetes.io/name: opentelemetry-collector
  ports:
    - protocol: TCP
      port: 4317
      targetPort: 4317
      name: otlp-grpc
    - protocol: TCP
      port: 4318
      targetPort: 4318
      name: otlp-http
    - protocol: TCP
      port: 8889
      targetPort: 8889
      name: prometheus-metrics
```

This service exposes OpenTelemetry Collector’s OTLP gRPC and HTTP ports along with the Prometheus metrics port (`8889`), which Prometheus scrapes for telemetry data.

---

**otel-own-metrics-svc.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: otel-collector-telemetry
  namespace: monitoring
spec:
  selector:
    app.kubernetes.io/name: opentelemetry-collector
  ports:
    - port: 8888
      protocol: TCP
      targetPort: 8888
  type: ClusterIP
```

This service exposes the OpenTelemetry Collector’s own telemetry metrics on port `8888`. It is accessible only within the cluster.

---

### Summary

- Define Kubernetes Services for OpenTelemetry Collector to expose telemetry and metrics endpoints.  
- Update Prometheus ConfigMap scrape_configs to include these service endpoints.  
- This enables Prometheus UI to show these targets under **Targets** and scrape metrics correctly.

---

# Summary

- Added and updated Helm repositories.  
- Disabled persistent storage usage.  
- Installed Prometheus and Alertmanager via Helm.  
- Cleaned up old PVCs.  
- Prepared IngressRoute files for external access with your own SSL certificate.  
- Checked pod statuses.  
- Added OpenTelemetry Collector services and Prometheus integration details.

---

If you have any questions, feel free to ask!
