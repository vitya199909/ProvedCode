# Terraform Infrastructure for GCP

Terraform конфігурація для розгортання CI/CD інфраструктури ProvedCode в Google Cloud Platform.

## Архітектура

**Локально (CI/CD інструменти):**
- GitLab - система контролю версій
- Jenkins - CI/CD оркестратор
- Artifactory - сховище артефактів

**В GCP (Production додаток):**

### Мережа
- **VPC** - ізольована мережа з підмережею 10.0.0.0/24
- **Firewall Rules** - правила доступу для всіх сервісів

### Додатки (GCE Instances)
- **Frontend VM** - Nginx + React додаток (порт 80)
  - Nginx як reverse proxy
  - Проксіює `/api` на backend
- **Backend VM** - Spring Boot додаток (порт 8080)

### База даних
- **Cloud SQL PostgreSQL** - керована база даних

## Передумови

1. **Google Cloud Platform Account**
   - Активний GCP проект
   - Увімкнені API:
     - Compute Engine API
     - Cloud SQL Admin API

2. **Google Cloud SDK**
   ```bash
   # Встановлення gcloud CLI
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   
   # Авторизація
   gcloud auth login
   gcloud auth application-default login
   
   # Встановлення проекту
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Terraform**
   ```bash
   # Встановлення Terraform >= 1.0
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

## Налаштування

1. **Створіть файл terraform.tfvars**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Відредагуйте terraform.tfvars**
   ```hcl
   gcp_project_id    = "your-actual-project-id"
   gcp_region        = "europe-west1"
   gcp_zone          = "europe-west1-b"
   postgres_password = "your-secure-password"
   
   # Обмежте доступ до ваших IP
   allowed_ip_ranges = ["YOUR_IP/32"]
   ```

## Використання

### 1. Ініціалізація
```bash
terraform init
```

### 2. Планування
```bash
terraform plan
```

### 3. Застосування
```bash
terraform apply
```

### 4. Отримання інформації про ресурси
```bash
# Всі outputs
terraform output

# Конкретні URLs
terraform output gitlab_url
terraform output jenkins_url

# SSH команди
terraform output ssh_commands
```

### 5. Підключення до VM
```bash
# Використайте gcloud
gcloud compute ssh provedcode-gitlab --zone=europe-west1-b

# Або з output
terraform output -json ssh_commands
```

### 6. Знищення інфраструктури
```bash
terraform destroy
```

## Структура файлів

- `provider.tf` - налаштування GCP провайдера
- `variables.tf` - оголошення змінних
- `terraform.tfvars` - значення змінних (не комітити!)
- `terraform.tfvars.example` - приклад конфігурації
- `main.tf` - основні ресурси (VPC, VM, Cloud SQL)
- `outputs.tf` - виходи (IPs, URLs, SSH команди)

## Змінні

| Змінна | Опис | За замовчуванням |
|--------|------|------------------|
| gcp_project_id | GCP Project ID | - (обов'язково) |
| gcp_region | GCP Region | europe-west1 |
| gcp_zone | GCP Zone | europe-west1-b |
| project_name | Назва проекту | provedcode |
| environment | Середовище | dev |
| machine_type | Тип VM для додатків | e2-medium |
| postgres_password | Пароль БД | - (обов'язково) |
| allowed_ip_ranges | Дозволені IP | ["0.0.0.0/0"] |

## Вартість

Приблизна вартість інфраструктури (europe-west1):

- 2x e2-medium (Backend, Frontend): ~$50/міс
- Cloud SQL db-f1-micro: ~$15/міс
- Network egress: ~$10-20/міс

**Загалом: ~$75-85/міс**

## URLs після розгортання

Після успішного `terraform apply` отримаєте:

```
gitlab_url      = "http://34.76.xxx.xxx:8080"
frontend_url    = "http://34.76.xxx.xxx"
backend_url     = "http://34.77.xxx.xxx:8080"
postgres_ip     = "34.78.xxx.xxx"

deployment_info = {
  backend_ip  = "34.77.xxx.xxx"
  frontend_ip = "34.76.xxx.xxx"
  db_host     = "34.78.xxx.xxx"
  db_name     = "provedcode"
  db_user     = "provedcode"
}
```

**Доступ:**
- Додаток: `http://<frontend_ip>`
- API: `http://<frontend_ip>/api`
- BCI/CD Pipeline

Локальні CI/CD інструменти деплоять в GCP:

1. **GitLab** - зберігає код
2. **Jenkins** - будує та деплоїть:
   - Backend JAR → Backend VM
   - Frontend build → Frontend VM (nginx)
3. **Artifactory** - зберігає артефакти

## Наступні кроки

1. Налаштування Ansible для автоматичного деплою
2. Інтеграція Jenkins з GCP
3. Налаштування Cloud DNS для доменів
4. Додавання Cloud Load Balancer
5. Налаштування SSL/TLS сертифікатів
6. Інтеграція з Cloud Monitoring та Loggction
3. **Використовуйте HTTPS** з Cloud Load Balancer
4. **Налаштуйте Cloud IAM** для обмеження доступу
5. **Увімкніть Cloud Armor** для DDoS захисту
Nginx автоматично налаштований як reverse proxy
- Backend доступний через frontend на `/api`
- Cloud SQL автоматично створює backup
- Всі VM мають зовнішні IP (ephemeral)
- CI/CD інструменти працюють локально
- Деплой виконується через SSH з Jenkins
2. Інтеграція з Cloud DNS для доменів
3. Додавання Cloud Load Balancer
4. Налаштування SSL/TLS сертифікатів
5. Інтеграція з Cloud Monitoring

## Примітки

- GitLab потребує 5-10 хвилин для повного завантаження
- Jenkins початковий пароль: `docker logs jenkins`
- Cloud SQL автоматично створює backup
- Всі VM мають зовнішні IP (ephemeral)
