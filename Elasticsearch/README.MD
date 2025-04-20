# Elasticsearch and Kibana on Kubernetes

This repository provides Kubernetes configurations to deploy Elasticsearch and Kibana on a Kubernetes cluster.

## Overview

- **Elasticsearch**: A distributed, RESTful search and analytics engine.
- **Kibana**: A data visualization and exploration tool used for viewing data in Elasticsearch.

In this setup, Elasticsearch is configured with 3 replicas and Kibana is connected to it for visualization purposes. The credentials for Elasticsearch are set to `admin` for both the username and password.

## Prerequisites

Before you begin, ensure you have the following prerequisites:

- A Kubernetes cluster up and running.
- `kubectl` configured to interact with your Kubernetes cluster.
- Access to create Secrets, StatefulSets, Deployments, and Services in your Kubernetes cluster.

## Installation

### 1. Clone the Repository

Apply the yaml file:

```bash
git apply -f  elasticsearch-kibana.yaml

