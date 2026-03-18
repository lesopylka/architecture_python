from fastapi import FastAPI
from app import auth, users, posts, messages

app = FastAPI(
    title="Social Network API",
)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(posts.router)
app.include_router(messages.router)

