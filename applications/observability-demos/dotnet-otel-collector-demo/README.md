# .NET OpenTelemetry Collector Demo

A .NET Web API demonstrating observability with OpenTelemetry Collector for distributed tracing, metrics, and logging.

## Architecture

```
.NET Web API → OpenTelemetry Collector → Jaeger/Prometheus
```

## Features

- **Distributed Tracing**: HTTP requests, database queries, custom spans
- **Metrics**: Business metrics, runtime stats, HTTP metrics
- **Structured Logging**: Correlated logs with trace IDs
- **Kubernetes Ready**: Deployment and service configurations included

## Quick Start

### Prerequisites
- .NET 8.0 SDK
- Kubernetes cluster
- kubectl configured

### Deploy to Kubernetes

```bash
# Clone repository
git clone https://github.com/ozancakar/DevOps-Lab.git
cd DevOps-Lab/applications/observability-demos/dotnet-otel-collector-demo

# Deploy all components
kubectl apply -f donet-otel-collector-demo-k8s.yaml

# Check deployment status
kubectl get pods
kubectl get services
```

### Run Locally

```bash
cd src/WebApi
dotnet restore
dotnet run
```

## Project Structure

```
├── src/WebApi/                            # .NET Web API application
└── Dockerfile                             # Container image
└── donet-otel-collector-demo-k8s.yaml     # Kubernetes deployment and service yaml
```

## API Endpoints

- `GET /api/products` - Products list
- `GET /api/products/{id}` - Single product
- `POST /api/orders` - Create order  
- `GET /api/health` - Health check

## Observability Dashboards

Access via port-forward or ingress:
- **Jaeger**: http://localhost:16686 (Tracing)
- **Prometheus**: http://localhost:9090 (Metrics)

```bash
# Port forward examples
kubectl port-forward svc/jaeger 16686:16686
kubectl port-forward svc/prometheus 9090:9090
```

## Configuration

### OpenTelemetry Setup (Program.cs)
```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(b => b.AddAspNetCore().AddHttpClient().AddOtlpExporter())
    .WithMetrics(b => b.AddAspNetCore().AddRuntimeInstrumentation().AddOtlpExporter());
```

### Environment Variables
- `OTEL_EXPORTER_OTLP_ENDPOINT`: Collector endpoint
- `OTEL_SERVICE_NAME`: Service name
- `OTEL_RESOURCE_ATTRIBUTES`: Resource attributes

## Key Metrics

```promql
# Request rate
rate(http_requests_total[5m])

# Error rate  
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

## Troubleshooting

```bash
# Check logs
kubectl logs -l app=otel-collector

# Test connectivity
kubectl port-forward svc/webapp 8080:80
curl http://localhost:8080/api/health
```

## Resources

- [OpenTelemetry .NET Docs](https://opentelemetry.io/docs/instrumentation/net/)
- [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)

---

**License**: MIT | **Issues**: [GitHub Issues](https://github.com/ozancakar/DevOps-Lab/issues)
