import os
from datetime import datetime

from sqlalchemy import (
    Boolean,
    Column,
    Date,
    DateTime,
    Index,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    create_engine,
)
from sqlalchemy.orm import declarative_base, sessionmaker

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./unified_mdm.db")
CONNECT_ARGS = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(DATABASE_URL, pool_pre_ping=True, connect_args=CONNECT_ARGS)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


class AuditMixin:
    created_by = Column(String(64), default="system")
    updated_by = Column(String(64), default="system")
    create_time = Column(DateTime, default=datetime.now)
    update_time = Column(DateTime, default=datetime.now, onupdate=datetime.now)
    version = Column(Integer, default=0, nullable=False)
    deleted = Column(Integer, default=0, nullable=False)


class MasterMixin(AuditMixin):
    company_id = Column(Integer, default=1)
    data_status = Column(String(20), default="ACTIVE")
    merged_to_id = Column(Integer)
    source_type = Column(String(20), default="MANUAL")
    effective_start_date = Column(Date)
    effective_end_date = Column(Date)
    remark = Column(Text)


class Company(Base, MasterMixin):
    __tablename__ = "md_company"
    id = Column(Integer, primary_key=True)
    company_code = Column(String(32), nullable=False)
    company_fullname = Column(String(200), nullable=False)
    company_shortname = Column(String(64))
    unified_social_credit = Column(String(64))
    tax_number = Column(String(64))
    invoice_title = Column(String(200))
    registered_address = Column(String(500))
    office_address = Column(String(500))
    contact_person = Column(String(100))
    contact_phone = Column(String(50))
    bank_name = Column(String(128))
    bank_account = Column(String(64))
    currency_code = Column(String(10), default="CNY")
    parent_company_id = Column(Integer, default=0)
    is_group = Column(Boolean, default=False)
    status = Column(Integer, default=1)
    __table_args__ = (UniqueConstraint("company_code", "deleted", name="uk_md_company_code"),)


class Org(Base, MasterMixin):
    __tablename__ = "md_org"
    id = Column(Integer, primary_key=True)
    parent_id = Column(Integer, default=0)
    ancestors = Column(String(512))
    org_code = Column(String(64), nullable=False)
    org_name = Column(String(128), nullable=False)
    org_type = Column(String(32), default="DEPT")
    manager_id = Column(Integer)
    manager_name = Column(String(100))
    cost_center_code = Column(String(64))
    profit_center_code = Column(String(64))
    description = Column(String(512))
    level = Column(Integer, default=1)
    sort_order = Column(Integer, default=0)
    status = Column(Integer, default=1)
    __table_args__ = (
        UniqueConstraint("company_id", "org_code", "deleted", name="uk_md_org_code"),
        Index("idx_md_org_parent", "parent_id"),
    )


class Position(Base, MasterMixin):
    __tablename__ = "md_position"
    id = Column(Integer, primary_key=True)
    position_code = Column(String(64), nullable=False)
    position_name = Column(String(128), nullable=False)
    position_seq = Column(String(32))
    job_family_code = Column(String(32))
    job_grade_code = Column(String(32))
    level_range = Column(String(32))
    org_id = Column(Integer)
    is_management = Column(Boolean, default=False)
    position_category = Column(String(32), default="PROFESSIONAL")
    job_description = Column(Text)
    requirement = Column(Text)
    status = Column(Integer, default=1)
    __table_args__ = (
        UniqueConstraint("company_id", "position_code", "deleted", name="uk_md_position_code"),
    )


class Employee(Base, MasterMixin):
    __tablename__ = "md_employee"
    id = Column(Integer, primary_key=True)
    job_number = Column(String(64), nullable=False)
    employee_name = Column(String(64), nullable=False)
    gender = Column(String(8))
    birthday = Column(Date)
    mobile_phone = Column(String(32))
    email = Column(String(128))
    work_email = Column(String(128))
    org_id = Column(Integer)
    org_name = Column(String(128))
    position_id = Column(Integer)
    position_name = Column(String(64))
    position_level = Column(String(32))
    manager_id = Column(Integer)
    employment_type = Column(String(50), default="FULL_TIME")
    party_type = Column(String(20), default="INTERNAL")
    work_status = Column(String(32), default="ACTIVE")
    entry_date = Column(Date)
    probation_months = Column(Integer)
    probation_end_date = Column(Date)
    regular_date = Column(Date)
    resign_date = Column(Date)
    resign_reason = Column(String(256))
    first_work_date = Column(Date)
    is_consultant = Column(Boolean, default=False)
    consultant_level = Column(String(50))
    primary_domain = Column(String(100))
    secondary_domain = Column(String(100))
    skill_tags = Column(String(500))
    consultant_type = Column(String(64))
    __table_args__ = (
        UniqueConstraint("company_id", "job_number", "deleted", name="uk_md_employee_job"),
        Index("idx_md_employee_org", "org_id"),
    )


