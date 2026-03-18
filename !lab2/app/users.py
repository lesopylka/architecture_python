from fastapi import APIRouter, HTTPException
from app.auth import users

router = APIRouter(prefix="/users", tags=["Users"])

#поиск по логину
@router.get("/by-login/{login}")
def get_user(login: str):
    user = users.get(login)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user


#поиск по имени, фамилии
@router.get("")
def search_users(name: str):
    result = []

    for u in users.values():
        if name.lower() in u["firstName"].lower() or name.lower() in u["lastName"].lower():
            result.append(u)

    return result