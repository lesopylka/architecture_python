# Social Network API

REST API сервис социальной сети.

## Возможности

- Регистрация и авторизация пользователей
- Поиск пользователей
- Добавление записей на стену
- Получение стены пользователя
- Отправка и получение сообщений (PtP)

## Запуск

### Локально
```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

###  Docker
docker-compose up --build
Swagger UI

http://localhost:8000/docs

##  Примеры
 
### Регистрация


### Добавление поста