class EmployeePrivate(Base, AuditMixin):
    __tablename__ = "md_employee_private"
    employee_id = Column(Integer, primary_key=True)
    id_card = Column(String(128))
    bank_name = Column(String(128))
    bank_account = Column(String(128))
    social_security_city = Column(String(64))
    social_security_no = Column(String(64))
    housing_fund_city = Column(String(64))
    housing_fund_account = Column(String(64))
    privacy_level = Column(String(20), default="HIGH")


class Role(Base, AuditMixin):
    __tablename__ = "sys_role"
    id = Column(Integer, primary_key=True)
    role_code = Column(String(64), nullable=False)
    role_name = Column(String(128), nullable=False)
    permissions = Column(Text, default="")
    description = Column(String(512))
    status = Column(Integer, default=1)
    __table_args__ = (UniqueConstraint("role_code", "deleted", name="uk_sys_role_code"),)


class User(Base, AuditMixin):
    __tablename__ = "md_user"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    username = Column(String(64), nullable=False)
    password_hash = Column(String(128), nullable=False)
    real_name = Column(String(64), nullable=False)
    email = Column(String(128))
    phone = Column(String(32))
    employee_id = Column(Integer)
    org_id = Column(Integer)
    role_id = Column(Integer)
    user_type = Column(String(32), default="INTERNAL")
    status = Column(Integer, default=1)
    login_fail_count = Column(Integer, default=0)
    lock_time = Column(DateTime)
    last_login_time = Column(DateTime)
    last_login_ip = Column(String(64))
    password_last_update_time = Column(DateTime)
    need_change_password = Column(Boolean, default=False)
    __table_args__ = (UniqueConstraint("username", "deleted", name="uk_md_user_username"),)


class AuditLog(Base):
    __tablename__ = "sys_audit_log"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer)
    username = Column(String(64))
    action = Column(String(32))
    entity = Column(String(64))
    entity_id = Column(Integer)
    detail = Column(Text)
    ip = Column(String(64))
    create_time = Column(DateTime, default=datetime.now)


class Customer(Base, MasterMixin):
    __tablename__ = "md_customer"
    id = Column(Integer, primary_key=True)
    customer_code = Column(String(64))
    customer_name = Column(String(255), nullable=False)
    customer_short_name = Column(String(128))
    standard_name = Column(String(255))
    customer_type = Column(String(32), default="ENTERPRISE")
    customer_level = Column(String(32))
    customer_classify = Column(String(32))
    customer_source = Column(String(64))
    industry_code = Column(String(32))
    industry_l1 = Column(String(128))
    industry_l2 = Column(String(128))
    industry_l3 = Column(String(128))
    customer_scale = Column(String(32))
    customer_nature = Column(String(32))
    customer_status = Column(String(32), default="POTENTIAL")
    region_code = Column(String(32))
    province = Column(String(64))
    city = Column(String(64))
    district = Column(String(64))
    address = Column(String(512))
    website = Column(String(255))
    parent_id = Column(Integer, default=0)
    owner_org_id = Column(Integer)
    manager_id = Column(Integer)
    manager_name = Column(String(64))
    follower_id = Column(Integer)
    follower_name = Column(String(64))
    primary_contact_id = Column(Integer)
    unified_social_credit = Column(String(64))
    tax_number = Column(String(64))
    invoice_title = Column(String(255))
    register_address = Column(String(512))
    bank_name = Column(String(128))
    bank_account = Column(String(64))
    credit_level = Column(String(32))
    credit_limit = Column(Numeric(18, 2))
    payment_cycle_days = Column(Integer)
    payment_offset_months = Column(Integer)
    settlement_currency = Column(String(10), default="CNY")
    deal_flag = Column(Boolean, default=False)
    in_public_sea = Column(Boolean, default=False)
    last_follow_time = Column(DateTime)
    recycle_time = Column(DateTime)
    customer_tags = Column(String(512))
    __table_args__ = (
        UniqueConstraint("company_id", "customer_code", "deleted", name="uk_md_customer_code"),
        Index("idx_md_customer_name", "customer_name"),
    )


