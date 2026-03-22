# Домашнее задание 02: Разработка REST API сервиса
Цель работы: Получить практические навыки разработки REST API сервиса с
использованием принципов REST, обработкой HTTP запросов, реализацией аутентификации
и документированием API.

- [Домашнее задание 02: Разработка REST API сервиса](#домашнее-задание-02-разработка-rest-api-сервиса)
  - [Задание](#задание)
  - [Результат](#результат)
  - [Вариант 1  – Социальная сеть](#вариант-1---социальная-сеть)
  - [Архитектура](#архитектура)
      - [POST /auth:](#post-auth)
      - [POST /users](#post-users)
      - [GET /users](#get-users)
      - [POST /posts](#post-posts)
      - [GET /posts?user\_id=1](#get-postsuser_id1)
      - [POST /messages](#post-messages)
      - [GET /messages?user\_id=1](#get-messagesuser_id1)
  - [Тестирование](#тестирование)
  - [HTTP статус-коды](#http-статус-коды)
  - [OpenAPI](#openapi)
  - [Хранилище](#хранилище)
  - [Запуск](#запуск)

## Задание
Выберите нужный вариант из файла `homework_variants.pdf` (варианты 1-24) и
выполните следующие задачи:
1. Проектирование REST API
 - Изучите выбранный вариант задания
 - Спроектируйте REST API endpoints для всех операций из вашего варианта
 - Используйте правильные HTTP методы (GET, POST, PUT, DELETE, PATCH)
 - Используйте правильные HTTP статус-коды
 - Спроектируйте структуру URL (ресурсы, вложенные ресурсы)
 - Определите структуру Request/Response для каждого endpoint
2. Реализация REST API сервиса
 - Реализуйте REST API сервис на выбранном языке и фреймворке (Python FastAPI,
C++ Poco, Yandex Userver)
 - Реализуйте минимум 5 API endpoints из вашего варианта задания
 - Используйте in-memory хранилище (списки, словари) или простую БД (SQLite)
 - Реализуйте обработку ошибок с правильными HTTP статус-кодами
 - Используйте DTO (Data Transfer Objects) для передачи данных
3. Реализация аутентификации
 - Реализуйте простую аутентификацию (можно использовать JWT токены или sessionbased)
 - Защитите минимум 2 endpoint с помощью аутентификации
 - Реализуйте endpoint для регистрации/логина пользователя
 - Добавьте middleware для проверки аутентификации
4. Документирование API
 - Создайте OpenAPI/Swagger спецификацию для вашего API
 - Опишите все endpoints с параметрами, request/response схемами
 - Добавьте примеры запросов и ответов
 - Если возможно, добавьте Swagger UI для интерактивного тестирования API
5. Тестирование
 - Создайте простые тесты для основных endpoints (можно использовать curl,
Postman или unit-тесты)
 - Протестируйте успешные сценарии
 - Протестируйте обработку ошибок (невалидные данные, отсутствующие ресурсы и
т.д.)

## Результат

## Вариант 1  – Социальная сеть

Приложение должно содержать следующие данные:
- Пользователь
- Стена
- Сообщения чата (PtP)
Реализовать API:
- Создание нового пользователя
- Поиск пользователя по логину
- Поиск пользователя по маске имя и фамилии
- Добавление записи на стену
- Загрузка стены пользователя
- Отправка сообщения пользователю
- Получение списка сообщения для пользователя

## Архитектура

Система состоит из 4 микросервисов:

| Сервис | Порт | Назначение |
|-------|------|-----------|
| auth-service | 8081 | Аутентификация |
| user-service | 8082 | Пользователи |
| wall-service | 8083 | Посты |
| chat-service | 8084 | Сообщения |

Каждый сервис запускается отдельно.

В аутентификации используется простая токен-аутентификация `Authorization: Bearer 123`

#### POST /auth:

Response:
```
{
  "token": "123"
}
```

#### POST /users

Request:
```
{
  "login": "alice"
}
```

Response:
```
{
  "id": 1,
  "login": "alice"
}
```
#### GET /users

Response:
```
[
  {
    "id": 1,
    "login": "alice"
  }
]
```
Поиск по логину: `GET /users?login=alice`


Поиск по маске: `GET /users?name=ali`

#### POST /posts

Headers:
```
Authorization: Bearer 123
```

Request:
```
{
  "user_id": 1,
  "content": "hello"
}
```

Response:
```
{
  "id": 1
}
```
#### GET /posts?user_id=1

Response:
```
[
  {
    "id": 1,
    "user_id": 1,
    "content": "hello"
  }
]
```

#### POST /messages

Headers:
```
Authorization: Bearer 123
```

Request:
```
{
  "from": 1,
  "to": 2,
  "text": "hi"
}
```

Response:
```
{
  "id": 1
}
```
#### GET /messages?user_id=1

Response:
```
[
  {
    "id": 1,
    "from": 1,
    "to": 2,
    "text": "hi"
  }
]
```
## Тестирование

Тестирование выполняется с помощью bash-скриптов:
```
./auth.sh
./users.sh
./posts.sh
./messages.sh
```

## HTTP статус-коды


| Endpoint   | Метод | Статус | Описание |
|------------|------|--------|----------|
| /auth      | POST | 200 OK | Успешная аутентификация |
| /auth      | POST | 405 Method Not Allowed | Неверный метод |
| /users     | POST | 201 Created | Пользователь создан |
| /users     | POST | 400 Bad Request | Неверные данные |
| /users     | GET  | 200 OK | Получение списка пользователей |
| /posts     | POST | 201 Created | Пост создан |
| /posts     | POST | 401 Unauthorized | Нет или неверный токен |
| /posts     | POST | 400 Bad Request | Ошибка в данных |
| /posts     | GET  | 200 OK | Получение постов |
| /posts     | GET  | 401 Unauthorized | Нет или неверный токен |
| /messages  | POST | 201 Created | Сообщение отправлено |
| /messages  | POST | 401 Unauthorized | Нет или неверный токен |
| /messages  | POST | 400 Bad Request | Ошибка в данных |
| /messages  | GET  | 200 OK | Получение сообщений |
| /messages  | GET  | 401 Unauthorized | Нет или неверный токен |
## OpenAPI

Файл спецификации: [openapi.yaml](openapi.yaml)

## Хранилище

Используется in-memory хранение:

- users
- posts
- messages

## Запуск

Собрать сервис:

```bash
cd <service>/build
cmake ..
ninja
./auth_service --config ../configs/static_config.yaml
./user_service --config ../configs/static_config.yaml
./wall_service --config ../configs/static_config.yaml
./chat_service --config ../configs/static_config.yaml
```
