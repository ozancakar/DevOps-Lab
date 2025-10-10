---

### 1)  Tek PowerShell Oturumu İçin Venv Oluşturabilmek Ve Script Çalıştırabilmek İçin Aşağıdaki Komutu Yazabiliriz. ###

``` Bash

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

```

### 2)  Sanal Ortamı ( Venv ) Oluşturmak İçin Bu Şekilde Yapabiliriz. ###

``` Bash

python -m venv venv

```


### 3)  Ardından Venv'i Aktif Duruma Getirecek Olan Scripti Çalıştırıyoruz. ###

``` Bash

.\venv\Scripts\Activate.ps1

```

### 4)  Daha Sonra Kurmak İstediğimiz Paketleri Yükleyebiliriz


``` Bash

pip install requests

```
