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

# Summary

- Added and updated Helm repositories.  
- Disabled persistent storage usage.  
- Installed Prometheus and Alertmanager via Helm.  
- Cleaned up old PVCs.  
- Prepared IngressRoute files for external access with your own SSL certificate.  
- Checked pod statuses.

---

If you have any questions, feel free to ask!
