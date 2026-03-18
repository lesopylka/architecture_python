from pydantic import BaseModel

#DTO для регистрации пользователя
class RegisterDTO(BaseModel):
    login: str
    password: str
    firstName: str
    lastName: str


#DTO для логина
class LoginDTO(BaseModel):
    login: str
    password: str


#DTO для создания поста
class PostDTO(BaseModel):
    userId: str
    content: str


#DTO для отправки сообщения
class MessageDTO(BaseModel):
    toUserId: str
    text: str