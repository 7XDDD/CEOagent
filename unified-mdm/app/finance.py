"""财务经营分析：项目损益、应收、客户盈利、预算与现金流。"""
from datetime import date

from .models import (
    Contract,
    ContractMilestone,
    ContractProject,
    Customer,
    FinanceBudget,
    FinanceCost,
    Project,
)

COST_TYPES = [
    {"value": "LABOR", "label": "人工成本"},
    {"value": "EXPENSE", "label": "费用成本"},
    {"value": "SUBCONTRACT", "label": "分包成本"},
    {"value": "OTHER", "label": "其他成本"},
]
COST_TYPE_LABELS = {x["value"]: x["label"] for x in COST_TYPES}

BUDGET_CATEGORIES = [
    {"value": "SIGNING", "label": "签约额"},
    {"value": "REVENUE", "label": "营业收入"},
    {"value": "LABOR_COST", "label": "人工成本"},
    {"value": "EXPENSE", "label": "费用成本"},
    {"value": "SUBCONTRACT", "label": "分包成本"},
    {"value": "CASH_IN", "label": "回款"},
]
BUDGET_CATEGORY_LABELS = {x["value"]: x["label"] for x in BUDGET_CATEGORIES}

BUDGET_TYPE_LABELS = {
    "COMPANY": "公司",
    "ORG": "组织",
    "PROJECT": "项目",
    "CUSTOMER": "客户",
}


def f(value):
    return float(value or 0)


def month_key(value):
    return value.strftime("%Y-%m") if value else ""


def month_first(value):
    return value.replace(day=1)


def add_months(value, count):
    year = value.year + (value.month - 1 + count) // 12
    month = (value.month - 1 + count) % 12 + 1
    return date(year, month, 1)


def months_between(start, end):
    current = month_first(start)
    last = month_first(end)
    result = []
    while current <= last:
        result.append(current)
        current = add_months(current, 1)
    return result


def month_label(value):
    return f"{value.year}年{value.month}月"


def sync_project_cost(db, project_id):
    """把成本明细汇总回项目主数据，保持项目详情口径一致。"""
    project = db.query(Project).filter(Project.id == project_id, Project.deleted == 0).first()
    if not project:
        return
    rows = (
        db.query(FinanceCost)
        .filter(FinanceCost.project_id == project_id, FinanceCost.deleted == 0)
        .all()
    )
    labor = sum(f(x.amount) for x in rows if x.cost_type == "LABOR")
    expense = sum(f(x.amount) for x in rows if x.cost_type == "EXPENSE")
    total = sum(f(x.amount) for x in rows)
    project.actual_labor_cost = labor
    project.actual_expense_cost = expense
    project.actual_cost = total
    budget = f(project.budget_labor_amount) + f(project.budget_expense_amount)
    project.cost_variance = budget - total
    project.cost_variance_rate = (budget - total) / budget if budget else 0


def sync_contract_finance_status(db, contract_id):
    """里程碑登记开票/回款后，回写合同的开票状态与收款状态。"""
    contract = db.query(Contract).filter(Contract.id == contract_id, Contract.deleted == 0).first()
    if not contract:
        return
    milestones = (
        db.query(ContractMilestone)
        .filter(ContractMilestone.contract_id == contract_id, ContractMilestone.deleted == 0)
        .all()
    )
    if not milestones:
        return
    invoiced_flags = [
        f(m.milestone_amount) > 0 and f(m.invoiced_amount) >= f(m.milestone_amount)
        for m in milestones
    ]
    paid_flags = [
        f(m.milestone_amount) > 0 and f(m.paid_amount or m.actual_payment_amount) >= f(m.milestone_amount)
        for m in milestones
    ]
    if all(invoiced_flags):
        contract.invoice_status = "COMPLETED"
    elif any(f(m.invoiced_amount) > 0 for m in milestones):
        contract.invoice_status = "PARTIAL"
    else:
        contract.invoice_status = "NOT_STARTED"
    if all(paid_flags):
        contract.payment_status = "PAID"
    elif any(f(m.paid_amount or m.actual_payment_amount) > 0 for m in milestones):
        contract.payment_status = "PARTIAL"
    else:
        contract.payment_status = "UNPAID"