class CustomerContact(Base, AuditMixin):
    __tablename__ = "md_customer_contact"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    customer_id = Column(Integer, nullable=False)
    contact_name = Column(String(64), nullable=False)
    contact_title = Column(String(64))
    contact_gender = Column(String(16))
    contact_phone = Column(String(32))
    contact_mobile = Column(String(32))
    contact_email = Column(String(128))
    contact_qq = Column(String(32))
    contact_wechat = Column(String(64))
    department = Column(String(128))
    contact_type = Column(String(32), default="BUSINESS")
    is_primary = Column(Boolean, default=False)
    is_decision_maker = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)
    status = Column(String(32), default="ACTIVE")
    remark = Column(String(512))


class CustomerAddress(Base, AuditMixin):
    __tablename__ = "md_customer_address"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    customer_id = Column(Integer, nullable=False)
    address_type = Column(String(32), default="OFFICE")
    country_id = Column(Integer)
    country_name = Column(String(64))
    province_id = Column(Integer)
    province_name = Column(String(64))
    city_id = Column(Integer)
    city_name = Column(String(64))
    district_id = Column(Integer)
    district_name = Column(String(64))
    region_code = Column(String(32))
    street = Column(String(256))
    detail_address = Column(String(512), nullable=False)
    postal_code = Column(String(20))
    longitude = Column(Numeric(10, 7))
    latitude = Column(Numeric(10, 7))
    contact_person = Column(String(64))
    contact_phone = Column(String(20))
    is_default = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)
    status = Column(String(32), default="ACTIVE")
    remark = Column(String(512))


class CustomerFollower(Base, AuditMixin):
    __tablename__ = "crm_customer_follower"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    customer_id = Column(Integer, nullable=False)
    employee_id = Column(Integer)
    employee_name = Column(String(64))
    follower_type = Column(String(32), default="SALES")
    is_primary = Column(Boolean, default=False)
    start_date = Column(Date)
    end_date = Column(Date)
    status = Column(Integer, default=1)
    remark = Column(String(512))
    __table_args__ = (
        UniqueConstraint("customer_id", "employee_id", "deleted", name="uk_crm_customer_follower"),
    )


class Opportunity(Base, MasterMixin):
    __tablename__ = "crm_opportunity"
    id = Column(Integer, primary_key=True)
    opportunity_no = Column(String(64), nullable=False)
    name = Column(String(200), nullable=False)
    customer_id = Column(Integer)
    customer_name = Column(String(200))
    stage = Column(String(20), default="STAGE_01")
    stage_rate = Column(Numeric(5, 2), default=5)
    amount = Column(Numeric(18, 2), default=0)
    expected_deal_date = Column(Date)
    expected_sign_date = Column(Date)
    status = Column(String(20), default="IN_PROGRESS")
    sales_status = Column(String(32), default="NORMAL")
    project_level = Column(String(32), default="MEDIUM")
    owner_id = Column(Integer)
    owner_name = Column(String(64))
    sales_person_id = Column(Integer)
    sales_person_name = Column(String(64))
    product_id = Column(Integer)
    product_name = Column(String(200))
    source_type = Column(String(20), default="MANUAL")
    description = Column(Text)
    data_status = Column(String(20), default="ACTIVE")
    remark = Column(String(512))
    __table_args__ = (
        UniqueConstraint("company_id", "opportunity_no", "deleted", name="uk_crm_opportunity_no"),
        Index("idx_crm_opportunity_customer", "customer_id"),
        Index("idx_crm_opportunity_stage", "stage"),
    )


class OpportunityFollow(Base, AuditMixin):
    __tablename__ = "crm_opportunity_follow"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    opportunity_id = Column(Integer, nullable=False)
    opportunity_name = Column(String(200))
    customer_id = Column(Integer)
    customer_name = Column(String(200))
    follow_time = Column(Date)
    follower_id = Column(Integer)
    follower_name = Column(String(64))
    contact_name = Column(String(64))
    content = Column(Text)
    plan_title = Column(String(200))
    plan_content = Column(Text)
    plan_time = Column(Date)
    plan_status = Column(String(20), default="PENDING")
    status = Column(String(20), default="DONE")
    remark = Column(String(512))



