import os
from datetime import date, datetime, timedelta
from pathlib import Path

from fastapi import Depends, FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy import func, or_
from sqlalchemy.orm import Session
from starlette.middleware.sessions import SessionMiddleware

from .auth import audit, get_current_user, get_role, has_permission, verify_password
from .finance import (
    BUDGET_CATEGORIES,
    BUDGET_CATEGORY_LABELS,
    BUDGET_TYPE_LABELS,
    COST_TYPES,
    COST_TYPE_LABELS,
    aging_summary,
    budget_rows,
    cashflow_forecast,
    contract_rows,
    contract_stats,
    customer_rows,
    customer_stats,
    milestone_rows,
    overview,
    project_rows,
    project_stats,
    sync_contract_finance_status,
    sync_project_cost,
)
from .crud import (
    create_record,
    display_value,
    get_entity,
    get_fk_maps,
    get_record,
    options_for_source,
    parse_form,
    query_records,
    soft_delete,
    update_record,
)
from .metadata import ENTITIES, OPP_STAGE_OPTS
from .models import (
    AuditLog,
    Company,
    Contract,
    ContractMilestone,
    ContractOpportunity,
    ContractProject,
    Customer,
    CustomerAddress,
    CustomerContact,
    CustomerFollower,
    Dict,
    DictItem,
    Employee,
    FinanceBudget,
    FinanceCost,
    IdMapping,
    Opportunity,
    OpportunityFollow,
    Org,
    Position,
    Product,
    Project,
    ProjectMember,
    ProjectMemberPeriod,
    Role,
    SessionLocal,
    TaxRate,
    User,
    init_db,
)
from .seed import ensure_finance_permissions, seed, seed_finance

BASE_DIR = Path(__file__).resolve().parent

app = FastAPI(title="链宇 · 大一统平台 · 主数据", version="1.0.0")
app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))


def fmt(value):
    if value is None:
        return ""
    if isinstance(value, bool):
        return "是" if value else "否"
    return value


templates.env.filters["fmt"] = fmt
templates.env.globals["now"] = datetime.now


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.middleware("http")
async def auth_middleware(request: Request, call_next):
    path = request.url.path
    public = path.startswith("/static") or path in ("/login", "/health", "/favicon.ico")
    if not public and not request.session.get("user_id"):
        return RedirectResponse(f"/login?next={path}", status_code=302)
    return await call_next(request)


app.add_middleware(
    SessionMiddleware,
    secret_key=os.getenv("SECRET_KEY", "unified-mdm-dev-secret-change-me"),
    max_age=8 * 3600,
    same_site="lax",
)


@app.on_event("startup")
def startup():
    init_db()
    seed()
    ensure_finance_permissions()
    seed_finance()


def page_ctx(request: Request, db: Session, **kwargs):
    user = get_current_user(request, db)
    role = get_role(db, user)
    return {
        "request": request,
        "current_user": user,
        "current_role": role,
        "app_name": "链宇 · 大一统平台",
        **kwargs,
    }


def require_perm(db, request, perm):
    user = get_current_user(request, db)
    if not has_permission(db, user, perm):
        return False
    return True


def enrich_values(db: Session, values: dict):
    """补齐常用名称快照，避免用户重复录入。"""
    def fill(id_key, name_key, model):
        raw = values.get(id_key)
        if not raw or values.get(name_key):
            return
        try:
            row = db.get(model, int(raw))
        except (TypeError, ValueError):
            row = None
        if row:
            if model is Customer:
                values[name_key] = row.customer_name
            elif model is Employee:
                values[name_key] = row.employee_name
            elif model is Product:
                values[name_key] = row.product_name
            elif model is Opportunity:
                values[name_key] = row.name

    fill("customer_id", "customer_name", Customer)
    fill("product_id", "product_name", Product)
    fill("opportunity_id", "opportunity_name", Opportunity)
    for id_key, name_key in [
        ("owner_id", "owner_name"),
        ("sales_person_id", "sales_person_name"),
        ("sales_manager_id", "sales_manager_name"),
        ("sales_id", "sales_name"),
        ("manager_id", "manager_name"),
        ("pm_id", "pm_name"),
        ("employee_id", "employee_name"),
        ("follower_id", "follower_name"),
    ]:
        fill(id_key, name_key, Employee)
    return values


def render_error(request: Request, db: Session, message: str, status_code: int = 400):
    return templates.TemplateResponse(
        request=request,
        name="error.html",
        context=page_ctx(request, db, message=message, status_code=status_code),
        status_code=status_code,
    )


@app.get("/health")
def health():
    try:
        db = SessionLocal()
        db.query(User).first()
        db.close()
        return JSONResponse({"status": "ok", "app": "unified-mdm", "time": datetime.now().isoformat()})
    except Exception as exc:
        return JSONResponse({"status": "error", "detail": str(exc)}, status_code=500)


@app.get("/login", response_class=HTMLResponse)
def login_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="login.html",
        context={"request": request, "error": "", "next": request.query_params.get("next", "/mdm")},
    )


@app.post("/login", response_class=HTMLResponse)
async def login(request: Request, db: Session = Depends(get_db)):
    form = await request.form()
    username = (form.get("username") or "").strip()
    password = form.get("password") or ""
    next_url = form.get("next") or "/mdm"
    user = db.query(User).filter(User.username == username, User.deleted == 0).first()
    if not user or not verify_password(password, user.password_hash):
        return templates.TemplateResponse(
            request=request,
            name="login.html",
            context={"request": request, "error": "账号或密码错误", "next": next_url},
            status_code=401,
        )
    if user.status != 1:
        return templates.TemplateResponse(
            request=request,
            name="login.html",
            context={"request": request, "error": "账号已停用，请联系管理员", "next": next_url},
            status_code=403,
        )
    request.session["user_id"] = user.id
    user.last_login_time = datetime.now()
    user.last_login_ip = request.client.host if request.client else ""
    audit(db, user, "LOGIN", "user", user.id, "登录系统", user.last_login_ip)
    db.commit()
    return RedirectResponse(next_url if next_url.startswith("/") else "/mdm", status_code=302)


@app.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login", status_code=302)