def contract_stats(db, contract, milestones=None):
    if milestones is None:
        milestones = (
            db.query(ContractMilestone)
            .filter(ContractMilestone.contract_id == contract.id, ContractMilestone.deleted == 0)
            .all()
        )
    today = date.today()
    invoiced = sum(f(m.invoiced_amount) for m in milestones)
    paid = sum(f(m.paid_amount or m.actual_payment_amount) for m in milestones)
    outstanding = max(invoiced - paid, 0)
    overdue = 0.0
    overdue_count = 0
    for m in milestones:
        left = max(f(m.invoiced_amount) - f(m.paid_amount or m.actual_payment_amount), 0)
        due = m.receivable_due_date or m.expected_payment_date
        if left > 0 and due and due < today:
            overdue += left
            overdue_count += 1
    contract_amount = f(contract.contract_amount)
    unbilled = max(contract_amount - invoiced, 0)
    return {
        "milestones": milestones,
        "contract_amount": contract_amount,
        "invoiced": invoiced,
        "paid": paid,
        "outstanding": outstanding,
        "overdue": overdue,
        "overdue_count": overdue_count,
        "unbilled": unbilled,
        "invoice_rate": invoiced / contract_amount if contract_amount else 0,
        "collection_rate": paid / contract_amount if contract_amount else 0,
        "ar_rate": outstanding / invoiced if invoiced else 0,
    }


def project_contracts(db, project_id):
    return (
        db.query(Contract)
        .join(ContractProject, ContractProject.contract_id == Contract.id)
        .filter(
            ContractProject.project_id == project_id,
            ContractProject.deleted == 0,
            Contract.deleted == 0,
        )
        .all()
    )


def project_stats(db, project):
    contracts = project_contracts(db, project.id)
    contract_rows = []
    for contract in contracts:
        contract_rows.append({"contract": contract, **contract_stats(db, contract)})
    contract_amount = sum(x["contract_amount"] for x in contract_rows)
    invoiced = sum(x["invoiced"] for x in contract_rows)
    paid = sum(x["paid"] for x in contract_rows)
    outstanding = sum(x["outstanding"] for x in contract_rows)
    overdue = sum(x["overdue"] for x in contract_rows)
    unbilled = sum(x["unbilled"] for x in contract_rows)

    costs = (
        db.query(FinanceCost)
        .filter(FinanceCost.project_id == project.id, FinanceCost.deleted == 0)
        .all()
    )
    if costs:
        labor_cost = sum(f(x.amount) for x in costs if x.cost_type == "LABOR")
        expense_cost = sum(f(x.amount) for x in costs if x.cost_type == "EXPENSE")
        subcontract_cost = sum(f(x.amount) for x in costs if x.cost_type == "SUBCONTRACT")
        other_cost = sum(f(x.amount) for x in costs if x.cost_type == "OTHER")
        total_cost = sum(f(x.amount) for x in costs)
    else:
        labor_cost = f(project.actual_labor_cost)
        expense_cost = f(project.actual_expense_cost)
        subcontract_cost = 0
        other_cost = 0
        total_cost = f(project.actual_cost)

    budgets = (
        db.query(FinanceBudget)
        .filter(
            FinanceBudget.project_id == project.id,
            FinanceBudget.deleted == 0,
            FinanceBudget.budget_year == date.today().year,
        )
        .all()
    )
    if budgets:
        budget_revenue = sum(f(x.budget_amount) for x in budgets if x.category == "REVENUE")
        budget_labor = sum(f(x.budget_amount) for x in budgets if x.category == "LABOR_COST")
        budget_expense = sum(f(x.budget_amount) for x in budgets if x.category == "EXPENSE")
        budget_subcontract = sum(f(x.budget_amount) for x in budgets if x.category == "SUBCONTRACT")
    else:
        budget_revenue = contract_amount
        budget_labor = f(project.budget_labor_amount)
        budget_expense = f(project.budget_expense_amount)
        budget_subcontract = 0
    budget_cost = budget_labor + budget_expense + budget_subcontract

    revenue = invoiced
    gross_profit = revenue - total_cost
    gross_margin = gross_profit / revenue if revenue else None
    return {
        "contracts": contract_rows,
        "contract_amount": contract_amount,
        "invoiced": invoiced,
        "paid": paid,
        "outstanding": outstanding,
        "overdue": overdue,
        "unbilled": unbilled,
        "labor_cost": labor_cost,
        "expense_cost": expense_cost,
        "subcontract_cost": subcontract_cost,
        "other_cost": other_cost,
        "total_cost": total_cost,
        "revenue": revenue,
        "gross_profit": gross_profit,
        "gross_margin": gross_margin,
        "budget_revenue": budget_revenue,
        "budget_labor": budget_labor,
        "budget_expense": budget_expense,
        "budget_subcontract": budget_subcontract,
        "budget_cost": budget_cost,
        "budget_usage": total_cost / budget_cost if budget_cost else None,
        "cost_variance": budget_cost - total_cost,
        "costs": costs,
    }