class Project(Base, MasterMixin):
    __tablename__ = "md_project"
    id = Column(Integer, primary_key=True)
    project_code = Column(String(64), nullable=False)
    project_name = Column(String(128), nullable=False)
    project_type = Column(String(32), default="CONSULTING")
    project_level = Column(String(32), default="MEDIUM")
    parent_id = Column(Integer, default=0)
    parent_project_code = Column(String(64))
    project_path = Column(String(512))
    customer_id = Column(Integer)
    customer_name = Column(String(128))
    signed_company_id = Column(Integer)
    signed_company_name = Column(String(128))
    pm_id = Column(Integer)
    pm_name = Column(String(64))
    sales_id = Column(Integer)
    sales_name = Column(String(64))
    org_id = Column(Integer)
    org_code = Column(String(64))
    org_name = Column(String(128))
    planned_start_date = Column(Date)
    planned_end_date = Column(Date)
    actual_start_date = Column(Date)
    actual_end_date = Column(Date)
    planned_days = Column(Numeric(10, 2))
    actual_days = Column(Numeric(10, 2))
    estimated_work_days = Column(Numeric(10, 2))
    budget_amount = Column(Numeric(18, 2))
    budget_labor_amount = Column(Numeric(18, 2))
    budget_expense_amount = Column(Numeric(18, 2))
    contract_amount = Column(Numeric(18, 2))
    actual_cost = Column(Numeric(18, 2))
    actual_labor_cost = Column(Numeric(18, 2))
    actual_expense_cost = Column(Numeric(18, 2))
    cost_variance = Column(Numeric(18, 2))
    cost_variance_rate = Column(Numeric(10, 4))
    currency = Column(String(10), default="CNY")
    settlement_mode = Column(String(32), default="TIME_MATERIAL")
    is_billable = Column(Boolean, default=True)
    status = Column(String(32), default="PREPARING")
    progress = Column(Integer, default=0)
    current_milestone = Column(String(128))
    sign_date = Column(Date)
    priority = Column(String(32), default="MEDIUM")
    project_address = Column(String(256))
    description = Column(Text)
    business_background = Column(Text)
    technical_requirements = Column(Text)
    deliverables = Column(Text)
    __table_args__ = (
        UniqueConstraint("company_id", "project_code", "deleted", name="uk_md_project_code"),
        Index("idx_md_project_customer", "customer_id"),
    )


class ProjectMember(Base, AuditMixin):
    __tablename__ = "md_project_member"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    project_id = Column(Integer, nullable=False)
    employee_id = Column(Integer, nullable=False)
    user_id = Column(Integer)
    job_number = Column(String(64))
    member_name = Column(String(64))
    role_in_project = Column(String(32), default="CONSULTANT")
    work_duty = Column(String(256))
    work_nature = Column(String(20), default="SETTLE")
    estimated_work_days = Column(Numeric(10, 2))
    allocation_rate = Column(Numeric(5, 2), default=100)
    join_date = Column(Date)
    leave_date = Column(Date)
    is_manager = Column(Boolean, default=False)
    is_primary = Column(Boolean, default=False)
    member_type = Column(String(20), default="INTERNAL")
    status = Column(Integer, default=1)
    remark = Column(String(512))
    __table_args__ = (
        UniqueConstraint("project_id", "employee_id", "deleted", name="uk_md_project_member"),
    )


class ProjectMemberPeriod(Base, AuditMixin):
    __tablename__ = "md_project_member_period"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    project_id = Column(Integer)
    member_id = Column(Integer, nullable=False)
    planned_join_date = Column(Date)
    planned_leave_date = Column(Date)
    actual_join_date = Column(Date)
    actual_leave_date = Column(Date)
    workload_ratio = Column(Numeric(5, 2), default=100)
    estimated_work_days = Column(Numeric(10, 2))
    is_active = Column(Boolean, default=True)
    period_order = Column(Integer, default=1)
    remark = Column(String(500))


