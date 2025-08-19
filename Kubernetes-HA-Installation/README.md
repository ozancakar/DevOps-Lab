**Kubernetes High Availability (HA) Cluster Setup - with 5 Servers (3 Master + 2 Worker)**

---


## 🛠 ARCHITECTURE

| Server Name | IP           | Roles                                      |
| ----------  | ------------ | ------------------------------------------- |
| master1     | 10.31.48.11  | Control Plane + etcd + HAProxy + Keepalived |
| master2     | 10.31.48.12  | Control Plane + etcd + HAProxy + Keepalived |
| master3     | 10.31.48.13  | Control Plane + etcd + HAProxy + Keepalived |
| worker1     | 10.31.48.14  | Worker Node                                 |
| worker2     | 10.31.48.15  | Worker Node                                 |
| VIP         | 10.31.48.100 | API Server Sanal IP (Keepalived + HAProxy)  |

---

## 📆 1. COMMON PREPARATION (ALL NODES)

### A. Hostname and Hosts Setting (Optional)

```bash
sudo hostnamectl set-hostname master1
```

`/etc/hosts` :

```
10.31.48.11 master1
10.31.48.12 master2
10.31.48.13 master3
10.31.48.14 worker1
10.31.48.15 worker2
10.31.48.100 vip
```

### B. Swap Off

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

```

### C. Required Packages

```bash
sudo apt update
sudo apt install -y curl vim net-tools apt-transport-https ca-certificates gnupg lsb-release software-properties-common
```

---

## 🚀 2. containerd + kubeadm + kubelet + kubectl Installation

```bash

sudo apt install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null


sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml


sudo sed -i 's|root = "/var/lib/containerd"|root = "/data/containerd"|' /etc/containerd/config.toml
sudo sed -i 's|state = "/run/containerd"|state = "/data/containerd-state"|' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd


curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## 🌐 3. Keepalived Installation (ONLY ON MASTER NODES)

```bash
sudo apt install keepalived -y
```

### master1: `/etc/keepalived/keepalived.conf`

```ini
vrrp_instance VI_1 {
    state MASTER
    interface ens192
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    virtual_ipaddress {
        10.31.48.100
    }
}
```

### master2: priority 90, state BACKUP

### master3: priority 80, state BACKUP

```bash
sudo systemctl enable keepalived --now
```

---

## 🚎 4. HAProxy Installation (ONLY ON MASTER NODES)

```bash
sudo apt install haproxy -y
```

### `/etc/haproxy/haproxy.cfg`

```ini
global
    log /dev/log local0
    daemon
    maxconn 2048

defaults
    log     global
    mode    tcp
    option  tcplog
    timeout connect 10s
    timeout client 1m
    timeout server 1m

frontend kubernetes
    bind *:6443
    default_backend kube-masters

backend kube-masters
    balance roundrobin
    option tcp-check
    server master1 10.31.48.11:6443 check
    server master2 10.31.48.12:6443 check
    server master3 10.31.48.13:6443 check
```

```bash
sudo systemctl enable haproxy --now
```

---

## 🚀 5. Cluster Init (ONLY on master1)

```bash
kubeadm init \
  --control-plane-endpoint "10.31.48.100:6443" \
  --upload-certs \
  --pod-network-cidr=10.244.0.0/16
```

### Move config to user

```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 👥 6. Join Other Master Nodes (master2 & master3)

```bash
kubeadm join 10.31.48.100:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH> \
  --control-plane --certificate-key <CERT_KEY>
```

---

## 👷 7. Join Worker Nodes (worker1 & worker2)

```bash
kubeadm join 10.31.48.100:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH>
```

---

## 🧬 8. CNI Installation (Cilium)

```bash

helm repo add cilium https://helm.cilium.io/
helm repo update


kubectl create namespace kube-system
helm install cilium cilium/cilium --version 1.14.4 \
  --namespace kube-system \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=10.31.48.100 \
  --set k8sServicePort=6443
```

---

## ✅ 9. Kontroller

```bash
kubectl get nodes
kubectl get pods -A
ip a | grep 10.31.48.100 
```

---

## 🔎 Notes

* VIP is only active on one node (with Keepalived)
* HAProxy redirects incoming requests to 3 masters
* VIP is always used during kubeadm init and join
* `ens192` was selected as the interface, because the server IP is taken from there
* All master nodes have Keepalived + HAProxy + kubelet + kubeadm + containerd installed
* Worker nodes only run containerd and kubelet components
* Cilium was selected as the CNI and installed with Helm
