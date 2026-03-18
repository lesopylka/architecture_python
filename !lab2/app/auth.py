from fastapi import APIRouter, HTTPException
from app.models import RegisterDTO, LoginDTO
import uuid

router = APIRouter(prefix="/auth", tags=["Auth"]) #создаем роутер с префиксом /auth
users = {}

#регистрация пользователя
@router.post("/register")
def register(data: RegisterDTO):
    #проверяем, есть ли уже такой логин
    if data.login in users:
        raise HTTPException(status_code=409, detail="User already exists")

    #генерируем уникальный id
    user_id = str(uuid.uuid4())

    #сохраняем пользователя
    users[data.login] = {
        "id": user_id,
        "password": data.password,
        "firstName": data.firstName,
        "lastName": data.lastName
    }
    #возвращаем id и токен
    return {
        "userId": user_id,
        "accessToken": user_id  #упрощенная аутентификация
    }


#логин пользователя
@router.post("/login")
def login(data: LoginDTO):
    user = users.get(data.login)

    if not user or user["password"] != data.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    return {
        "accessToken": user["id"]
    }