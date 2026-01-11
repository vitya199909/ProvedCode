# Jenkins & Nexus Integration Setup

## Що було налаштовано

✅ **Nexus Repository Manager**
- Maven repositories: maven-releases, maven-snapshots
- Docker registry: localhost:8083
- URL: http://localhost:8082
- Credentials: admin/admin123

✅ **Jenkins Pipeline Integration**
- Maven settings.xml скопійовано в контейнер
- Автоматична публікація JAR артефактів
- Автоматична публікація Docker images
- Версіонування з pom.xml

## Використання

### Перегляд артефактів

**Nexus UI**: http://localhost:8082
- Логін: admin
- Пароль: admin123
- Browse → maven-releases → com.provedcode

### Jenkins Pipeline

Pipeline автоматично:
1. Білдить backend JAR
2. Публікує в Nexus Maven Repository
3. Білдить Docker images
4. Публікує в Nexus Docker Registry з версією з pom.xml

### Версіонування

Версія береться з `pom.xml`:
```xml
<version>0.5.0-SNAPSHOT</version>
```

Для релізу змініть на:
```xml
<version>0.5.0</version>
```

### Ручна публікація (якщо потрібно)

**Maven artifact**:
```bash
cd App_Docker_Compose/backend/provedcode-backend-vitya199909
mvn deploy -s /path/to/maven-settings.xml
```

**Docker image**:
```bash
docker login localhost:8083 -u admin -p admin123
docker tag myapp-backend:latest localhost:8083/myapp-backend:0.5.0
docker push localhost:8083/myapp-backend:0.5.0
```

## Структура Nexus Repositories

```
maven-releases/
  └── com/provedcode/demo/
      └── 0.5.0/
          ├── demo-0.5.0.jar
          ├── demo-0.5.0.pom
          └── demo-0.5.0-sources.jar

docker-hosted/
  └── myapp-backend:0.5.0
  └── myapp-frontend:0.5.0
```

## Troubleshooting

### Maven не може підключитися до Nexus
```bash
# Перевірте чи settings.xml є в Jenkins
docker exec jenkins cat /var/jenkins_home/maven-settings.xml

# Перевірте підключення
docker exec jenkins curl http://nexus:8081/service/rest/v1/status
```

### Docker push fails
```bash
# Логін в registry
docker exec jenkins sh -c 'echo "admin123" | docker login nexus:8083 -u admin --password-stdin'
```

### Nexus недоступний
```bash
docker logs nexus
docker restart nexus
```
