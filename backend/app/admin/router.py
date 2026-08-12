from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.admin.schemas import (
    AdminAnalyticsOverview,
    CardModerationView,
    CardStatusUpdateRequest,
    EntitlementGrantRequest,
    EntitlementGrantView,
)
from app.admin.service import AdminService
from app.core.database import get_db_session
from app.core.deps import require_admin
from app.models.user import User

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/content/review-queue", response_model=list[CardModerationView])
async def review_queue(
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_db_session),
) -> list[CardModerationView]:
    return await AdminService(session).list_review_queue()


@router.patch("/content/cards/{card_id}/status", response_model=CardModerationView)
async def update_card_status(
    card_id: UUID,
    payload: CardStatusUpdateRequest,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_db_session),
) -> CardModerationView:
    return await AdminService(session).update_card_status(card_id, payload)


@router.post("/entitlements/grants", response_model=EntitlementGrantView)
async def grant_entitlement(
    payload: EntitlementGrantRequest,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_db_session),
) -> EntitlementGrantView:
    return await AdminService(session).grant_entitlement(payload)


@router.get("/analytics/overview", response_model=AdminAnalyticsOverview)
async def analytics_overview(
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_db_session),
) -> AdminAnalyticsOverview:
    return await AdminService(session).analytics_overview()
