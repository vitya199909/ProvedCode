# CCI (Continuous Code Inspection) Stack

Стек для автоматичної інспекції якості коду з SonarQube.

## Запуск

```bash
cd /home/viktor/ProvedCode/CCI_Docker_Compose
docker-compose up -d
```

## Перший запуск

1. Дочекайтесь завантаження SonarQube (2-3 хвилини):
```bash
# Перевірка статусу
curl -s http://localhost:9000/api/system/status

# Або логи
docker logs -f sonarqube
# Чекайте на: "SonarQube is operational"
```

2. Відкрийте http://localhost:9000

3. Увійдіть з дефолтними credentials:
   - Login: `admin`
   - Password: `admin`

4. Система попросить змінити пароль — встановіть новий

## Створення проекту

### Backend (Java/Spring Boot)

1. У SonarQube: Administration → Projects → Create Project
   - Project key: `provedcode-backend`
   - Display name: `ProvedCode Backend`

2. Generate Token:
   - Натисніть "Locally"
   - Generate token → скопіюйте токен
   - Виберіть "Maven"

3. Додайте в Jenkins credentials:
   - Jenkins → Credentials → Add
   - Kind: Secret text
   - Secret: ваш токен
   - ID: `sonarqube-token`

### Frontend (React)

1. У SonarQube: Administration → Projects → Create Project
   - Project key: `provedcode-frontend`
   - Display name: `ProvedCode Frontend`

2. Generate Token (аналогічно backend)

## Налаштування проектів

### Backend: Maven plugin вже налаштований у pom.xml
### Frontend: Буде додано sonar-scanner

## Quality Gates

По дефолту SonarQube використовує "Sonar way" Quality Gate:
- Coverage > 80%
- 0 Bugs (Blocker/Critical)
- 0 Vulnerabilities
- 0 Security Hotspots
- Technical Debt < 5%

Можна налаштувати свій: Quality Gates → Create

## Metrics що перевіряються

- **Bugs** — помилки в коді
- **Vulnerabilities** — дірки в безпеці
- **Security Hotspots** — потенційні проблеми безпеки
- **Code Smells** — погано написаний код
- **Coverage** — покриття тестами
- **Duplications** — дублікати коду
- **Technical Debt** — час для виправлення всіх issues

## Інтеграція з Jenkins

Stage буде додано в Jenkinsfile:
```groovy
stage('Code Inspection') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh 'mvn sonar:sonar'
        }
    }
}
```

## Зупинка

```bash
docker-compose down
# Або з видаленням даних:
docker-compose down -v
```
