# Ansible Configuration

Ansible playbooks для автоматизації деплою ProvedCode додатку в GCP.

## Структура

```
Ansible/
├── ansible.cfg                 # Ansible конфігурація
├── inventory/
│   └── gcp.yml                # Інвентар GCP hosts
├── group_vars/
│   └── all.yml                # Глобальні змінні
├── playbooks/
│   ├── setup-all.yml          # Початкове налаштування серверів
│   ├── deploy-backend.yml     # Деплой backend
│   ├── deploy-frontend.yml    # Деплой frontend
│   └── deploy-all.yml         # Деплой всього
├── roles/
│   ├── common/                # Спільні налаштування
│   ├── java/                  # Java встановлення
│   ├── nginx/                 # Nginx конфігурація
│   ├── backend-setup/         # Backend setup
│   └── frontend-setup/        # Frontend setup
├── templates/
│   ├── application.properties.j2
│   ├── backend.service.j2
│   └── nginx-site.conf.j2
└── scripts/
    └── export-terraform-outputs.sh
```

## Передумови

1. **Ansible встановлений**
   ```bash
   sudo apt update
   sudo apt install ansible
   ```

2. **SSH доступ до GCP VMs**
   ```bash
   # Згенеруйте SSH ключ якщо потрібно
   ssh-keygen -t rsa -b 4096
   
   # Додайте до GCP
   gcloud compute config-ssh
   ```

3. **Terraform infrastructure deployed**
   ```bash
   cd ../Terraform
   terraform apply
   ```

## Налаштування

### 1. Експорт Terraform outputs

```bash
cd Ansible
source ./scripts/export-terraform-outputs.sh
```

Це встановить змінні:
- `BACKEND_IP` - зовнішній IP backend
- `FRONTEND_IP` - зовнішній IP frontend
- `BACKEND_INTERNAL_IP` - внутрішній IP backend
- `DB_HOST` - Cloud SQL IP
- `DB_NAME`, `DB_USER`, `DB_PASSWORD`

### 2. Перевірка інвентаря

```bash
ansible-inventory --list -y
```

### 3. Перевірка connectivity

```bash
ansible all -m ping
```

## Використання

### Початкове налаштування серверів

Виконується один раз після створення інфраструктури:

```bash
ansible-playbook playbooks/setup-all.yml
```

Встановить:
- Спільні пакети (curl, wget, git, etc.)
- Java 17 (на backend)
- Nginx (на frontend)
- Налаштує firewall

### Деплой Backend

```bash
# З Artifactory
export ARTIFACTORY_URL="http://localhost:8082"
export BACKEND_VERSION="1.0.0"
ansible-playbook playbooks/deploy-backend.yml

# Або з локального артефакту
export ARTIFACT_PATH="/path/to/backend.jar"
ansible-playbook playbooks/deploy-backend.yml
```

### Деплой Frontend

```bash
# З Artifactory
export FRONTEND_VERSION="1.0.0"
ansible-playbook playbooks/deploy-frontend.yml

# Або з локального артефакту
export ARTIFACT_PATH="/path/to/frontend.tar.gz"
ansible-playbook playbooks/deploy-frontend.yml
```

### Деплой всього

```bash
export BACKEND_VERSION="1.0.0"
export FRONTEND_VERSION="1.0.0"
ansible-playbook playbooks/deploy-all.yml
```

## Інтеграція з Jenkins

### Jenkinsfile приклад

```groovy
pipeline {
    agent any
    
    environment {
        BACKEND_VERSION = "${env.BUILD_NUMBER}"
        FRONTEND_VERSION = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Build Backend') {
            steps {
                sh 'cd App_Docker_Compose/backend && mvn clean package'
            }
        }
        
        stage('Build Frontend') {
            steps {
                sh 'cd App_Docker_Compose/frontend && npm install && npm run build'
            }
        }
        
        stage('Deploy to GCP') {
            steps {
                script {
                    // Export Terraform outputs
                    sh 'cd Ansible && source ./scripts/export-terraform-outputs.sh'
                    
                    // Deploy
                    sh '''
                        cd Ansible
                        export ARTIFACT_PATH="../App_Docker_Compose/backend/target/backend.jar"
                        ansible-playbook playbooks/deploy-backend.yml
                        
                        export ARTIFACT_PATH="../App_Docker_Compose/frontend/build.tar.gz"
                        ansible-playbook playbooks/deploy-frontend.yml
                    '''
                }
            }
        }
    }
}
```

## Змінні середовища

### Обов'язкові

- `BACKEND_IP` - Backend VM IP
- `FRONTEND_IP` - Frontend VM IP
- `BACKEND_INTERNAL_IP` - Backend internal IP
- `DB_HOST` - PostgreSQL host
- `DB_PASSWORD` - PostgreSQL password

### Опціональні

- `BACKEND_VERSION` - версія backend (default: latest)
- `FRONTEND_VERSION` - версія frontend (default: latest)
- `ARTIFACTORY_URL` - Artifactory URL
- `ARTIFACT_PATH` - шлях до локального артефакту
- `LOG_LEVEL` - рівень логування (default: INFO)

## Ролі

### common
Встановлює базові пакети та налаштовує систему.

### java
Встановлює OpenJDK 17 для backend.

### nginx
Встановлює та налаштовує Nginx як reverse proxy.

### backend-setup
Створює директорії та налаштовує firewall для backend.

### frontend-setup
Створює директорії для frontend та встановлює Node.js.

## Troubleshooting

### Перевірка статусу сервісів

```bash
# Backend
ansible backend -a "systemctl status provedcode-backend"

# Frontend (Nginx)
ansible frontend -a "systemctl status nginx"
```

### Перегляд логів

```bash
# Backend logs
ansible backend -a "tail -n 50 /opt/provedcode/backend/application.log"

# Nginx logs
ansible frontend -a "tail -n 50 /var/log/nginx/error.log"
```

### Рестарт сервісів

```bash
# Backend
ansible backend -b -a "systemctl restart provedcode-backend"

# Frontend
ansible frontend -b -a "systemctl restart nginx"
```

### SSH підключення

```bash
# Використовуйте gcloud
gcloud compute ssh provedcode-backend --zone=europe-west1-b
gcloud compute ssh provedcode-frontend --zone=europe-west1-b
```

## Best Practices

1. **Використовуйте версіонування** для артефактів
2. **Зберігайте секрети** в Ansible Vault або Jenkins Credentials
3. **Тестуйте деплой** на dev середовищі перед prod
4. **Робіть backup** бази перед деплоєм
5. **Моніторте** додаток після деплою

## Наступні кроки

1. Налаштування Ansible Vault для секретів
2. Інтеграція з Jenkins Pipeline
3. Додавання rollback механізму
4. Налаштування health checks
5. Інтеграція з моніторингом (Prometheus/Grafana)
