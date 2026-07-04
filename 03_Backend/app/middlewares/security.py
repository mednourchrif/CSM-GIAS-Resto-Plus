from starlette.datastructures import MutableHeaders
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import Response
from starlette.types import ASGIApp


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Adds security-related HTTP headers to every response.

    These headers help mitigate common web vulnerabilities including
    XSS, clickjacking, MIME-type sniffing, and protocol downgrade attacks.
    """

    def __init__(self, app: ASGIApp) -> None:
        super().__init__(app)

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        response = await call_next(request)

        headers = MutableHeaders(response.headers)

        headers.setdefault("X-Content-Type-Options", "nosniff")
        headers.setdefault("X-Frame-Options", "DENY")
        headers.setdefault("X-XSS-Protection", "1; mode=block")
        headers.setdefault("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
        headers.setdefault("Referrer-Policy", "strict-origin-when-cross-origin")
        headers.setdefault(
            "Permissions-Policy",
            "camera=(), microphone=(), geolocation=(), fullscreen=(self)",
        )
        headers.setdefault("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate")
        headers.setdefault("Pragma", "no-cache")
        headers.setdefault("Expires", "0")

        return response
