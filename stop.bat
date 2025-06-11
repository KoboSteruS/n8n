@echo off
title N8N Stop Script

echo ==========================================
echo       N8N Stop Script
echo ==========================================
echo.

echo Останавливаем все контейнеры N8N...

echo Останавливаем простую конфигурацию...
docker-compose -f docker-compose.simple.yml down

echo Останавливаем полную конфигурацию...
docker-compose down

echo.
echo Проверяем статус контейнеров...
docker ps -a | findstr n8n

echo.
echo ==========================================
echo Все контейнеры N8N остановлены!
echo ==========================================
echo.

pause 