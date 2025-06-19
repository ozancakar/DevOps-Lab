# SonarQube Kubernetes Deployment

Deploy SonarQube with PostgreSQL on Kubernetes cluster.

## Requirements

- Kubernetes cluster (v1.20+)
- kubectl CLI
- Traefik Ingress Controller
- 4GB RAM, 2 CPU cores minimum

## Quick Start

### 1. Create namespace and directories
```bash
kubectl create namespace sonarqube

# On Kubernetes nodes
sudo mkdir -p /data/{sonarpostgres,sonarqube/{data,logs,extensions/plugins}}
sudo chown -R 1000:1000 /data/sonarqube/
```

### 2. Deploy
```bash
kubectl apply -f sonarqube-deployment.yaml
```

### 3. Access
```bash
kubectl port-forward svc/sonarqube-service 9000:9000 -n sonarqube
# Open http://localhost:9000
# Login: admin/admin
```

## Configuration

### Default Settings
- **PostgreSQL**: postgres:15, user/db: sonarqube, password: sonarqube
- **SonarQube**: 9.9.8-community, port 9000
- **Storage**: hostPath volumes under `/data/`

### SSL/TLS Setup
```bash
# Create TLS secret
kubectl create secret tls yourdomain-tls --cert=cert.crt --key=private.key -n sonarqube

# Update domain in YAML
- match: Host(`sonarqube.yourdomain.com`)
```

## Branch Plugin (Optional)

For branch analysis in Community Edition:

```bash
# Download plugin
cd /data/sonarqube/extensions/plugins
sudo wget https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/1.14.0/sonarqube-community-branch-plugin-1.14.0.jar
sudo chown 1000:1000 *.jar

# Uncomment environment variables in YAML:
- name: SONAR_WEB_JAVAADDITIONALOPTS
  value: "-javaagent:/opt/sonarqube/extensions/plugins/sonarqube-community-branch-plugin-1.14.0.jar=web"
- name: SONAR_CE_JAVAADDITIONALOPTS
  value: "-javaagent:/opt/sonarqube/extensions/plugins/sonarqube-community-branch-plugin-1.14.0.jar=ce"

# Restart deployment
kubectl rollout restart deployment/sonarqube -n sonarqube
```

## Troubleshooting

### Common Issues
```bash
# Check logs
kubectl logs deployment/sonarqube -n sonarqube

# Fix permissions
sudo chown -R 1000:1000 /data/sonarqube/

# Fix system limits
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
```

### Database Issues
```bash
# Test connection
kubectl exec -it deployment/postgres -n sonarqube -- psql -U sonarqube -d sonarqube
```

## Security

⚠️ **Change default password after first login!**

For production:
- Use strong PostgreSQL password
- Configure network policies
- Enable RBAC

## Support

- [SonarQube Docs](https://docs.sonarqube.org/)
- [Branch Plugin](https://github.com/mc1arke/sonarqube-community-branch-plugin)

---
**Note**: Uses hostPath storage. Consider PVC for production.