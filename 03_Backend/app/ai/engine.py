"""Face recognition engine — abstract interface and stub implementation.

Architecture
------------
:class:`FaceRecognitionEngine` is the abstract base class that every
concrete face-recognition implementation must subclass.  The rest of
the application (services, endpoints) depends **only** on this interface,
never on a concrete implementation.

Shipping with the stub
----------------------
:class:`StubFaceRecognitionEngine` is bundled so that the full API
surface (enroll, verify, identify) can be tested end-to-end without
a real AI model.  When a production model (InsightFace, DeepFace, …)
is ready, a new ``class InsightFaceEngine(FaceRecognitionEngine)``
is created and injected into :class:`FaceService` via dependency
inversion — no other code changes.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field

import numpy as np
from PIL import Image, ImageOps


@dataclass
class FaceDetection:
    """Result of a single face detection."""

    bbox: tuple[int, int, int, int] = (0, 0, 0, 0)
    confidence: float = 0.0
    landmarks: list[tuple[float, float]] = field(default_factory=list)


class FaceRecognitionEngine(ABC):
    """Abstract face recognition interface.

    Every concrete implementation must provide detection, embedding
    extraction, and comparison.
    """

    @abstractmethod
    def detect_face(self, image: Image.Image) -> FaceDetection | None:
        """Detect a face in the image.

        :param image: RGB PIL Image.
        :returns: A :class:`FaceDetection` if exactly one face is found,
            ``None`` otherwise.
        """

    @abstractmethod
    def extract_embedding(self, image: Image.Image) -> np.ndarray:
        """Extract a face embedding vector from the image.

        :param image: RGB PIL Image.
        :returns: A 512-element float32 numpy array.
        """

    @abstractmethod
    def compare(self, emb1: np.ndarray, emb2: np.ndarray) -> float:
        """Compute a similarity score between two embeddings.

        :param emb1: First embedding (512-d float32).
        :param emb2: Second embedding (512-d float32).
        :returns: Similarity in ``[0, 1]`` where 1 = identical.
        """


class StubFaceRecognitionEngine(FaceRecognitionEngine):
    """Stub implementation for development and testing.

    Produces a small perceptual embedding for local camera-flow testing. It is
    deliberately not a production biometric model, and production startup
    rejects it. Unlike a cryptographic image hash, the embedding tolerates
    modest lighting/compression changes between enrollment and identification.
    """

    _EMBEDDING_DIM = 512

    def __init__(self, seed: int = 42) -> None:
        self._seed = seed

    def detect_face(self, image: Image.Image) -> FaceDetection | None:
        _ = image
        return FaceDetection(bbox=(10, 10, 100, 100), confidence=0.95)

    def extract_embedding(self, image: Image.Image) -> np.ndarray:
        fitted = ImageOps.fit(
            ImageOps.exif_transpose(image).convert("RGB"),
            (16, 16),
            method=Image.Resampling.LANCZOS,
            centering=(0.5, 0.45),
        )
        rgb = np.asarray(fitted, dtype=np.float32)
        gray = np.asarray(fitted.convert("L"), dtype=np.float32)

        # Local contrast makes the descriptor less sensitive to exposure.
        standard_deviation = max(float(gray.std()), 1.0)
        luminance = np.clip((gray - float(gray.mean())) / (3.0 * standard_deviation), -1, 1)
        gradient_y, gradient_x = np.gradient(luminance)
        edges = np.sqrt((gradient_x * gradient_x) + (gradient_y * gradient_y))

        vector = np.concatenate((luminance.ravel(), edges.ravel())).astype(np.float32)
        # Preserve a tiny colour signature for otherwise textureless test/demo
        # frames without allowing global colour to dominate real images.
        vector[-3:] = (rgb.mean(axis=(0, 1)) - 127.5) / 127.5
        vector = np.roll(vector, self._seed % self._EMBEDDING_DIM)
        norm = np.linalg.norm(vector)
        return vector / norm if norm > 0 else vector

    def compare(self, emb1: np.ndarray, emb2: np.ndarray) -> float:
        dot = float(np.dot(emb1, emb2))
        norm = float(np.linalg.norm(emb1) * np.linalg.norm(emb2))
        return dot / norm if norm > 0 else 0.0
