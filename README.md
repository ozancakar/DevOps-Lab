
# DevOps Lab

Bu repo, profesyonel Kubernetes ortamlarında yaygın olarak kullanılan servislerin kurulum ve yapılandırmalarını YAML dosyalarıyla dokümante eder. Ingress yapılandırmalarından stateful servis dağıtımlarına kadar geniş bir yelpazeyi kapsamaktadır.

## Genel Bakış

Bu projede aşağıdaki hizmetleri içeren bir altyapı oluşturulmuştur:

1. **Traefik**  
   Kubernetes Ingress Controller olarak kullanılır. HTTPS desteği ve ACME üzerinden otomatik sertifika yönetimi sağlar.

2. **MetalLB**  
   Layer 2 seviyesinde LoadBalancer tipi servisler için IP dağıtımı yaparak Traefik’in dış erişimini mümkün kılar.

3. **Servis Dağıtımları**  
   Aşağıdaki servisler Traefik üzerinden `IngressRoute` ile erişilebilir hale getirilmiştir:
   - RabbitMQ
   - Redis Sentinel
   - MinIO
   - Elasticsearch + Kibana

## Yapılandırma Klasörleri

Her servis, kendine ait klasörde aşağıdaki YAML dosyalarını barındırır:
- Deployment veya StatefulSet
- Service
- ConfigMap/Secret (gerekiyorsa)
- IngressRoute (Traefik için)

## Kalıcı Veri Yapısı

Bu projede veriler `hostPath` yöntemi kullanılarak doğrudan node üzerinde saklanmaktadır. Bu yöntem küçük ölçekli veya lokal kümelerde pratik bir çözümdür.

**Örnek `hostPath` kullanımı:**

```yaml
volumeMounts:
  - name: redis-data
    mountPath: /data
volumes:
  - name: redis-data
    hostPath:
      path: /data/redis
      type: DirectoryOrCreate
```

Buna ek olarak, PVC ve PV yapısının nasıl kullanıldığını göstermek için aşağıda örnek yapı paylaşıldı:

**`PersistentVolume` ve `PersistentVolumeClaim` örneği:**

```yaml
# persistent-volume.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/pv-example

---
# persistent-volume-claim.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: example-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

## Servis Listesi

| Servis                   | Açıklama                                       |
|--------------------------|------------------------------------------------|
| **Traefik**              | Ingress Controller, TLS sonlandırma, ACME     |
| **MetalLB**              | Layer 2 LoadBalancer IP dağıtımı              |
| **RabbitMQ**             | Mesaj kuyruğu sistemi (StatefulSet)           |
| **Redis Sentinel**       | Yüksek erişilebilirlik sağlayan Redis yapısı  |
| **MinIO**                | S3 uyumlu obje depolama çözümü                |
| **Elasticsearch + Kibana** | Log analizi ve görselleştirme araçları     |

## Amaç

Bu proje hem kişisel bir portföy hem de gerçek dünya kullanım senaryolarına uygun bir örnek olarak hazırlandı. Tüm servisler sade, anlaşılır ve doğrudan YAML dosyalarıyla yapılandırılmıştır. Helm kullanılmadan tamamen deklaratif bir yapıyla ilerlenmiştir.

## İletişim

- GitHub: [ozancakar](https://github.com/ozancakar)
- E-posta: ozancakar49@gmail.com
- LinkedIn: [ozan-çakar](https://www.linkedin.com/in/ozan-çakar-651490228)
