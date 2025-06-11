#!/bin/bash

# =============================================================================
# N8N Docker Management Script for Linux/Mac
# =============================================================================

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для цветного вывода
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker не установлен или недоступен!"
        log_info "Установите Docker с https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose не установлен или недоступен!"
        log_info "Установите Docker Compose с https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    log_success "Docker найден. Версия: $(docker --version)"
}

# Проверка .env файла
check_env() {
    if [ ! -f ".env" ]; then
        log_warning "Файл .env не найден!"
        if [ -f "env.example" ]; then
            log_info "Копируем env.example в .env..."
            cp env.example .env
            log_warning "ВАЖНО: Отредактируйте файл .env перед запуском!"
            log_warning "Особенно важно установить N8N_ENCRYPTION_KEY"
            echo
            read -p "Нажмите Enter для продолжения..."
        else
            log_error "Файл env.example не найден!"
            exit 1
        fi
    fi
}

# Генерация ключа шифрования
generate_encryption_key() {
    if command -v openssl &> /dev/null; then
        echo $(openssl rand -base64 32)
    else
        echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    fi
}

# Запуск в простом режиме
start_simple() {
    log_info "Запускаем N8N в простом режиме (SQLite)..."
    docker-compose -f docker-compose.simple.yml up -d
    show_status
}

# Запуск в полном режиме
start_full() {
    log_info "Запускаем N8N в полном режиме (PostgreSQL + Redis)..."
    docker-compose up -d
    show_status
}

# Запуск с туннелем
start_tunnel() {
    log_info "Запускаем N8N с туннелем (только для разработки!)..."
    docker-compose -f docker-compose.simple.yml up -d
    sleep 10
    docker exec n8n_simple n8n start --tunnel
}

# Остановка
stop_all() {
    log_info "Останавливаем все контейнеры N8N..."
    docker-compose down || true
    docker-compose -f docker-compose.simple.yml down || true
    log_success "Контейнеры остановлены!"
}

# Перезапуск
restart_services() {
    log_info "Перезапускаем N8N..."
    docker-compose down || true
    docker-compose up -d
    show_status
}

# Показ логов
show_logs() {
    log_info "Показываем логи N8N (Ctrl+C для выхода)..."
    docker-compose logs -f n8n
}

# Очистка данных
cleanup() {
    echo
    log_warning "ВНИМАНИЕ! Это удалит ВСЕ данные N8N!"
    read -p "Вы уверены? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        log_info "Операция отменена"
        return
    fi
    
    log_info "Останавливаем контейнеры..."
    docker-compose down -v || true
    docker-compose -f docker-compose.simple.yml down -v || true
    
    log_info "Удаляем volumes..."
    docker volume rm n8n_data 2>/dev/null || true
    docker volume rm n8n_postgres_data 2>/dev/null || true
    docker volume rm n8n_redis_data 2>/dev/null || true
    
    log_success "Очистка завершена!"
}

# Показ статуса
show_status() {
    echo
    log_info "Ожидание запуска контейнеров..."
    sleep 15
    
    echo
    log_info "Статус контейнеров:"
    docker-compose ps
    
    echo
    echo "=========================================="
    log_success "N8N успешно запущен!"
    echo
    log_info "Веб-интерфейс: http://localhost:5678"
    echo
    log_info "Первый запуск:"
    echo "1. Откройте http://localhost:5678 в браузере"
    echo "2. Создайте учетную запись администратора"
    echo "3. Начните создавать workflow'ы!"
    echo
    log_info "Полезные команды:"
    echo "- Логи: docker-compose logs -f n8n"
    echo "- Остановка: docker-compose down"
    echo "- Обновление: docker-compose pull && docker-compose up -d"
    echo "=========================================="
}

# Обновление
update_n8n() {
    log_info "Обновляем N8N до последней версии..."
    docker-compose pull
    docker-compose up -d
    log_success "Обновление завершено!"
}

# Резервное копирование
backup_data() {
    log_info "Создаем резервную копию данных N8N..."
    
    # Создаем директорию для бэкапов
    mkdir -p ./backups
    
    # Создаем имя файла с датой
    backup_name="n8n_backup_$(date +%Y%m%d_%H%M%S)"
    
    # Экспортируем данные
    if docker-compose ps | grep -q n8n_app; then
        docker exec n8n_app n8n export:workflow --backup --output=/home/node/.n8n/backups/${backup_name}_workflows.json
        docker exec n8n_app n8n export:credentials --backup --output=/home/node/.n8n/backups/${backup_name}_credentials.json
        log_success "Резервная копия создана: ${backup_name}"
    else
        log_error "Контейнер N8N не запущен!"
    fi
}

# Главное меню
show_menu() {
    echo
    echo "=========================================="
    echo "       N8N Docker Management Script"
    echo "=========================================="
    echo
    echo "Выберите действие:"
    echo "1. Простой запуск (SQLite, рекомендуется для начала)"
    echo "2. Полный запуск (PostgreSQL + Redis + Worker)"
    echo "3. Запуск с туннелем (для разработки)"
    echo "4. Остановить все контейнеры"
    echo "5. Перезапустить"
    echo "6. Просмотр логов"
    echo "7. Обновить N8N"
    echo "8. Резервное копирование"
    echo "9. Очистка (удаление всех данных)"
    echo "10. Генерировать ключ шифрования"
    echo "0. Выход"
    echo
}

# Главная функция
main() {
    # Проверки
    check_docker
    check_env
    
    while true; do
        show_menu
        read -p "Введите номер (0-10): " choice
        
        case $choice in
            1) start_simple ;;
            2) start_full ;;
            3) start_tunnel ;;
            4) stop_all ;;
            5) restart_services ;;
            6) show_logs ;;
            7) update_n8n ;;
            8) backup_data ;;
            9) cleanup ;;
            10) 
                echo "Новый ключ шифрования: $(generate_encryption_key)"
                echo "Добавьте его в .env файл как N8N_ENCRYPTION_KEY"
                ;;
            0) 
                log_info "До свидания!"
                exit 0
                ;;
            *) 
                log_error "Неверный выбор! Пожалуйста, выберите от 0 до 10."
                ;;
        esac
        
        echo
        read -p "Нажмите Enter для продолжения..."
    done
}

# Запуск скрипта
main "$@" 