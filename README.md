# DevOps Lab

Bu repo, profesyonel Kubernetes ortamlarında kullanılan servislerin kurulumunu ve yapılandırmasını YAML dosyalarıyla belgelemek amacıyla oluşturulmuştur. İçerikte, Ingress yapılandırmalarından stateful servislerin dağıtımına kadar birçok örnek bulunmaktadır.

## 🚀 Genel Yaklaşım

Bu çalışmada aşağıdaki sırayla bir altyapı kurulumu hedeflenmiştir:

1. **Traefik**  
   Kubernetes Ingress Controller olarak kullanılır. HTTPS ve sertifika yönetimi için ACME desteği vardır.

2. **MetalLB**  
   LoadBalancer tipi servisler için Layer 2 IP dağıtımı sağlar. Traefik'e dış IP atanarak dış dünyadan erişim sağlanır.

3. **Servis Dağıtımları**  
   - RabbitMQ
   - Redis Sentinel
   - MinIO
   - Elasticsearch + Kibana

   Bu servislerin tamamı `IngressRoute` kullanılarak Traefik üzerinden HTTPS erişimli olarak yapılandırılmıştır.

## 📁 Yapılandırma Klasörleri

Her servis için ayrı bir klasör altında YAML dosyaları yer almaktadır. Her dizin, o servisin:
- Deployment (ya da StatefulSet)
- Service
- ConfigMap/Secret (varsa)
- IngressRoute (Traefik için)
şeklinde ayrılmıştır.

---

## 📌 Notlar

- Sertifikalar manuel olarak oluşturulmuş ve Traefik'e eklenmiştir.
- Persistent Volume kullanılmayan yapılar HostPath olarak yapılandırılmıştır.
- Her servis için Helm yerine manuel YAML tercih edilmiştir (declarative yapı ön planda).

## 📜 İçerik Listesi

| Servis | Açıklama |
|--------|----------|
| Traefik | Ingress Controller, TLS termination, ACME |
| MetalLB | Layer 2 LoadBalancer IP dağıtımı |
| RabbitMQ | Mesaj kuyruğu, StatefulSet olarak dağıtılmıştır |
| Redis Sentinel | High Availability Redis yapısı |
| MinIO | S3 uyumlu object storage servisi |
| Elasticsearch + Kibana | Log analizi ve görselleştirme aracı |

---

## 🧠 Hedef

Bu proje hem bireysel portföy geliştirme hem de gerçek dünya uygulamaları için örnek teşkil etmesi amacıyla hazırlanmıştır. Her servis, sade ve anlaşılır YAML dosyalarıyla kurulmuş olup, projeye katkı sağlamak isteyen herkes için geliştirilmeye açıktır.

---

## 📫 İletişim

GitHub: [ozancakar](https://github.com/ozancakar)  
Mail: ozancakar49@gmail.com  
LinkedIn: [linkedin.com/in/ozan-çakar-651490228](https://www.linkedin.com/in/ozan-%C3%A7akar-651490228/)