@app.get("/", response_class=HTMLResponse)
@app.get("/mdm", response_class=HTMLResponse)
@app.get("/mdm/", response_class=HTMLResponse)
def dashboard(request: Request, db: Session = Depends(get_db)):
    if not require_perm(db, request, "md.org.view"):
        return render_error(request, db, "没有访问工作台的权限", 403)
    counts = {
        "company": db.query(Company).filter(Company.deleted == 0).count(),
        "org": db.query(Org).filter(Org.deleted == 0).count(),
        "position": db.query(Position).filter(Position.deleted == 0).count(),
        "employee": db.query(Employee).filter(Employee.deleted == 0).count(),
        "customer": db.query(Customer).filter(Customer.deleted == 0).count(),
        "project": db.query(Project).filter(Project.deleted == 0).count(),
        "contract": db.query(Contract).filter(Contract.deleted == 0).count(),
        "product": db.query(Product).filter(Product.deleted == 0).count(),
        "tax_rate": db.query(TaxRate).filter(TaxRate.deleted == 0).count(),
    }
    dq = [
        {
            "label": "客户名称重复",
            "value": db.query(Customer.customer_name)
            .filter(Customer.deleted == 0)
            .group_by(Customer.customer_name)
            .having(func.count(Customer.id) > 1)
            .count(),
            "hint": "建议合并重复客户",
        },
        {
            "label": "合同未关联客户",
            "value": db.query(Contract)
            .filter(Contract.deleted == 0, or_(Contract.customer_id.is_(None), Contract.customer_id == 0))
            .count(),
            "hint": "合同必须挂客户",
        },
        {
            "label": "项目未指定项目经理",
            "value": db.query(Project)
            .filter(Project.deleted == 0, or_(Project.pm_id.is_(None), Project.pm_id == 0))
            .count(),
            "hint": "项目必须有 PM",
        },
        {
            "label": "员工未归属组织",
            "value": db.query(Employee)
            .filter(Employee.deleted == 0, or_(Employee.org_id.is_(None), Employee.org_id == 0))
            .count(),
            "hint": "员工必须挂组织",
        },
        {
            "label": "客户缺少统一社会信用代码",
            "value": db.query(Customer)
            .filter(
                Customer.deleted == 0,
                or_(Customer.unified_social_credit.is_(None), Customer.unified_social_credit == ""),
            )
            .count(),
            "hint": "财税信息不完整",
        },
        {
            "label": "合同金额为零",
            "value": db.query(Contract)
            .filter(Contract.deleted == 0, or_(Contract.contract_amount.is_(None), Contract.contract_amount == 0))
            .count(),
            "hint": "检查合同金额是否录入",
        },
    ]
    logs = db.query(AuditLog).order_by(AuditLog.id.desc()).limit(8).all()
    return templates.TemplateResponse(
        request=request,
        name="dashboard.html",
        context=page_ctx(request, db, counts=counts, dq=dq, logs=logs),
    )


@app.get("/org/tree", response_class=HTMLResponse)
def org_tree(request: Request, db: Session = Depends(get_db)):
    if not require_perm(db, request, "md.org.view"):
        return render_error(request, db, "没有访问组织架构的权限", 403)
    orgs = db.query(Org).filter(Org.deleted == 0).order_by(Org.sort_order.asc(), Org.id.asc()).all()
    children = {}
    for org in orgs:
        children.setdefault(org.parent_id or 0, []).append(org)
    roots = children.get(0, []) + [o for o in orgs if o.parent_id and o.parent_id not in {x.id for x in orgs}]
    return templates.TemplateResponse(
        request=request,
        name="org_tree.html",
        context=page_ctx(request, db, orgs=orgs, children=children, roots=roots),
    )


