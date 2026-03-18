from fastapi import APIRouter
from app.models import PostDTO
import uuid

router = APIRouter(prefix="/posts", tags=["Wall"])
posts = {}

#добавить пост
@router.post("")
def add_post(post: PostDTO):
    #генерируем id поста
    post_id = str(uuid.uuid4())

    if post.userId not in posts:
        posts[post.userId] = []

    posts[post.userId].append({
        "postId": post_id,
        "content": post.content
    })

    return {"postId": post_id}


#получить стену пользователя
@router.get("/{userId}")
def get_posts(userId: str):
    return posts.get(userId, [])