class Contract(Base, MasterMixin):
    __tablename__ = "md_contract"
    id = Column(Integer, primary_key=True)
    contract_no = Column(String(100), nullable=False)
    sub_contract_no = Column(String(64), default="")
    contract_name = Column(String(500), nullable=False)
    contract_type_code = Column(String(50))
    contract_type_name = Column(String(200))
    contract_category = Column(String(32), default="SALES")
    customer_id = Column(Integer)
    customer_name = Column(String(200))
    org_id = Column(Integer)
    org_code = Column(String(50))
    org_name = Column(String(128))
    product_line_code = Column(String(50))
    product_line_name = Column(String(64))
    manager_id = Column(Integer)
    manager_name = Column(String(100))
    sales_manager_id = Column(Integer)
    sales_manager_name = Column(String(100))
    owner_id = Column(Integer)
    owner_name = Column(String(100))
    contract_amount = Column(Numeric(18, 2), default=0)
    currency = Column(String(10), default="CNY")
    exchange_rate = Column(Numeric(10, 4), default=1)
    tax_rate = Column(Numeric(10, 4), default=0)
    tax_amount = Column(Numeric(18, 2), default=0)
    amount_excl_tax = Column(Numeric(18, 2), default=0)
    amount_incl_tax = Column(Numeric(18, 2), default=0)
    sign_date = Column(Date)
    expected_sign_date = Column(Date)
    start_date = Column(Date)
    end_date = Column(Date)
    approval_status = Column(String(20), default="DRAFT")
    sign_status = Column(String(20), default="UNSIGNED")
    execution_status = Column(String(20), default="NOT_STARTED")
    invoice_status = Column(String(20), default="NOT_STARTED")
    payment_status = Column(String(20), default="UNPAID")
    payment_method = Column(String(32))
    payment_terms = Column(String(512))
    warranty_clause = Column(Text)
    breach_clause = Column(Text)
    contract_file_url = Column(String(512))
    signed_file_url = Column(String(512))
    parent_id = Column(Integer, default=0)
    contract_version_no = Column(String(32))
    source_file_name = Column(String(500))
    __table_args__ = (
        UniqueConstraint(
            "company_id", "contract_no", "sub_contract_no", "deleted", name="uk_md_contract_no"
        ),
        Index("idx_md_contract_customer", "customer_id"),
    )


class ContractMilestone(Base, AuditMixin):
    __tablename__ = "md_contract_milestone"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    contract_id = Column(Integer, nullable=False)
    milestone_code = Column(String(64))
    milestone_name = Column(String(200), nullable=False)
    milestone_type = Column(String(32), default="DELIVERY")
    payment_unit_id = Column(Integer)
    payment_ratio = Column(Numeric(9, 6), default=0)
    milestone_amount = Column(Numeric(18, 2), default=0)
    currency = Column(String(10), default="CNY")
    plan_invoice_year = Column(Integer)
    plan_month = Column(Integer)
    plan_date = Column(Date)
    forecast_invoice_year = Column(Integer)
    forecast_month = Column(Integer)
    forecast_date = Column(Date)
    actual_invoice_year = Column(Integer)
    actual_month = Column(Integer)
    actual_date = Column(Date)
    invoice_status = Column(String(20), default="UNINVOICED")
    planned_complete_date = Column(Date)
    actual_complete_date = Column(Date)
    milestone_status = Column(String(20), default="PENDING")
    expected_payment_date = Column(Date)
    receivable_due_date = Column(Date)
    actual_payment_date = Column(Date)
    expected_payment_amount = Column(Numeric(18, 2))
    actual_payment_amount = Column(Numeric(18, 2))
    invoiced_amount = Column(Numeric(18, 2))
    paid_amount = Column(Numeric(18, 2))
    payment_status = Column(String(20), default="UNPAID")
    sort_order = Column(Integer, default=0)
    remark = Column(String(512))


class ContractProject(Base, AuditMixin):
    __tablename__ = "md_project_contract"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    project_id = Column(Integer, nullable=False)
    contract_id = Column(Integer, nullable=False)
    relation_type = Column(String(32), default="MAIN")
    is_primary = Column(Boolean, default=False)
    __table_args__ = (
        UniqueConstraint("project_id", "contract_id", "deleted", name="uk_md_project_contract"),
    )


class ContractOpportunity(Base, AuditMixin):
    __tablename__ = "crm_contract_opportunity"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    contract_id = Column(Integer, nullable=False)
    opportunity_id = Column(Integer, nullable=False)
    __table_args__ = (
        UniqueConstraint("contract_id", "opportunity_id", "deleted", name="uk_crm_contract_opportunity"),
    )


