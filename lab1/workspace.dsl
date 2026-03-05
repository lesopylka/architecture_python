workspace "Социальная сеть" "ДЗ 01 – Документирование архитектуры в Structurizr (Вариант 1)" {

  model {
    // Роли
    guest = person "Гость" "Незарегистрированный пользователь. Может искать пользователей и просматривать доступную публичную информацию."
    user = person "Пользователь" "Зарегистрированный пользователь. Публикует записи на стене и отправляет личные сообщения (PtP)."
    moderator = person "Модератор" "Следит за соблюдением правил и может удалять неподходящий контент."

    // Внешние системы
    notificationProvider = softwareSystem "Сервис уведомлений" "Внешний сервис отправки уведомлений (email/push/SMS)." "External"

    // Моя система
    socialNetwork = softwareSystem "Социальная сеть" "Социальная сеть: создание и поиск пользователей; добавление и загрузка записей стены; отправка и получение PtP сообщений." {

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

      apiGateway -> userService "API пользователей (/users/*)" "HTTPS/REST"
      apiGateway -> wallService "API стены (/walls/*)" "HTTPS/REST"
      apiGateway -> chatService "API сообщений (/messages/*)" "HTTPS/REST"

      userService -> postgres "Данные: Пользователь (users)" "SQL"
      wallService -> postgres "Данные: Стена (wall_posts)" "SQL"
      chatService -> mongo "Данные: Сообщения PtP (messages)" "MongoDB"

      userService -> redis "Кеширование результатов поиска пользователей" "RESP"
      wallService -> redis "Кеширование загрузки стены" "RESP"
      chatService -> redis "Кеширование последних сообщений" "RESP"

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
      description "Пользователи взаимодействуют с социальной сетью через веб/мобильный клиент. Система интегрируется с внешним сервисом уведомлений."
    }

    container socialNetwork "C2-Containers" {
      include *
      autolayout lr
      title "C2 – Диаграмма контейнеров: Социальная сеть"
      description "Контейнеры отражают основные сценарии: User Service – создание/поиск пользователей; Wall Service – добавление/загрузка стены; Chat Service – отправка/получение PtP сообщений. Redis используется для кеширования чтения, внешний сервис – для отправки уведомлений."
    }

    dynamic socialNetwork "D1-PtPMessage" {
      title "D1 – Динамика: отправка PtP сообщения пользователю"
      description "Сценарий PtP: клиент отправляет сообщение через API Gateway; Chat Service сохраняет сообщение в MongoDB, обновляет кеш последних сообщений в Redis и отправляет уведомление получателю через внешний сервис."

      user -> mobileApp "Пишет сообщение и нажимает «Отправить»"
      mobileApp -> apiGateway "POST /messages {fromUserId, toUserId, text}" "HTTPS/REST"
      apiGateway -> chatService "Маршрутизация запроса /messages" "HTTPS/REST"
      chatService -> mongo "INSERT messages (сохранение сообщения)" "MongoDB"
      chatService -> redis "UPDATE cache (последние сообщения)" "RESP"
      chatService -> notificationProvider "Notify(toUserId)" "HTTPS API"
      chatService -> apiGateway "200 OK {messageId}" "HTTPS/REST"
      apiGateway -> mobileApp "200 OK {messageId}" "HTTPS/REST"

      autolayout lr
    }
  }

}