from fastapi import APIRouter

from app.api.v1 import (
    auth,
    employees,
    face,
    health,
    interns,
    meals,
    qr_codes,
    receptionists,
    stats,
    visitors,
)

router = APIRouter()
router.include_router(health.router, tags=["health"])
router.include_router(auth.router)
router.include_router(employees.router)
router.include_router(interns.router)
router.include_router(visitors.router)
router.include_router(receptionists.router)
router.include_router(qr_codes.router)
router.include_router(face.router)
router.include_router(meals.router)
router.include_router(stats.router)
