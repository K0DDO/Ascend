from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.models.user import User
from app.sync.schemas import SyncBatchRequest, SyncBatchResponse, SyncDiagnosticsResponse, SyncStateResponse
from app.sync.service import SyncService

router = APIRouter(prefix="/sync", tags=["sync"])


@router.post("/events", response_model=SyncBatchResponse)
async def ingest_sync_events(
    payload: SyncBatchRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> SyncBatchResponse:
    return await SyncService(session).ingest_batch(user_id=user.id, payload=payload)


@router.get("/state", response_model=SyncStateResponse)
async def sync_state(
    since: str | None = Query(default=None),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> SyncStateResponse:
    return await SyncService(session).state(user_id=user.id, since=since)


@router.get("/diagnostics", response_model=SyncDiagnosticsResponse)
async def sync_diagnostics(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> SyncDiagnosticsResponse:
    return await SyncService(session).diagnostics(user_id=user.id)