def customer_stats(db, customer):
    contracts = (
        db.query(Contract)
        .filter(Contract.customer_id == customer.id, Contract.deleted == 0)
        .all()
    )
    stats = [contract_stats(db, c) for c in contracts]
    contract_amount = sum(x["contract_amount"] for x in stats)
    invoiced = sum(x["invoiced"] for x in stats)
    paid = sum(x["paid"] for x in stats)
    outstanding = sum(x["outstanding"] for x in stats)
    overdue = sum(x["overdue"] for x in stats)
    unbilled = sum(x["unbilled"] for x in stats)
    costs = (
        db.query(FinanceCost)
        .filter(FinanceCost.customer_id == customer.id, FinanceCost.deleted == 0)
        .all()
    )
    total_cost = sum(f(x.amount) for x in costs)
    gross_profit = invoiced - total_cost
    gross_margin = gross_profit / invoiced if invoiced else None
    project_count = (
        db.query(Project).filter(Project.customer_id == customer.id, Project.deleted == 0).count()
    )
    credit_limit = f(customer.credit_limit)
    return {
        "contract_amount": contract_amount,
        "invoiced": invoiced,
        "paid": paid,
        "outstanding": outstanding,
        "overdue": overdue,
        "unbilled": unbilled,
        "total_cost": total_cost,
        "gross_profit": gross_profit,
        "gross_margin": gross_margin,
        "project_count": project_count,
        "contract_count": len(contracts),
        "credit_limit": credit_limit,
        "credit_usage": outstanding / credit_limit if credit_limit else None,
    }


def project_rows(db, q="", risk=""):
    query = db.query(Project).filter(Project.deleted == 0)
    if q:
        like = f"%{q}%"
        query = query.filter(
            (Project.project_code.ilike(like))
            | (Project.project_name.ilike(like))
            | (Project.customer_name.ilike(like))
            | (Project.pm_name.ilike(like))
        )
    rows = []
    for project in query.order_by(Project.id.asc()).all():
        stats = project_stats(db, project)
        if risk == "LOSS" and stats["gross_profit"] >= 0:
            continue
        if risk == "LOW_MARGIN" and (
            stats["gross_margin"] is None or stats["gross_margin"] >= 0.15
        ):
            continue
        if risk == "OVER_BUDGET" and (
            stats["budget_usage"] is None or stats["budget_usage"] <= 1
        ):
            continue
        rows.append({"project": project, **stats})
    return rows


def customer_rows(db, q=""):
    query = db.query(Customer).filter(Customer.deleted == 0)
    if q:
        like = f"%{q}%"
        query = query.filter(
            (Customer.customer_name.ilike(like)) | (Customer.customer_code.ilike(like))
        )
    rows = []
    for customer in query.order_by(Customer.id.asc()).all():
        rows.append({"customer": customer, **customer_stats(db, customer)})
    return rows


def milestone_rows(db, q="", status=""):
    query = (
        db.query(ContractMilestone, Contract)
        .join(Contract, Contract.id == ContractMilestone.contract_id)
        .filter(ContractMilestone.deleted == 0, Contract.deleted == 0)
    )
    if q:
        like = f"%{q}%"
        query = query.filter(
            (Contract.contract_no.ilike(like))
            | (Contract.contract_name.ilike(like))
            | (Contract.customer_name.ilike(like))
        )
    today = date.today()
    rows = []
    for milestone, contract in query.order_by(
        ContractMilestone.expected_payment_date.asc(), ContractMilestone.id.asc()
    ).all():
        amount = f(milestone.milestone_amount)
        invoiced = f(milestone.invoiced_amount)
        paid = f(milestone.paid_amount or milestone.actual_payment_amount)
        outstanding = max(invoiced - paid, 0)
        unbilled = max(amount - invoiced, 0)
        due = milestone.receivable_due_date or milestone.expected_payment_date
        days_overdue = (today - due).days if due and outstanding > 0 and due < today else 0
        if invoiced <= 0:
            computed = "UNINVOICED"
        elif paid >= invoiced:
            computed = "PAID"
        elif days_overdue > 0:
            computed = "OVERDUE"
        elif paid > 0:
            computed = "PARTIAL"
        else:
            computed = "UNPAID"
        if status and computed != status:
            continue
        rows.append(
            {
                "milestone": milestone,
                "contract": contract,
                "amount": amount,
                "invoiced": invoiced,
                "paid": paid,
                "outstanding": outstanding,
                "unbilled": unbilled,
                "overdue": outstanding if computed == "OVERDUE" else 0,
                "days_overdue": days_overdue,
                "status": computed,
                "due": due,
            }
        )
    return rows


