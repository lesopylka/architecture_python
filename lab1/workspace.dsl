напиши mvp черновик  этой архитектуры, сделай шаблон
workspace "Социальная сеть" "ДЗ 01 — Документирование архитектуры в Structurizr (Вариант 1)" {

  model {
    // Роли
    guest = person "Гость" "Незарегистрированный пользователь. Может искать пользователей и просматривать доступную публичную информацию."
    user = person "Пользователь" "Зарегистрированный пользователь. Публикует записи на стене и отправляет личные сообщения (PtP)."
    moderator = person "Модератор" "Следит за соблюдением правил и может удалять неподходящий контент (в рамках учебного примера)."

    // Внешние системы
    notificationProvider = softwareSystem "Сервис уведомлений (внешний)" "Внешний сервис отправки уведомлений (email/push/SMS)." "External"

    // Моя система
    socialNetwork = softwareSystem "Социальная сеть" "Система с данными: Пользователь, Стена, Сообщения PtP; реализует API по ТЗ." {

      // Клиенты
      webApp = container "Веб-клиент" "Интерфейс в браузере." "Web UI"
      mobileApp = container "Мобильный клиент" "Интерфейс на телефоне." "Mobile UI"

      // Точка входа
      apiGateway = container "API Gateway" "Единая точка входа для клиентов. Маршрутизирует запросы по сервисам." "Nginx (reverse proxy)"

      // Сервисы домена
      userService = container "User Service" "Пользователи: создание и поиск." "FastAPI"
      wallService = container "Wall Service" "Стена: добавление записи и загрузка стены пользователя." "FastAPI"
      chatService = container "Chat Service" "Чат PtP: отправка сообщения и получение списка сообщений пользователя." "FastAPI"

      // Хранилища
      postgres = container "PostgreSQL" "Хранит пользователей и записи стены." "PostgreSQL"
      mongo = container "MongoDB" "Хранит PtP сообщения." "MongoDB"
      redis = container "Redis" "Кеширование часто запрашиваемых данных (поиск/стена/последние сообщения)." "Redis"

      // Связи
      guest -> webApp "Использует интерфейс" "HTTPS"
      user -> webApp "Использует интерфейс" "HTTPS"
      user -> mobileApp "Использует интерфейс" "HTTPS"
      moderator -> webApp "Проверяет/модерирует контент" "HTTPS"
      
      webApp -> apiGateway "Вызывает API" "HTTPS/REST"
      mobileApp -> apiGateway "Вызывает API" "HTTPS/REST"
      
      apiGateway -> userService "Маршрутизация: /users/*" "HTTPS/REST"
      apiGateway -> wallService "Маршрутизация: /walls/*" "HTTPS/REST"
      apiGateway -> chatService "Маршрутизация: /messages/*" "HTTPS/REST"

      userService -> postgres "Данные: Пользователь (users)" "SQL"
      wallService -> postgres "Данные: Стена (wall_posts)" "SQL"
      chatService -> mongo "Данные: Сообщения PtP (messages)" "MongoDB"

      userService -> redis "Кеширование результатов поиска пользователей" "RESP"
      wallService -> redis "Кеширование загрузки стены" "RESP"
      chatService -> redis "Кеширование последних сообщений (опционально)" "RESP"

      chatService -> notificationProvider "Уведомление получателя о новом сообщении (учебно/опционально)" "HTTPS API"
    }

    // Пользователь
    apiGateway -> userService "API: POST /users (создание пользователя)" "HTTPS/REST"
    apiGateway -> userService "API: GET /users/by-login/{login} (поиск по логину)" "HTTPS/REST"
    apiGateway -> userService "API: GET /users/search?query=... (поиск по маске имя+фамилия)" "HTTPS/REST"

    // Стена
    apiGateway -> wallService "API: POST /walls/{userId}/posts (добавить запись на стену)" "HTTPS/REST"
    apiGateway -> wallService "API: GET /walls/{userId} (загрузить стену пользователя)" "HTTPS/REST"

    // Сообщения PtP
    apiGateway -> chatService "API: POST /messages (отправить сообщение пользователю)" "HTTPS/REST"
    apiGateway -> chatService "API: GET /messages?user_id=... (список сообщений пользователя)" "HTTPS/REST"
  }

  views {
    systemContext socialNetwork "C1-SystemContext" {
      include guest
      include user
      include moderator
      include socialNetwork
      include notificationProvider
      autolayout lr
      title "C1 — Контекст системы: Социальная сеть"
      description "Пользователи взаимодействуют с социальной сетью через веб/мобильный клиент. Система интегрируется с внешним сервисом уведомлений."
    }

    container socialNetwork "C2-Containers" {
      include *
      autolayout lr
      title "C2 — Диаграмма контейнеров: Социальная сеть"
      description "Контейнеры подобраны для точной реализации данных и API из ТЗ (Пользователь, Стена, PtP сообщения). Указаны технологии и протоколы."
    }

    dynamic socialNetwork "D1-PtPMessage" {
      title "D1 — Динамика: отправка PtP сообщения пользователю"
      description "Сценарий из ТЗ: пользователь отправляет личное сообщение. Запрос проходит через API Gateway, сохраняется в MongoDB, опционально обновляется кеш, затем формируется уведомление получателю."

      user -> mobileApp "Пишет сообщение и нажимает «Отправить»"
      mobileApp -> apiGateway "POST /messages {fromUserId, toUserId, text}" "HTTPS/REST"
      apiGateway -> chatService "Маршрутизация запроса /messages" "HTTPS/REST"
      chatService -> mongo "INSERT messages (сохранение сообщения)" "MongoDB"
      chatService -> redis "UPDATE cache (последние сообщения, опционально)" "RESP"
      chatService -> notificationProvider "Notify(toUserId) (учебно/опционально)" "HTTPS API"
      apiGateway -> mobileApp "200 OK {messageId}" "HTTPS/REST"

      autolayout lr
    }
  }

}