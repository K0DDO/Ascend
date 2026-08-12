from fastapi import APIRouter

from app.api.v1 import health
from app.auth.router import router as auth_router
from app.content.router import router as content_router
from app.entitlements.router import router as me_router
from app.gamification.router import router as gamification_router
from app.learning.router import router as learning_router
from app.progress.router import router as progress_router

api_v1_router = APIRouter()
api_v1_router.include_router(health.router)
api_v1_router.include_router(auth_router)
api_v1_router.include_router(me_router)
api_v1_router.include_router(content_router)
api_v1_router.include_router(learning_router)
api_v1_router.include_router(progress_router)
api_v1_router.include_router(gamification_router)