def contract_rows(db, q="", status=""):
    query = db.query(Contract).filter(Contract.deleted == 0)
    if q:
        like = f"%{q}%"
        query = query.filter(
            (Contract.contract_no.ilike(like))
            | (Contract.contract_name.ilike(like))
            | (Contract.customer_name.ilike(like))
        )
    rows = []
    for contract in query.order_by(Contract.sign_date.desc(), Contract.id.desc()).all():
        stats = contract_stats(db, contract)
        if not stats["invoiced"]:
            computed = "UNINVOICED"
        elif stats["overdue"] > 0:
            computed = "OVERDUE"
        elif stats["outstanding"] > 0 and stats["paid"] > 0:
            computed = "PARTIAL"
        elif stats["outstanding"] > 0:
            computed = "UNPAID"
        else:
            computed = "PAID"
        if status and computed != status:
            continue
        rows.append({"contract": contract, "status": computed, **stats})
    return rows


def aging_summary(db):
    today = date.today()
    buckets = [
        {"key": "CURRENT", "label": "未到期", "amount": 0.0, "count": 0},
        {"key": "D1_30", "label": "1-30天", "amount": 0.0, "count": 0},
        {"key": "D31_60", "label": "31-60天", "amount": 0.0, "count": 0},
        {"key": "D61_90", "label": "61-90天", "amount": 0.0, "count": 0},
        {"key": "D90_PLUS", "label": "90天以上", "amount": 0.0, "count": 0},
    ]
    rows = (
        db.query(ContractMilestone)
        .filter(ContractMilestone.deleted == 0, ContractMilestone.invoiced_amount > 0)
        .all()
    )
    for m in rows:
        left = max(f(m.invoiced_amount) - f(m.paid_amount or m.actual_payment_amount), 0)
        if left <= 0:
            continue
        due = m.receivable_due_date or m.expected_payment_date
        days = (today - due).days if due else 0
        if days <= 0:
            bucket = buckets[0]
        elif days <= 30:
            bucket = buckets[1]
        elif days <= 60:
            bucket = buckets[2]
        elif days <= 90:
            bucket = buckets[3]
        else:
            bucket = buckets[4]
        bucket["amount"] += left
        bucket["count"] += 1
    return buckets


def monthly_series(db):
    today = date.today()
    milestones = db.query(ContractMilestone).filter(ContractMilestone.deleted == 0).all()
    costs = db.query(FinanceCost).filter(FinanceCost.deleted == 0).all()
    dates = []
    revenue = {}
    cash_in = {}
    for m in milestones:
        invoiced = f(m.invoiced_amount)
        paid = f(m.paid_amount or m.actual_payment_amount)
        invoice_date = m.actual_date or m.plan_date
        if invoiced > 0 and invoice_date:
            key = month_key(invoice_date)
            revenue[key] = revenue.get(key, 0) + invoiced
            dates.append(invoice_date)
        payment_date = m.actual_payment_date or (m.expected_payment_date if paid > 0 else None)
        if paid > 0 and payment_date:
            key = month_key(payment_date)
            cash_in[key] = cash_in.get(key, 0) + paid
            dates.append(payment_date)
    cost_by_month = {}
    for c in costs:
        if c.cost_date:
            key = month_key(c.cost_date)
            cost_by_month[key] = cost_by_month.get(key, 0) + f(c.amount)
            dates.append(c.cost_date)
    if dates:
        start = min(dates)
        if month_first(start) > month_first(today):
            start = add_months(today, -5)
    else:
        start = add_months(today, -5)
    keys = months_between(start, today)
    if len(keys) > 12:
        keys = keys[-12:]
    rows = []
    for key_date in keys:
        key = month_key(key_date)
        rev = revenue.get(key, 0)
        cost = cost_by_month.get(key, 0)
        rows.append(
            {
                "key": key,
                "label": month_label(key_date),
                "revenue": rev,
                "cost": cost,
                "gross_profit": rev - cost,
                "cash_in": cash_in.get(key, 0),
            }
        )
    return rows


