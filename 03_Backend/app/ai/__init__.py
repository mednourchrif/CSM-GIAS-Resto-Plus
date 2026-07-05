"""AI module — face recognition engine interface and stub implementations.

This package defines the pluggable face recognition contract
(:class:`FaceRecognitionEngine`) that the rest of the application
depends on.  The stub implementation shipped here allows the full
API surface to be tested end-to-end without any real AI model.
"""

from app.ai.engine import (
    FaceDetection,
    FaceRecognitionEngine,
    StubFaceRecognitionEngine,
)

__all__ = [
    "FaceDetection",
    "FaceRecognitionEngine",
    "StubFaceRecognitionEngine",
]
