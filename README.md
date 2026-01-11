# ProvedCode - DevOps Infrastructure

> Повнофункціональна DevOps інфраструктура для веб-додатку ProvedCode з CI/CD, моніторингом, інспекцією коду та управлінням артефактами.

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.0.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![React](https://img.shields.io/badge/React-18.2.0-blue.svg)](https://reactjs.org/)
[![Docker](https://img.shields.io/badge/Docker-26.1.5-2496ED.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5.svg)](https://kubernetes.io/)

---

## 📋 Зміст

- [Огляд проекту](#-огляд-проекту)
- [Архітектура](#-архітектура)
- [Компоненти інфраструктури](#-компоненти-інфраструктури)
- [Швидкий старт](#-швидкий-старт)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Моніторинг](#-моніторинг)
- [Інспекція коду](#-інспекція-коду)
- [Управління артефактами](#-управління-артефактами)
- [Розгортання](#-розгортання)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Огляд проекту

**ProvedCode** - платформа для верифікації професійних навичок розробників з можливістю створення профілів, додавання доказів компетенцій та отримання спонсорської підтримки.

### Основні можливості

- 👥 **Управління талантами** - профілі розробників з верифікацією навичок
- 💼 **Спонсорство** - підтримка талантів від компаній
- 📊 **Доказова база** - портфоліо проектів, сертифікатів, рекомендацій
- 🔐 **OAuth2 аутентифікація** - безпечний вхід через провайдерів
- 🌐 **RESTful API** - документований бекенд з Spring Boot
- ⚛️ **Сучасний UI** - React з Material-UI

---

## 🏗 Архітектура

```
┌─────────────────────────────────────────────────────────────┐
│                    КОРИСТУВАЧ / БРАУЗЕР                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
         ┌────────────▼────────────┐
         │    NGINX (Port 80)      │  ◄── Reverse Proxy
         └────────────┬────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
┌───────▼──────┐           ┌────────▼────────┐
│   Frontend   │           │    Backend      │
│  React App   │           │  Spring Boot    │
│  (Port 80)   │           │  (2 instances)  │
└──────────────┘           └────────┬────────┘
                                    │
                           ┌────────▼────────┐
                           │   PostgreSQL    │
                           │  Database (17)  │
                           └─────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    DevOps ІНФРАСТРУКТУРА                     │
├─────────────────────────────────────────────────────────────┤
│  Jenkins (8081)  │  SonarQube (9000)  │  Nexus (8082)       │
│  CI/CD Pipeline  │  Code Quality      │  Artifact Storage   │
├─────────────────────────────────────────────────────────────┤
│  Prometheus      │  Grafana (9091)    │  Loki               │
│  Metrics         │  Dashboards        │  Logs               │
└─────────────────────────────────────────────────────────────┘
```

### Технологічний стек

**Backend:**
- ☕ Java 17 + Spring Boot 3.0.4
- 🗃️ PostgreSQL 17
- 🔐 Spring Security + OAuth2
- 📧 Spring Mail
- 💾 Liquibase (міграції БД)
- 🧪 JUnit 5, Mockito

**Frontend:**
- ⚛️ React 18.2.0
- 🎨 Material-UI (MUI)
- 🔄 React Router v6
- 🌐 Axios
- 🎭 React Hook Form

**Infrastructure:**
- 🐳 Docker & Docker Compose
- ☸️ Kubernetes
- 📦 Vagrant (локальна розробка)

**DevOps Tools:**
- 🔨 Jenkins (CI/CD)
- 📊 SonarQube (код інспекція)
- 📦 Nexus Repository (артефакти)
- 📈 Prometheus + Grafana (моніторинг)
- 📝 Loki (логування)

---

## 🧩 Компоненти інфраструктури

### 1. Основний додаток (`App_Docker_Compose/`)

**Сервіси:**
- `db` - PostgreSQL 17
- `backend1`, `backend2` - Spring Boot (балансування навантаження)
- `frontend` - React App (Nginx)
- `nginx` - Reverse Proxy (порт 8080)

**Запуск:**
```bash
cd App_Docker_Compose
docker compose up -d
```

**Доступ:** http://localhost

---

### 2. Jenkins CI/CD (`Jenkins_Docker_Compose/`)

**Особливості:**
- Custom образ з Maven, Node.js, Docker CLI
- Інтеграція з GitHub через credentials
- Автоматичний checkout submodules
- Multi-stage pipeline

**Запуск:**
```bash
cd Jenkins_Docker_Compose
docker compose up -d
```

**Доступ:** http://localhost:8081

**Перший запуск:**
```bash
docker logs jenkins  # знайти initial admin password
```

---

### 3. SonarQube Code Inspection (`CCI_Docker_Compose/`)

**Компоненти:**
- SonarQube Server 9.9.8 LTS
- PostgreSQL 17 (SonarQube DB)

**Запуск:**
```bash
cd CCI_Docker_Compose
docker compose up -d
```

**Доступ:** http://localhost:9000
- Логін: `admin`
- Пароль: `admin` (змініть після першого входу)

**Projects:**
- `provedcode-backend` - Java код аналіз
- `provedcode-frontend` - JavaScript/React аналіз

---

### 4. Nexus Repository Manager (`Nexus_Docker_Compose/`)

**Репозиторії:**
- **Maven:** `maven-releases`, `maven-snapshots`
- **Docker:** `docker-hosted` (порт 8083)
- **npm:** `npm-hosted` (опціонально)

**Запуск:**
```bash
cd Nexus_Docker_Compose
docker compose up -d
./setup-nexus.sh  # автоматичне налаштування
```

**Доступ:** http://localhost:8082
- Логін: `admin`
- Пароль: `admin123`

**Docker Registry:**
```bash
docker login localhost:8083 -u admin -p admin123
docker pull localhost:8083/myapp-backend:0.5.0-SNAPSHOT
```

---

### 5. Моніторинг (`Monitoring_Docker_Compose/`)

**Stack:**
- **Prometheus** - збір метрик (порт 9090)
- **Grafana** - візуалізація (порт 9091)
- **Loki** - централізоване логування
- **Node Exporter** - системні метрики
- **Postgres Exporter** - метрики БД
- **Nginx Exporter** - метрики веб-сервера

**Запуск:**
```bash
cd Monitoring_Docker_Compose
docker compose up -d
```

**Доступ:**
- Grafana: http://localhost:9091 (admin/admin)
- Prometheus: http://localhost:9090

**Dashboards:**
- Node Exporter Full
- PostgreSQL Database
- Nginx metrics
- Custom application metrics

---

### 6. Kubernetes (`k8s/`)

**Manifests:**
- `namespace.yaml` - namespace `provedcode`
- `postgres.yaml` - PostgreSQL StatefulSet + Service
- `backend.yaml` - Backend Deployment (2 replicas)
- `frontend.yaml` - Frontend Deployment + Service
- `nginx-configmap.yaml` + `nginx-k8s.conf` - Nginx config
- `secrets.yaml` - credentials

**Розгортання:**
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/nginx-configmap.yaml
```

---

### 7. Vagrant (`Vagrant_ProvedCode/`)

Локальна віртуальна машина з розгорнутим додатком.

**Компоненти:**
- VM з Ubuntu
- PostgreSQL, Java, Node.js
- Backend + Frontend як systemd services
- Provision scripts для автоматичної установки

**Запуск:**
```bash
cd Vagrant_ProvedCode
vagrant up
```

---

## 🚀 Швидкий старт

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Git
- 8GB RAM мінімум
- 50GB вільного місця на диску

### Крок 1: Клонування

```bash
git clone https://github.com/vitya199909/ProvedCode.git
cd ProvedCode
git submodule update --init --recursive
```

### Крок 2: Запуск всієї інфраструктури

```bash
# Автоматичний запуск всіх компонентів
./all_start.sh

# Або вручну:
cd Jenkins_Docker_Compose && docker compose up -d && cd ..
cd CCI_Docker_Compose && docker compose up -d && cd ..
cd Nexus_Docker_Compose && docker compose up -d && cd ..
cd Monitoring_Docker_Compose && docker compose up -d && cd ..
cd App_Docker_Compose && docker compose up -d && cd ..
```

### Крок 3: Налаштування Jenkins

1. Відкрийте http://localhost:8081
2. Отримайте admin password:
   ```bash
   docker logs jenkins
   ```
3. Встановіть рекомендовані плагіни
4. Створіть адмін користувача

### Крок 4: Налаштування Credentials

**GitHub Credentials** (для submodules):
- Manage Jenkins → Credentials → Add
- ID: `github-credentials`
- Username: ваш GitHub username
- Password: Personal Access Token

**Deploy SSH** (для деплою на сервер):
- ID: `deploy-ssh`
- Type: SSH Username with private key
- Username: `viktor`
- Private Key: додайте ваш SSH ключ

### Крок 5: Створення Pipeline

1. Jenkins → New Item → Pipeline
2. Pipeline script from SCM
3. Git: `https://github.com/vitya199909/ProvedCode.git`
4. Script Path: `App_Docker_Compose/Jenkinsfile`
5. Build Now

---

## 🔄 CI/CD Pipeline

### Stages

```
┌──────────────────┐
│ Checkout         │  Git clone + submodules
│ Submodules       │
└────────┬─────────┘
         │
┌────────▼─────────┐
│ Code Inspection  │  SonarQube + ESLint
│ - Backend        │  Quality Gates
│ - Frontend       │
└────────┬─────────┘
         │
┌────────▼─────────┐
│ Quality Gate     │  Перевірка якості коду
└────────┬─────────┘
         │
┌────────▼─────────┐
│ Build & Publish  │  Maven deploy
│ Artifacts        │  Docker build & push
└────────┬─────────┘
         │
┌────────▼─────────┐
│ Deploy           │  SSH до prod server
└──────────────────┘
```

### Jenkinsfile Highlights

**Backend Inspection:**
```groovy
mvn clean verify sonar:sonar \
  -Dsonar.host.url=http://sonarqube:9000 \
  -Dsonar.projectKey=provedcode-backend
```

**Frontend Inspection:**
```groovy
npm run lint
npx sonar-scanner \
  -Dsonar.host.url=http://sonarqube:9000 \
  -Dsonar.projectKey=provedcode-frontend
```

**Artifact Publishing:**
```groovy
mvn deploy -DskipTests -s /var/jenkins_home/maven-settings.xml
docker build -t myapp-backend:latest .
docker tag myapp-backend:latest localhost:8083/myapp-backend:${version}
docker push localhost:8083/myapp-backend:${version}
```

---

## 📊 Моніторинг

### Prometheus Targets

- **Node Exporter:** `http://node-exporter:9100/metrics`
- **Postgres Exporter:** `http://postgres-exporter:9187/metrics`
- **Nginx Exporter:** `http://nginx-exporter:9113/metrics`
- **Backend App:** `http://backend1:8080/actuator/prometheus`

### Grafana Dashboards

**System Overview:**
- CPU, Memory, Disk usage
- Network I/O
- System load

**PostgreSQL:**
- Connections
- Transaction rate
- Database size
- Query performance

**Application:**
- HTTP requests
- Response times
- Error rates
- JVM metrics

### Alerting

Налаштуйте alerts в Prometheus:

```yaml
groups:
  - name: application
    rules:
      - alert: HighMemoryUsage
        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1
        for: 5m
        
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
```

---

## 🔍 Інспекція коду

### SonarQube Rules

**Backend (Java):**
- Code Smells
- Bugs
- Vulnerabilities
- Security Hotspots
- Code Coverage (JaCoCo)
- Duplicate Code

**Frontend (JavaScript):**
- ESLint rules
- React best practices
- Code complexity
- Maintainability

### Quality Gates

**Умови для проходження:**
- Coverage > 80%
- Duplicated Lines < 3%
- Maintainability Rating = A
- Reliability Rating = A
- Security Rating = A

### Локальна інспекція

**Backend:**
```bash
cd App_Docker_Compose/backend/provedcode-backend-vitya199909
mvn clean verify sonar:sonar
```

**Frontend:**
```bash
cd App_Docker_Compose/frontend/provedcode-frontend-vitya199909
npm run lint
npm run sonar
```

---

## 📦 Управління артефактами

### Maven Artifacts

**Версіонування:**
- Release: `0.5.0`
- Snapshot: `0.5.0-SNAPSHOT`

**Публікація:**
```bash
mvn deploy
```

**Використання:**
```xml
<dependency>
    <groupId>com.provedcode</groupId>
    <artifactId>demo</artifactId>
    <version>0.5.0</version>
</dependency>
```

### Docker Images

**Структура тегів:**
- `localhost:8083/myapp-backend:0.5.0-SNAPSHOT`
- `localhost:8083/myapp-backend:latest`
- `localhost:8083/myapp-frontend:0.5.0-SNAPSHOT`
- `localhost:8083/myapp-frontend:latest`

**Pull з Nexus:**
```bash
docker pull localhost:8083/myapp-backend:0.5.0-SNAPSHOT
docker run -p 8080:8080 localhost:8083/myapp-backend:0.5.0-SNAPSHOT
```

---

## 🌍 Розгортання

### Docker Compose (Dev/Test)

```bash
cd App_Docker_Compose
docker compose up -d
```

### Kubernetes (Production)

```bash
# Створити namespace
kubectl create namespace provedcode

# Застосувати всі маніфести
kubectl apply -f k8s/

# Перевірити статус
kubectl get pods -n provedcode
kubectl get services -n provedcode
```

### Vagrant (Local VM)

```bash
cd Vagrant_ProvedCode
vagrant up
vagrant ssh
# Додаток працює на http://192.168.56.10
```

---

## 🔧 Troubleshooting

### Jenkins не може підключитися до GitHub

```bash
# Перевірте credentials
docker exec jenkins cat ~/.git-credentials

# Додайте SSH ключ
ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub  # додайте в GitHub Deploy Keys
```

### SonarQube не стартує

```bash
# Перевірте логи
docker logs sonarqube

# Збільште heap memory
docker exec sonarqube cat /opt/sonarqube/conf/sonar.properties
# sonar.web.javaOpts=-Xmx1024m
```

### Nexus 401 Unauthorized

```bash
# Увімкніть Anonymous Access
curl -u admin:admin123 -X PUT \
  "http://localhost:8082/service/rest/v1/security/anonymous" \
  -H "Content-Type: application/json" \
  -d '{"enabled": true}'
```

### Docker build fails - "no space left"

```bash
# Очистіть Docker
docker system prune -a --volumes -f

# Розшириіть диск
sudo growpart /dev/sda 2
sudo resize2fs /dev/sda2
```

### Pipeline fails - Maven dependencies

```bash
# Перевірте Maven settings
docker exec jenkins cat /var/jenkins_home/maven-settings.xml

# Очистіть локальний репозиторій
docker exec jenkins rm -rf /root/.m2/repository
```

---

## 📝 Конфігурація

### Змінні оточення

**Backend:**
```env
SPRING_PROFILES_ACTIVE=prod
DB_LOGIN=myuser
DB_PASSWORD=mypassword
DB_URL=db:5432/mydb
S3_ACCESS_KEY=your-key
S3_SECRET_KEY=your-secret
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
```

**Frontend:**
```env
REACT_APP_BASE_URL=http://localhost
```

### Ports

| Service       | Port  | Description              |
|---------------|-------|--------------------------|
| Application   | 80    | Main app (Nginx)         |
| Jenkins       | 8081  | CI/CD                    |
| Nexus UI      | 8082  | Artifact Management      |
| Nexus Docker  | 8083  | Docker Registry          |
| Prometheus    | 9090  | Metrics                  |
| Grafana       | 9091  | Dashboards               |
| SonarQube     | 9000  | Code Quality             |
| Backend       | 8080* | Spring Boot (internal)   |
| Frontend      | 80*   | React (internal)         |
| PostgreSQL    | 5432* | Database (internal)      |

*Internal ports (доступні лише в Docker network)

---

## 🤝 Contributing

1. Fork репозиторій
2. Створіть feature branch (`git checkout -b feature/amazing-feature`)
3. Commit зміни (`git commit -m 'Add amazing feature'`)
4. Push в branch (`git push origin feature/amazing-feature`)
5. Відкрийте Pull Request

---

## 📄 License

Цей проект ліцензований під MIT License - дивіться файл [LICENSE](LICENSE) для деталей.

---

## 👥 Автори

- **Viktor Nedilskyi** - *DevOps Infrastructure* - [@vitya199909](https://github.com/vitya199909)
- **ProvedCode Team** - *Application Development*

---

## 📞 Контакти

- GitHub: [@vitya199909](https://github.com/vitya199909)
- Email: vitya199909@gmail.com

---

**Версія:** 0.5.0  
**Дата:** Січень 2026  
**Статус:** ✅ Production Ready

---

## 💻 Системні вимоги

### Рекомендована конфігурація

**Мінімальні вимоги:**
- **CPU:** 2 cores
- **RAM:** 8 GB
- **Disk:** 30 GB вільного місця
- **OS:** Linux (Ubuntu 20.04+), macOS, Windows 10+ з WSL2

**Оптимальна конфігурація (повний стек):**
- **CPU:** 4 cores
- **RAM:** 10-12 GB
- **Disk:** 50 GB вільного місця
- **OS:** Linux Ubuntu 22.04 LTS

**Software:**
- Docker 20.10+
- Docker Compose 2.0+
- Git 2.30+
- (Опціонально) kubectl для Kubernetes
- (Опціонально) Vagrant 2.2+ для VM

### Використання ресурсів по компонентам

| Компонент           | RAM    | CPU   | Disk   |
|---------------------|--------|-------|--------|
| Application Stack   | ~2 GB  | 1 core| 5 GB   |
| Jenkins             | ~2 GB  | 1 core| 10 GB  |
| SonarQube           | ~2 GB  | 1 core| 5 GB   |
| Nexus               | ~1 GB  | 0.5 core| 10 GB |
| Monitoring Stack    | ~2 GB  | 0.5 core| 5 GB   |
| **Всього**          | **~10 GB** | **4 cores** | **35+ GB** |

### Продуктивність

Тестувалося на VM з:
- **CPU:** 4 cores Intel/AMD
- **RAM:** 10 GB
- **Disk:** 50 GB SSD
- **OS:** Ubuntu 22.04 LTS

Pipeline час виконання: ~5-7 хвилин (повний цикл)