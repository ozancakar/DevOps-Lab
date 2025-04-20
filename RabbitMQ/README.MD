# RabbitMQ Kubernetes Kurulum Rehberi

Bu rehber, RabbitMQ'yu bir Kubernetes ortamında kurmanıza yardımcı olacaktır. RabbitMQ'yu bir `LoadBalancer` servisi üzerinden MetalLB kullanarak dışa açacağız ve RabbitMQ yönetim arayüzüne nasıl erişebileceğinizi adım adım açıklayacağız.

## 🧱 Gereksinimler

Başlamadan önce aşağıdaki gereksinimlerin sağlandığından emin olun:

- Çalışan bir Kubernetes kümesi.
- `kubectl` yüklü ve kümenizle iletişim kuracak şekilde yapılandırılmış olmalı.
- MetalLB yüklenmiş olmalı, böylece dış IP alabiliriz.
- DNS veya `hosts` dosyanızı değiştirme yetkiniz olmalı.

## ⚙️ Adım Adım Kurulum Talimatları

### Adım 1: RabbitMQ Dağıtımını Uygula

1. İlk olarak, RabbitMQ YAML konfigürasyonunu Kubernetes kümenize uygulayın. Bu, RabbitMQ için gerekli kaynakları oluşturacaktır.

   Aşağıdaki komutu çalıştırın:

   ```bash
   kubectl apply -f rabbitmq.yaml

2. Daha sonra kubectl get svc kısmında rabbitmq-loadbalancer servisinin aldığı ip adresini öğrenelim 

![Kubectl get svc](kubectlgetsvc.png)

3. DNS serveri olmayan bir ortamda çalışmıyor isek kendi host dosyamıza bunu bu şekilde ekleyeceğiz bu dosyanın windowstaki yolu bu şekildedir ( C:\Windows\System32\drivers\etc\hosts ).
![C:\Windows\System32\drivers\etc\host file ](hostfilescreenshot.png)

4. Artık tarayıcı üzerinden labrabbitmq.mydomain.com:15672 urline gidip dashboarda erişebiliriz.
![labrabbitmq.mydomain.com ](urlscreenshot.png)
