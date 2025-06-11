@echo off
title N8N Management Script

echo ==========================================
echo N8N Docker Management Script
echo ==========================================
echo.

REM Проверяем наличие Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ОШИБКА: Docker не установлен или недоступен!
    echo Пожалуйста, установите Docker Desktop с https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo Docker найден. Версия:
docker --version
echo.

REM Проверяем наличие .env файла
if not exist ".env" (
    echo ВНИМАНИЕ: Файл .env не найден!
    echo Копируем env.example в .env...
    if exist "env.example" (
        copy "env.example" ".env"
        echo.
        echo ВАЖНО: Отредактируйте файл .env перед запуском!
        echo Особенно важно установить N8N_ENCRYPTION_KEY
        echo.
        pause
    ) else (
        echo ОШИБКА: Файл env.example не найден!
        pause
        exit /b 1
    )
)

echo Выберите режим запуска:
echo 1. Простой запуск (SQLite, рекомендуется для начала)
echo 2. Полный запуск (PostgreSQL + Redis + Worker)
echo 3. Запуск с туннелем (для разработки)
echo 4. Остановить все контейнеры
echo 5. Перезапустить
echo 6. Просмотр логов
echo 7. Очистка (удаление всех данных)
echo.

set /p choice="Введите номер (1-7): "

if "%choice%"=="1" goto simple
if "%choice%"=="2" goto full
if "%choice%"=="3" goto tunnel
if "%choice%"=="4" goto stop
if "%choice%"=="5" goto restart
if "%choice%"=="6" goto logs
if "%choice%"=="7" goto cleanup
goto invalid

:simple
echo.
echo Запускаем N8N в простом режиме (SQLite)...
docker-compose -f docker-compose.simple.yml up -d
goto status

:full
echo.
echo Запускаем N8N в полном режиме (PostgreSQL + Redis)...
docker-compose up -d
goto status

:tunnel
echo.
echo Запускаем N8N с туннелем (только для разработки!)...
docker-compose -f docker-compose.simple.yml up -d
timeout /t 10 /nobreak
docker exec n8n_simple n8n start --tunnel
goto end

:stop
echo.
echo Останавливаем все контейнеры N8N...
docker-compose down
docker-compose -f docker-compose.simple.yml down
goto end

:restart
echo.
echo Перезапускаем N8N...
docker-compose down
docker-compose up -d
goto status

:logs
echo.
echo Показываем логи N8N (Ctrl+C для выхода)...
docker-compose logs -f n8n
goto end

:cleanup
echo.
echo ВНИМАНИЕ! Это удалит ВСЕ данные N8N!
set /p confirm="Вы уверены? (yes/no): "
if not "%confirm%"=="yes" goto end

echo Останавливаем контейнеры...
docker-compose down -v
docker-compose -f docker-compose.simple.yml down -v

echo Удаляем volumes...
docker volume rm n8n_data 2>nul
docker volume rm n8n_postgres_data 2>nul
docker volume rm n8n_redis_data 2>nul

echo Очистка завершена!
goto end

:status
echo.
echo Ожидание запуска контейнеров...
timeout /t 15 /nobreak

echo.
echo Статус контейнеров:
docker-compose ps

echo.
echo ==========================================
echo N8N успешно запущен!
echo.
echo Веб-интерфейс: http://localhost:5678
echo.
echo Первый запуск:
echo 1. Откройте http://localhost:5678 в браузере
echo 2. Создайте учетную запись администратора
echo 3. Начните создавать workflow'ы!
echo.
echo Полезные команды:
echo - Логи: docker-compose logs -f n8n
echo - Остановка: docker-compose down
echo - Обновление: docker-compose pull ^&^& docker-compose up -d
echo ==========================================
goto end

:invalid
echo Неверный выбор! Пожалуйста, выберите от 1 до 7.
pause
goto start

:end
echo.
pause 