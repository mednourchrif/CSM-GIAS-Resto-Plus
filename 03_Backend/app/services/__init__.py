"""Services — business-logic layer.

Services orchestrate repositories and enforce domain rules.  Each service
inherits from :class:`BaseService` and may add custom business methods.
"""

from app.services.base import BaseService

__all__ = [
    "BaseService",
]
