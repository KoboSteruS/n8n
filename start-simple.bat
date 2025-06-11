@echo off
title N8N Quick Start

echo ==========================================
echo       N8N Quick Start Script
echo ==========================================
echo.

REM Проверяем наличие Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ОШИБКА: Docker не установлен или недоступен!
    echo Установите Docker Desktop с https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo Docker найден!
echo.

echo Запускаем N8N в простом режиме...
docker-compose -f docker-compose.simple.yml up -d

echo.
echo Ожидание запуска контейнера...
timeout /t 15 /nobreak >nul

echo.
echo Проверяем статус...
docker-compose -f docker-compose.simple.yml ps

echo.
echo ==========================================
echo N8N успешно запущен!
echo.
echo Откройте в браузере: http://localhost:5678
echo.
echo Полезные команды:
echo - Остановка: docker-compose -f docker-compose.simple.yml down
echo - Логи: docker-compose -f docker-compose.simple.yml logs -f
echo - Статус: docker-compose -f docker-compose.simple.yml ps
echo ==========================================
echo.

set /p choice="Открыть N8N в браузере? (y/n): "
if /i "%choice%"=="y" start http://localhost:5678

echo.
pause 