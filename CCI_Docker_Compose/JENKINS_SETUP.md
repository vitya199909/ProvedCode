# Jenkins Configuration для SonarQube

## 1. Встановлення плагінів Jenkins

1. Відкрийте Jenkins: http://localhost:8080
2. Manage Jenkins → Manage Plugins
3. Встановіть:
   - **SonarQube Scanner for Jenkins**
   - **Quality Gates Plugin** (якщо немає)

4. Перезапустіть Jenkins

## 2. Налаштування SonarQube Server в Jenkins

1. Manage Jenkins → Configure System
2. Прокрутіть до секції **SonarQube servers**
3. Натисніть "Add SonarQube"
4. Заповніть:
   - Name: `SonarQube`
   - Server URL: `http://10.1.11.97:9000`
   - Server authentication token: [виберіть credential - див. крок 3]

## 3. Створення SonarQube Token

### У SonarQube:
1. Відкрийте http://localhost:9000
2. Увійдіть: admin / admin (змініть пароль при першому вході)
3. User → My Account → Security → Generate Token
   - Name: `jenkins`
   - Type: `User Token`
   - Expires in: `No expiration`
   - Generate

4. **Скопіюйте token** (він показується 1 раз!)

### У Jenkins:
1. Manage Jenkins → Manage Credentials
2. (global) → Add Credentials
3. Заповніть:
   - Kind: `Secret text`
   - Scope: `Global`
   - Secret: [вставте SonarQube token]
   - ID: `sonarqube-token`
   - Description: `SonarQube authentication token`
4. Create

## 4. Створення проектів у SonarQube

### Backend:
1. У SonarQube: Projects → Create Project
2. Manually:
   - Project key: `provedcode-backend`
   - Display name: `ProvedCode Backend`
3. Create project
4. Locally (виберіть Maven)
5. Generate a token → або використайте існуючий jenkins token

### Frontend:
1. Projects → Create Project
2. Manually:
   - Project key: `provedcode-frontend`
   - Display name: `ProvedCode Frontend`
3. Create project
4. Locally (виберіть Other - JS/TS/etc)

## 5. Налаштування Quality Gate (опціонально)

По дефолту використовується "Sonar way" з умовами:
- Coverage > 80%
- 0 Bugs
- 0 Vulnerabilities
- Duplicated Lines < 3%
- Maintainability Rating = A

Якщо хочете свій:
1. Quality Gates → Create
2. Додайте умови
3. Set as Default

## 6. Перевірка налаштування

1. Запустіть Jenkins pipeline
2. Stage "Code Inspection - Backend" має викликати Maven Sonar
3. Stage "Quality Gate" має чекати результат з SonarQube
4. Якщо Quality Gate провалився → pipeline зупиниться

## 7. Тестовий запуск вручну

### Backend (локально):
```bash
cd /home/viktor/ProvedCode/App_Docker_Compose/backend/provedcode-backend-vitya199909
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=provedcode-backend \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=YOUR_TOKEN
```

### Frontend (локально):
```bash
cd /home/viktor/ProvedCode/App_Docker_Compose/frontend/provedcode-frontend-vitya199909
npm install
npm run lint
# Для SonarQube потрібен sonar-scanner CLI:
# npm install -g sonar-scanner
# npm run sonar
```

## Troubleshooting

### Jenkins не може підключитись до SonarQube:
- Перевірте що SonarQube запущено: `docker ps | grep sonarqube`
- Перевірте доступність: `curl http://10.1.11.97:9000`
- Перевірте що Jenkins credential містить правильний token

### Quality Gate timeout:
- Збільшіть timeout в Jenkinsfile (default: 5 min)
- Перевірте що webhook налаштований у SonarQube (не обов'язково для простих проектів)

### Backend Maven build fails:
- Перевірте що всі тести проходять: `mvn test`
- JaCoCo coverage plugin потребує working tests

### Frontend lint errors:
- Запустіть локально: `npm run lint`
- Виправте errors або змініть правила в .eslintrc.json