@app.get("/audit", response_class=HTMLResponse)
def audit_page(request: Request, db: Session = Depends(get_db), page: int = 1):
    if not require_perm(db, request, "sys.audit.view"):
        return render_error(request, db, "只有管理员可以查看审计日志", 403)
    page = max(1, page)
    page_size = 30
    total = db.query(AuditLog).count()
    logs = (
        db.query(AuditLog)
        .order_by(AuditLog.id.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )
    pages = max(1, (total + page_size - 1) // page_size)
    return templates.TemplateResponse(
        request=request,
        name="audit.html",
        context=page_ctx(request, db, logs=logs, page=page, pages=pages, total=total),
    )


@app.get("/crm", response_class=HTMLResponse)
def crm_dashboard(request: Request, db: Session = Depends(get_db)):
    if not require_perm(db, request, "crm.dashboard.view"):
        return render_error(request, db, "没有访问 CRM 看板的权限", 403)
    today = date.today()
    soon = today + timedelta(days=30)
    pipeline_total = (
        db.query(func.coalesce(func.sum(Opportunity.amount), 0))
        .filter(Opportunity.deleted == 0, Opportunity.status == "IN_PROGRESS")
        .scalar()
        or 0
    )
    won_total = (
        db.query(func.coalesce(func.sum(Opportunity.amount), 0))
        .filter(Opportunity.deleted == 0, Opportunity.status == "WON")
        .scalar()
        or 0
    )
    signed_total = (
        db.query(func.coalesce(func.sum(Contract.contract_amount), 0))
        .filter(Contract.deleted == 0, Contract.sign_status == "SIGNED")
        .scalar()
        or 0
    )

    milestones = db.query(ContractMilestone).filter(ContractMilestone.deleted == 0).all()
    outstanding_total = 0.0
    overdue_total = 0.0
    overdue_count = 0
    for m in milestones:
        amount = float(m.milestone_amount or 0)
        paid = float(m.paid_amount or m.actual_payment_amount or 0)
        left = max(amount - paid, 0)
        outstanding_total += left
        if left > 0 and m.expected_payment_date and m.expected_payment_date < today:
            overdue_total += left
            overdue_count += 1

    funnel = []
    for stage in OPP_STAGE_OPTS:
        count = (
            db.query(Opportunity)
            .filter(Opportunity.deleted == 0, Opportunity.stage == stage["value"])
            .count()
        )
        amount = (
            db.query(func.coalesce(func.sum(Opportunity.amount), 0))
            .filter(Opportunity.deleted == 0, Opportunity.stage == stage["value"])
            .scalar()
            or 0
        )
        funnel.append({"code": stage["value"], "label": stage["label"], "count": count, "amount": amount})

    recent_opps = (
        db.query(Opportunity)
        .filter(Opportunity.deleted == 0)
        .order_by(Opportunity.id.desc())
        .limit(8)
        .all()
    )
    upcoming = (
        db.query(ContractMilestone, Contract)
        .join(Contract, Contract.id == ContractMilestone.contract_id)
        .filter(
            ContractMilestone.deleted == 0,
            Contract.deleted == 0,
            ContractMilestone.payment_status != "PAID",
            ContractMilestone.expected_payment_date.isnot(None),
            ContractMilestone.expected_payment_date <= soon,
        )
        .order_by(ContractMilestone.expected_payment_date.asc())
        .limit(8)
        .all()
    )
    counts = {
        "customer": db.query(Customer).filter(Customer.deleted == 0).count(),
        "opportunity": db.query(Opportunity).filter(Opportunity.deleted == 0).count(),
        "contract": db.query(Contract).filter(Contract.deleted == 0).count(),
        "overdue": overdue_count,
    }
    return templates.TemplateResponse(
        request=request,
        name="crm_dashboard.html",
        context=page_ctx(
            request,
            db,
            counts=counts,
            pipeline_total=pipeline_total,
            won_total=won_total,
            signed_total=signed_total,
            outstanding_total=outstanding_total,
            overdue_total=overdue_total,
            funnel=funnel,
            recent_opps=recent_opps,
            upcoming=upcoming,
            today=today,
        ),
    )


@app.get("/crm/payment", response_class=HTMLResponse)
def crm_payment(request: Request, db: Session = Depends(get_db), q: str = "", status: str = ""):
    if not require_perm(db, request, "crm.payment.view"):
        return render_error(request, db, "没有访问回款视图的权限", 403)
    today = date.today()
    query = (
        db.query(ContractMilestone, Contract)
        .join(Contract, Contract.id == ContractMilestone.contract_id)
        .filter(ContractMilestone.deleted == 0, Contract.deleted == 0)
    )
    if q:
        query = query.filter(
            or_(
                Contract.contract_no.ilike(f"%{q}%"),
                Contract.contract_name.ilike(f"%{q}%"),
                Contract.customer_name.ilike(f"%{q}%"),
            )
        )
    rows = query.order_by(ContractMilestone.expected_payment_date.asc(), ContractMilestone.id.asc()).all()
    items = []
    totals = {"contract": 0.0, "invoiced": 0.0, "paid": 0.0, "outstanding": 0.0, "overdue": 0.0}
    seen_contracts = set()
    for m, c in rows:
        amount = float(m.milestone_amount or 0)
        paid = float(m.paid_amount or m.actual_payment_amount or 0)
        invoiced = float(m.invoiced_amount or 0)
        outstanding = max(amount - paid, 0)
        if amount > 0 and paid >= amount:
            computed = "PAID"
        elif paid > 0:
            computed = "PARTIAL"
        elif m.expected_payment_date and m.expected_payment_date < today:
            computed = "OVERDUE"
        else:
            computed = "UNPAID"
        if status and computed != status:
            continue
        if c.id not in seen_contracts:
            totals["contract"] += float(c.contract_amount or 0)
            seen_contracts.add(c.id)
        totals["invoiced"] += invoiced
        totals["paid"] += paid
        totals["outstanding"] += outstanding
        if computed == "OVERDUE":
            totals["overdue"] += outstanding
        items.append(
            {
                "milestone": m,
                "contract": c,
                "amount": amount,
                "paid": paid,
                "invoiced": invoiced,
                "outstanding": outstanding,
                "status": computed,
                "overdue": computed == "OVERDUE",
            }
        )
    return templates.TemplateResponse(
        request=request,
        name="crm_payment.html",
        context=page_ctx(
            request,
            db,
            items=items,
            totals=totals,
            q=q,
            status=status,
            today=today,
        ),
    )


@app.post("/crm/opportunity/{opportunity_id}/convert")
def crm_convert_opportunity(request: Request, opportunity_id: int, db: Session = Depends(get_db)):
    if not require_perm(db, request, "md.opportunity.edit"):
        return render_error(request, db, "没有商机转合同的权限", 403)
    opp = db.query(Opportunity).filter(Opportunity.id == opportunity_id, Opportunity.deleted == 0).first()
    if not opp:
        return render_error(request, db, "商机不存在或已删除", 404)
    existing = (
        db.query(ContractOpportunity)
        .filter(
            ContractOpportunity.opportunity_id == opp.id,
            ContractOpportunity.deleted == 0,
        )
        .first()
    )
    if existing:
        return RedirectResponse(f"/detail/contract/{existing.contract_id}", status_code=302)
    base_no = f"HT{datetime.now().strftime('%Y%m%d')}{opp.id:03d}"
    contract_no = base_no
    suffix = 1
    while (
        db.query(Contract)
        .filter(
            Contract.company_id == opp.company_id,
            Contract.contract_no == contract_no,
            Contract.deleted == 0,
        )
        .first()
    ):
        suffix += 1
        contract_no = f"{base_no}-{suffix}"
    contract = Contract(
        company_id=opp.company_id or 1,
        contract_no=contract_no,
        sub_contract_no="",
        contract_name=opp.name if opp.name.endswith("合同") else f"{opp.name}合同",
        contract_type_code="CONSULTING",
        contract_type_name="咨询服务",
        contract_category="SALES",
        customer_id=opp.customer_id,
        customer_name=opp.customer_name,
        org_id=None,
        org_code=None,
        org_name=None,
        manager_id=opp.owner_id,
        manager_name=opp.owner_name,
        sales_manager_id=opp.sales_person_id,
        sales_manager_name=opp.sales_person_name,
        owner_id=opp.owner_id,
        owner_name=opp.owner_name,
        contract_amount=opp.amount or 0,
        currency="CNY",
        exchange_rate=1,
        tax_rate=0,
        tax_amount=0,
        amount_excl_tax=opp.amount or 0,
        amount_incl_tax=opp.amount or 0,
        approval_status="DRAFT",
        sign_status="UNSIGNED",
        execution_status="NOT_STARTED",
        invoice_status="NOT_STARTED",
        payment_status="UNPAID",
        contract_version_no="V1.0",
        data_status="ACTIVE",
        source_type="CRM",
        remark=f"由商机 {opp.opportunity_no} 转入",
    )
    db.add(contract)
    db.flush()
    db.add(
        ContractOpportunity(
            company_id=contract.company_id,
            contract_id=contract.id,
            opportunity_id=opp.id,
        )
    )
    opp.stage = "STAGE_06"
    opp.stage_rate = 90
    opp.status = "IN_PROGRESS"
    user = get_current_user(request, db)
    audit(
        db,
        user,
        "CONVERT",
        "opportunity",
        opp.id,
        f"商机 {opp.opportunity_no} 转合同 {contract.contract_no}",
        request.client.host if request.client else "",
    )
    db.commit()
    return RedirectResponse(f"/detail/contract/{contract.id}", status_code=302)


@app.get("/fin", response_class=HTMLResponse)
def fin_dashboard(request: Request, db: Session = Depends(get_db)):
    if not require_perm(db, request, "fin.dashboard.view"):
        return render_error(request, db, "没有访问财务中心的权限", 403)
    data = overview(db)
    return templates.TemplateResponse(
        request=request,
        name="finance_dashboard.html",
        context=page_ctx(request, db, data=data, today=date.today()),
    )


@app.get("/fin/projects", response_class=HTMLResponse)
def fin_projects(
    request: Request,
    db: Session = Depends(get_db),
    q: str = "",
    risk: str = "",
):
    if not require_perm(db, request, "fin.project.view"):
        return render_error(request, db, "没有访问项目损益的权限", 403)
    rows = project_rows(db, q=q, risk=risk)
    totals = {
        "contract": sum(x["contract_amount"] for x in rows),
        "revenue": sum(x["revenue"] for x in rows),
        "cost": sum(x["total_cost"] for x in rows),
        "gross_profit": sum(x["gross_profit"] for x in rows),
        "loss": len([x for x in rows if x["gross_profit"] < 0 and x["revenue"] > 0]),
        "over_budget": len([x for x in rows if x["budget_usage"] is not None and x["budget_usage"] > 1]),
    }
    return templates.TemplateResponse(
        request=request,
        name="finance_projects.html",
        context=page_ctx(
            request,
            db,
            rows=rows,
            totals=totals,
            q=q,
            risk=risk,
            message=request.query_params.get("message", ""),
        ),
    )


@app.get("/fin/projects/{project_id}", response_class=HTMLResponse)
def fin_project_detail(request: Request, project_id: int, db: Session = Depends(get_db)):
    if not require_perm(db, request, "fin.project.view"):
        return render_error(request, db, "没有访问项目损益的权限", 403)
    project = db.query(Project).filter(Project.id == project_id, Project.deleted == 0).first()
    if not project:
        return render_error(request, db, "项目不存在或已删除", 404)
    stats = project_stats(db, project)
    costs = sorted(
        stats["costs"],
        key=lambda x: (x.cost_date or date.min, x.id),
        reverse=True,
    )
    monthly = {}
    for link in stats["contracts"]:
        for m in link["milestones"]:
            if float(m.invoiced_amount or 0) > 0:
                key = (m.actual_date or m.plan_date)
                if key:
                    key = key.strftime("%Y-%m")
                    monthly.setdefault(key, {"revenue": 0.0, "cost": 0.0})
                    monthly[key]["revenue"] += float(m.invoiced_amount or 0)
    for cost in costs:
        if cost.cost_date:
            key = cost.cost_date.strftime("%Y-%m")
            monthly.setdefault(key, {"revenue": 0.0, "cost": 0.0})
            monthly[key]["cost"] += float(cost.amount or 0)
    monthly_rows = [
        {"month": key, **value, "gross_profit": value["revenue"] - value["cost"]}
        for key, value in sorted(monthly.items())
    ]
    return templates.TemplateResponse(
        request=request,
        name="finance_project_detail.html",
        context=page_ctx(
            request,
            db,
            project=project,
            stats=stats,
            costs=costs,
            monthly=monthly_rows,
            can_edit=require_perm(db, request, "fin.cost.edit"),
            message=request.query_params.get("message", ""),
        ),
    )


@app.get("/fin/receivables", response_class=HTMLResponse)
def fin_receivables(
    request: Request,
    db: Session = Depends(get_db),
    q: str = "",
    status: str = "",
):
    if not require_perm(db, request, "fin.receivable.view"):
        return render_error(request, db, "没有访问应收与回款的权限", 403)
    contracts = contract_rows(db, q=q, status=status)
    milestones = milestone_rows(db, q=q, status=status)
    totals = {
        "contract": sum(x["contract_amount"] for x in contracts),
        "invoiced": sum(x["invoiced"] for x in contracts),
        "paid": sum(x["paid"] for x in contracts),
        "outstanding": sum(x["outstanding"] for x in contracts),
        "overdue": sum(x["overdue"] for x in contracts),
        "unbilled": sum(x["unbilled"] for x in contracts),
    }
    return templates.TemplateResponse(
        request=request,
        name="finance_receivables.html",
        context=page_ctx(
            request,
            db,
            contracts=contracts,
            milestones=milestones,
            totals=totals,
            aging=aging_summary(db),
            q=q,
            status=status,
            today=date.today(),
            can_edit=require_perm(db, request, "fin.receivable.edit"),
        ),
    )


@app.get("/fin/milestones/{milestone_id}", response_class=HTMLResponse)
def fin_milestone_detail(request: Request, milestone_id: int, db: Session = Depends(get_db)):
    if not require_perm(db, request, "fin.receivable.view"):
        return render_error(request, db, "没有访问应收与回款的权限", 403)
    milestone = (
        db.query(ContractMilestone)
        .filter(ContractMilestone.id == milestone_id, ContractMilestone.deleted == 0)
        .first()
    )
    if not milestone:
        return render_error(request, db, "里程碑不存在或已删除", 404)
    contract = db.query(Contract).filter(Contract.id == milestone.contract_id, Contract.deleted == 0).first()
    amount = float(milestone.milestone_amount or 0)
    invoiced = float(milestone.invoiced_amount or 0)
    paid = float(milestone.paid_amount or milestone.actual_payment_amount or 0)
    return templates.TemplateResponse(
        request=request,
        name="finance_milestone.html",
        context=page_ctx(
            request,
            db,
            milestone=milestone,
            contract=contract,
            amount=amount,
            invoiced=invoiced,
            paid=paid,
            outstanding=max(invoiced - paid, 0),
            unbilled=max(amount - invoiced, 0),
            can_edit=require_perm(db, request, "fin.receivable.edit"),
            message=request.query_params.get("message", ""),
        ),
    )


@app.post("/fin/milestones/{milestone_id}/invoice")
async def fin_milestone_invoice(
    request: Request, milestone_id: int, db: Session = Depends(get_db)
):
    if not require_perm(db, request, "fin.receivable.edit"):
        return render_error(request, db, "没有登记开票的权限", 403)
    milestone = (
        db.query(ContractMilestone)
        .filter(ContractMilestone.id == milestone_id, ContractMilestone.deleted == 0)
        .first()
    )
    if not milestone:
        return render_error(request, db, "里程碑不存在或已删除", 404)
    form = await request.form()
    try:
        amount = float(form.get("amount") or 0)
    except ValueError:
        amount = 0
    if amount <= 0:
        return render_error(request, db, "开票金额必须大于 0", 400)
    total = float(milestone.milestone_amount or 0)
    current = float(milestone.invoiced_amount or 0)
    if current + amount > total + 0.01:
        return render_error(request, db, "开票金额不能超过里程碑未开票金额", 400)
    try:
        invoice_date = date.fromisoformat(str(form.get("invoice_date") or ""))
    except ValueError:
        invoice_date = date.today()
    milestone.invoiced_amount = current + amount
    milestone.actual_date = invoice_date
    milestone.actual_invoice_year = invoice_date.year
    milestone.actual_month = invoice_date.month
    milestone.invoice_status = "INVOICED" if float(milestone.invoiced_amount) >= total else "PARTIAL"
    sync_contract_finance_status(db, milestone.contract_id)
    user = get_current_user(request, db)
    audit(
        db,
        user,
        "INVOICE",
        "contract_milestone",
        milestone.id,
        f"登记开票 {amount:,.2f}，里程碑 {milestone.milestone_name}",
        request.client.host if request.client else "",
    )
    db.commit()
    return RedirectResponse(f"/fin/milestones/{milestone.id}?message=开票已登记", status_code=302)


@app.post("/fin/milestones/{milestone_id}/receipt")
async def fin_milestone_receipt(
    request: Request, milestone_id: int, db: Session = Depends(get_db)
):
    if not require_perm(db, request, "fin.receivable.edit"):
        return render_error(request, db, "没有登记回款的权限", 403)
    milestone = (
        db.query(ContractMilestone)
        .filter(ContractMilestone.id == milestone_id, ContractMilestone.deleted == 0)
        .first()
    )
    if not milestone:
        return render_error(request, db, "里程碑不存在或已删除", 404)
    form = await request.form()
    try:
        amount = float(form.get("amount") or 0)
    except ValueError:
        amount = 0
    if amount <= 0:
        return render_error(request, db, "回款金额必须大于 0", 400)
    total = float(milestone.milestone_amount or 0)
    current = float(milestone.paid_amount or milestone.actual_payment_amount or 0)
    if current + amount > total + 0.01:
        return render_error(request, db, "回款金额不能超过里程碑未回款金额", 400)
    try:
        receipt_date = date.fromisoformat(str(form.get("receipt_date") or ""))
    except ValueError:
        receipt_date = date.today()
    milestone.paid_amount = current + amount
    milestone.actual_payment_amount = current + amount
    milestone.actual_payment_date = receipt_date
    milestone.payment_status = "PAID" if float(milestone.paid_amount) >= total else "PARTIAL"
    sync_contract_finance_status(db, milestone.contract_id)
    user = get_current_user(request, db)
    audit(
        db,
        user,
        "RECEIPT",
        "contract_milestone",
        milestone.id,
        f"登记回款 {amount:,.2f}，里程碑 {milestone.milestone_name}",
        request.client.host if request.client else "",
    )
    db.commit()
    return RedirectResponse(f"/fin/milestones/{milestone.id}?message=回款已登记", status_code=302)


@app.get("/fin/customers", response_class=HTMLResponse)
def fin_customers(request: Request, db: Session = Depends(get_db), q: str = ""):
    if not require_perm(db, request, "fin.customer.view"):
        return render_error(request, db, "没有访问客户盈利的权限", 403)
    rows = customer_rows(db, q=q)
    totals = {
        "revenue": sum(x["invoiced"] for x in rows),
        "cost": sum(x["total_cost"] for x in rows),
        "gross_profit": sum(x["gross_profit"] for x in rows),
        "outstanding": sum(x["outstanding"] for x in rows),
        "overdue": sum(x["overdue"] for x in rows),
    }
    return templates.TemplateResponse(
        request=request,
        name="finance_customers.html",
        context=page_ctx(request, db, rows=rows, totals=totals, q=q),
    )


@app.get("/fin/cashflow", response_class=HTMLResponse)
def fin_cashflow(request: Request, db: Session = Depends(get_db)):
    if not require_perm(db, request, "fin.cashflow.view"):
        return render_error(request, db, "没有访问现金流预测的权限", 403)
    data = cashflow_forecast(db)
    return templates.TemplateResponse(
        request=request,
        name="finance_cashflow.html",
        context=page_ctx(request, db, data=data, today=date.today()),
    )


@app.get("/fin/budget", response_class=HTMLResponse)
def fin_budget(request: Request, db: Session = Depends(get_db), year: int = 0):
    if not require_perm(db, request, "fin.budget.view"):
        return render_error(request, db, "没有访问预算达成的权限", 403)
    rows, year = budget_rows(db, year or date.today().year)
    totals = {x["value"]: {"budget": 0.0, "actual": 0.0} for x in BUDGET_CATEGORIES}
    for row in rows:
        category = row["budget"].category
        if category not in totals:
            continue
        totals[category]["budget"] += row["budget_amount"]
        totals[category]["actual"] += row["actual"]
    years = [
        x[0]
        for x in db.query(FinanceBudget.budget_year)
        .filter(FinanceBudget.deleted == 0)
        .distinct()
        .order_by(FinanceBudget.budget_year.desc())
        .all()
    ]
    if year not in years:
        years.insert(0, year)
    return templates.TemplateResponse(
        request=request,
        name="finance_budget.html",
        context=page_ctx(
            request,
            db,
            rows=rows,
            totals=totals,
            year=year,
            years=years,
            categories=BUDGET_CATEGORIES,
            category_labels=BUDGET_CATEGORY_LABELS,
            type_labels=BUDGET_TYPE_LABELS,
            projects=db.query(Project).filter(Project.deleted == 0).order_by(Project.id.asc()).all(),
            orgs=db.query(Org).filter(Org.deleted == 0).order_by(Org.id.asc()).all(),
            can_edit=require_perm(db, request, "fin.budget.edit"),
            message=request.query_params.get("message", ""),
        ),
    )


@app.post("/fin/budget")
async def fin_budget_create(request: Request, db: Session = Depends(get_db)):
    if not require_perm(db, request, "fin.budget.edit"):
        return render_error(request, db, "没有维护预算的权限", 403)
    form = await request.form()
    try:
        year = int(form.get("budget_year") or date.today().year)
    except ValueError:
        year = date.today().year
    budget_type = str(form.get("budget_type") or "COMPANY")
    category = str(form.get("category") or "")
    if category not in BUDGET_CATEGORY_LABELS:
        return render_error(request, db, "请选择有效的预算科目", 400)
    try:
        amount = float(form.get("budget_amount") or 0)
    except ValueError:
        amount = 0
    if amount <= 0:
        return render_error(request, db, "预算金额必须大于 0", 400)
    project = None
    org = None
    if budget_type == "PROJECT":
        try:
            project_id = int(form.get("project_id") or 0)
        except ValueError:
            project_id = 0
        project = db.query(Project).filter(Project.id == project_id, Project.deleted == 0).first()
        if not project:
            return render_error(request, db, "项目预算必须选择项目", 400)
    elif budget_type == "ORG":
        try:
            org_id = int(form.get("org_id") or 0)
        except ValueError:
            org_id = 0
        org = db.query(Org).filter(Org.id == org_id, Org.deleted == 0).first()
        if not org:
            return render_error(request, db, "组织预算必须选择组织", 400)
    elif budget_type != "COMPANY":
        budget_type = "COMPANY"
    budget = FinanceBudget(
        company_id=1,
        budget_year=year,
        budget_type=budget_type,
        project_id=project.id if project else None,
        project_code=project.project_code if project else None,
        project_name=project.project_name if project else None,
        org_id=org.id if org else None,
        org_name=org.org_name if org else None,
        customer_id=project.customer_id if project else None,
        customer_name=project.customer_name if project else None,
        category=category,
        budget_amount=amount,
        version="V1.0",
        status="APPROVED",
        remark=str(form.get("remark") or ""),
    )
    db.add(budget)
    db.flush()
    user = get_current_user(request, db)
    audit(
        db,
        user,
        "CREATE",
        "finance_budget",
        budget.id,
        f"新增 {year} 年预算 {BUDGET_CATEGORY_LABELS.get(category)} {amount:,.2f}",
        request.client.host if request.client else "",
    )
    db.commit()
    return RedirectResponse(f"/fin/budget?year={year}&message=预算已保存", status_code=302)


@app.post("/fin/budget/{budget_id}/delete")
def fin_budget_delete(request: Request, budget_id: int, db: Session = Depends(get_db)):
    if not require_perm(db, request, "fin.budget.edit"):
        return render_error(request, db, "没有维护预算的权限", 403)
    budget = db.query(FinanceBudget).filter(FinanceBudget.id == budget_id, FinanceBudget.deleted == 0).first()
    if not budget:
        return render_error(request, db, "预算记录不存在或已删除", 404)
    user = get_current_user(request, db)
    budget.deleted = 1
    budget.updated_by = user.username if user else "system"
    audit(
        db,
        user,
        "DELETE",
        "finance_budget",
        budget.id,
        "删除预算记录",
        request.client.host if request.client else "",
    )
    db.commit()
    return RedirectResponse(f"/fin/budget?year={budget.budget_year}&message=预算已删除", status_code=302)


@app.get("/fin/costs", response_class=HTMLResponse)
def fin_costs(
    request: Request,
    db: Session = Depends(get_db),
    q: str = "",
    project_id: int = 0,
    cost_type: str = "",
):
    if not require_perm(db, request, "fin.cost.view"):
        return render_error(request, db, "没有访问成本录入的权限", 403)
    query = db.query(FinanceCost).filter(FinanceCost.deleted == 0)
    if project_id:
        query = query.filter(FinanceCost.project_id == project_id)
    if cost_type:
        query = query.filter(FinanceCost.cost_type == cost_type)
    if q:
        like = f"%{q}%"
        query = query.filter(
            (FinanceCost.project_name.ilike(like))
            | (FinanceCost.project_code.ilike(like))
            | (FinanceCost.supplier_name.ilike(like))
            | (FinanceCost.employee_name.ilike(like))
            | (FinanceCost.remark.ilike(like))
        )
    costs = query.order_by(FinanceCost.cost_date.desc(), FinanceCost.id.desc()).all()
    projects = db.query(Project).filter(Project.deleted == 0).order_by(Project.id.asc()).all()
    employees = db.query(Employee).filter(Employee.deleted == 0).order_by(Employee.id.asc()).all()
    totals = {
        "all": sum(float(x.amount or 0) for x in costs),
        "labor": sum(float(x.amount or 0) for x in costs if x.cost_type == "LABOR"),
        "expense": sum(float(x.amount or 0) for x in costs if x.cost_type == "EXPENSE"),
        "subcontract": sum(float(x.amount or 0) for x in costs if x.cost_type == "SUBCONTRACT"),
    }
    return templates.TemplateResponse(
        request=request,
        name="finance_costs.html",
        context=page_ctx(
            request,
            db,
            costs=costs,
            projects=projects,
            employees=employees,
            totals=totals,
            q=q,
            project_id=project_id,
            cost_type=cost_type,
            cost_types=COST_TYPES,
            cost_type_labels=COST_TYPE_LABELS,
            can_edit=require_perm(db, request, "fin.cost.edit"),
            message=request.query_params.get("message", ""),
        ),
    )


@app.post("/fin/costs")
async def fin_cost_create(request: Request, db: Session = Depends(get_db)):
    if not require_perm(db, request, "fin.cost.edit"):
        return render_error(request, db, "没有录入成本的权限", 403)
    form = await request.form()
    try:
        project_id = int(form.get("project_id") or 0)
    except ValueError:
        project_id = 0
    project = db.query(Project).filter(Project.id == project_id, Project.deleted == 0).first()
    if not project:
        return render_error(request, db, "请选择有效的项目", 400)
    try:
        amount = float(form.get("amount") or 0)
    except ValueError:
        amount = 0
    if amount <= 0:
        return render_error(request, db, "成本金额必须大于 0", 400)
    try:
        cost_date = date.fromisoformat(str(form.get("cost_date") or ""))
    except ValueError:
        cost_date = date.today()
    cost_type = str(form.get("cost_type") or "LABOR")
    if cost_type not in COST_TYPE_LABELS:
        cost_type = "LABOR"
    employee_id = int(form.get("employee_id") or 0) if str(form.get("employee_id") or "").isdigit() else 0
    employee = db.query(Employee).filter(Employee.id == employee_id, Employee.deleted == 0).first() if employee_id else None
    link = (
        db.query(ContractProject)
        .filter(ContractProject.project_id == project.id, ContractProject.deleted == 0)
        .first()
    )
    contract = db.query(Contract).filter(Contract.id == link.contract_id, Contract.deleted == 0).first() if link else None
    cost = FinanceCost(
        company_id=project.company_id or 1,
        project_id=project.id,
        project_code=project.project_code,
        project_name=project.project_name,
        contract_id=contract.id if contract else None,
        contract_no=contract.contract_no if contract else None,
        customer_id=project.customer_id,
        customer_name=project.customer_name,
        org_id=project.org_id,
        org_name=project.org_name,
        cost_type=cost_type,
        cost_category=str(form.get("cost_category") or COST_TYPE_LABELS[cost_type]),
        cost_date=cost_date,
        period=cost_date.strftime("%Y-%m"),
        amount=amount,
        supplier_name=str(form.get("supplier_name") or ""),
        employee_id=employee.id if employee else None,
        employee_name=employee.employee_name if employee else "",
        source="MANUAL",
        status="CONFIRMED",
        remark=str(form.get("remark") or ""),
    )
    db.add(cost)
    db.flush()
    sync_project_cost(db, project.id)
    user = get_current_user(request, db)
    audit(
        db,
        user,
        "CREATE",
        "finance_cost",
        cost.id,
        f"录入 {project.project_code} 成本 {amount:,.2f}",
        request.client.host if request.client else "",
    )
    db.commit()
    return RedirectResponse(f"/fin/costs?message=成本已录入", status_code=302)


@app.post("/fin/costs/{cost_id}/delete")
def fin_cost_delete(request: Request, cost_id: int, db: Session = Depends(get_db)):
    if not require_perm(db, request, "fin.cost.edit"):
        return render_error(request, db, "没有删除成本的权限", 403)
    cost = db.query(FinanceCost).filter(FinanceCost.id == cost_id, FinanceCost.deleted == 0).first()
    if not cost:
        return render_error(request, db, "成本记录不存在或已删除", 404)
    project_id = cost.project_id
    user = get_current_user(request, db)
    cost.deleted = 1
    cost.updated_by = user.username if user else "system"
    sync_project_cost(db, project_id)
    audit(
        db,
        user,
        "DELETE",
        "finance_cost",
        cost.id,
        f"删除项目成本 {cost.amount:,.2f}",
        request.client.host if request.client else "",
    )
    db.commit()
    return RedirectResponse("/fin/costs?message=成本已删除", status_code=302)


@app.get("/md/{entity_key}", response_class=HTMLResponse)
def entity_list(
    request: Request,
    entity_key: str,
    db: Session = Depends(get_db),
    q: str = "",
    page: int = 1,
    parent_field: str = "",
    parent_id: str = "",
):
    try:
        ent = get_entity(entity_key)
    except KeyError:
        return render_error(request, db, "未知的主数据实体", 404)
    if not require_perm(db, request, f"md.{entity_key}.view"):
        return render_error(request, db, "没有访问该主数据的权限", 403)
    page = max(1, page)
    rows, total, pages = query_records(
        db, ent, q=q, page=page, page_size=20, parent_field=parent_field or None, parent_id=parent_id or None
    )
    fk_maps = get_fk_maps(db, ent, rows)
    columns = [f for f in ent["fields"] if f["list"]]
    view_rows = []
    for row in rows:
        view_rows.append(
            {
                "id": row.id,
                "cells": {f["name"]: display_value(f, row, fk_maps) for f in columns},
            }
        )
    return templates.TemplateResponse(
        request=request,
        name="list.html",
        context=page_ctx(
            request,
            db,
            ent=ent,
            columns=columns,
            rows=view_rows,
            total=total,
            page=page,
            pages=pages,
            q=q,
            parent_field=parent_field,
            parent_id=parent_id,
            message=request.query_params.get("message", ""),
        ),
    )


def _form_context(request, db, ent, record=None, values=None, error=""):
    fk_options = {}
    for field in ent["fields"]:
        if field.get("source"):
            fk_options[field["name"]] = options_for_source(db, field["source"])
    if values is None:
        values = {}
        if record:
            for field in ent["fields"]:
                if field["name"] == "password":
                    values[field["name"]] = ""
                else:
                    val = getattr(record, field["name"], None)
                    values[field["name"]] = "" if val is None else val
        else:
            for field in ent["fields"]:
                values[field["name"]] = field.get("default") or ""
    return page_ctx(
        request,
        db,
        ent=ent,
        record=record,
        values=values,
        fk_options=fk_options,
        error=error,
    )


@app.get("/md/{entity_key}/new", response_class=HTMLResponse)
def entity_new(request: Request, entity_key: str, db: Session = Depends(get_db)):
    try:
        ent = get_entity(entity_key)
    except KeyError:
        return render_error(request, db, "未知的主数据实体", 404)
    if not require_perm(db, request, f"md.{entity_key}.edit"):
        return render_error(request, db, "没有新增该主数据的权限", 403)
    prefill = {}
    for field in ent["fields"]:
        if field["name"] in request.query_params:
            prefill[field["name"]] = request.query_params.get(field["name"])
    ctx = _form_context(request, db, ent, values=None)
    if prefill:
        ctx["values"] = {**ctx["values"], **prefill}
    return templates.TemplateResponse(request=request, name="form.html", context=ctx)


@app.post("/md/{entity_key}/new", response_class=HTMLResponse)
async def entity_create(request: Request, entity_key: str, db: Session = Depends(get_db)):
    try:
        ent = get_entity(entity_key)
    except KeyError:
        return render_error(request, db, "未知的主数据实体", 404)
    if not require_perm(db, request, f"md.{entity_key}.edit"):
        return render_error(request, db, "没有新增该主数据的权限", 403)
    form = await request.form()
    values, errors = parse_form(ent, form)
    if errors:
        ctx = _form_context(request, db, ent, values={k: form.get(k) for k in form}, error="；".join(errors))
        return templates.TemplateResponse(request=request, name="form.html", context=ctx, status_code=400)
    enrich_values(db, values)
    user = get_current_user(request, db)
    try:
        record = create_record(db, ent, values, user.username if user else "system")
    except ValueError as exc:
        ctx = _form_context(request, db, ent, values={k: form.get(k) for k in form}, error=str(exc))
        return templates.TemplateResponse(request=request, name="form.html", context=ctx, status_code=400)
    audit(db, user, "CREATE", entity_key, record.id, f"新增 {ent['label']}", request.client.host if request.client else "")
    db.commit()
    return RedirectResponse(f"/md/{entity_key}?message=保存成功", status_code=302)


@app.get("/md/{entity_key}/{record_id}/edit", response_class=HTMLResponse)
def entity_edit(request: Request, entity_key: str, record_id: int, db: Session = Depends(get_db)):
    try:
        ent = get_entity(entity_key)
    except KeyError:
        return render_error(request, db, "未知的主数据实体", 404)
    if not require_perm(db, request, f"md.{entity_key}.edit"):
        return render_error(request, db, "没有编辑该主数据的权限", 403)
    record = get_record(db, ent, record_id)
    if not record:
        return render_error(request, db, "记录不存在或已删除", 404)
    return templates.TemplateResponse(
        request=request,
        name="form.html",
        context=_form_context(request, db, ent, record=record),
    )


@app.post("/md/{entity_key}/{record_id}/edit", response_class=HTMLResponse)
async def entity_update(request: Request, entity_key: str, record_id: int, db: Session = Depends(get_db)):
    try:
        ent = get_entity(entity_key)
    except KeyError:
        return render_error(request, db, "未知的主数据实体", 404)
    if not require_perm(db, request, f"md.{entity_key}.edit"):
        return render_error(request, db, "没有编辑该主数据的权限", 403)
    record = get_record(db, ent, record_id)
    if not record:
        return render_error(request, db, "记录不存在或已删除", 404)
    form = await request.form()
    values, errors = parse_form(ent, form)
    if errors:
        ctx = _form_context(request, db, ent, record=record, values={k: form.get(k) for k in form}, error="；".join(errors))
        return templates.TemplateResponse(request=request, name="form.html", context=ctx, status_code=400)
    enrich_values(db, values)
    user = get_current_user(request, db)
    try:
        update_record(db, ent, record, values, user.username if user else "system")
    except ValueError as exc:
        ctx = _form_context(request, db, ent, record=record, values={k: form.get(k) for k in form}, error=str(exc))
        return templates.TemplateResponse(request=request, name="form.html", context=ctx, status_code=400)
    audit(db, user, "UPDATE", entity_key, record.id, f"编辑 {ent['label']}", request.client.host if request.client else "")
    db.commit()
    return RedirectResponse(f"/md/{entity_key}?message=保存成功", status_code=302)


@app.post("/md/{entity_key}/{record_id}/delete")
def entity_delete(request: Request, entity_key: str, record_id: int, db: Session = Depends(get_db)):
    try:
        ent = get_entity(entity_key)
    except KeyError:
        return render_error(request, db, "未知的主数据实体", 404)
    if not require_perm(db, request, f"md.{entity_key}.edit"):
        return render_error(request, db, "没有删除该主数据的权限", 403)
    record = get_record(db, ent, record_id)
    if not record:
        return render_error(request, db, "记录不存在或已删除", 404)
    user = get_current_user(request, db)
    soft_delete(db, record)
    audit(db, user, "DELETE", entity_key, record_id, f"删除 {ent['label']}", request.client.host if request.client else "")
    db.commit()
    return RedirectResponse(f"/md/{entity_key}?message=已删除", status_code=302)


@app.get("/detail/{entity_key}/{record_id}", response_class=HTMLResponse)
def entity_detail(request: Request, entity_key: str, record_id: int, db: Session = Depends(get_db)):
    try:
        ent = get_entity(entity_key)
    except KeyError:
        return render_error(request, db, "未知的主数据实体", 404)
    if not require_perm(db, request, f"md.{entity_key}.view"):
        return render_error(request, db, "没有查看该主数据的权限", 403)
    record = get_record(db, ent, record_id)
    if not record:
        return render_error(request, db, "记录不存在或已删除", 404)

    if entity_key == "customer":
        contacts = (
            db.query(CustomerContact)
            .filter(CustomerContact.customer_id == record.id, CustomerContact.deleted == 0)
            .order_by(CustomerContact.sort_order.asc(), CustomerContact.id.asc())
            .all()
        )
        addresses = (
            db.query(CustomerAddress)
            .filter(CustomerAddress.customer_id == record.id, CustomerAddress.deleted == 0)
            .order_by(CustomerAddress.sort_order.asc(), CustomerAddress.id.asc())
            .all()
        )
        projects = (
            db.query(Project)
            .filter(Project.customer_id == record.id, Project.deleted == 0)
            .order_by(Project.id.desc())
            .all()
        )
        contracts = (
            db.query(Contract)
            .filter(Contract.customer_id == record.id, Contract.deleted == 0)
            .order_by(Contract.id.desc())
            .all()
        )
        followers = (
            db.query(CustomerFollower)
            .filter(CustomerFollower.customer_id == record.id, CustomerFollower.deleted == 0)
            .order_by(CustomerFollower.is_primary.desc(), CustomerFollower.id.asc())
            .all()
        )
        opportunities = (
            db.query(Opportunity)
            .filter(Opportunity.customer_id == record.id, Opportunity.deleted == 0)
            .order_by(Opportunity.id.desc())
            .all()
        )
        return templates.TemplateResponse(
            request=request,
            name="customer_detail.html",
            context=page_ctx(
                request,
                db,
                ent=ent,
                record=record,
                contacts=contacts,
                addresses=addresses,
                projects=projects,
                contracts=contracts,
                followers=followers,
                opportunities=opportunities,
                fin=customer_stats(db, record),
                message=request.query_params.get("message", ""),
            ),
        )

    if entity_key == "project":
        members = (
            db.query(ProjectMember)
            .filter(ProjectMember.project_id == record.id, ProjectMember.deleted == 0)
            .order_by(ProjectMember.id.asc())
            .all()
        )
        links = (
            db.query(ContractProject, Contract)
            .join(Contract, Contract.id == ContractProject.contract_id)
            .filter(ContractProject.project_id == record.id, ContractProject.deleted == 0, Contract.deleted == 0)
            .all()
        )
        return templates.TemplateResponse(
            request=request,
            name="project_detail.html",
            context=page_ctx(
                request,
                db,
                ent=ent,
                record=record,
                members=members,
                links=links,
                fin=project_stats(db, record),
            ),
        )

    if entity_key == "contract":
        milestones = (
            db.query(ContractMilestone)
            .filter(ContractMilestone.contract_id == record.id, ContractMilestone.deleted == 0)
            .order_by(ContractMilestone.sort_order.asc(), ContractMilestone.id.asc())
            .all()
        )
        links = (
            db.query(ContractProject, Project)
            .join(Project, Project.id == ContractProject.project_id)
            .filter(ContractProject.contract_id == record.id, ContractProject.deleted == 0, Project.deleted == 0)
            .all()
        )
        opportunities = (
            db.query(ContractOpportunity, Opportunity)
            .join(Opportunity, Opportunity.id == ContractOpportunity.opportunity_id)
            .filter(
                ContractOpportunity.contract_id == record.id,
                ContractOpportunity.deleted == 0,
                Opportunity.deleted == 0,
            )
            .all()
        )
        return templates.TemplateResponse(
            request=request,
            name="contract_detail.html",
            context=page_ctx(
                request,
                db,
                ent=ent,
                record=record,
                milestones=milestones,
                links=links,
                opportunities=opportunities,
                fin=contract_stats(db, record, milestones),
                message=request.query_params.get("message", ""),
            ),
        )

    if entity_key == "opportunity":
        follows = (
            db.query(OpportunityFollow)
            .filter(OpportunityFollow.opportunity_id == record.id, OpportunityFollow.deleted == 0)
            .order_by(OpportunityFollow.follow_time.desc(), OpportunityFollow.id.desc())
            .all()
        )
        links = (
            db.query(ContractOpportunity, Contract)
            .join(Contract, Contract.id == ContractOpportunity.contract_id)
            .filter(
                ContractOpportunity.opportunity_id == record.id,
                ContractOpportunity.deleted == 0,
                Contract.deleted == 0,
            )
            .all()
        )
        return templates.TemplateResponse(
            request=request,
            name="opportunity_detail.html",
            context=page_ctx(
                request,
                db,
                ent=ent,
                record=record,
                follows=follows,
                links=links,
                message=request.query_params.get("message", ""),
            ),
        )

    fk_maps = get_fk_maps(db, ent, [record])
    items = [
        (field["label"], display_value(field, record, fk_maps))
        for field in ent["fields"]
        if field["form"] and field["name"] != "password"
    ]
    return templates.TemplateResponse(
        request=request,
        name="detail_generic.html",
        context=page_ctx(request, db, ent=ent, record=record, items=items),
    )


@app.get("/api/stats")
def api_stats(db: Session = Depends(get_db)):
    return {
        "company": db.query(Company).filter(Company.deleted == 0).count(),
        "org": db.query(Org).filter(Org.deleted == 0).count(),
        "position": db.query(Position).filter(Position.deleted == 0).count(),
        "employee": db.query(Employee).filter(Employee.deleted == 0).count(),
        "customer": db.query(Customer).filter(Customer.deleted == 0).count(),
        "opportunity": db.query(Opportunity).filter(Opportunity.deleted == 0).count(),
        "opportunity_follow": db.query(OpportunityFollow).filter(OpportunityFollow.deleted == 0).count(),
        "customer_follower": db.query(CustomerFollower).filter(CustomerFollower.deleted == 0).count(),
        "project": db.query(Project).filter(Project.deleted == 0).count(),
        "contract": db.query(Contract).filter(Contract.deleted == 0).count(),
        "finance_cost": db.query(FinanceCost).filter(FinanceCost.deleted == 0).count(),
        "finance_budget": db.query(FinanceBudget).filter(FinanceBudget.deleted == 0).count(),
        "product": db.query(Product).filter(Product.deleted == 0).count(),
        "tax_rate": db.query(TaxRate).filter(TaxRate.deleted == 0).count(),
        "dict": db.query(Dict).filter(Dict.deleted == 0).count(),
        "dict_item": db.query(DictItem).filter(DictItem.deleted == 0).count(),
        "id_mapping": db.query(IdMapping).filter(IdMapping.deleted == 0).count(),
    }
