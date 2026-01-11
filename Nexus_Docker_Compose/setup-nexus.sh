#!/bin/bash

# Nexus Setup Script
# Автоматичне налаштування Nexus Repository Manager

set -e

NEXUS_URL="http://localhost:8082"
NEXUS_USER="admin"
NEXUS_PASSWORD="652bb060-094c-44e5-8286-d25249772b1f"
NEW_PASSWORD="admin123"  # Змініть на свій пароль

echo "🚀 Налаштування Nexus Repository Manager..."

# Функція для очікування готовності Nexus
wait_for_nexus() {
    echo "⏳ Очікування запуску Nexus..."
    until curl -sf "$NEXUS_URL/service/rest/v1/status" > /dev/null 2>&1; do
        echo "   Nexus ще не готовий, чекаємо..."
        sleep 5
    done
    echo "✅ Nexus готовий!"
}

wait_for_nexus

# Зміна паролю адміна (якщо потрібно)
echo "🔐 Спроба зміни паролю адміна..."
curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X PUT "$NEXUS_URL/service/rest/v1/security/users/admin/change-password" \
    -H "Content-Type: text/plain" \
    -d "$NEW_PASSWORD" || echo "⚠️ Пароль вже змінено або помилка"

NEXUS_PASSWORD="$NEW_PASSWORD"

echo ""
echo "📦 Створення Maven Repositories..."

# Maven Hosted Repository
curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X POST "$NEXUS_URL/service/rest/v1/repositories/maven/hosted" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "maven-releases",
        "online": true,
        "storage": {
            "blobStoreName": "default",
            "strictContentTypeValidation": true,
            "writePolicy": "ALLOW"
        },
        "maven": {
            "versionPolicy": "RELEASE",
            "layoutPolicy": "STRICT"
        }
    }' || echo "   maven-releases вже існує"

# Maven Snapshots Repository
curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X POST "$NEXUS_URL/service/rest/v1/repositories/maven/hosted" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "maven-snapshots",
        "online": true,
        "storage": {
            "blobStoreName": "default",
            "strictContentTypeValidation": true,
            "writePolicy": "ALLOW"
        },
        "maven": {
            "versionPolicy": "SNAPSHOT",
            "layoutPolicy": "STRICT"
        }
    }' || echo "   maven-snapshots вже існує"

echo ""
echo "🐳 Створення Docker Repositories..."

# Docker Hosted Repository
curl -u "$NEXUS_USER:$NEXUS_PASSWORD" -X POST "$NEXUS_URL/service/rest/v1/repositories/docker/hosted" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "docker-hosted",
        "online": true,
        "storage": {
            "blobStoreName": "default",
            "strictContentTypeValidation": true,
            "writePolicy": "ALLOW"
        },
        "docker": {
            "v1Enabled": false,
            "forceBasicAuth": true,
            "httpPort": 8083
        }
    }' || echo "   docker-hosted вже існує"

echo ""
echo "✅ Налаштування завершено!"
echo ""
echo "📋 Інформація для доступу:"
echo "   URL: $NEXUS_URL"
echo "   Користувач: $NEXUS_USER"
echo "   Пароль: $NEW_PASSWORD"
echo ""
echo "📦 Створені репозиторії:"
echo "   - maven-releases: $NEXUS_URL/repository/maven-releases/"
echo "   - maven-snapshots: $NEXUS_URL/repository/maven-snapshots/"
echo "   - docker-hosted: localhost:8083"
echo ""
echo "🔧 Наступні кроки:"
echo "   1. Відкрийте $NEXUS_URL у браузері"
echo "   2. Увійдіть як admin/$NEW_PASSWORD"
echo "   3. Налаштуйте Maven settings.xml для Jenkins"
echo "   4. Додайте credentials в Jenkins"
