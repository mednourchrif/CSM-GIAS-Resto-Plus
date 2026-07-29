# Face Engine Integration and Production Boundary

## Status

The repository contains a complete application boundary for enrollment,
verification, identification, template encryption, deletion, and kiosk
fallback. It does **not** contain an approved production biometric model.

`FACE_ENGINE=stub` is a deterministic image-fingerprint adapter for local
development and automated tests. It is not face recognition, does not perform
liveness detection, accepts every valid image as containing one face, and must
not be used to make a real identity decision. Production configuration rejects
this adapter.

`FACE_ENGINE=disabled` is the supported production-safe QR-only mode. Face
settings are reported as disabled and face operations fail closed with a safe
message. Any other engine name currently fails startup until its reviewed
adapter is installed.

## Existing boundary

The backend depends on `FaceRecognitionEngine` in
`03_Backend/app/ai/engine.py`. A production adapter must implement:

```python
def detect_face(image: PIL.Image.Image) -> FaceDetection | None: ...
def extract_embedding(image: PIL.Image.Image) -> numpy.ndarray: ...
def compare(emb1: numpy.ndarray, emb2: numpy.ndarray) -> float: ...
```

The current service contract expects:

- an RGB `PIL.Image`;
- exactly one acceptable face, expressed through `FaceDetection`;
- a 512-element `float32` embedding (2,048 bytes);
- a comparison score normalized to `[0, 1]`, where a larger value is a
  stronger match;
- deterministic behavior for the same model/version and preprocessing;
- exceptions translated to safe application errors, never raw model traces.

The adapter is selected only in `FaceService`. API routes, enrollment state,
template storage, kiosk grants, and meal registration do not depend on a
specific model. This is the intended replacement seam.

## Data and security boundaries

- Uploaded images are decoded in memory, validated as JPEG/PNG/WebP, limited
  to 5 MiB each and dimensions from 100×100 through 4096×4096. Raw images are
  not stored by the backend.
- New templates are encrypted with versioned Fernet authenticated encryption
  (`fernet:v1:`). Production face mode requires a dedicated
  `BIOMETRIC_ENCRYPTION_KEY`.
- Legacy plaintext 512-float templates remain readable to support migration.
  Their use emits a warning without a user identifier. Re-enrollment replaces
  them with encrypted templates.
- A malformed or undecryptable template fails safely. Template bytes are never
  returned by the API or written to application logs.
- Enrollment and deletion require an authenticated administrator. Kiosk
  verification and identification require the managed-tablet API key or an
  authenticated administrator.
- A match issues only a short-lived, one-use identification grant. It does not
  register a meal. Eligibility is checked again atomically when the meal is
  registered.
- Face deletion by user permanently erases all templates. Database backups and
  replicas require a matching retention/deletion policy before deployment.

The encryption key must live in the deployment secret manager, not in Git,
Flutter assets, APK resources, shell history, screenshots, or support logs.
Key rotation needs an explicit decrypt/re-encrypt migration; changing the key
without migration makes existing templates unreadable.

## Enrollment behavior

The mobile enrollment flow captures 3–5 images. The current multipart endpoint
validates and processes each capture sequentially; because every call
deactivates earlier templates, the **last valid capture is active**. The
endpoint does not currently calculate capture quality or fuse several
embeddings. Its old “best image” wording must not be used in a presentation.

A production adapter should change this deliberately:

1. Detect exactly one face and reject occlusion, blur, extreme pose, poor
   lighting, and replay media.
2. Compute a documented quality score for each capture.
3. Reject inconsistent captures before any template becomes active.
4. Select the best capture or create a reviewed aggregate template.
5. Store the actual model name/version, preprocessing version, and quality.
6. Keep the operation transactional and preserve at most the retention policy's
   required records.

## Production adapter checklist

1. Add a class implementing `FaceRecognitionEngine`; do not put vendor/model
   code in routes or repositories.
2. Pin model artifacts by cryptographic digest and license; record the model,
   runtime, and preprocessing versions.
3. Load the model once per worker during startup and fail readiness if loading
   or a self-test fails.
4. Make color conversion, crop/alignment, normalization, embedding dimension,
   and comparison metric explicit and covered by golden-vector tests.
5. Define separate behavior for no face, multiple faces, low quality, spoof
   suspected, no match, and internal failure.
6. Add bounded execution time and memory limits. Do not perform an unbounded
   linear scan as enrollment volume grows; use an evaluated index or a narrow
   eligible population without weakening authorization.
7. Add liveness/presentation-attack detection appropriate to the kiosk camera
   and threat model. A face detector alone is not liveness.
8. Configure a new `FACE_ENGINE` name and register it in the `FaceService`
   factory. Keep unknown names as startup failures.
9. Re-enroll legacy/stub templates. Stub embeddings are incompatible with a
   real model and must never be migrated as if they were biometric templates.
10. Complete privacy, legal basis/consent, retention, deletion, incident
    response, and operator-access reviews for the deployment jurisdiction.

## Evaluation gate

Do not choose the `0.75` development default by intuition. Create a
representative, consented evaluation set for the actual tablet, camera
position, lighting, demographics, accessories, and expected user population.
Keep enrollment and probe samples from the same person in separate sessions.

Measure at minimum:

- false acceptance rate (FAR) and false rejection rate (FRR);
- false-match and false-non-match distributions at candidate thresholds;
- failure-to-enroll and failure-to-acquire rates;
- results by relevant demographic and environmental cohorts;
- latency and memory on the physical tablet/backend hardware;
- printed-photo, screen replay, mask, camera substitution, and repeated-attempt
  attacks;
- behavior for twins/look-alikes, glasses, facial hair, head coverings, pose,
  motion blur, and changing illumination.

Select and document the threshold from the risk target and measured curves.
Test the threshold stored in `face_similarity_threshold`, and monitor drift
without logging templates or raw images. A production approval record should
identify the dataset, sample sizes, results, accepted residual risks, model
digest, chosen threshold, and approvers.

## Safe demonstration mode

For an internship demonstration:

- use QR as the reliable end-to-end identification path;
- if showing face UI, run only in a clearly labelled development environment
  and state that the bundled adapter is a deterministic prototype;
- do not enroll real biometric data into the stub environment;
- never describe the stub result as biometric accuracy, liveness, or identity
  assurance.

