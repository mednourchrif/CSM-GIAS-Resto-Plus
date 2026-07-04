import time
import uuid

from loguru import logger
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import Response
from starlette.types import ASGIApp

from app.core.constants import HEADER_PROCESS_TIME, HEADER_REQUEST_ID


class CoreMiddleware(BaseHTTPMiddleware):
    """Generates a unique request ID, logs every request with duration, and
    injects observability headers into the response.

    Combines three concerns (ID generation, timing, logging) into a single
    middleware traversal to avoid the overhead of multiple passes.
    """

    def __init__(self, app: ASGIApp) -> None:
        super().__init__(app)

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        request_id = request.headers.get(HEADER_REQUEST_ID, str(uuid.uuid4()))
        request.state.request_id = request_id

        start_time = time.perf_counter()

        with logger.contextualize(request_id=request_id):
            logger.info("→ {} {}", request.method, request.url.path)

            response = await call_next(request)

            duration_ms = (time.perf_counter() - start_time) * 1000

            response.headers[HEADER_REQUEST_ID] = request_id
            response.headers[HEADER_PROCESS_TIME] = f"{duration_ms:.2f}"

            logger.info(
                "← {} {} — {} ({:.2f}ms)",
                request.method,
                request.url.path,
                response.status_code,
                duration_ms,
            )

        return response
