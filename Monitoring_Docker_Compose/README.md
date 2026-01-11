# Monitoring Stack для ProvedCode

Стек моніторингу включає Prometheus, Grafana, PostgreSQL Exporter, Nginx Exporter та Loki для логів.

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

- **Loki**: http://localhost:3100 (API для логів)

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

### System (Node Exporter)
- CPU usage і load average
- Memory і swap
- Disk space і I/O
- Network traffic
- Температури і sensors

## Централізоване логування (Loki)

### Що збирається:
- **Backend logs** - Spring Boot application logs (всі 3 інстанси)
- **Frontend logs** - Nginx access та error logs
- **Database logs** - PostgreSQL logs
- **Docker logs** - stdout/stderr з усіх контейнерів
- **System logs** - Syslog, Auth.log, kern.log та інші системні логи з /var/log

### Використання логів у Grafana:
1. Відкрийте Grafana → Explore
2. Виберіть datasource **Loki**
3. Приклади запитів:
   ```logql
   # Всі логи backend
   {compose_service="backend1"}
   
   # Логи з помилками
   {compose_service=~"backend.*"} |= "ERROR"
   
   # Nginx access logs
   {compose_service="frontend"} |= "GET"
   
   # Логи PostgreSQL
   {compose_service="db"}
   
   # За останню годину з фільтром
   {compose_service="backend1"} |= "Exception" [1h]
   
   # Системні логи (syslog)
   {job="syslog"}
   
   # Логи аутентифікації
   {job="auth"} |= "Failed password"
   
   # Всі системні логи сервера
   {job="varlogs"}
   ```

## Налаштування дашбордів Grafana

1. Відкрийте Grafana (http://localhost:9091)
2. Імпортуйте готові дашборди:
   - **Spring Boot Dashboard**: ID `12900` (Spring Boot 2.1+ Statistics)
   - **PostgreSQL Dashboard**: ID `9628`
   - **Nginx Dashboard**: ID `12708` (NGINX Prometheus Exporter)
   - **Logs Dashboard**: вже автоматично створений як "ProvedCode Logs"
   - **Node Exporter**: ID `1860` (якщо потрібен системний моніторинг)

### Як імпортувати дашборди з Grafana.com:
1. У Grafana натисніть "+" → "Import dashboard"
2. Введіть ID дашборда (наприклад, `12900`)
3. Натисніть "Load"
4. Виберіть datasource: **Prometheus**
5. Натисніть "Import"

### Створення власних дашбордів:
1. Натисніть "+" → "Create Dashboard"
2. "Add visualization" → виберіть datasource (Prometheus або Loki)
3. Для метрик (Prometheus) - введіть запит типу `system_cpu_usage`
4. Для логів (Loki) - введіть запит типу `{compose_service="backend1"}`
5. Налаштуйте відображення і збережіть панель

