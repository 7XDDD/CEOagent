from datetime import date, datetime
from decimal import Decimal

from .auth import hash_password
from .finance import sync_project_cost
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
    Opportunity,
    OpportunityFollow,
    Org,
    Position,
    Product,
    Project,
    ProjectMember,
    Role,
    TaxRate,
    User,
    SessionLocal,
)


def seed():
    db = SessionLocal()
    try:
        if db.query(User).count() > 0:
            return
        roles = [
            Role(role_code="ADMIN", role_name="超级管理员", permissions="*", description="全部权限", status=1),
            Role(role_code="EDITOR", role_name="主数据编辑", permissions="md.*,crm.*", description="主数据 + CRM 增删改查", status=1),
            Role(role_code="VIEWER", role_name="只读用户", permissions="md.*.view,crm.*.view", description="主数据 + CRM 只读", status=1),
        ]
        db.add_all(roles)
        db.flush()

        company = Company(
            company_id=1,
            company_code="LY",
            company_fullname="深圳市链宇技术有限公司",
            company_shortname="链宇科技",
            unified_social_credit="91440300MA5EXAMPLE",
            tax_number="91440300MA5EXAMPLE",
            invoice_title="深圳市链宇技术有限公司",
            registered_address="深圳市南山区科技园",
            office_address="深圳市南山区科技园",
            contact_person="刘洋",
            contact_phone="0755-88888888",
            bank_name="招商银行深圳分行",
            bank_account="755900000000000",
            currency_code="CNY",
            is_group=True,
            status=1,
            effective_start_date=date(2020, 1, 1),
        )
        db.add(company)
        db.flush()

        orgs = [
            Org(company_id=1, parent_id=0, org_code="LY", org_name="链宇集团", org_type="GROUP", level=1, sort_order=1, status=1),
            Org(company_id=1, parent_id=0, org_code="LY-SALES", org_name="销售中心", org_type="DEPT", level=1, sort_order=2, status=1),
            Org(company_id=1, parent_id=0, org_code="LY-DELIVERY", org_name="交付中心", org_type="DEPT", level=1, sort_order=3, status=1),
            Org(company_id=1, parent_id=0, org_code="LY-FIN", org_name="财务部", org_type="DEPT", level=1, sort_order=4, status=1),
            Org(company_id=1, parent_id=0, org_code="LY-HR", org_name="人力行政部", org_type="DEPT", level=1, sort_order=5, status=1),
        ]
        db.add_all(orgs)
        db.flush()
        parent = {o.org_code: o for o in orgs}
        for o in orgs:
            if o.org_code == "LY":
                o.parent_id = 0
                o.ancestors = "0"
                continue
            if o.parent_id == 0:
                o.parent_id = parent["LY"].id
                o.ancestors = f"0,{parent['LY'].id}"
        data_org = Org(
            company_id=1,
            parent_id=parent["LY-DELIVERY"].id,
            ancestors=f"0,{parent['LY'].id},{parent['LY-DELIVERY'].id}",
            org_code="LY-DELIVERY-DATA",
            org_name="数据交付部",
            org_type="DEPT",
            level=2,
            sort_order=1,
            status=1,
        )
        db.add(data_org)
        db.flush()
        org_map = {o.org_code: o for o in orgs + [data_org]}

        positions = [
            Position(company_id=1, position_code="PM", position_name="项目经理", position_seq="交付", job_family_code="DELIVERY", job_grade_code="P6", level_range="P5-P7", org_id=org_map["LY-DELIVERY"].id, is_management=True, position_category="MANAGEMENT", status=1),
            Position(company_id=1, position_code="CONSULTANT", position_name="高级顾问", position_seq="咨询", job_family_code="CONSULTING", job_grade_code="P5", level_range="P4-P6", org_id=data_org.id, position_category="CONSULTANT", status=1),
            Position(company_id=1, position_code="DEV", position_name="开发工程师", position_seq="技术", job_family_code="TECH", job_grade_code="P4", level_range="P3-P5", org_id=data_org.id, position_category="PROFESSIONAL", status=1),
            Position(company_id=1, position_code="SALES", position_name="销售经理", position_seq="销售", job_family_code="SALES", job_grade_code="P5", level_range="P4-P6", org_id=org_map["LY-SALES"].id, position_category="PROFESSIONAL", status=1),
            Position(company_id=1, position_code="FIN", position_name="财务经理", position_seq="职能", job_family_code="FINANCE", job_grade_code="P6", level_range="P5-P7", org_id=org_map["LY-FIN"].id, is_management=True, position_category="MANAGEMENT", status=1),
            Position(company_id=1, position_code="HR", position_name="HR经理", position_seq="职能", job_family_code="HR", job_grade_code="P6", level_range="P5-P7", org_id=org_map["LY-HR"].id, is_management=True, position_category="MANAGEMENT", status=1),
        ]
        db.add_all(positions)
        db.flush()
        pos_map = {p.position_code: p for p in positions}

        employees = [
            Employee(company_id=1, job_number="E001", employee_name="张伟", gender="MALE", mobile_phone="13800000001", work_email="zhangwei@example.com", org_id=org_map["LY-DELIVERY"].id, org_name="交付中心", position_id=pos_map["PM"].id, position_name="项目经理", position_level="P6", employment_type="FULL_TIME", party_type="INTERNAL", work_status="ACTIVE", entry_date=date(2021, 3, 1), is_consultant=False),
            Employee(company_id=1, job_number="E002", employee_name="李娜", gender="FEMALE", mobile_phone="13800000002", work_email="lina@example.com", org_id=data_org.id, org_name="数据交付部", position_id=pos_map["CONSULTANT"].id, position_name="高级顾问", position_level="P5", manager_id=None, employment_type="FULL_TIME", party_type="INTERNAL", work_status="ACTIVE", entry_date=date(2022, 6, 1), is_consultant=False),
            Employee(company_id=1, job_number="E003", employee_name="王强", gender="MALE", mobile_phone="13800000003", work_email="wangqiang@example.com", org_id=data_org.id, org_name="数据交付部", position_id=pos_map["DEV"].id, position_name="开发工程师", position_level="P4", employment_type="FULL_TIME", party_type="INTERNAL", work_status="ACTIVE", entry_date=date(2023, 2, 1), is_consultant=False),
            Employee(company_id=1, job_number="E004", employee_name="赵敏", gender="FEMALE", mobile_phone="13800000004", work_email="zhaomin@example.com", org_id=org_map["LY-SALES"].id, org_name="销售中心", position_id=pos_map["SALES"].id, position_name="销售经理", position_level="P5", employment_type="FULL_TIME", party_type="INTERNAL", work_status="ACTIVE", entry_date=date(2021, 9, 1), is_consultant=False),
            Employee(company_id=1, job_number="E005", employee_name="陈静", gender="FEMALE", mobile_phone="13800000005", work_email="chenjing@example.com", org_id=org_map["LY-FIN"].id, org_name="财务部", position_id=pos_map["FIN"].id, position_name="财务经理", position_level="P6", employment_type="FULL_TIME", party_type="INTERNAL", work_status="ACTIVE", entry_date=date(2020, 5, 1), is_consultant=False),
            Employee(company_id=1, job_number="E006", employee_name="刘洋", gender="MALE", mobile_phone="13800000006", work_email="liuyang@example.com", org_id=org_map["LY-HR"].id, org_name="人力行政部", position_id=pos_map["HR"].id, position_name="HR经理", position_level="P6", employment_type="FULL_TIME", party_type="INTERNAL", work_status="ACTIVE", entry_date=date(2020, 1, 1), is_consultant=False),
        ]
        db.add_all(employees)
        db.flush()
        emp_map = {e.job_number: e for e in employees}
        for code in ("E002", "E003"):
            emp_map[code].manager_id = emp_map["E001"].id
        for code in ("E001", "E004", "E005", "E006"):
            pass

        org_map["LY-DELIVERY"].manager_id = emp_map["E001"].id
        org_map["LY-DELIVERY"].manager_name = "张伟"
        org_map["LY-SALES"].manager_id = emp_map["E004"].id
        org_map["LY-SALES"].manager_name = "赵敏"
        org_map["LY-FIN"].manager_id = emp_map["E005"].id
        org_map["LY-FIN"].manager_name = "陈静"
        org_map["LY-HR"].manager_id = emp_map["E006"].id
        org_map["LY-HR"].manager_name = "刘洋"
        data_org.manager_id = emp_map["E001"].id
        data_org.manager_name = "张伟"
        db.flush()

        users = [
            User(company_id=1, username="admin", password_hash=hash_password("Admin@2026"), real_name="系统管理员", email="admin@example.com", role_id=roles[0].id, user_type="INTERNAL", status=1),
            User(company_id=1, username="editor", password_hash=hash_password("Editor@2026"), real_name="张伟", email="zhangwei@example.com", employee_id=emp_map["E001"].id, org_id=org_map["LY-DELIVERY"].id, role_id=roles[1].id, user_type="INTERNAL", status=1),
            User(company_id=1, username="viewer", password_hash=hash_password("Viewer@2026"), real_name="李娜", email="lina@example.com", employee_id=emp_map["E002"].id, org_id=data_org.id, role_id=roles[2].id, user_type="INTERNAL", status=1),
        ]
        db.add_all(users)
        db.flush()

        customers = [
            Customer(
                company_id=1,
                customer_code="C001",
                customer_name="华夏制造集团有限公司",
                customer_short_name="华夏制造",
                standard_name="华夏制造集团有限公司",
                customer_type="ENTERPRISE",
                customer_level="A",
                customer_classify="A",
                customer_source="老客户转介绍",
                industry_code="C36",
                industry_l1="制造业",
                industry_l2="装备制造",
                customer_scale="大型",
                customer_nature="民营",
                customer_status="ACTIVE",
                region_code="440300",
                province="广东省",
                city="深圳市",
                district="南山区",
                address="深圳市南山区科技园",
                website="https://www.huaxia.example.com",
                manager_id=emp_map["E004"].id,
                manager_name="赵敏",
                follower_id=emp_map["E004"].id,
                follower_name="赵敏",
                unified_social_credit="91440300MA5C001X",
                tax_number="91440300MA5C001X",
                invoice_title="华夏制造集团有限公司",
                register_address="深圳市南山区科技园",
                bank_name="中国银行深圳分行",
                bank_account="744000000001",
                credit_level="AAA",
                credit_limit=Decimal("5000000"),
                payment_cycle_days=45,
                payment_offset_months=2,
                settlement_currency="CNY",
                deal_flag=True,
                customer_tags="重点客户,制造业",
            ),
            Customer(
                company_id=1,
                customer_code="C002",
                customer_name="星辰能源股份有限公司",
                customer_short_name="星辰能源",
                standard_name="星辰能源股份有限公司",
                customer_type="ENTERPRISE",
                customer_level="B",
                customer_classify="B",
                customer_source="市场活动",
                industry_code="D44",
                industry_l1="能源",
                industry_l2="新能源",
                customer_scale="大型",
                customer_status="POTENTIAL",
                region_code="320500",
                province="江苏省",
                city="苏州市",
                district="工业园区",
                address="苏州市工业园区",
                manager_id=emp_map["E004"].id,
                manager_name="赵敏",
                follower_id=emp_map["E004"].id,
                follower_name="赵敏",
                unified_social_credit="91320500MA5C002X",
                tax_number="91320500MA5C002X",
                invoice_title="星辰能源股份有限公司",
                credit_level="AA",
                credit_limit=Decimal("3000000"),
                payment_cycle_days=60,
                payment_offset_months=3,
                settlement_currency="CNY",
                customer_tags="新能源,潜力客户",
            ),
            Customer(
                company_id=1,
                customer_code="C003",
                customer_name="云海科技有限公司",
                customer_short_name="云海科技",
                standard_name="云海科技有限公司",
                customer_type="ENTERPRISE",
                customer_level="B",
                customer_classify="B",
                customer_source="官网线索",
                industry_code="I65",
                industry_l1="信息传输、软件和信息技术服务业",
                customer_scale="中型",
                customer_status="ACTIVE",
                region_code="310000",
                province="上海市",
                city="上海市",
                district="浦东新区",
                address="上海市浦东新区张江",
                manager_id=emp_map["E004"].id,
                manager_name="赵敏",
                follower_id=emp_map["E004"].id,
                follower_name="赵敏",
                unified_social_credit="91310115MA5C003X",
                tax_number="91310115MA5C003X",
                invoice_title="云海科技有限公司",
                payment_cycle_days=30,
                payment_offset_months=1,
                settlement_currency="CNY",
                customer_tags="科技,成长型",
            ),
        ]
        db.add_all(customers)
        db.flush()
        cust_map = {c.customer_code: c for c in customers}

        contacts = [
            CustomerContact(company_id=1, customer_id=cust_map["C001"].id, contact_name="王建国", contact_title="采购总监", contact_gender="MALE", contact_mobile="13900000001", contact_email="wangjianguo@huaxia.example.com", department="采购部", contact_type="BUSINESS", is_primary=True, is_decision_maker=True, sort_order=1, status="ACTIVE"),
            CustomerContact(company_id=1, customer_id=cust_map["C001"].id, contact_name="李梅", contact_title="财务经理", contact_gender="FEMALE", contact_mobile="13900000002", contact_email="limei@huaxia.example.com", department="财务部", contact_type="FINANCE", is_primary=False, is_decision_maker=False, sort_order=2, status="ACTIVE"),
            CustomerContact(company_id=1, customer_id=cust_map["C002"].id, contact_name="周涛", contact_title="信息总监", contact_gender="MALE", contact_mobile="13900000003", contact_email="zhoutao@xingchen.example.com", department="信息中心", contact_type="BUSINESS", is_primary=True, is_decision_maker=True, sort_order=1, status="ACTIVE"),
            CustomerContact(company_id=1, customer_id=cust_map["C003"].id, contact_name="孙悦", contact_title="技术负责人", contact_gender="FEMALE", contact_mobile="13900000004", contact_email="sunyue@yunhai.example.com", department="技术部", contact_type="DELIVERY", is_primary=True, is_decision_maker=False, sort_order=1, status="ACTIVE"),
        ]
        db.add_all(contacts)

        addresses = [
            CustomerAddress(company_id=1, customer_id=cust_map["C001"].id, address_type="REGISTERED", province_name="广东省", city_name="深圳市", district_name="南山区", region_code="440300", detail_address="科技园南区华夏大厦", contact_person="王建国", contact_phone="13900000001", is_default=True, sort_order=1, status="ACTIVE"),
            CustomerAddress(company_id=1, customer_id=cust_map["C001"].id, address_type="BILLING", province_name="广东省", city_name="深圳市", district_name="南山区", region_code="440300", detail_address="科技园南区华夏大厦 18 楼财务部", contact_person="李梅", contact_phone="13900000002", is_default=False, sort_order=2, status="ACTIVE"),
            CustomerAddress(company_id=1, customer_id=cust_map["C002"].id, address_type="OFFICE", province_name="江苏省", city_name="苏州市", district_name="工业园区", region_code="320500", detail_address="星湖街 88 号星辰能源大厦", contact_person="周涛", contact_phone="13900000003", is_default=True, sort_order=1, status="ACTIVE"),
            CustomerAddress(company_id=1, customer_id=cust_map["C003"].id, address_type="OFFICE", province_name="上海市", city_name="上海市", district_name="浦东新区", region_code="310000", detail_address="张江高科技园区云海大厦", contact_person="孙悦", contact_phone="13900000004", is_default=True, sort_order=1, status="ACTIVE"),
        ]
        db.add_all(addresses)
        db.flush()

        products = [
            Product(company_id=1, product_code="P001", product_name="数字化转型咨询", product_type="SERVICE", category_code="CONSULTING", unit="人天", tax_rate=Decimal("0.06"), standard_price=Decimal("2200"), sales_price=Decimal("3500"), currency="CNY", status=1),
            Product(company_id=1, product_code="P002", product_name="数据中台实施", product_type="SERVICE", category_code="IMPLEMENT", unit="人天", tax_rate=Decimal("0.06"), standard_price=Decimal("2800"), sales_price=Decimal("4200"), currency="CNY", status=1),
            Product(company_id=1, product_code="P003", product_name="运维服务", product_type="SERVICE", category_code="OPERATION", unit="月", tax_rate=Decimal("0.06"), standard_price=Decimal("30000"), sales_price=Decimal("50000"), currency="CNY", status=1),
        ]
        db.add_all(products)
        db.flush()
        product_map = {p.product_code: p for p in products}

        tax_rates = [
            TaxRate(company_id=1, contract_type_code="CONSULTING", contract_type_name="咨询服务", effective_date=date(2026, 1, 1), tax_rate=Decimal("0.06"), surtax_rate=Decimal("0.12"), description="咨询服务增值税6%", status=1),
            TaxRate(company_id=1, contract_type_code="IMPLEMENT", contract_type_name="技术服务", effective_date=date(2026, 1, 1), tax_rate=Decimal("0.06"), surtax_rate=Decimal("0.12"), description="技术服务增值税6%", status=1),
            TaxRate(company_id=1, contract_type_code="SOFTWARE", contract_type_name="软件销售", effective_date=date(2026, 1, 1), tax_rate=Decimal("0.13"), surtax_rate=Decimal("0.12"), description="软件销售增值税13%", status=1),
        ]
        db.add_all(tax_rates)
        db.flush()

        projects = [
            Project(
                company_id=1,
                project_code="PRJ001",
                project_name="华夏制造数字化转型一期",
                project_type="CONSULTING",
                project_level="LARGE",
                customer_id=cust_map["C001"].id,
                customer_name=cust_map["C001"].customer_name,
                signed_company_id=company.id,
                signed_company_name=company.company_shortname,
                pm_id=emp_map["E001"].id,
                pm_name="张伟",
                sales_id=emp_map["E004"].id,
                sales_name="赵敏",
                org_id=org_map["LY-DELIVERY"].id,
                org_code="LY-DELIVERY",
                org_name="交付中心",
                planned_start_date=date(2026, 2, 1),
                planned_end_date=date(2026, 8, 31),
                actual_start_date=date(2026, 2, 5),
                estimated_work_days=Decimal("420"),
                budget_amount=Decimal("1200000"),
                budget_labor_amount=Decimal("900000"),
                budget_expense_amount=Decimal("300000"),
                contract_amount=Decimal("1500000"),
                actual_cost=Decimal("360000"),
                actual_labor_cost=Decimal("300000"),
                actual_expense_cost=Decimal("60000"),
                cost_variance=Decimal("-840000"),
                cost_variance_rate=Decimal("-0.70"),
                currency="CNY",
                settlement_mode="TIME_MATERIAL",
                is_billable=True,
                status="IN_PROGRESS",
                progress=35,
                current_milestone="上线验收",
                sign_date=date(2026, 1, 15),
                priority="HIGH",
                description="为华夏制造提供数字化转型规划与数据中台建设。",
            ),
            Project(
                company_id=1,
                project_code="PRJ002",
                project_name="星辰能源数据中台项目",
                project_type="IT_IMPLEMENT",
                project_level="MEDIUM",
                customer_id=cust_map["C002"].id,
                customer_name=cust_map["C002"].customer_name,
                signed_company_id=company.id,
                signed_company_name=company.company_shortname,
                pm_id=emp_map["E001"].id,
                pm_name="张伟",
                sales_id=emp_map["E004"].id,
                sales_name="赵敏",
                org_id=org_map["LY-DELIVERY"].id,
                org_code="LY-DELIVERY",
                org_name="交付中心",
                planned_start_date=date(2026, 4, 1),
                planned_end_date=date(2026, 10, 31),
                estimated_work_days=Decimal("260"),
                budget_amount=Decimal("800000"),
                budget_labor_amount=Decimal("600000"),
                budget_expense_amount=Decimal("200000"),
                contract_amount=Decimal("900000"),
                currency="CNY",
                settlement_mode="MILESTONE",
                is_billable=True,
                status="PREPARING",
                progress=5,
                current_milestone="预付款",
                sign_date=date(2026, 3, 1),
                priority="MEDIUM",
                description="星辰能源数据中台规划与实施。",
            ),
        ]
        db.add_all(projects)
        db.flush()
        proj_map = {p.project_code: p for p in projects}

        contracts = [
            Contract(
                company_id=1,
                contract_no="HT2026001",
                sub_contract_no="",
                contract_name="华夏制造数字化转型一期合同",
                contract_type_code="CONSULTING",
                contract_type_name="咨询服务",
                contract_category="SALES",
                customer_id=cust_map["C001"].id,
                customer_name=cust_map["C001"].customer_name,
                org_id=org_map["LY-DELIVERY"].id,
                org_code="LY-DELIVERY",
                org_name="交付中心",
                product_line_code="DIGITAL",
                product_line_name="数字化转型",
                manager_id=emp_map["E001"].id,
                manager_name="张伟",
                sales_manager_id=emp_map["E004"].id,
                sales_manager_name="赵敏",
                owner_id=emp_map["E004"].id,
                owner_name="赵敏",
                contract_amount=Decimal("1500000"),
                currency="CNY",
                exchange_rate=Decimal("1"),
                tax_rate=Decimal("0.06"),
                tax_amount=Decimal("84905.66"),
                amount_excl_tax=Decimal("1415094.34"),
                amount_incl_tax=Decimal("1500000"),
                sign_date=date(2026, 1, 15),
                start_date=date(2026, 2, 1),
                end_date=date(2026, 8, 31),
                approval_status="APPROVED",
                sign_status="SIGNED",
                execution_status="EXECUTING",
                invoice_status="PARTIAL",
                payment_status="PARTIAL",
                payment_method="银行转账",
                payment_terms="预付款30%，上线验收40%，质保金30%",
                contract_version_no="V1.0",
                remark="重点客户合同",
            ),
            Contract(
                company_id=1,
                contract_no="HT2026002",
                sub_contract_no="",
                contract_name="星辰能源数据中台合同",
                contract_type_code="IMPLEMENT",
                contract_type_name="技术服务",
                contract_category="SALES",
                customer_id=cust_map["C002"].id,
                customer_name=cust_map["C002"].customer_name,
                org_id=org_map["LY-DELIVERY"].id,
                org_code="LY-DELIVERY",
                org_name="交付中心",
                product_line_code="DATA",
                product_line_name="数据中台",
                manager_id=emp_map["E001"].id,
                manager_name="张伟",
                sales_manager_id=emp_map["E004"].id,
                sales_manager_name="赵敏",
                owner_id=emp_map["E004"].id,
                owner_name="赵敏",
                contract_amount=Decimal("900000"),
                currency="CNY",
                exchange_rate=Decimal("1"),
                tax_rate=Decimal("0.06"),
                tax_amount=Decimal("50943.40"),
                amount_excl_tax=Decimal("849056.60"),
                amount_incl_tax=Decimal("900000"),
                sign_date=date(2026, 3, 1),
                start_date=date(2026, 4, 1),
                end_date=date(2026, 10, 31),
                approval_status="APPROVED",
                sign_status="SIGNED",
                execution_status="NOT_STARTED",
                invoice_status="NOT_STARTED",
                payment_status="UNPAID",
                payment_method="银行转账",
                payment_terms="预付款30%，验收50%，质保20%",
                contract_version_no="V1.0",
            ),
        ]
        db.add_all(contracts)
        db.flush()
        con_map = {c.contract_no: c for c in contracts}

        milestones = [
            ContractMilestone(company_id=1, contract_id=con_map["HT2026001"].id, milestone_code="M1", milestone_name="预付款", milestone_type="ADVANCE", payment_ratio=Decimal("0.30"), milestone_amount=Decimal("450000"), plan_date=date(2026, 2, 1), actual_date=date(2026, 2, 10), invoice_status="INVOICED", milestone_status="COMPLETED", expected_payment_date=date(2026, 3, 1), actual_payment_date=date(2026, 2, 25), expected_payment_amount=Decimal("450000"), actual_payment_amount=Decimal("450000"), invoiced_amount=Decimal("450000"), paid_amount=Decimal("450000"), payment_status="PAID", sort_order=1),
            ContractMilestone(company_id=1, contract_id=con_map["HT2026001"].id, milestone_code="M2", milestone_name="上线验收", milestone_type="ACCEPTANCE", payment_ratio=Decimal("0.40"), milestone_amount=Decimal("600000"), plan_date=date(2026, 6, 30), invoice_status="PARTIAL", milestone_status="IN_PROGRESS", expected_payment_date=date(2026, 8, 15), expected_payment_amount=Decimal("600000"), actual_payment_amount=Decimal("200000"), invoiced_amount=Decimal("300000"), paid_amount=Decimal("200000"), payment_status="PARTIAL", sort_order=2),
            ContractMilestone(company_id=1, contract_id=con_map["HT2026001"].id, milestone_code="M3", milestone_name="质保金", milestone_type="WARRANTY", payment_ratio=Decimal("0.30"), milestone_amount=Decimal("450000"), plan_date=date(2026, 8, 31), invoice_status="UNINVOICED", milestone_status="PENDING", expected_payment_date=date(2026, 10, 31), expected_payment_amount=Decimal("450000"), payment_status="UNPAID", sort_order=3),
            ContractMilestone(company_id=1, contract_id=con_map["HT2026002"].id, milestone_code="M1", milestone_name="预付款", milestone_type="ADVANCE", payment_ratio=Decimal("0.30"), milestone_amount=Decimal("270000"), plan_date=date(2026, 4, 1), invoice_status="UNINVOICED", milestone_status="PENDING", expected_payment_date=date(2026, 5, 1), expected_payment_amount=Decimal("270000"), payment_status="UNPAID", sort_order=1),
            ContractMilestone(company_id=1, contract_id=con_map["HT2026002"].id, milestone_code="M2", milestone_name="验收款", milestone_type="ACCEPTANCE", payment_ratio=Decimal("0.50"), milestone_amount=Decimal("450000"), plan_date=date(2026, 9, 30), invoice_status="UNINVOICED", milestone_status="PENDING", expected_payment_date=date(2026, 11, 15), expected_payment_amount=Decimal("450000"), payment_status="UNPAID", sort_order=2),
            ContractMilestone(company_id=1, contract_id=con_map["HT2026002"].id, milestone_code="M3", milestone_name="质保金", milestone_type="WARRANTY", payment_ratio=Decimal("0.20"), milestone_amount=Decimal("180000"), plan_date=date(2026, 10, 31), invoice_status="UNINVOICED", milestone_status="PENDING", expected_payment_date=date(2026, 12, 31), expected_payment_amount=Decimal("180000"), payment_status="UNPAID", sort_order=3),
        ]
        db.add_all(milestones)

        members = [
            ProjectMember(company_id=1, project_id=proj_map["PRJ001"].id, employee_id=emp_map["E001"].id, job_number="E001", member_name="张伟", role_in_project="PM", work_nature="SETTLE", estimated_work_days=Decimal("120"), allocation_rate=Decimal("60"), join_date=date(2026, 2, 1), is_manager=True, is_primary=True, member_type="INTERNAL", status=1),
            ProjectMember(company_id=1, project_id=proj_map["PRJ001"].id, employee_id=emp_map["E002"].id, job_number="E002", member_name="李娜", role_in_project="CONSULTANT", work_nature="SETTLE", estimated_work_days=Decimal("180"), allocation_rate=Decimal("100"), join_date=date(2026, 2, 1), is_primary=True, member_type="INTERNAL", status=1),
            ProjectMember(company_id=1, project_id=proj_map["PRJ001"].id, employee_id=emp_map["E003"].id, job_number="E003", member_name="王强", role_in_project="DEVELOPER", work_nature="SETTLE", estimated_work_days=Decimal("120"), allocation_rate=Decimal("80"), join_date=date(2026, 2, 15), member_type="INTERNAL", status=1),
            ProjectMember(company_id=1, project_id=proj_map["PRJ002"].id, employee_id=emp_map["E001"].id, job_number="E001", member_name="张伟", role_in_project="PM", work_nature="SETTLE", estimated_work_days=Decimal("80"), allocation_rate=Decimal("40"), join_date=date(2026, 4, 1), is_manager=True, is_primary=True, member_type="INTERNAL", status=1),
            ProjectMember(company_id=1, project_id=proj_map["PRJ002"].id, employee_id=emp_map["E002"].id, job_number="E002", member_name="李娜", role_in_project="CONSULTANT", work_nature="SETTLE", estimated_work_days=Decimal("100"), allocation_rate=Decimal("60"), join_date=date(2026, 4, 1), is_primary=True, member_type="INTERNAL", status=1),
        ]
        db.add_all(members)

        links = [
            ContractProject(company_id=1, project_id=proj_map["PRJ001"].id, contract_id=con_map["HT2026001"].id, relation_type="MAIN", is_primary=True),
            ContractProject(company_id=1, project_id=proj_map["PRJ002"].id, contract_id=con_map["HT2026002"].id, relation_type="MAIN", is_primary=True),
        ]
        db.add_all(links)

        opportunities = [
            Opportunity(company_id=1, opportunity_no="OPP2026001", name="华夏制造二期数据治理商机", customer_id=cust_map["C001"].id, customer_name=cust_map["C001"].customer_name, stage="STAGE_03", stage_rate=Decimal("20"), amount=Decimal("800000"), expected_deal_date=date(2026, 12, 15), expected_sign_date=date(2026, 12, 31), status="IN_PROGRESS", sales_status="NORMAL", project_level="LARGE", owner_id=emp_map["E004"].id, owner_name="赵敏", sales_person_id=emp_map["E004"].id, sales_person_name="赵敏", product_id=product_map["P001"].id, product_name="数字化转型咨询", source_type="MANUAL", description="华夏制造二期数据治理规划，客户预算已立项。"),
            Opportunity(company_id=1, opportunity_no="OPP2026002", name="星辰能源数据中台商机", customer_id=cust_map["C002"].id, customer_name=cust_map["C002"].customer_name, stage="STAGE_06", stage_rate=Decimal("90"), amount=Decimal("900000"), expected_deal_date=date(2026, 3, 1), expected_sign_date=date(2026, 3, 1), status="IN_PROGRESS", sales_status="KEY", project_level="MEDIUM", owner_id=emp_map["E004"].id, owner_name="赵敏", sales_person_id=emp_map["E004"].id, sales_person_name="赵敏", product_id=product_map["P002"].id, product_name="数据中台实施", source_type="MANUAL", description="星辰能源数据中台项目，已进入合同审批阶段。"),
            Opportunity(company_id=1, opportunity_no="OPP2026003", name="云海科技数据咨询商机", customer_id=cust_map["C003"].id, customer_name=cust_map["C003"].customer_name, stage="STAGE_02", stage_rate=Decimal("10"), amount=Decimal("300000"), expected_deal_date=date(2026, 11, 30), expected_sign_date=date(2026, 12, 15), status="IN_PROGRESS", sales_status="NORMAL", project_level="SMALL", owner_id=emp_map["E004"].id, owner_name="赵敏", sales_person_id=emp_map["E004"].id, sales_person_name="赵敏", product_id=product_map["P001"].id, product_name="数字化转型咨询", source_type="MANUAL", description="云海科技数据治理咨询，处于需求确认阶段。"),
            Opportunity(company_id=1, opportunity_no="OPP2026004", name="华夏制造运维续签商机", customer_id=cust_map["C001"].id, customer_name=cust_map["C001"].customer_name, stage="STAGE_07", stage_rate=Decimal("100"), amount=Decimal("500000"), expected_deal_date=date(2026, 9, 30), expected_sign_date=date(2026, 9, 30), status="WON", sales_status="NORMAL", project_level="SMALL", owner_id=emp_map["E004"].id, owner_name="赵敏", sales_person_id=emp_map["E004"].id, sales_person_name="赵敏", product_id=product_map["P003"].id, product_name="运维服务", source_type="MANUAL", description="华夏制造年度运维续签，已赢单。"),
            Opportunity(company_id=1, opportunity_no="OPP2026005", name="华夏制造数字化转型一期商机", customer_id=cust_map["C001"].id, customer_name=cust_map["C001"].customer_name, stage="STAGE_07", stage_rate=Decimal("100"), amount=Decimal("1500000"), expected_deal_date=date(2026, 1, 15), expected_sign_date=date(2026, 1, 15), status="WON", sales_status="KEY", project_level="LARGE", owner_id=emp_map["E004"].id, owner_name="赵敏", sales_person_id=emp_map["E004"].id, sales_person_name="赵敏", product_id=product_map["P001"].id, product_name="数字化转型咨询", source_type="MANUAL", description="华夏制造数字化转型一期，已签约。"),
        ]
        db.add_all(opportunities)
        db.flush()
        opp_map = {o.opportunity_no: o for o in opportunities}

        follows = [
            OpportunityFollow(company_id=1, opportunity_id=opp_map["OPP2026001"].id, opportunity_name=opp_map["OPP2026001"].name, customer_id=cust_map["C001"].id, customer_name=cust_map["C001"].customer_name, follow_time=date(2026, 11, 1), follower_id=emp_map["E004"].id, follower_name="赵敏", contact_name="王建国", content="拜访客户采购总监，确认二期数据治理预算已立项，客户希望 12 月完成方案。", plan_title="提交二期方案建议书", plan_content="整理数据治理方法论和标杆案例，11 月 20 日前提交。", plan_time=date(2026, 11, 20), plan_status="PENDING", status="DONE"),
            OpportunityFollow(company_id=1, opportunity_id=opp_map["OPP2026001"].id, opportunity_name=opp_map["OPP2026001"].name, customer_id=cust_map["C001"].id, customer_name=cust_map["C001"].customer_name, follow_time=date(2026, 11, 10), follower_id=emp_map["E004"].id, follower_name="赵敏", contact_name="王建国", content="与客户数据负责人沟通，确认一期数据中台使用效果良好，二期可扩大范围。", plan_title="安排方案汇报", plan_content="约客户高层 11 月底进行方案汇报。", plan_time=date(2026, 11, 28), plan_status="PENDING", status="DONE"),
            OpportunityFollow(company_id=1, opportunity_id=opp_map["OPP2026002"].id, opportunity_name=opp_map["OPP2026002"].name, customer_id=cust_map["C002"].id, customer_name=cust_map["C002"].customer_name, follow_time=date(2026, 2, 20), follower_id=emp_map["E004"].id, follower_name="赵敏", contact_name="周涛", content="向客户信息中心汇报数据中台方案，客户认可技术路线，要求补充实施计划和报价。", plan_title="商务谈判", plan_content="确认合同金额和付款节点，推进合同审批。", plan_time=date(2026, 2, 28), plan_status="DONE", status="DONE"),
            OpportunityFollow(company_id=1, opportunity_id=opp_map["OPP2026003"].id, opportunity_name=opp_map["OPP2026003"].name, customer_id=cust_map["C003"].id, customer_name=cust_map["C003"].customer_name, follow_time=date(2026, 11, 5), follower_id=emp_map["E004"].id, follower_name="赵敏", contact_name="孙悦", content="与云海科技技术负责人完成需求调研，客户关注数据治理和数据资产盘点。", plan_title="输出需求调研报告", plan_content="一周内输出调研报告和初步方案。", plan_time=date(2026, 11, 15), plan_status="PENDING", status="DONE"),
            OpportunityFollow(company_id=1, opportunity_id=opp_map["OPP2026004"].id, opportunity_name=opp_map["OPP2026004"].name, customer_id=cust_map["C001"].id, customer_name=cust_map["C001"].customer_name, follow_time=date(2026, 9, 15), follower_id=emp_map["E004"].id, follower_name="赵敏", contact_name="王建国", content="运维续签商务沟通完成，客户确认续签一年。", plan_title="合同签署", plan_content="跟进合同盖章和回款。", plan_time=date(2026, 9, 30), plan_status="DONE", status="DONE"),
            OpportunityFollow(company_id=1, opportunity_id=opp_map["OPP2026005"].id, opportunity_name=opp_map["OPP2026005"].name, customer_id=cust_map["C001"].id, customer_name=cust_map["C001"].customer_name, follow_time=date(2026, 1, 5), follower_id=emp_map["E004"].id, follower_name="赵敏", contact_name="王建国", content="完成合同谈判，客户确认合同金额 150 万，分三期付款。", plan_title="合同签署", plan_content="1 月 15 日前完成合同签署。", plan_time=date(2026, 1, 15), plan_status="DONE", status="DONE"),
        ]
        db.add_all(follows)

        followers = [
            CustomerFollower(company_id=1, customer_id=cust_map["C001"].id, employee_id=emp_map["E004"].id, employee_name="赵敏", follower_type="SALES", is_primary=True, start_date=date(2021, 1, 1), status=1),
            CustomerFollower(company_id=1, customer_id=cust_map["C001"].id, employee_id=emp_map["E001"].id, employee_name="张伟", follower_type="DELIVERY", is_primary=False, start_date=date(2026, 2, 1), status=1),
            CustomerFollower(company_id=1, customer_id=cust_map["C002"].id, employee_id=emp_map["E004"].id, employee_name="赵敏", follower_type="SALES", is_primary=True, start_date=date(2025, 6, 1), status=1),
            CustomerFollower(company_id=1, customer_id=cust_map["C003"].id, employee_id=emp_map["E004"].id, employee_name="赵敏", follower_type="SALES", is_primary=True, start_date=date(2026, 9, 1), status=1),
        ]
        db.add_all(followers)

        opp_links = [
            ContractOpportunity(company_id=1, contract_id=con_map["HT2026001"].id, opportunity_id=opp_map["OPP2026005"].id),
            ContractOpportunity(company_id=1, contract_id=con_map["HT2026002"].id, opportunity_id=opp_map["OPP2026002"].id),
        ]
        db.add_all(opp_links)
        db.flush()

        dicts = [
            Dict(company_id=1, dict_code="ORG_TYPE", dict_name="组织类型", system_type="SYS", status=1),
            Dict(company_id=1, dict_code="EMPLOYMENT_TYPE", dict_name="用工类型", system_type="HR", status=1),
            Dict(company_id=1, dict_code="PROJECT_STATUS", dict_name="项目状态", system_type="PMT", status=1),
            Dict(company_id=1, dict_code="CONTRACT_STATUS", dict_name="合同状态", system_type="CRM", status=1),
            Dict(company_id=1, dict_code="CUSTOMER_STATUS", dict_name="客户状态", system_type="CRM", status=1),
        ]
        db.add_all(dicts)
        db.flush()
        dict_map = {d.dict_code: d for d in dicts}
        items = [
            DictItem(company_id=1, dict_id=dict_map["ORG_TYPE"].id, item_code="GROUP", item_name="集团", sort_order=1, status=1),
            DictItem(company_id=1, dict_id=dict_map["ORG_TYPE"].id, item_code="DEPT", item_name="部门", sort_order=2, status=1),
            DictItem(company_id=1, dict_id=dict_map["EMPLOYMENT_TYPE"].id, item_code="FULL_TIME", item_name="全职", sort_order=1, status=1),
            DictItem(company_id=1, dict_id=dict_map["EMPLOYMENT_TYPE"].id, item_code="EXTERNAL", item_name="外部合作", sort_order=2, status=1),
            DictItem(company_id=1, dict_id=dict_map["PROJECT_STATUS"].id, item_code="IN_PROGRESS", item_name="进行中", sort_order=1, status=1),
            DictItem(company_id=1, dict_id=dict_map["PROJECT_STATUS"].id, item_code="COMPLETED", item_name="已结项", sort_order=2, status=1),
            DictItem(company_id=1, dict_id=dict_map["CONTRACT_STATUS"].id, item_code="SIGNED", item_name="已签约", sort_order=1, status=1),
            DictItem(company_id=1, dict_id=dict_map["CONTRACT_STATUS"].id, item_code="EXECUTING", item_name="执行中", sort_order=2, status=1),
            DictItem(company_id=1, dict_id=dict_map["CUSTOMER_STATUS"].id, item_code="ACTIVE", item_name="活跃", sort_order=1, status=1),
            DictItem(company_id=1, dict_id=dict_map["CUSTOMER_STATUS"].id, item_code="POTENTIAL", item_name="潜在", sort_order=2, status=1),
        ]
        db.add_all(items)

        db.add(AuditLog(user_id=users[0].id, username="admin", action="INIT", entity="system", entity_id=0, detail="初始化平台底座与主数据种子", ip="127.0.0.1", create_time=datetime.now()))
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def ensure_finance_permissions():
    """给已有角色补充财务中心权限，兼容已初始化过的数据库。"""
    db = SessionLocal()
    try:
        for role_code, extra in (("EDITOR", "fin.*"), ("VIEWER", "fin.*.view")):
            role = db.query(Role).filter(Role.role_code == role_code, Role.deleted == 0).first()
            if not role:
                continue
            raw = (role.permissions or "").replace(" ", "")
            if extra not in raw:
                role.permissions = f"{raw},{extra}".strip(",")
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def seed_finance():
    """补充财务演示数据：项目成本、预算。已存在则跳过。"""
    db = SessionLocal()
    try:
        if db.query(FinanceCost).count() > 0 or db.query(FinanceBudget).count() > 0:
            return
        projects = {
            p.project_code: p
            for p in db.query(Project).filter(Project.deleted == 0).all()
        }
        contracts = {
            c.contract_no: c
            for c in db.query(Contract).filter(Contract.deleted == 0).all()
        }
        prj1 = projects.get("PRJ001")
        prj2 = projects.get("PRJ002")
        con1 = contracts.get("HT2026001")
        con2 = contracts.get("HT2026002")
        if not prj1 or not prj2 or not con1 or not con2:
            return

        def cost(project, contract, cost_type, category, when, amount, supplier="", employee=""):
            return FinanceCost(
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
                cost_category=category,
                cost_date=when,
                period=when.strftime("%Y-%m"),
                amount=Decimal(str(amount)),
                supplier_name=supplier,
                employee_name=employee,
                source="MANUAL",
                status="CONFIRMED",
                remark="财务初始化演示数据",
            )

        costs = [
            cost(prj1, con1, "LABOR", "项目人工", date(2026, 2, 28), 60000, employee="张伟"),
            cost(prj1, con1, "LABOR", "项目人工", date(2026, 3, 31), 60000, employee="李娜"),
            cost(prj1, con1, "LABOR", "项目人工", date(2026, 4, 30), 60000, employee="李娜"),
            cost(prj1, con1, "LABOR", "项目人工", date(2026, 5, 31), 60000, employee="王强"),
            cost(prj1, con1, "LABOR", "项目人工", date(2026, 6, 30), 60000, employee="王强"),
            cost(prj1, con1, "EXPENSE", "差旅办公", date(2026, 2, 15), 10000, supplier="携程商旅"),
            cost(prj1, con1, "EXPENSE", "差旅办公", date(2026, 3, 15), 10000, supplier="携程商旅"),
            cost(prj1, con1, "EXPENSE", "项目会议", date(2026, 4, 15), 15000, supplier="深圳会务"),
            cost(prj1, con1, "EXPENSE", "差旅办公", date(2026, 5, 15), 15000, supplier="携程商旅"),
            cost(prj1, con1, "EXPENSE", "资料采购", date(2026, 6, 15), 10000, supplier="京东企业购"),
            cost(prj2, con2, "LABOR", "项目人工", date(2026, 4, 30), 60000, employee="张伟"),
            cost(prj2, con2, "LABOR", "项目人工", date(2026, 5, 31), 60000, employee="李娜"),
            cost(prj2, con2, "EXPENSE", "差旅办公", date(2026, 4, 15), 30000, supplier="携程商旅"),
        ]
        db.add_all(costs)
        db.flush()

        company_budgets = [
            ("SIGNING", 3000000),
            ("REVENUE", 2400000),
            ("LABOR_COST", 1500000),
            ("EXPENSE", 500000),
            ("CASH_IN", 2200000),
        ]
        org_budgets = [
            ("SIGNING", 2400000),
            ("REVENUE", 2400000),
            ("LABOR_COST", 1500000),
            ("EXPENSE", 500000),
            ("CASH_IN", 2200000),
        ]
        budgets = []
        for category, amount in company_budgets:
            budgets.append(
                FinanceBudget(
                    company_id=1,
                    budget_year=2026,
                    budget_type="COMPANY",
                    category=category,
                    budget_amount=Decimal(str(amount)),
                    version="V1.0",
                    status="APPROVED",
                    remark="2026 年度公司预算",
                )
            )
        for category, amount in org_budgets:
            budgets.append(
                FinanceBudget(
                    company_id=1,
                    budget_year=2026,
                    budget_type="ORG",
                    org_id=prj1.org_id,
                    org_name=prj1.org_name,
                    category=category,
                    budget_amount=Decimal(str(amount)),
                    version="V1.0",
                    status="APPROVED",
                    remark="2026 年度交付中心预算",
                )
            )
        for project, contract, rows in (
            (prj1, con1, [("REVENUE", 1500000), ("LABOR_COST", 900000), ("EXPENSE", 300000)]),
            (prj2, con2, [("REVENUE", 900000), ("LABOR_COST", 600000), ("EXPENSE", 200000)]),
        ):
            for category, amount in rows:
                budgets.append(
                    FinanceBudget(
                        company_id=project.company_id or 1,
                        budget_year=2026,
                        budget_type="PROJECT",
                        project_id=project.id,
                        project_code=project.project_code,
                        project_name=project.project_name,
                        customer_id=project.customer_id,
                        customer_name=project.customer_name,
                        contract_id=contract.id,
                        contract_no=contract.contract_no,
                        category=category,
                        budget_amount=Decimal(str(amount)),
                        version="V1.0",
                        status="APPROVED",
                        remark="项目预算",
                    )
                )
        db.add_all(budgets)
        db.flush()
        db.commit()
        for project in (prj1, prj2):
            sync_project_cost(db, project.id)
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
