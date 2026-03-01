workspace "Вариант: 1 Социальная сеть" "Выполнила: Суляева Алина М8О-105СВ-25" {

  
  model {
    guest = person "Гость" 
    user = person "Пользователь" 

    notificationProvider = softwareSystem "Сервис уведомлений (внешний)" "External"

    socialNetwork = softwareSystem "Социальная сеть" {

      webApp = container "Веб-клиент" "Web UI"
      mobileApp = container "Мобильный клиент" "Mobile UI"

      apiGateway = container "API Gateway" "Nginx"

      userService = container "User Service" "FastAPI"
      wallService = container "Wall Service" "FastAPI"
      chatService = container "Chat Service" "FastAPI"

      postgres = container "PostgreSQL" "PostgreSQL"
      mongo = container "MongoDB" "MongoDB"

      user -> webApp "Использует" "HTTPS"
      user -> mobileApp "Использует" "HTTPS"
      guest -> webApp "Использует" "HTTPS"

      webApp -> apiGateway "REST" "HTTPS"
      mobileApp -> apiGateway "REST" "HTTPS"

      apiGateway -> userService "/users/*" "HTTPS/REST"
      apiGateway -> wallService "/walls/*" "HTTPS/REST"
      apiGateway -> chatService "/messages/*" "HTTPS/REST"

      userService -> postgres "users" "SQL"
      wallService -> postgres "wall_posts" "SQL"
      chatService -> mongo "messages" "MongoDB"

      chatService -> notificationProvider "Notify (опц.)" "HTTPS"
    }
  }

  views {
    systemContext socialNetwork "C1" {
      include guest
      include user
      include socialNetwork
      include notificationProvider
      autolayout lr
    }

    container socialNetwork "C2" {
      include *
      autolayout lr
    }

    dynamic socialNetwork "D1" {
      user -> mobileApp "Отправить сообщение"
      mobileApp -> apiGateway "POST /messages" "HTTPS"
      apiGateway -> chatService "route" "HTTPS/REST"
      chatService -> mongo "insert" "MongoDB"
      chatService -> notificationProvider "notify (опц.)" "HTTPS"
      apiGateway -> mobileApp "200 OK" "HTTPS"
      autolayout lr
    }
  }
}