def risk_alerts(db, projects, customers, contracts):
    alerts = []
    for row in projects:
        p = row["project"]
        if row["gross_profit"] < 0 and row["revenue"] > 0:
            alerts.append(
                {
                    "level": "red",
                    "title": f"{p.project_code} 项目亏损",
                    "detail": f"收入 {row['revenue']:,.0f}，成本 {row['total_cost']:,.0f}，毛利 {row['gross_profit']:,.0f}",
                    "link": f"/fin/projects/{p.id}",
                }
            )
        elif row["total_cost"] > 0 and row["revenue"] <= 0:
            alerts.append(
                {
                    "level": "amber",
                    "title": f"{p.project_code} 有成本未确认收入",
                    "detail": f"已发生成本 {row['total_cost']:,.0f}，尚未开票确认收入",
                    "link": f"/fin/projects/{p.id}",
                }
            )
        elif row["gross_margin"] is not None and row["gross_margin"] < 0.15:
            alerts.append(
                {
                    "level": "amber",
                    "title": f"{p.project_code} 毛利率偏低",
                    "detail": f"毛利率 {row['gross_margin'] * 100:.1f}%，低于 15%",
                    "link": f"/fin/projects/{p.id}",
                }
            )
        if row["budget_usage"] is not None and row["budget_usage"] > 1:
            alerts.append(
                {
                    "level": "amber",
                    "title": f"{p.project_code} 成本超预算",
                    "detail": f"预算使用率 {row['budget_usage'] * 100:.1f}%",
                    "link": f"/fin/projects/{p.id}",
                }
            )
    for row in contracts:
        c = row["contract"]
        if row["unbilled"] > 0 and c.end_date and c.end_date < date.today():
            alerts.append(
                {
                    "level": "red",
                    "title": f"{c.contract_no} 到期未开票",
                    "detail": f"合同已到期，仍有未开票金额 {row['unbilled']:,.0f}",
                    "link": f"/detail/contract/{c.id}",
                }
            )
        if row["overdue"] > 0:
            alerts.append(
                {
                    "level": "red",
                    "title": f"{c.contract_no} 应收逾期",
                    "detail": f"逾期应收 {row['overdue']:,.0f}",
                    "link": f"/fin/receivables?q={c.contract_no}",
                }
            )
        for m in row["milestones"]:
            if (
                f(m.milestone_amount) > 0
                and f(m.invoiced_amount) <= 0
                and m.expected_payment_date
                and m.expected_payment_date < date.today()
            ):
                alerts.append(
                    {
                        "level": "red",
                        "title": f"{c.contract_no} 里程碑到期未开票",
                        "detail": f"{m.milestone_name} 计划回款 {m.expected_payment_date}，金额 {f(m.milestone_amount):,.0f}",
                        "link": f"/detail/contract/{c.id}",
                    }
                )
                break
    for row in customers:
        c = row["customer"]
        if row["credit_usage"] is not None and row["credit_usage"] > 1:
            alerts.append(
                {
                    "level": "amber",
                    "title": f"{c.customer_name} 超出信用额度",
                    "detail": f"应收 {row['outstanding']:,.0f} / 信用额度 {row['credit_limit']:,.0f}",
                    "link": f"/detail/customer/{c.id}",
                }
            )
    return alerts[:10]


