workspace "Социальная сеть" "ДЗ 01 – Документирование архитектуры в Structurizr (Вариант 1)" {

  model {
    // Роли
    guest = person "Гость" "Незарегистрированный пользователь. Может только видеть страницу регистрации / входа"
    user = person "Пользователь" "Зарегистрированный пользователь. Публикует записи на стене и отправляет личные сообщения (PtP)."
    moderator = person "Модератор" "Следит за соблюдением правил, просматривает жалобы и удаляет неподходящий контент."

    // Внешние системы
    notificationProvider = softwareSystem "Сервис уведомлений" "Внешний сервис отправки уведомлений (email/push/SMS)." "External"

    // Основная система
    socialNetwork = softwareSystem "Социальная сеть" "Социальная сеть: регистрация и поиск пользователей; добавление и загрузка записей стены; отправка и получение PtP сообщений; модерация контента." {

      // Клиенты
      webApp = container "Веб-клиент" "Интерфейс в браузере." "Web UI"
      mobileApp = container "Мобильный клиент" "Интерфейс на телефоне." "Mobile UI"

      // Точка входа
      apiGateway = container "API Gateway" "Единая точка входа: маршрутизация запросов, базовая фильтрация и проксирование к внутренним сервисам." "Nginx / Reverse Proxy"

      // Сервисы
      authService = container "Auth Service" "Регистрация, вход, проверка учетных данных, выдача токенов доступа." "FastAPI"
      userService = container "User Service" "Пользователи: профиль, создание и поиск пользователей." "FastAPI"
      wallService = container "Wall Service" "Стена: добавление записи, загрузка записей пользователя, удаление записей." "FastAPI"
      chatService = container "Chat Service" "Чат PtP: отправка сообщения, получение списка диалогов и истории сообщений." "FastAPI"
      moderationService = container "Moderation Service" "Модерация контента: обработка жалоб, удаление неподходящих записей и сообщений." "FastAPI"

      // Хранилища
      authDb = container "Auth DB" "Хранит учетные данные, хеши паролей, токены/сессии." "PostgreSQL"
      userDb = container "User DB" "Хранит профили пользователей." "PostgreSQL"
      wallDb = container "Wall DB" "Хранит записи стены." "PostgreSQL"
      chatDb = container "Chat DB" "Хранит PtP сообщения." "MongoDB"
      redis = container "Redis" "Кеширование часто запрашиваемых данных: поиск пользователей, стена, последние сообщения." "Redis"

      // Взаимодействие пользователей с клиентами
      guest -> webApp "Открывает страницу входа и регистрации" "HTTPS"
      guest -> mobileApp "Открывает экран входа и регистрации" "HTTPS"
      user -> webApp "Использует интерфейс" "HTTPS"
      user -> mobileApp "Использует интерфейс" "HTTPS"
      moderator -> webApp "Использует интерфейс модерации" "HTTPS"

      // Клиенты -> gateway
      webApp -> apiGateway "Вызывает API" "HTTPS/REST"
      mobileApp -> apiGateway "Вызывает API" "HTTPS/REST"

      // Gateway -> сервисы
      apiGateway -> authService "API аутентификации (/auth/*)" "HTTPS/REST"
      apiGateway -> userService "API пользователей (/users/*)" "HTTPS/REST"
      apiGateway -> wallService "API стены (/posts/*)" "HTTPS/REST"
      apiGateway -> chatService "API сообщений (/messages/*)" "HTTPS/REST"
      apiGateway -> moderationService "API модерации (/moderation/*)" "HTTPS/REST"

      // Сервисы -> БД
      authService -> authDb "Данные аутентификации" "SQL"
      userService -> userDb "Данные профилей пользователей" "SQL"
      wallService -> wallDb "Данные записей стены" "SQL"
      chatService -> chatDb "Данные PtP сообщений" "MongoDB"

      // Сервисы -> Redis
      userService -> redis "Кеширование результатов поиска пользователей" "RESP"
      wallService -> redis "Кеширование загрузки стены" "RESP"
      chatService -> redis "Кеширование последних сообщений" "RESP"

      // Межсервисные взаимодействия
      wallService -> userService "Проверка существования автора/владельца стены" "HTTPS/REST"
      chatService -> userService "Проверка существования отправителя и получателя" "HTTPS/REST"
      moderationService -> wallService "Удаление/скрытие записи стены" "HTTPS/REST"
      moderationService -> chatService "Удаление/скрытие сообщения" "HTTPS/REST"

      // Уведомления
      chatService -> notificationProvider "Отправка уведомления получателю о новом сообщении" "HTTPS API"
    }
  }

  views {
    systemContext socialNetwork "C1-SystemContext" {
      include guest
      include user
      include moderator
      include socialNetwork
      include notificationProvider
      autolayout lr
      title "C1 – Контекст системы: Социальная сеть"
      description "Гость, пользователь и модератор взаимодействуют с социальной сетью через клиентские приложения. Система интегрируется с внешним сервисом уведомлений."
    }

    container socialNetwork "C2-Containers" {
      include *
      autolayout lr
      title "C2 – Диаграмма контейнеров: Социальная сеть"
      description "Контейнеры отражают ключевые подсистемы: аутентификация, управление пользователями, стена, PtP-сообщения и модерация. У каждого доменного сервиса собственное хранилище. Redis используется для ускорения операций чтения."
    }

    dynamic socialNetwork "D1-PtPMessage" {
      title "D1 – Динамика: отправка PtP сообщения пользователю"
      description "Пользователь отправляет сообщение через мобильный клиент. Chat Service проверяет участников, сохраняет сообщение, обновляет кеш последних сообщений и отправляет уведомление получателю."

      user -> mobileApp "Пишет сообщение и нажимает «Отправить»"
      mobileApp -> apiGateway "POST /messages {fromUserId, toUserId, text}" "HTTPS/REST"
      apiGateway -> chatService "Маршрутизация запроса /messages" "HTTPS/REST"
      chatService -> userService "Проверка существования отправителя и получателя" "HTTPS/REST"
      userService -> chatService "OK" "HTTPS/REST"
      chatService -> chatDb "INSERT message" "MongoDB"
      chatService -> redis "UPDATE cache (последние сообщения)" "RESP"
      chatService -> notificationProvider "Notify(toUserId)" "HTTPS API"
      chatService -> apiGateway "200 OK {messageId}" "HTTPS/REST"
      apiGateway -> mobileApp "200 OK {messageId}" "HTTPS/REST"

      autolayout lr
    }

    dynamic socialNetwork "D2-Moderation" {
      title "D2 – Динамика: удаление записи модератором"
      description "Модератор удаляет неподходящую запись со стены через веб-клиент. Moderation Service инициирует удаление записи в Wall Service."

      moderator -> webApp "Открывает список жалоб и выбирает запись для удаления"
      webApp -> apiGateway "DELETE /moderation/posts/{postId}" "HTTPS/REST"
      apiGateway -> moderationService "Маршрутизация запроса модерации" "HTTPS/REST"
      moderationService -> wallService "Удалить/скрыть запись {postId}" "HTTPS/REST"
      wallService -> wallDb "DELETE or UPDATE post status" "SQL"
      wallService -> redis "INVALIDATE cache (стена пользователя)" "RESP"
      wallService -> moderationService "OK" "HTTPS/REST"
      moderationService -> apiGateway "200 OK" "HTTPS/REST"
      apiGateway -> webApp "200 OK" "HTTPS/REST"

      autolayout lr
    }
  }

}