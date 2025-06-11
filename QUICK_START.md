# 🚀 Быстрый запуск N8N

## ✅ Готово к использованию!

N8N проект успешно развернут и готов к работе!

## 🎯 Немедленный запуск

### Windows (простой способ):
```cmd
# Дважды кликните на файл:
start-simple.bat
```

### Командная строка:
```cmd
docker-compose -f docker-compose.simple.yml up -d
```

## 🌐 Доступ к N8N

**Откройте в браузере:** http://localhost:5678

## 📋 Первоначальная настройка

1. **Откройте** http://localhost:5678 в браузере
2. **Создайте** учетную запись администратора
3. **Начните** создавать ваши первые workflow'ы!

## ⚙️ Управление

### Остановка:
```cmd
# Простой способ
stop.bat

# Или командная строка
docker-compose -f docker-compose.simple.yml down
```

### Просмотр логов:
```cmd
docker-compose -f docker-compose.simple.yml logs -f
```

### Статус:
```cmd
docker-compose -f docker-compose.simple.yml ps
```

## 🔧 Конфигурации

### 1. Простая (текущая)
- **Использует:** SQLite
- **Для:** разработки, тестирования, небольших проектов
- **Файл:** `docker-compose.simple.yml`

### 2. Продвинутая
- **Использует:** PostgreSQL + Redis + Worker
- **Для:** production, высокие нагрузки
- **Файл:** `docker-compose.yml`

```cmd
# Переключение на продвинутую конфигурацию
docker-compose up -d
```

## 🔐 Безопасность

⚠️ **ВАЖНО:** Измените ключ шифрования в файле `.env`:

```env
N8N_ENCRYPTION_KEY=your-very-secure-encryption-key-here
```

**Генерация безопасного ключа:**
```powershell
# PowerShell
[System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
```

## 📁 Структура проекта

```
n8n/
├── docker-compose.yml              # Продвинутая конфигурация
├── docker-compose.simple.yml      # Простая конфигурация
├── .env                           # Настройки (НЕ коммитьте!)
├── env.example                    # Пример настроек
├── start-simple.bat              # Быстрый запуск
├── stop.bat                      # Остановка
├── scripts/                      # Управляющие скрипты
├── nginx/                        # Конфигурация Nginx
├── backups/                      # Резервные копии
└── README.md                     # Полная документация
```

## 🆘 Помощь

### Проблемы?
1. Проверьте логи: `docker logs n8n_simple`
2. Перезапустите: `stop.bat` → `start-simple.bat`
3. Прочитайте полную документацию в `README.md`

### Полезные ссылки
- **Документация N8N:** https://docs.n8n.io/
- **Community Forum:** https://community.n8n.io/
- **Примеры workflow'ов:** https://n8n.io/workflows/

---

## 🎉 Поздравляем!

Ваш N8N сервер готов к автоматизации бизнес-процессов!

**Следующие шаги:**
1. Откройте http://localhost:5678
2. Создайте учетную запись
3. Изучите примеры workflow'ов
4. Начните автоматизацию! 