def overview(db):
    contracts = db.query(Contract).filter(Contract.deleted == 0).all()
    contract_stats_rows = [contract_stats(db, c) for c in contracts]
    contract_total = sum(x["contract_amount"] for x in contract_stats_rows)
    invoiced_total = sum(x["invoiced"] for x in contract_stats_rows)
    paid_total = sum(x["paid"] for x in contract_stats_rows)
    ar_total = sum(x["outstanding"] for x in contract_stats_rows)
    overdue_total = sum(x["overdue"] for x in contract_stats_rows)
    unbilled_total = sum(x["unbilled"] for x in contract_stats_rows)
    costs = db.query(FinanceCost).filter(FinanceCost.deleted == 0).all()
    cost_total = sum(f(x.amount) for x in costs)
    gross_profit = invoiced_total - cost_total
    gross_margin = gross_profit / invoiced_total if invoiced_total else None
    project_list = project_rows(db)
    customer_list = customer_rows(db)
    contract_list = contract_rows(db)
    alerts = risk_alerts(db, project_list, customer_list, contract_list)
    projects_sorted = sorted(project_list, key=lambda x: x["gross_profit"], reverse=True)
    customers_sorted = sorted(customer_list, key=lambda x: x["invoiced"], reverse=True)
    cashflow = cashflow_forecast(db)
    return {
        "contract_total": contract_total,
        "invoiced_total": invoiced_total,
        "paid_total": paid_total,
        "ar_total": ar_total,
        "overdue_total": overdue_total,
        "unbilled_total": unbilled_total,
        "cost_total": cost_total,
        "gross_profit": gross_profit,
        "gross_margin": gross_margin,
        "project_count": len(project_list),
        "customer_count": len(customer_list),
        "contract_count": len(contract_list),
        "monthly": monthly_series(db),
        "aging": aging_summary(db),
        "top_projects": projects_sorted[:8],
        "bottom_projects": list(reversed(projects_sorted))[:5],
        "top_customers": customers_sorted[:8],
        "alerts": alerts,
        "cashflow": cashflow,
    }


def cashflow_forecast(db, actual_months=6, forecast_months=6):
    today = date.today()
    current = month_first(today)
    milestones = db.query(ContractMilestone).filter(ContractMilestone.deleted == 0).all()
    costs = db.query(FinanceCost).filter(FinanceCost.deleted == 0).all()

    actual_in = {}
    for m in milestones:
        paid = f(m.paid_amount or m.actual_payment_amount)
        payment_date = m.actual_payment_date or (m.expected_payment_date if paid > 0 else None)
        if paid > 0 and payment_date:
            key = month_key(payment_date)
            actual_in[key] = actual_in.get(key, 0) + paid
    actual_out = {}
    for c in costs:
        if c.cost_date:
            key = month_key(c.cost_date)
            actual_out[key] = actual_out.get(key, 0) + f(c.amount)

    forecast_in = {}
    for m in milestones:
        if not m.expected_payment_date or m.expected_payment_date < current:
            continue
        left = max(f(m.milestone_amount) - f(m.paid_amount or m.actual_payment_amount), 0)
        if left <= 0:
            continue
        key = month_key(m.expected_payment_date)
        forecast_in[key] = forecast_in.get(key, 0) + left

    forecast_out = {}
    projects = db.query(Project).filter(Project.deleted == 0).all()
    for p in projects:
        if p.status in ("COMPLETED", "CLOSED", "CANCELLED"):
            continue
        rows = [x for x in costs if x.project_id == p.id]
        spent = sum(f(x.amount) for x in rows)
        budget = f(p.budget_labor_amount) + f(p.budget_expense_amount)
        remaining = max(budget - spent, 0)
        if remaining <= 0:
            continue
        end = p.planned_end_date or add_months(today, 3)
        next_month = add_months(current, 1)
        if end <= current:
            keys = [add_months(current, i) for i in (1, 2, 3)]
        else:
            start = max(next_month, month_first(p.planned_start_date or today))
            keys = months_between(start, max(start, end))[:forecast_months]
        if not keys:
            keys = [next_month]
        share = remaining / len(keys)
        for key_date in keys:
            key = month_key(key_date)
            forecast_out[key] = forecast_out.get(key, 0) + share

    rows = []
    cumulative = 0.0
    for offset in range(-actual_months + 1, 1):
        month = add_months(current, offset)
        key = month_key(month)
        inflow = actual_in.get(key, 0)
        outflow = actual_out.get(key, 0)
        net = inflow - outflow
        cumulative += net
        rows.append(
            {
                "key": key,
                "label": month_label(month),
                "kind": "ACTUAL",
                "inflow": inflow,
                "outflow": outflow,
                "net": net,
                "cumulative": cumulative,
            }
        )
    for offset in range(1, forecast_months + 1):
        month = add_months(current, offset)
        key = month_key(month)
        inflow = forecast_in.get(key, 0)
        outflow = forecast_out.get(key, 0)
        net = inflow - outflow
        cumulative += net
        rows.append(
            {
                "key": key,
                "label": month_label(month),
                "kind": "FORECAST",
                "inflow": inflow,
                "outflow": outflow,
                "net": net,
                "cumulative": cumulative,
            }
        )
    return {
        "rows": rows,
        "actual_in": sum(x["inflow"] for x in rows if x["kind"] == "ACTUAL"),
        "actual_out": sum(x["outflow"] for x in rows if x["kind"] == "ACTUAL"),
        "forecast_in": sum(x["inflow"] for x in rows if x["kind"] == "FORECAST"),
        "forecast_out": sum(x["outflow"] for x in rows if x["kind"] == "FORECAST"),
    }


