# Kubernetes Deployment для ProvedCode Web Application

Ця директорія містить Kubernetes маніфести для деплою повного веб-додатку (Frontend + Backend + PostgreSQL).

## Структура

- `namespace.yaml` - створює namespace `webapp`
- `secrets.yaml` - містить credentials для БД та інші секрети
- `postgres.yaml` - PostgreSQL база даних з persistent storage
- `backend.yaml` - Spring Boot backend (3 репліки)
- `frontend.yaml` - React frontend з NGINX + Ingress

## Архітектура

```
┌─────────────────┐
│   Ingress       │ localhost:8888 → Frontend
│   (NGINX)       │
└────────┬────────┘
         │
    ┌────▼──────┐
    │ Frontend  │ (2 pods)
    │  Service  │
    └────┬──────┘
         │
    ┌────▼──────┐
    │ Backend   │ (3 pods)
    │  Service  │ :8080
    └────┬──────┘
         │
    ┌────▼──────┐
    │ PostgreSQL│ (1 pod)
    │  Service  │ :5432
    │    + PVC  │
    └───────────┘
```

## Початкове встановлення

### 1. Встановити Kubernetes (якщо ще не встановлено)

```bash
# Встановити minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Встановити kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Запустити minikube
minikube start --driver=docker
```

### 2. Активувати Ingress addon

```bash
minikube addons enable ingress
```

### 3. Збудувати Docker образи в minikube

```bash
cd /home/viktor/ProvedCode/App_Docker_Compose

# Підключитися до Docker daemon minikube
eval $(minikube docker-env)

# Збудувати образи
docker build -t myapp-backend:latest ./backend
docker build -t myapp-frontend:latest ./frontend
```

## Деплой додатку

### Застосувати всі маніфести

```bash
cd /home/viktor/ProvedCode/k8s

# 1. Створити namespace та secrets
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml

# 2. Задеплоїти PostgreSQL
kubectl apply -f postgres.yaml

# 3. Задеплоїти Backend
kubectl apply -f backend.yaml

# 4. Задеплоїти Frontend
kubectl apply -f frontend.yaml

# АБО застосувати все одразу
kubectl apply -f .
```

### Перевірити статус

```bash
# Подивитись всі ресурси
kubectl get all -n webapp

# Подивитись pods
kubectl get pods -n webapp

# Перевірити статус deployments
kubectl get deployments -n webapp

# Перевірити services
kubectl get services -n webapp

# Перевірити ingress
kubectl get ingress -n webapp
```

### Логи

```bash
# Логи backend
kubectl logs -n webapp -l app=backend -f

# Логи frontend
kubectl logs -n webapp -l app=frontend -f

# Логи PostgreSQL
kubectl logs -n webapp -l app=postgres -f
```

## Запуск та зупинка кластера

### Запустити Kubernetes кластер

```bash
# Запустити minikube
minikube start

# Перевірити статус
minikube status
kubectl get pods -n webapp

# Налаштувати port-forward для доступу через localhost
kubectl port-forward -n webapp svc/frontend 8888:80 > /dev/null 2>&1 &
```

### Доступ до додатку

**Через localhost (рекомендовано):**
```bash
http://localhost:8888
```

**Або через IP minikube (стандартний порт 80):**
```bash
# Дізнатися IP
minikube ip

# Відкрити в браузері
http://192.168.49.2
```

### Зупинити кластер

```bash
# Зупинити всі port-forward
pkill -f "port-forward"

# Зупинити minikube (зберігає дані)
minikube stop

# Видалити кластер повністю (видаляє всі дані)
minikube delete
```

### Перезапустити після зупинки

```bash
# 1. Запустити minikube
minikube start

# 2. Дочекатись готовності всіх pods (30-60 секунд)
kubectl get pods -n webapp -w

# 3. Налаштувати доступ
kubectl port-forward -n webapp svc/frontend 8888:80 > /dev/null 2>&1 &

# 4. Відкрити сайт
# http://localhost:8888
```

## Масштабування

```bash
# Збільшити кількість backend pods
kubectl scale deployment/backend -n webapp --replicas=5

# Збільшити кількість frontend pods
kubectl scale deployment/frontend -n webapp --replicas=3
```

## Оновлення додатку

```bash
# 1. Збудувати нові образи
eval $(minikube docker-env)
docker build -t myapp-backend:latest ./backend
docker build -t myapp-frontend:latest ./frontend

# 2. Перезапустити deployments
kubectl rollout restart deployment/backend -n webapp
kubectl rollout restart deployment/frontend -n webapp

# 3. Перевірити статус rollout
kubectl rollout status deployment/backend -n webapp
kubectl rollout status deployment/frontend -n webapp
```

## Видалення

```bash
# Видалити всі ресурси
kubectl delete namespace webapp

# АБО видалити окремо
kubectl delete -f .
```

## Troubleshooting

### Pods не запускаються

```bash
# Описати pod для деталей
kubectl describe pod <pod-name> -n webapp

# Перевірити events
kubectl get events -n webapp --sort-by='.lastTimestamp'
```

### База даних не доступна

```bash
# Перевірити PostgreSQL pod
kubectl logs -n webapp -l app=postgres

# Під'єднатися до PostgreSQL pod
kubectl exec -it -n webapp <postgres-pod-name> -- psql -U myuser -d mydb
```

### Образи не знайдено

```bash
# Переконатися що використовується Docker minikube
eval $(minikube docker-env)

# Перелічити образи в minikube
docker images | grep myapp
```

## Корисні команди

```bash
# Dashboard
minikube dashboard

# SSH в minikube node
minikube ssh

# Подивитись логи всіх компонентів
kubectl logs -n webapp --all-containers=true --tail=50

# Перезапустити конкретний deployment
kubectl rollout restart deployment/backend -n webapp
kubectl rollout restart deployment/frontend -n webapp

# Подивитись IP та порти
minikube service list -n webapp
```

## Швидкий старт

### Перший раз (початкова установка):
```bash
cd /home/viktor/ProvedCode/k8s
minikube start --driver=docker
minikube addons enable ingress
eval $(minikube docker-env)
cd /home/viktor/ProvedCode/App_Docker_Compose
docker build -t myapp-backend:latest ./backend
docker build -t myapp-frontend:latest ./frontend
cd /home/viktor/ProvedCode/k8s
kubectl apply -f .
kubectl port-forward -n webapp svc/frontend 8888:80 > /dev/null 2>&1 &
# Відкрити: http://localhost:8888
```

### Наступні рази (після зупинки):
```bash
minikube start
kubectl get pods -n webapp  # дочекатись статусу Running
kubectl port-forward -n webapp svc/frontend 8888:80 > /dev/null 2>&1 &
# Відкрити: http://localhost:8888
```

### Завершення роботи:
```bash
pkill -f "port-forward"
minikube stop
```

## Моніторинг ресурсів

```bash
# Використання ресурсів pods
kubectl top pods -n webapp

# Використання ресурсів nodes
kubectl top nodes
```
