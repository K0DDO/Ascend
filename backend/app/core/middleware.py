import logging
import time
import uuid
from collections import defaultdict, deque
from collections.abc import Awaitable, Callable

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

logger = logging.getLogger(__name__)


class RequestIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(
        self,
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        request_id = request.headers.get("X-Request-ID") or str(uuid.uuid4())
        request.state.request_id = request_id

        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(
        self,
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        response = await call_next(request)
        response.headers.setdefault("X-Content-Type-Options", "nosniff")
        response.headers.setdefault("X-Frame-Options", "DENY")
        response.headers.setdefault("Referrer-Policy", "no-referrer")
        response.headers.setdefault("Permissions-Policy", "geolocation=()")
        return response


class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, *, limit_per_minute: int = 120) -> None:
        super().__init__(app)
        self.limit_per_minute = max(1, limit_per_minute)
        self._hits: dict[str, deque[float]] = defaultdict(deque)

    def _client_key(self, request: Request) -> str:
        forwarded = request.headers.get("X-Forwarded-For")
        if forwarded:
            return forwarded.split(",")[0].strip()
        if request.client:
            return request.client.host
        return "unknown"

    async def dispatch(
        self,
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        if request.url.path.endswith("/health"):
            return await call_next(request)

        now = time.time()
        key = f"{self._client_key(request)}:{request.method}:{request.url.path}"
        bucket = self._hits[key]
        while bucket and now - bucket[0] > 60:
            bucket.popleft()
        if len(bucket) >= self.limit_per_minute:
            request_id = getattr(request.state, "request_id", "-")
            logger.warning("rate_limit_exceeded request_id=%s path=%s", request_id, request.url.path)
            return Response(
                status_code=429,
                content='{"error":{"code":"rate_limited","message":"Too many requests"}}',
                media_type="application/json",
                headers={"Retry-After": "60"},
            )
        bucket.append(now)
        return await call_next(request)
