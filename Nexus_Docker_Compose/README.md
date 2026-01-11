# Nexus Repository Manager

Artifact Management система для зберігання Maven artifacts, Docker images та npm packages.

## Запуск

```bash
docker compose up -d
```

## Доступ

- **URL**: http://localhost:8082
- **Перший логін**: `admin`
- **Пароль**: Знаходиться в контейнері

```bash
docker exec nexus cat /nexus-data/admin.password
```

## Налаштування після першого запуску

### 1. Зміна паролю
- Увійдіть як `admin` з паролем з файлу
- Встановіть новий пароль
- Увімкніть/вимкніть Anonymous Access (рекомендую вимкнути)

### 2. Створення Maven Repositories

**Maven Hosted Repository** (для ваших артефактів):
- Назва: `maven-releases`
- Version policy: Release
- Deployment policy: Allow redeploy

**Maven Proxy Repository** (кеш Maven Central):
- Назва: `maven-central-proxy`
- Remote storage: https://repo1.maven.org/maven2/

**Maven Group Repository** (об'єднує всі):
- Назва: `maven-public`
- Members: maven-releases, maven-central-proxy

### 3. Створення Docker Repositories

**Docker Hosted Registry**:
- Name: `docker-hosted`
- HTTP port: `8083`
- Allow anonymous docker pull: ✓ (опціонально)

**Docker Proxy Registry** (кеш Docker Hub):
- Name: `docker-proxy`
- HTTP port: `8084`
- Remote storage: https://registry-1.docker.io
- Docker Index: Use Docker Hub

**Docker Group Registry**:
- Name: `docker-group`
- HTTP port: `8085` (додайте в docker-compose.yml якщо потрібно)
- Members: docker-hosted, docker-proxy

### 4. Створення npm Repository (якщо потрібно)

**npm Hosted**:
- Name: `npm-hosted`

**npm Proxy**:
- Name: `npm-proxy`
- Remote storage: https://registry.npmjs.org

**npm Group**:
- Name: `npm-public`
- Members: npm-hosted, npm-proxy

## Інтеграція з Jenkins

### Maven Credentials
1. Nexus → Security → Users → Create
   - ID: `jenkins-deploy`
   - Password: (generate strong password)
   - Roles: `nx-admin` або створіть custom role

2. Jenkins → Manage Jenkins → Credentials → Add
   - Kind: Username with password
   - ID: `nexus-credentials`
   - Username: `jenkins-deploy`
   - Password: (from Nexus)

### Docker Registry Credentials
1. Використовуйте того ж користувача або створіть окремого
2. Jenkins → Credentials → Add
   - ID: `nexus-docker-registry`

## Maven Settings

Додайте в `pom.xml`:

```xml
<distributionManagement>
    <repository>
        <id>nexus-releases</id>
        <url>http://nexus:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>nexus-snapshots</id>
        <url>http://nexus:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```

Створіть `~/.m2/settings.xml` в Jenkins контейнері:

```xml
<settings>
  <servers>
    <server>
      <id>nexus-releases</id>
      <username>jenkins-deploy</username>
      <password>YOUR_PASSWORD</password>
    </server>
    <server>
      <id>nexus-snapshots</id>
      <username>jenkins-deploy</username>
      <password>YOUR_PASSWORD</password>
    </server>
  </servers>
  <mirrors>
    <mirror>
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://nexus:8081/repository/maven-public/</url>
    </mirror>
  </mirrors>
</settings>
```

## Docker Registry Usage

### Login
```bash
docker login localhost:8083 -u admin -p YOUR_PASSWORD
```

### Tag & Push
```bash
docker tag myapp-backend:latest localhost:8083/myapp-backend:1.0.0
docker push localhost:8083/myapp-backend:1.0.0
```

### Pull
```bash
docker pull localhost:8083/myapp-backend:1.0.0
```

## Nexus API

### Health Check
```bash
curl http://localhost:8082/service/rest/v1/status
```

### List Repositories
```bash
curl -u admin:password http://localhost:8082/service/rest/v1/repositories
```

## Troubleshooting

### Nexus не стартує
```bash
docker logs nexus
docker exec nexus cat /nexus-data/log/nexus.log
```

### Забув пароль адміна
```bash
docker exec nexus cat /nexus-data/admin.password
```

### Очистити всі дані
```bash
docker compose down -v
docker volume rm nexus_nexus-data
```

## Performance Tips

1. **Збільшити heap memory** (якщо потрібно):
   ```yaml
   environment:
     - INSTALL4J_ADD_VM_PARAMS=-Xms1g -Xmx2g -XX:MaxDirectMemorySize=2g
   ```

2. **Blob Store Cleanup**:
   - Nexus → System → Tasks → Create
   - Admin - Compact blob store
   - Schedule: Daily

3. **Docker Cleanup**:
   - Створіть Cleanup Policy для старих Docker images
   - Nexus → Repository → Cleanup Policies
