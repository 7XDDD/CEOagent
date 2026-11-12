from datetime import datetime
from fnmatch import fnmatch

import bcrypt
from fastapi import Request
from sqlalchemy.orm import Session

from .models import AuditLog, Role, User


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode("utf-8"), hashed.encode("utf-8"))
    except Exception:
        return False


def get_current_user(request: Request, db: Session):
    user_id = request.session.get("user_id")
    if not user_id:
        return None
    return db.query(User).filter(User.id == user_id, User.deleted == 0).first()


def get_role(db: Session, user: User):
    if not user or not user.role_id:
        return None
    return db.query(Role).filter(Role.id == user.role_id, Role.deleted == 0).first()


def has_permission(db: Session, user: User, perm: str) -> bool:
    if not user:
        return False
    if user.username == "admin":
        return True
    role = get_role(db, user)
    if not role:
        return False
    raw = (role.permissions or "").replace(" ", "")
    perms = [p for p in raw.split(",") if p]
    for pattern in perms:
        if pattern == "*" or fnmatch(perm, pattern):
            return True
    return False


def audit(db: Session, user, action: str, entity: str, entity_id=None, detail: str = "", ip: str = ""):
    db.add(
        AuditLog(
            user_id=getattr(user, "id", None),
            username=getattr(user, "username", "system"),
            action=action,
            entity=entity,
            entity_id=entity_id,
            detail=detail[:2000] if detail else "",
            ip=ip,
            create_time=datetime.now(),
        )
    )
