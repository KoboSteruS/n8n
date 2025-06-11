# 🚀 N8N Docker Deployment

Профессиональное развертывание N8N с использованием Docker для автоматизации бизнес-процессов.

## 📋 Содержание

- [Введение](#введение)
- [Требования](#требования)
- [Быстрый старт](#быстрый-старт)
- [Конфигурации](#конфигурации)
- [Управление](#управление)
- [Безопасность](#безопасность)
- [Резервное копирование](#резервное-копирование)
- [Мониторинг](#мониторинг)
- [Устранение неисправностей](#устранение-неисправностей)

## 🎯 Введение

N8N - это мощный инструмент автоматизации workflow'ов с открытым исходным кодом. Данный проект предоставляет готовую к production среду развертывания N8N с использованием Docker.

### ✨ Особенности

- **Два режима развертывания**: простой (SQLite) и продвинутый (PostgreSQL + Redis)
- **Масштабируемость**: поддержка worker'ов для обработки задач
- **Безопасность**: настроенная авторизация и шифрование
- **Мониторинг**: интегрированные health checks
- **Резервное копирование**: автоматизированные бэкапы
- **Proxy**: опциональный Nginx для production

## 🔧 Требования

### Системные требования

- **ОС**: Windows 10/11, macOS 10.14+, Ubuntu 18.04+
- **RAM**: Минимум 2GB, рекомендуется 4GB+
- **Диск**: 10GB свободного места
- **Docker**: Docker Desktop 4.0+ или Docker Engine 20.10+
- **Docker Compose**: v2.0+

### Проверка требований

```bash
# Проверка Docker
docker --version

# Проверка Docker Compose
docker-compose --version

# Проверка свободного места
df -h
```

## 🚀 Быстрый старт

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd n8n-docker-deployment
```

### 2. Настройка окружения

```bash
# Копируем пример конфигурации
cp env.example .env

# Генерируем ключ шифрования (Linux/Mac)
openssl rand -base64 32

# Или для Windows
# Используйте онлайн генератор или PowerShell:
# [System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
```

### 3. Редактирование конфигурации

Отредактируйте файл `.env`:

```bash
# Обязательно измените эти значения!
N8N_ENCRYPTION_KEY=your-very-secure-encryption-key-here
POSTGRES_PASSWORD=your-secure-postgres-password
REDIS_PASSWORD=your-secure-redis-password
```

### 4. Запуск

#### Windows:
```cmd
# Запуск управляющего скрипта
scripts\start.bat
```

#### Linux/Mac:
```bash
# Делаем скрипт исполняемым
chmod +x scripts/start.sh

# Запуск
./scripts/start.sh
```

### 5. Первая настройка

1. Откройте http://localhost:5678 в браузере
2. Создайте учетную запись администратора
3. Начните создавать ваши первые workflow'ы!

## ⚙️ Конфигурации

### Простая конфигурация (SQLite)

Идеально для:
- Разработки и тестирования
- Небольших проектов
- Быстрого старта

```bash
# Запуск простой конфигурации
docker-compose -f docker-compose.simple.yml up -d
```

### Продвинутая конфигурация (PostgreSQL + Redis)

Рекомендуется для:
- Production окружения
- Высоких нагрузок
- Масштабирования

```bash
# Запуск полной конфигурации
docker-compose up -d
```

### Компоненты продвинутой конфигурации

- **PostgreSQL**: Основная база данных
- **Redis**: Кэширование и очереди
- **N8N App**: Основное приложение
- **N8N Worker**: Обработчик задач в фоне
- **Nginx**: Reverse proxy (опционально)

## 🎮 Управление

### Основные команды

```bash
# Запуск
docker-compose up -d

# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Просмотр логов
docker-compose logs -f n8n

# Обновление
docker-compose pull && docker-compose up -d

# Статус контейнеров
docker-compose ps
```

### Масштабирование Worker'ов

```bash
# Увеличение количества worker'ов
docker-compose up -d --scale n8n-worker=3
```

### Доступ к контейнерам

```bash
# Доступ к N8N CLI
docker exec -it n8n_app bash

# Доступ к PostgreSQL
docker exec -it n8n_postgres psql -U n8n -d n8n

# Доступ к Redis
docker exec -it n8n_redis redis-cli
```

## 🔒 Безопасность

### Ключ шифрования

⚠️ **КРИТИЧЕСКИ ВАЖНО**: Никогда не теряйте ключ шифрования `N8N_ENCRYPTION_KEY`!

```bash
# Генерация нового ключа
openssl rand -base64 32

# Сохранение в безопасном месте
echo "N8N_ENCRYPTION_KEY=your-key-here" >> .env.backup
```

### Настройки паролей

Обязательно измените дефолтные пароли:

```env
POSTGRES_PASSWORD=very-secure-password-123!
REDIS_PASSWORD=another-secure-password-456!
```

### Production настройки

Для production окружения:

```env
# Включите HTTPS
N8N_PROTOCOL=https
N8N_HOST=yourdomain.com
WEBHOOK_URL=https://yourdomain.com/
N8N_SECURE_COOKIE=true

# Отключите debug
NODE_ENV=production
N8N_LOG_LEVEL=warn
```

## 💾 Резервное копирование

### Автоматическое резервное копирование

```bash
# Создание бэкапа через скрипт
./scripts/start.sh
# Выберите опцию "8. Резервное копирование"
```

### Ручное резервное копирование

```bash
# Экспорт workflow'ов
docker exec n8n_app n8n export:workflow --backup --output=/home/node/.n8n/backups/workflows_backup.json

# Экспорт credentials
docker exec n8n_app n8n export:credentials --backup --output=/home/node/.n8n/backups/credentials_backup.json

# Бэкап базы данных
docker exec n8n_postgres pg_dump -U n8n n8n > backup_database.sql
```

### Восстановление

```bash
# Импорт workflow'ов
docker exec n8n_app n8n import:workflow --input=/home/node/.n8n/backups/workflows_backup.json

# Импорт credentials
docker exec n8n_app n8n import:credentials --input=/home/node/.n8n/backups/credentials_backup.json

# Восстановление базы данных
cat backup_database.sql | docker exec -i n8n_postgres psql -U n8n -d n8n
```

## 📊 Мониторинг

### Health Checks

```bash
# Проверка статуса N8N
curl http://localhost:5678/healthz

# Проверка статуса через Docker
docker-compose ps
```

### Логирование

```bash
# Просмотр логов всех сервисов
docker-compose logs

# Логи конкретного сервиса
docker-compose logs -f n8n
docker-compose logs -f postgres
docker-compose logs -f redis
```

### Мониторинг ресурсов

```bash
# Использование ресурсов контейнерами
docker stats

# Размер volumes
docker system df -v
```

## 🩺 Устранение неисправностей

### Частые проблемы

#### N8N не запускается

```bash
# Проверьте логи
docker-compose logs n8n

# Проверьте порты
netstat -tlnp | grep 5678

# Перезапустите контейнеры
docker-compose down && docker-compose up -d
```

#### Проблемы с базой данных

```bash
# Проверьте логи PostgreSQL
docker-compose logs postgres

# Проверьте подключение
docker exec n8n_postgres pg_isready -U n8n

# Пересоздайте базу (ОСТОРОЖНО!)
docker-compose down -v
docker-compose up -d
```

#### Проблемы с памятью

```bash
# Увеличьте лимиты в docker-compose.yml
services:
  n8n:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

### Диагностические команды

```bash
# Информация о Docker
docker info

# Проверка сети
docker network ls
docker network inspect n8n_network

# Проверка volumes
docker volume ls
docker volume inspect n8n_data
```

## 🔄 Обновление

### Обновление N8N

```bash
# Остановка сервисов
docker-compose down

# Загрузка новых образов
docker-compose pull

# Запуск с новыми образами
docker-compose up -d

# Проверка версии
docker exec n8n_app n8n --version
```

### Обновление конфигурации

1. Сделайте бэкап текущей конфигурации
2. Обновите файлы конфигурации
3. Перезапустите сервисы

## 📝 Дополнительные настройки

### Настройка Nginx (Production)

```bash
# Запуск с Nginx
docker-compose --profile proxy up -d

# Настройка SSL сертификатов
mkdir -p nginx/ssl
# Поместите cert.pem и key.pem в nginx/ssl/
```

### Настройка домена

1. Обновите DNS записи
2. Получите SSL сертификат (Let's Encrypt)
3. Обновите конфигурацию в `.env`
4. Перезапустите сервисы

## 🆘 Поддержка

### Полезные ссылки

- [Официальная документация N8N](https://docs.n8n.io/)
- [Community Forum](https://community.n8n.io/)
- [GitHub Issues](https://github.com/n8n-io/n8n/issues)

### Логи для отладки

При обращении за поддержкой приложите:

```bash
# Версия Docker
docker --version

# Логи сервисов
docker-compose logs > n8n_logs.txt

# Конфигурация (без паролей!)
cat docker-compose.yml
```

---

## 📄 Лицензия

Этот проект использует лицензию MIT. См. файл LICENSE для деталей.

## 🤝 Вклад в проект

1. Fork проекта
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

---

**💡 Совет**: Начните с простой конфигурации, а затем переходите к продвинутой по мере роста потребностей! 