class Product(Base, MasterMixin):
    __tablename__ = "md_product"
    id = Column(Integer, primary_key=True)
    product_code = Column(String(64), nullable=False)
    product_name = Column(String(128), nullable=False)
    product_type = Column(String(32), default="SERVICE")
    category_code = Column(String(50))
    unit = Column(String(32))
    tax_rate = Column(Numeric(5, 4), default=0)
    standard_price = Column(Numeric(12, 2))
    sales_price = Column(Numeric(18, 2))
    currency = Column(String(10), default="CNY")
    status = Column(Integer, default=1)
    __table_args__ = (
        UniqueConstraint("company_id", "product_code", "deleted", name="uk_md_product_code"),
    )


class TaxRate(Base, MasterMixin):
    __tablename__ = "md_tax_rate"
    id = Column(Integer, primary_key=True)
    contract_type_code = Column(String(50))
    contract_type_name = Column(String(128))
    effective_date = Column(Date)
    expire_date = Column(Date)
    tax_rate = Column(Numeric(10, 4), default=0)
    surtax_rate = Column(Numeric(10, 4), default=0)
    description = Column(String(512))
    status = Column(Integer, default=1)


class Dict(Base, MasterMixin):
    __tablename__ = "md_dict"
    id = Column(Integer, primary_key=True)
    dict_code = Column(String(64), nullable=False)
    dict_name = Column(String(128), nullable=False)
    system_type = Column(String(20), default="SYS")
    status = Column(Integer, default=1)
    __table_args__ = (UniqueConstraint("dict_code", "deleted", name="uk_md_dict_code"),)


class DictItem(Base, AuditMixin):
    __tablename__ = "md_dict_item"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    dict_id = Column(Integer, nullable=False)
    item_code = Column(String(64), nullable=False)
    item_name = Column(String(128), nullable=False)
    item_value = Column(String(256))
    sort_order = Column(Integer, default=0)
    status = Column(Integer, default=1)


class IdMapping(Base, AuditMixin):
    __tablename__ = "md_id_mapping"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    entity_type = Column(String(32), nullable=False)
    source_system = Column(String(32), nullable=False)
    source_id = Column(String(64), nullable=False)
    md_id = Column(Integer, nullable=False)
    __table_args__ = (
        UniqueConstraint(
            "entity_type", "source_system", "source_id", name="uk_md_id_mapping_source"
        ),
    )


class FinanceCost(Base, AuditMixin):
    __tablename__ = "fin_cost"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    project_id = Column(Integer, nullable=False)
    project_code = Column(String(64))
    project_name = Column(String(128))
    contract_id = Column(Integer)
    contract_no = Column(String(100))
    customer_id = Column(Integer)
    customer_name = Column(String(200))
    org_id = Column(Integer)
    org_name = Column(String(128))
    cost_type = Column(String(32), default="LABOR")
    cost_category = Column(String(64))
    cost_date = Column(Date, nullable=False)
    period = Column(String(7))
    amount = Column(Numeric(18, 2), default=0)
    supplier_name = Column(String(200))
    employee_id = Column(Integer)
    employee_name = Column(String(64))
    source = Column(String(32), default="MANUAL")
    status = Column(String(20), default="CONFIRMED")
    remark = Column(String(512))
    __table_args__ = (
        Index("idx_fin_cost_project", "project_id"),
        Index("idx_fin_cost_date", "cost_date"),
    )


class FinanceBudget(Base, AuditMixin):
    __tablename__ = "fin_budget"
    id = Column(Integer, primary_key=True)
    company_id = Column(Integer, default=1)
    budget_year = Column(Integer, nullable=False)
    budget_type = Column(String(20), default="PROJECT")
    project_id = Column(Integer)
    project_code = Column(String(64))
    project_name = Column(String(128))
    org_id = Column(Integer)
    org_name = Column(String(128))
    customer_id = Column(Integer)
    customer_name = Column(String(200))
    contract_id = Column(Integer)
    contract_no = Column(String(100))
    category = Column(String(32), nullable=False)
    budget_amount = Column(Numeric(18, 2), default=0)
    version = Column(String(20), default="V1.0")
    status = Column(String(20), default="APPROVED")
    remark = Column(String(512))
    __table_args__ = (
        Index("idx_fin_budget_year", "budget_year"),
        Index("idx_fin_budget_project", "project_id"),
        Index("idx_fin_budget_org", "org_id"),
    )


def init_db():
    Base.metadata.create_all(engine)
