# GitHub Actions CI/CD

Автоматизований CI/CD pipeline використовуючи GitHub Actions для деплою ProvedCode на GCP.

## Workflows

### 1. CI/CD Pipeline (`ci-cd.yml`)

**Тригери:**
- Push до `main` або `develop`
- Pull Request до `main`
- Ручний запуск

**Jobs:**
- `build-backend` - білд Spring Boot додатку
- `build-frontend` - білд React додатку
- `deploy` - деплой на GCP (тільки для main)
- `notify` - нотифікація про статус

**Процес:**
```
Code Push → Build Backend → Build Frontend → Deploy to GCP → Verify
```

### 2. Terraform Infrastructure (`terraform.yml`)

**Ручний запуск** з вибором дії:
- `plan` - перегляд змін
- `apply` - застосування інфраструктури
- `destroy` - знищення інфраструктури

### 3. Setup Infrastructure (`setup.yml`)

**Ручний запуск** для початкового налаштування серверів:
- Додає SSH ключі до VM
- Встановлює Java, Nginx
- Налаштовує firewall

## Налаштування

### Крок 1: GCP Service Account

Створіть Service Account з правами:
- Compute Admin
- Cloud SQL Admin
- Service Account User

```bash
# Створення Service Account
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions"

# Надання прав
gcloud projects add-iam-policy-binding robotic-haven-459022-i7 \
  --member="serviceAccount:github-actions@robotic-haven-459022-i7.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding robotic-haven-459022-i7 \
  --member="serviceAccount:github-actions@robotic-haven-459022-i7.iam.gserviceaccount.com" \
  --role="roles/cloudsql.admin"

# Створення ключа
gcloud iam service-accounts keys create key.json \
  --iam-account=github-actions@robotic-haven-459022-i7.iam.gserviceaccount.com
```

### Крок 2: GitHub Secrets

Додайте в **Settings → Secrets and variables → Actions**:

#### Обов'язкові:

| Secret Name | Опис | Як отримати |
|-------------|------|-------------|
| `GCP_SA_KEY` | Service Account JSON ключ | З попереднього кроку (key.json) |
| `GCP_PROJECT_ID` | GCP Project ID | `robotic-haven-459022-i7` |
| `SSH_PRIVATE_KEY` | SSH приватний ключ | `cat ~/.ssh/id_ed25519` |
| `SSH_PUBLIC_KEY` | SSH публічний ключ | `cat ~/.ssh/id_ed25519.pub` |

#### Database:

| Secret Name | Значення |
|-------------|----------|
| `DB_HOST` | IP Cloud SQL |
| `DB_NAME` | `provedcode` |
| `DB_USER` | `provedcode` |
| `DB_PASSWORD` | Ваш пароль |

### Крок 3: Додавання Secrets

```bash
# GitHub CLI
gh secret set GCP_SA_KEY < key.json
gh secret set GCP_PROJECT_ID -b "robotic-haven-459022-i7"
gh secret set SSH_PRIVATE_KEY < ~/.ssh/id_ed25519
gh secret set SSH_PUBLIC_KEY < ~/.ssh/id_ed25519.pub
gh secret set DB_NAME -b "provedcode"
gh secret set DB_USER -b "provedcode"
gh secret set DB_PASSWORD -b "your-password"

# DB_HOST отримуємо з Terraform
cd Terraform
gh secret set DB_HOST -b "$(terraform output -raw postgres_ip)"
```

## Використання

### Перший деплой

1. **Створіть інфраструктуру:**
   - Відкрийте Actions → Terraform Infrastructure
   - Run workflow → вберіть `apply`

2. **Налаштуйте сервери:**
   - Відкрийте Actions → Setup Infrastructure
   - Run workflow

3. **Задеплойте додаток:**
   - Push код до `main` або запустіть CI/CD Pipeline вручну

### Регулярний деплой

Просто push код до `main`:
```bash
git add .
git commit -m "feat: new feature"
git push origin main
```

Pipeline автоматично:
1. ✅ Збілдить backend і frontend
2. ✅ Запустить тести
3. ✅ Задеплоїть на GCP
4. ✅ Перевірить health

## Структура Pipeline

```yaml
Build Backend (Maven) ─┐
                       ├─→ Deploy to GCP ─→ Verify ─→ Notify
Build Frontend (npm) ──┘
```

## Моніторинг

Після деплою перевірте:

```bash
# Frontend
curl http://FRONTEND_IP/health

# Backend
curl http://BACKEND_IP:8080/actuator/health
```

В GitHub Actions побачите:
- ✅ Build logs
- 📦 Artifacts (JAR, build)
- 🚀 Deployment summary
- 🔗 URLs додатку

## Troubleshooting

### Deploy failed

**Перевірте logs:**
- GitHub Actions → конкретний workflow run → Deploy job

**Типові проблеми:**

1. **SSH connection failed**
   ```bash
   # Перевірте SSH ключ
   gh secret set SSH_PRIVATE_KEY < ~/.ssh/id_ed25519
   ```

2. **GCP permissions**
   ```bash
   # Перевірте Service Account права
   gcloud projects get-iam-policy robotic-haven-459022-i7
   ```

3. **Ansible failed**
   ```bash
   # Локально перевірте
   cd Ansible
   source ./scripts/export-terraform-outputs.sh
   ansible all -m ping
   ```

### Backend не запускається

**Перевірте на сервері:**
```bash
# SSH до backend
gcloud compute ssh provedcode-backend --zone=europe-west1-b

# Статус сервісу
sudo systemctl status provedcode-backend

# Логи
sudo journalctl -u provedcode-backend -n 50
```

### Frontend показує 502

**Перевірте nginx:**
```bash
# SSH до frontend
gcloud compute ssh provedcode-frontend --zone=europe-west1-b

# Nginx статус
sudo systemctl status nginx

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

## Розширення

### Додати Staging середовище

1. Створіть `develop` branch
2. Змініть в `ci-cd.yml`:
   ```yaml
   if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
   ```

### Додати Slack нотифікації

Додайте job в `ci-cd.yml`:
```yaml
- name: Slack Notification
  uses: rtCamp/action-slack-notify@v2
  env:
    SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
```

### Rollback

```bash
# В Actions → виберіть попередній успішний workflow
# Run → Re-run jobs
```

## Best Practices

✅ **Завжди тестуйте** перед merge до main  
✅ **Використовуйте PR** для code review  
✅ **Моніторте** logs після деплою  
✅ **Робіть backup** БД перед великими змінами  
✅ **Обмежте** allowed_ip_ranges в продакшні  

## Вартість

GitHub Actions безкоштовно для публічних репозиторіїв.

Для приватних:
- 2000 хвилин/місяць безкоштовно
- ~1 деплой = 10-15 хвилин
- ~130 деплоїв/місяць безкоштовно
