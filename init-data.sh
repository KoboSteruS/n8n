#!/bin/bash

# =============================================================================
# PostgreSQL Initialization Script for N8N
# =============================================================================

set -e

# Функция логирования
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Начинаем инициализацию базы данных N8N..."

# Создание базы данных если она не существует
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Создание расширений для N8N
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
    
    -- Настройка схемы
    CREATE SCHEMA IF NOT EXISTS ${POSTGRES_SCHEMA:-public};
    
    -- Настройка прав доступа
    GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};
    GRANT ALL PRIVILEGES ON SCHEMA ${POSTGRES_SCHEMA:-public} TO ${POSTGRES_USER};
    
    -- Настройка параметров для оптимальной работы N8N
    ALTER DATABASE ${POSTGRES_DB} SET timezone TO 'UTC';
    ALTER DATABASE ${POSTGRES_DB} SET log_statement TO 'none';
    ALTER DATABASE ${POSTGRES_DB} SET log_min_duration_statement TO 1000;
EOSQL

log "Инициализация базы данных завершена успешно!"

# Создание индексов для оптимизации производительности N8N
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Эти индексы будут созданы автоматически при первом запуске N8N,
    -- но можно создать заранее для лучшей производительности
    
    -- Настройка для N8N tables (создадутся автоматически при первом запуске)
    -- Здесь можно добавить дополнительные настройки если необходимо
EOSQL

log "Настройка индексов завершена!"

# Создание резервного пользователя для мониторинга (опционально)
if [ ! -z "$POSTGRES_MONITORING_USER" ] && [ ! -z "$POSTGRES_MONITORING_PASSWORD" ]; then
    log "Создание пользователя для мониторинга..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER ${POSTGRES_MONITORING_USER} WITH PASSWORD '${POSTGRES_MONITORING_PASSWORD}';
        GRANT CONNECT ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_MONITORING_USER};
        GRANT USAGE ON SCHEMA ${POSTGRES_SCHEMA:-public} TO ${POSTGRES_MONITORING_USER};
        GRANT SELECT ON ALL TABLES IN SCHEMA ${POSTGRES_SCHEMA:-public} TO ${POSTGRES_MONITORING_USER};
        ALTER DEFAULT PRIVILEGES IN SCHEMA ${POSTGRES_SCHEMA:-public} GRANT SELECT ON TABLES TO ${POSTGRES_MONITORING_USER};
EOSQL
    log "Пользователь для мониторинга создан!"
fi

log "Инициализация базы данных N8N завершена полностью!" 