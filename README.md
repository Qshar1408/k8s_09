# Домашнее задание к занятию «Установка Kubernetes»

### Грибанов Антон. FOPS-31

### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развёрнутые ВМ с ОС Ubuntu 20.04-lts.


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция по установке kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
2. [Документация kubespray](https://kubespray.io/).

-----

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

### Решение:

#### 1. Развернул 5 машин в яндекс-облаке

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_001.png)

Cкрипты terraform [Cкрипты terraform](https://github.com/Qshar1408/k8s_09/blob/main/src)

#### 2. На каждой ноде выполнил следующие действия:

Выполните следующие команды на каждой машине (можно автоматизировать через ssh или ansible):

2.1. Обновление и установка нужных пакетов:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl apt-transport-https ca-certificates software-properties-common
```

2.2. Отключил swap :

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_002.png)

2.3. Установка containerd:

     - Установка зависимостей:
  
```bash
sudo apt install -y containerd
```

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_003.png)

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_004.png)

     - Создание конфигурации для containerd:
     
```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_005.png)

     - Перезапуск containerd:

```bash
sudo systemctl restart containerd
sudo systemctl enable containerd
```

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_006.png)

---

#### 3. Установка Kubernetes на всех нодах
bash

3.1. Устанавливаю необходимые зависимости

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg
```

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_007.png)

3.2. Добавляю GPG ключ
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

3.3. Добавляю репозиторий

```bash
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

3.4. Обновляю список пакетов

```bash
sudo apt update
```

3.5. Устанавливаю последние версии

```bash
sudo apt install -y kubelet kubeadm kubectl
```

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_008.png)

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_010.png)

3.6. Фиксирую версии (чтобы не обновлялись автоматически)

```bash
sudo apt-mark hold kubelet kubeadm kubectl
```

#### 4. Инициализация master ноды (node-1)

4.1. Инициализирую кластер с указанием containerd и типом мастер-ноды:

```bash
sudo kubeadm init --cri-socket /run/containerd/containerd.sock --control-plane-endpoint=10.0.1.15:6443 --upload-certs
```
![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_011.png)

Ключевые параметры:
- --cri-socket /run/containerd/containerd.sock указывает использовать containerd
- --control-plane-endpoint указывает IP мастер-ноды
- --upload-certs для HA ключей

4.2. По окончании init видим вывод с инструкциями, включая команду join для воркеров, сохраните ее. Пример:

```
kubeadm join [IP]:6443 --token XXXXX --discovery-token-ca-cert-hash sha256:XXXXX
```

cat > ~/.kube/config << 'EOF'
apiVersion: v1
clusters:
- cluster:
    server: https://10.0.1.15:6443
    insecure-skip-tls-verify: true
  name: test-cluster
contexts:
- context:
    cluster: test-cluster
    user: ""
  name: test-context
current-context: test-context
kind: Config
preferences: {}
users: []
EOF

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_012.png)

4.3. Настройка kubectl для пользователя qshar:
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

4.4. Настраиваем CNI (Calico)

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

4.5. Убеждаемся, что master нода в состоянии Ready:

```bash
kubectl get nodes
```

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_013.png)


4.6. Далее, переходим на каждую из нод, и присоединяем их к мастер-ноде

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_014.png)

4.7.Проверяем на мастер-ноде доступность:

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_015.png)

4.8. Иногда может потребоваться "одобрение":

     4.8.1. Проверяем CSR запросы

```bash     
kubectl get csr
```

     4.8.2. Одобряем все pending CSR

```bash
kubectl get csr -o name | xargs kubectl certificate approve
```

4.9. Проверяем на мастер-ноде доступность:

![k8s_09](https://github.com/Qshar1408/k8s_09/blob/main/img/k8s_09_016.png)



## Дополнительные задания (со звёздочкой)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.** Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой необязательные к выполнению и не повлияют на получение зачёта по этому домашнему заданию. 

------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA.
2. Использовать нечётное количество Master-node.
3. Для cluster ip использовать keepalived или другой способ.

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl get nodes`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
