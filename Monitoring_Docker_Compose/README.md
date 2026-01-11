# Monitoring Stack для ProvedCode

Стек моніторингу включає Prometheus, Grafana та PostgreSQL Exporter.

## Запуск

1. Спочатку запустіть основний застосунок:
```bash
cd ../App_Docker_Compose
docker-compose up -d
```

2. Потім запустіть моніторинг:
```bash
cd ../Monitoring_Docker_Compose
docker-compose up -d
```

## Доступ до сервісів

- **Grafana**: http://localhost:9091
  - Логін: `admin`
  - Пароль: `admin`

- **Prometheus**: http://localhost:9090

## Що моніториться

### Spring Boot Backend
- HTTP метрики (запити, відповіді, затримки)
- JVM метрики (пам'ять, garbage collection, потоки)
- Метрики застосунку (custom metrics)

### PostgreSQL
- З'єднання з БД
- Кількість запитів
- Розмір БД та таблиць
- Продуктивність запитів

### Prometheus
- Само-моніторинг Prometheus

## Налаштування дашбордів Grafana

1. Відкрийте Grafana (http://localhost:9091)
2. Імпортуйте готові дашборди:
   - **Spring Boot Dashboard**: ID `6756`
   - **PostgreSQL Dashboard**: ID `9628`
   - **Node Exporter**: ID `1860` (якщо потрібен системний моніторинг)

## Додавання моніторингу до Backend

Для того, щоб backend віддавав метрики, потрібно:

1. Додати залежності до `pom.xml`:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

2. Додати конфігурацію до `application.properties`:
```properties
management.endpoints.web.exposure.include=health,info,prometheus,metrics
management.endpoint.health.show-details=always
management.metrics.export.prometheus.enabled=true
management.metrics.distribution.percentiles-histogram.http.server.requests=true
```

3. Пересібрати Docker образ backend