def _scope_contracts(db, budget):
    query = db.query(Contract).filter(Contract.deleted == 0)
    if budget.budget_type == "PROJECT" and budget.project_id:
        query = query.join(
            ContractProject, ContractProject.contract_id == Contract.id
        ).filter(
            ContractProject.project_id == budget.project_id,
            ContractProject.deleted == 0,
        )
    elif budget.budget_type == "CUSTOMER" and budget.customer_id:
        query = query.filter(Contract.customer_id == budget.customer_id)
    elif budget.budget_type == "ORG" and budget.org_id:
        query = query.filter(Contract.org_id == budget.org_id)
    return query.all()


def _scope_costs(db, budget):
    query = db.query(FinanceCost).filter(FinanceCost.deleted == 0)
    if budget.budget_type == "PROJECT" and budget.project_id:
        query = query.filter(FinanceCost.project_id == budget.project_id)
    elif budget.budget_type == "CUSTOMER" and budget.customer_id:
        query = query.filter(FinanceCost.customer_id == budget.customer_id)
    elif budget.budget_type == "ORG" and budget.org_id:
        query = query.filter(FinanceCost.org_id == budget.org_id)
    return query.all()


def budget_actual(db, budget):
    contracts = _scope_contracts(db, budget)
    costs = _scope_costs(db, budget)
    if budget.category == "SIGNING":
        return sum(f(c.contract_amount) for c in contracts if c.sign_status == "SIGNED")
    if budget.category == "REVENUE":
        total = 0.0
        for c in contracts:
            total += contract_stats(db, c)["invoiced"]
        return total
    if budget.category == "CASH_IN":
        total = 0.0
        for c in contracts:
            total += contract_stats(db, c)["paid"]
        return total
    if budget.category == "LABOR_COST":
        return sum(f(x.amount) for x in costs if x.cost_type == "LABOR")
    if budget.category == "EXPENSE":
        return sum(f(x.amount) for x in costs if x.cost_type == "EXPENSE")
    if budget.category == "SUBCONTRACT":
        return sum(f(x.amount) for x in costs if x.cost_type == "SUBCONTRACT")
    if budget.category == "GROSS_PROFIT":
        revenue = sum(contract_stats(db, c)["invoiced"] for c in contracts)
        return revenue - sum(f(x.amount) for x in costs)
    return 0.0


def budget_rows(db, year=None):
    year = year or date.today().year
    rows = (
        db.query(FinanceBudget)
        .filter(FinanceBudget.deleted == 0, FinanceBudget.budget_year == year)
        .order_by(FinanceBudget.budget_type.asc(), FinanceBudget.id.asc())
        .all()
    )
    result = []
    for budget in rows:
        actual = budget_actual(db, budget)
        amount = f(budget.budget_amount)
        rate = actual / amount if amount else None
        if budget.budget_type == "PROJECT" and budget.project_id:
            scope = budget.project_name or budget.project_code
        elif budget.budget_type == "ORG":
            scope = budget.org_name or "组织"
        elif budget.budget_type == "CUSTOMER":
            scope = budget.customer_name or "客户"
        else:
            scope = "公司"
        result.append(
            {
                "budget": budget,
                "scope": scope,
                "type_label": BUDGET_TYPE_LABELS.get(budget.budget_type, budget.budget_type),
                "category_label": BUDGET_CATEGORY_LABELS.get(
                    budget.category, budget.category
                ),
                "budget_amount": amount,
                "actual": actual,
                "rate": rate,
                "variance": actual - amount,
            }
        )
    return result, year
