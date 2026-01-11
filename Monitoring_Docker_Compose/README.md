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

### Nginx Frontend
- HTTP запити (кількість, статус коди)
- Active connections
- Requests per second
- Upstream backends статус

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
   - **Spring Boot Dashboard**: ID `12900` (Spring Boot 2.1+ Statistics)
   - **PostgreSQL Dashboard**: ID `9628`
   - **Nginx Dashboard**: ID `12708` (NGINX Prometheus Exporter)
   - **Node Exporter**: ID `1860` (якщо потрібен системний моніторинг)

