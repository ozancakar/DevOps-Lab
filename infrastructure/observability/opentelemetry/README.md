# OpenTelemetry Collector – Basic Configuration

This configuration defines a simple OpenTelemetry Collector setup for gathering and exposing metrics from both the host system and applications. It uses Prometheus format for exporting and supports OTLP (OpenTelemetry Protocol) for receiving metrics.

---

## 🧱 Deployment Details

| Parameter       | Value                                  |
|----------------|------------------------------------------|
| Mode           | `deployment`                             |
| Replicas       | `1`                                      |
| Image          | `otel/opentelemetry-collector-contrib:latest` |
| Resources      | CPU: 200m / Memory: 256Mi (limits)       |
|                | CPU: 100m / Memory: 128Mi (requests)     |

> ℹ️ It is recommended to avoid using `latest` tag in production.

---

## ⚙️ Configuration Overview

### 📥 Receivers

#### `hostmetrics`
Collects metrics from the host system including:
- CPU
- Disk
- Filesystem
- Load
- Memory
- Network

#### `prometheus`
Scrapes metrics from the Collector itself (used for self-monitoring).

- **Endpoint:** `0.0.0.0:8888`

#### `otlp`
Receives telemetry data from applications via OTLP protocol.

- **gRPC Endpoint:** `0.0.0.0:4317`
- **HTTP Endpoint:** `0.0.0.0:4318`

### ⚙️ Processors

- **`batch`:** Buffers and batches telemetry data to improve performance.

### 📤 Exporters

#### `prometheus`
Exports collected metrics in Prometheus format.

- **Metrics endpoint:** `0.0.0.0:8889`

### 🔁 Pipeline Flow

```yaml
service:
  pipelines:
    metrics:
      receivers: [otlp, hostmetrics]
      processors: [batch]
      exporters: [prometheus]
```

---

## 🔍 Adding Traces Support

To collect and export trace data, you need to:

### 1. Enable OTLP for traces in the `receivers` block:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
```

### 2. Add a trace exporter (e.g., Jaeger):

```yaml
exporters:
  jaeger:
    endpoint: http://jaeger-collector.monitoring:14268/api/traces
    tls:
      insecure: true
```

### 3. Add a traces pipeline to the `service` section:

```yaml
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [jaeger]
```

---

## ✅ Example Applications

You can configure your applications (e.g., Go, Java, Python) to send metrics and traces to the following endpoints:

- **Metrics:** `http://<collector-ip>:4318/v1/metrics`
- **Traces:** `http://<collector-ip>:4318/v1/traces`

---

## 📦 Usage

Apply the configuration with:

```bash
kubectl apply -f otelcol-config.yaml
```

---

## 📘 References

- [OpenTelemetry Collector Docs](https://opentelemetry.io/docs/collector/)
- [Prometheus Exporter](https://opentelemetry.io/docs/collector/exporter/prometheus/)
- [OTLP Protocol](https://opentelemetry.io/docs/specs/otlp/)
