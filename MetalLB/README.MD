# MetalLB Setup Guide

This guide explains how to set up MetalLB in your Kubernetes cluster. MetalLB is a network load balancer for Kubernetes that can provide external IPs for `LoadBalancer` services, such as **Traefik**, enabling external access to your services.

## 🧱 Requirements
- A Kubernetes cluster is already set up and running.
- `kubectl` is installed and configured to interact with your Kubernetes cluster.

## ⚙️ Setup Instructions

Follow the steps below to set up MetalLB in your Kubernetes environment.

### Step 1: Install MetalLB Components
First, we need to install the core MetalLB components by applying the official manifest. This will create the necessary resources and the `metallb-system` namespace in your cluster.

Run the following command to apply the MetalLB manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/config/crd/bases/metallb.io_ipaddresspools.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/config/crd/bases/metallb.io_l2advertisements.yaml
