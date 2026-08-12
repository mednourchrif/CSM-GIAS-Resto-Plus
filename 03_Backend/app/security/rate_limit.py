"""Small in-process login throttle for the single-instance deployment."""

import time
from collections import defaultdict, deque
from threading import Lock


class LoginRateLimiter:
    """Track failed attempts in a fixed rolling window.

    This implementation matches the project's single backend instance. A
    shared store such as Redis is required before deploying multiple workers
    or replicas.
    """

    def __init__(self, max_attempts: int, window_seconds: int) -> None:
        self._max_attempts = max_attempts
        self._window_seconds = window_seconds
        self._attempts: dict[str, deque[float]] = defaultdict(deque)
        self._lock = Lock()

    def retry_after(self, key: str) -> int | None:
        """Return seconds to wait, or ``None`` when the request is allowed."""
        now = time.monotonic()
        with self._lock:
            attempts = self._attempts[key]
            self._prune(attempts, now)
            if len(attempts) < self._max_attempts:
                return None
            return max(1, int(self._window_seconds - (now - attempts[0])))

    def record_failure(self, key: str) -> None:
        now = time.monotonic()
        with self._lock:
            attempts = self._attempts[key]
            self._prune(attempts, now)
            attempts.append(now)

    def reset(self, key: str) -> None:
        with self._lock:
            self._attempts.pop(key, None)

    def clear(self) -> None:
        with self._lock:
            self._attempts.clear()

    def _prune(self, attempts: deque[float], now: float) -> None:
        cutoff = now - self._window_seconds
        while attempts and attempts[0] <= cutoff:
            attempts.popleft()
