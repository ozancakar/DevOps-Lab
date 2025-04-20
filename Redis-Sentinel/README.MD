# Redis Sentinel Kubernetes Installation Guide

This guide will help you set up Redis in a Kubernetes environment using Sentinel for high availability.

## 🧱 Requirements

Before starting, make sure the following requirements are met:

- A running Kubernetes cluster.
- `kubectl` is installed and configured to communicate with your cluster.

## ⚙️ Step-by-Step Installation Instructions

### Step 1: Apply the Redis Sentinel Deployment

1. First, apply the Redis Sentinel YAML configuration to your Kubernetes cluster. This will create the necessary resources for Redis Sentinel.

   Run the following command:

   ```bash
   kubectl apply -f redis-sentinel.yaml
