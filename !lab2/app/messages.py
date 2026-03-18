from fastapi import APIRouter
from app.models import MessageDTO
import uuid

router = APIRouter(prefix="/messages", tags=["Chat"])
messages = {}


# отправить сообщение
@router.post("")
def send_message(msg: MessageDTO):
    message_id = str(uuid.uuid4())

    if msg.toUserId not in messages:
        messages[msg.toUserId] = []
        
    messages[msg.toUserId].append({
        "messageId": message_id,
        "text": msg.text
    })

    return {"messageId": message_id}


# получить сообщения пользователя
@router.get("/{userId}")
def get_messages(userId: str):
    return messages.get(userId, [])