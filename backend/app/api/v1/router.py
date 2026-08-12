from fastapi import APIRouter

from app.admin.router import router as admin_router
from app.analytics.router import router as analytics_router
from app.api.v1 import health
from app.ai.router import router as ai_router
from app.auth.router import router as auth_router
from app.content.router import router as content_router
from app.entitlements.router import router as me_router
from app.gamification.router import router as gamification_router
from app.learning.router import router as learning_router
from app.mentor.router import router as mentor_router
from app.progress.router import router as progress_router
from app.sync.router import router as sync_router

api_v1_router = APIRouter()
api_v1_router.include_router(health.router)
api_v1_router.include_router(auth_router)
api_v1_router.include_router(me_router)
api_v1_router.include_router(content_router)
api_v1_router.include_router(learning_router)
api_v1_router.include_router(progress_router)
api_v1_router.include_router(gamification_router)
api_v1_router.include_router(ai_router)
api_v1_router.include_router(mentor_router)
api_v1_router.include_router(admin_router)
api_v1_router.include_router(sync_router)
api_v1_router.include_router(analytics_router)
