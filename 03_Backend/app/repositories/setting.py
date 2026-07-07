from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.setting import Setting
from app.repositories.base import BaseRepository


class SettingRepository(BaseRepository[Setting]):
    def __init__(self) -> None:
        super().__init__(Setting)

    def get_by_key(self, db: Session, key: str) -> Setting | None:
        stmt = select(Setting).where(Setting.key == key)
        return db.execute(stmt).scalar_one_or_none()

    def get_grouped(self, db: Session) -> dict[str, list[Setting]]:
        stmt = select(Setting).order_by(Setting.category, Setting.order)
        settings = list(db.execute(stmt).scalars().all())
        grouped: dict[str, list[Setting]] = {}
        for s in settings:
            grouped.setdefault(s.category, []).append(s)
        return grouped

    def get_all_as_dict(self, db: Session) -> dict[str, str]:
        stmt = select(Setting.key, Setting.value).order_by(Setting.key)
        return dict(db.execute(stmt).all())

    def upsert(self, db: Session, key: str, value: str) -> Setting:
        instance = self.get_by_key(db, key)
        if instance:
            instance.value = value
            db.flush()
            db.refresh(instance)
            return instance
        return self.create(db, key=key, value=value, label=key, category="general")

    def reset_to_default(self, db: Session, key: str) -> Setting | None:
        instance = self.get_by_key(db, key)
        if instance:
            instance.value = instance.default_value
            db.flush()
            db.refresh(instance)
        return instance
