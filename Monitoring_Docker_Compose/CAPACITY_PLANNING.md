# Capacity Planning & Scalability Guide

## Моніторинг використання ресурсів

Використовуйте дашборд **"Capacity Planning & Resource Usage"** в Grafana для аналізу:
- CPU usage тренди
- Memory usage тренди  
- Disk space
- Network traffic
- Backend request rate
- Database connections

## Коли потрібно масштабувати?

### ⚠️ Критичні показники для масштабування:

#### 🖥️ CPU
- **Warning**: CPU > 70% протягом години
- **Critical**: CPU > 80% протягом 30 хвилин
- **Дія**: Додати ще один backend інстанс або збільшити CPU

#### 🧠 Memory
- **Warning**: Memory > 80% 
- **Critical**: Memory > 85%
- **Дія**: Збільшити RAM або оптимізувати JVM heap

#### 💾 Disk
- **Warning**: Disk > 80%
- **Critical**: Disk > 90%
- **Дія**: Очистити логи, збільшити диск, або налаштувати ротацію

#### 📊 Backend Load
- **Warning**: Request rate > 100 req/s на інстанс
- **Critical**: Response time > 500ms
- **Дія**: Додати backend інстанси (scale horizontally)

#### 🗄️ Database
- **Warning**: Active connections > 8
- **Critical**: Active connections = max pool size (10)
- **Дія**: Збільшити connection pool або додати read replicas

## Як масштабувати

### Horizontal Scaling (додавання інстансів)

**Backend:**
```yaml
# docker-compose.yml
services:
  backend4:
    build: ./backend
    image: myapp-backend:latest
    restart: unless-stopped
    environment:
      # ... same as backend1
    depends_on:
      - db
    networks:
      - app-net
```

**Nginx load balancer** (вже налаштований):
```nginx
upstream backend_servers {
    least_conn;
    server backend1:8080;
    server backend2:8080;
    server backend3:8080;
    server backend4:8080;  # додати новий
}
```

### Vertical Scaling (збільшення ресурсів)

**Обмеження ресурсів Docker:**
```yaml
services:
  backend1:
    # ...
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
```

**JVM Heap для Backend:**
```yaml
environment:
  JAVA_OPTS: "-Xms1g -Xmx2g"
```

**PostgreSQL:**
```yaml
environment:
  # max_connections
  POSTGRES_MAX_CONNECTIONS: 200
```

## Стратегія масштабування

### 1. Моніторинг (✅ Вже налаштовано)
- Prometheus збирає метрики
- Grafana показує тренди
- Loki збирає логи

### 2. Аналіз трендів
- Дивіться дашборд "Capacity Planning" щодня
- Використовуйте period 7 днів для трендів
- Прогнозуйте зростання навантаження

### 3. Планування
**Якщо CPU/Memory зростає на 10% щомісяця:**
- Через 3 місяці досягнете 80%
- Плануйте масштабування за місяць до critical

### 4. Тестування навантаження
```bash
# Apache Bench для тестування
ab -n 10000 -c 100 http://localhost/api/v5/talents

# або k6
k6 run --vus 100 --duration 30s load-test.js
```

### 5. Автомасштабування (Kubernetes)
Якщо перейдете на k8s:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Чеклист перед масштабуванням

- [ ] Перевірте метрики за останній тиждень
- [ ] Переконайтеся що база даних витримає навантаження
- [ ] Переконайтеся що є вільні ресурси на сервері
- [ ] Зробіть backup перед змінами
- [ ] Протестуйте на dev/staging середовищі
- [ ] Задокументуйте зміни

## Оптимізація перед масштабуванням

Спробуйте оптимізувати перед додаванням ресурсів:

1. **Backend**: 
   - Кешування (Redis)
   - Database indexes
   - Query optimization
   - Connection pooling

2. **Frontend**:
   - CDN для статики
   - Gzip compression
   - Browser caching

3. **Database**:
   - Query optimization
   - Indexes
   - Connection pooling
   - Vacuuming (PostgreSQL)

## Корисні команди

```bash
# Перевірити використання ресурсів
docker stats

# Переглянути метрики окремого контейнера
docker stats backend1

# Логи з фільтром по часу
docker logs --since 1h backend1

# Перезапуск після змін
docker-compose up -d --scale backend=5
```

## Алерти (рекомендується налаштувати)

Створіть алерти в Grafana для:
- CPU > 80% протягом 10 хвилин
- Memory > 85%
- Disk > 90%
- Response time > 1s
- Error rate > 5%

Налаштування → Alerting → Alert rules
