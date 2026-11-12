from datetime import date, datetime
from decimal import Decimal, InvalidOperation

from sqlalchemy import or_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .metadata import ENTITIES
from .models import (
    Company,
    Contract,
    Customer,
    Dict,
    Employee,
    Opportunity,
    Org,
    Position,
    Product,
    Project,
    Role,
)


SOURCE_MAP = {
    "company": (Company, "company_code", "company_shortname", "company_fullname"),
    "org": (Org, "org_code", "org_name", None),
    "position": (Position, "position_code", "position_name", None),
    "employee": (Employee, "job_number", "employee_name", None),
    "customer": (Customer, "customer_code", "customer_name", None),
    "project": (Project, "project_code", "project_name", None),
    "contract": (Contract, "contract_no", "contract_name", None),
    "opportunity": (Opportunity, "opportunity_no", "name", None),
    "product": (Product, "product_code", "product_name", None),
    "dict": (Dict, "dict_code", "dict_name", None),
    "role": (Role, "role_code", "role_name", None),
}


def get_entity(key: str):
    ent = ENTITIES.get(key)
    if not ent:
        raise KeyError(key)
    return ent


def _label(source, row):
    code_field, name_field, fallback = SOURCE_MAP[source][1:]
    code = getattr(row, code_field, None)
    name = getattr(row, name_field, None) or (getattr(row, fallback, None) if fallback else None)
    if code and name:
        return f"{code} · {name}"
    return name or code or f"#{row.id}"


def options_for_source(db: Session, source: str, limit: int = 1000):
    if source not in SOURCE_MAP:
        return []
    model = SOURCE_MAP[source][0]
    query = db.query(model)
    if hasattr(model, "deleted"):
        query = query.filter(model.deleted == 0)
    rows = query.order_by(model.id.asc()).limit(limit).all()
    return [{"value": str(row.id), "label": _label(source, row)} for row in rows]


def get_fk_maps(db: Session, ent, rows):
    maps = {}
    for field in ent["fields"]:
        source = field.get("source")
        if not source:
            continue
        model = SOURCE_MAP[source][0]
        query = db.query(model)
        if hasattr(model, "deleted"):
            query = query.filter(model.deleted == 0)
        maps[field["name"]] = {row.id: _label(source, row) for row in query.all()}
    return maps


def query_records(db: Session, ent, q="", page=1, page_size=20, parent_field=None, parent_id=None):
    model = ent["model"]
    query = db.query(model)
    if hasattr(model, "deleted"):
        query = query.filter(model.deleted == 0)
    if q:
        clauses = []
        for name in ent["search"]:
            col = getattr(model, name, None)
            if col is not None:
                clauses.append(col.ilike(f"%{q}%"))
        if clauses:
            query = query.filter(or_(*clauses))
    if parent_field and parent_id:
        col = getattr(model, parent_field, None)
        if col is not None:
            query = query.filter(col == int(parent_id))
    total = query.count()
    rows = query.order_by(model.id.desc()).offset((page - 1) * page_size).limit(page_size).all()
    pages = max(1, (total + page_size - 1) // page_size)
    return rows, total, pages


def get_record(db: Session, ent, record_id: int):
    model = ent["model"]
    query = db.query(model).filter(model.id == record_id)
    if hasattr(model, "deleted"):
        query = query.filter(model.deleted == 0)
    return query.first()


def _parse_value(field, raw):
    ftype = field["type"]
    if ftype == "checkbox":
        return str(raw).lower() in ("on", "1", "true", "yes")
    if raw is None:
        raw = ""
    raw = str(raw).strip()
    if raw == "":
        return None
    if ftype in ("number",):
        try:
            return int(float(raw))
        except ValueError:
            return None
    if ftype == "select" and field.get("value_type") == "int":
        try:
            return int(raw)
        except ValueError:
            return None
    if ftype in ("decimal",):
        try:
            return Decimal(raw)
        except InvalidOperation:
            return None
    if ftype == "date":
        try:
            return datetime.strptime(raw, "%Y-%m-%d").date()
        except ValueError:
            return None
    if ftype == "datetime":
        try:
            return datetime.fromisoformat(raw)
        except ValueError:
            return None
    return raw


def parse_form(ent, form):
    values = {}
    errors = []
    for field in ent["fields"]:
        if not field["form"]:
            continue
        name = field["name"]
        raw = form.get(name)
        value = _parse_value(field, raw)
        if field["required"] and field["type"] != "password" and (value is None or value == ""):
            errors.append(f"{field['label']}不能为空")
        values[name] = value
    return values, errors


def _assign(record, values):
    for key, value in values.items():
        if key == "password":
            continue
        if hasattr(record, key):
            setattr(record, key, value)


def create_record(db: Session, ent, values, username: str):
    model = ent["model"]
    record = model()
    _assign(record, values)
    if hasattr(record, "created_by"):
        record.created_by = username
        record.updated_by = username
    if hasattr(record, "company_id") and not getattr(record, "company_id", None):
        record.company_id = 1
    if ent["key"] == "user":
        from .auth import hash_password

        password = values.get("password") or "ChangeMe@2026"
        record.password_hash = hash_password(password)
        record.password_last_update_time = datetime.now()
    db.add(record)
    try:
        db.commit()
        db.refresh(record)
    except IntegrityError:
        db.rollback()
        raise ValueError("保存失败：编码或唯一键重复，请检查后重试")
    return record


def update_record(db: Session, ent, record, values, username: str):
    _assign(record, values)
    if hasattr(record, "updated_by"):
        record.updated_by = username
    if hasattr(record, "version"):
        record.version = (record.version or 0) + 1
    if ent["key"] == "user":
        from .auth import hash_password

        password = values.get("password")
        if password:
            record.password_hash = hash_password(password)
            record.password_last_update_time = datetime.now()
    try:
        db.commit()
        db.refresh(record)
    except IntegrityError:
        db.rollback()
        raise ValueError("保存失败：编码或唯一键重复，请检查后重试")
    return record


def soft_delete(db: Session, record):
    record.deleted = record.id
    db.commit()


def display_value(field, row, fk_maps):
    value = getattr(row, field["name"], None)
    if value is None:
        return ""
    if field.get("source"):
        return fk_maps.get(field["name"], {}).get(value, value)
    if isinstance(value, bool):
        return "是" if value else "否"
    if isinstance(value, (date, datetime)):
        return value.strftime("%Y-%m-%d")
    if isinstance(value, Decimal):
        return f"{value:,.2f}".rstrip("0").rstrip(".")
    return value
