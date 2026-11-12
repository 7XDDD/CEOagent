/*
 Navicat Premium Data Transfer

 Source Server         : HR系统
 Source Server Type    : MySQL
 Source Server Version : 80028
 Source Host           : 172.16.0.116:3306
 Source Schema         : enterprise_portal

 Target Server Type    : MySQL
 Target Server Version : 80028
 File Encoding         : 65001

 Date: 03/11/2026 16:34:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for crm_budget_line
-- ----------------------------
DROP TABLE IF EXISTS `crm_budget_line`;
CREATE TABLE `crm_budget_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `budget_sheet_id` bigint NOT NULL COMMENT '关联预算单据头',
  `company_id` bigint NOT NULL DEFAULT 1,
  `fiscal_year` int NOT NULL COMMENT '预算年度 [冗余字段]',
  `version_id` bigint NULL DEFAULT NULL COMMENT '预算版本ID',
  `milestone_id` bigint NULL DEFAULT NULL COMMENT '关联里程碑ID (可空)',
  `milestone_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '里程碑编码 (冗余)',
  `line_no` int NOT NULL DEFAULT 0 COMMENT '行号',
  `payment_ratio` decimal(10, 4) NULL DEFAULT NULL COMMENT '收款比例 (快照)',
  `contract_amount` decimal(18, 2) NULL DEFAULT NULL COMMENT '合同金额(快照)',
  `tax_rate` decimal(10, 4) NULL DEFAULT NULL COMMENT '税率 (快照)',
  `surtax_rate` decimal(10, 4) NULL DEFAULT 0.1200 COMMENT '附加税率 (快照)',
  `tax_rate_date` date NULL DEFAULT NULL COMMENT '税率适用日期',
  `line_amount` decimal(20, 6) NOT NULL DEFAULT 0.000000 COMMENT '本行预算金额合计(万元)',
  `calc_formula` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计算公式描述',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_budget_sheet_id`(`budget_sheet_id` ASC) USING BTREE,
  INDEX `idx_company_year`(`company_id` ASC, `fiscal_year` ASC) USING BTREE,
  INDEX `idx_milestone_id`(`milestone_id` ASC) USING BTREE,
  INDEX `idx_version_id`(`version_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24384 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预算明细行表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_budget_period
-- ----------------------------
DROP TABLE IF EXISTS `crm_budget_period`;
CREATE TABLE `crm_budget_period`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL DEFAULT 1,
  `fiscal_year` int NOT NULL,
  `period_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'MONTHLY/QUARTERLY/YEARLY',
  `period_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '期间编码 M1...M12 / Q1...Q4 / YEAR',
  `period_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '期间名称 (如: 1月/第一季度/全年)',
  `period_no` int NOT NULL COMMENT '期间序号: 月=1-12, 季=1-4, 年=0',
  `start_date` date NULL DEFAULT NULL,
  `end_date` date NULL DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 1,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_period_unique`(`company_id` ASC, `fiscal_year` ASC, `period_type` ASC, `period_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_company_year`(`company_id` ASC, `fiscal_year` ASC) USING BTREE,
  INDEX `idx_period_type`(`period_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 369 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预算期间表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_budget_period_amount
-- ----------------------------
DROP TABLE IF EXISTS `crm_budget_period_amount`;
CREATE TABLE `crm_budget_period_amount`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `budget_line_id` bigint NOT NULL,
  `budget_sheet_id` bigint NOT NULL,
  `company_id` bigint NOT NULL DEFAULT 1,
  `fiscal_year` int NOT NULL,
  `version_id` bigint NULL DEFAULT NULL COMMENT '预算版本ID',
  `period_id` bigint NOT NULL COMMENT '预算期间ID (关联 bud_budget_period)',
  `period_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `period_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '期间编码 (M1/M2.../Q1...)',
  `budget_amount` decimal(20, 6) NOT NULL DEFAULT 0.000000 COMMENT '本期间预算金额(万元)',
  `actual_amount` decimal(20, 6) NULL DEFAULT NULL COMMENT '期间实际发生(万元)',
  `forecast_amount` decimal(20, 6) NULL DEFAULT NULL COMMENT '滚动预测金额(万元)',
  `amount_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ORIGINAL' COMMENT 'ORIGINAL(原始)/ADJUSTED(调整)/ROLLING(滚动)',
  `time_offset_months` int NOT NULL DEFAULT 0 COMMENT '期间偏移(税费=1,表示开票月份+1)',
  `calc_formula` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_line_period_unique`(`budget_line_id` ASC, `period_id` ASC, `amount_type` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_budget_sheet_id`(`budget_sheet_id` ASC) USING BTREE,
  INDEX `idx_company_year_period`(`company_id` ASC, `fiscal_year` ASC, `period_id` ASC) USING BTREE,
  INDEX `idx_period_type_code`(`period_type` ASC, `period_code` ASC) USING BTREE,
  INDEX `idx_version_period`(`version_id` ASC, `period_code` ASC) USING BTREE,
  INDEX `idx_period_version_code`(`version_id` ASC, `period_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18609 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预算期间金额表(行存储-1NF核心)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_budget_sheet
-- ----------------------------
DROP TABLE IF EXISTS `crm_budget_sheet`;
CREATE TABLE `crm_budget_sheet`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `fiscal_year` int NOT NULL,
  `version_id` bigint NOT NULL COMMENT '预算版本ID (关联 bud_budget_version)',
  `catalog_id` bigint NOT NULL COMMENT '预算表目录ID (关联 sys_budget_catalog)',
  `catalog_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '预算表编码 (101/102/103...) 冗余以加速查询',
  `contract_id` bigint NOT NULL COMMENT '关联合同ID',
  `contract_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '合同号 (冗余以加速查询, 非3NF但为了性能)',
  `contract_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '合同名称 (冗余, 报表查询免JOIN)',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',
  `contract_amount` decimal(20, 6) NULL DEFAULT NULL COMMENT '合同金额(万元)',
  `customer_id` bigint NULL DEFAULT NULL,
  `customer_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户名称(冗余, 用于分组汇总)',
  `contract_type_id` bigint NULL DEFAULT NULL,
  `contract_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同类型名称(冗余, 用于分组汇总)',
  `contract_type_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同类型名称',
  `org_id` bigint NULL DEFAULT NULL,
  `product_line_id` bigint NULL DEFAULT NULL COMMENT '产品线ID',
  `product_line` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品线(冗余, 用于分组汇总)',
  `stock_flag` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `manager` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sales_manager` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售经理',
  `contract_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同状态快照 (预算计算时的合同状态)',
  `total_amount` decimal(20, 6) NOT NULL DEFAULT 0.000000 COMMENT '全年预算合计金额(万元)',
  `calc_rule` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计算规则/公式说明',
  `approval_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DRAFT',
  `is_summary_row` tinyint NOT NULL DEFAULT 0,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `owner_id` bigint NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sheet_unique`(`company_id` ASC, `fiscal_year` ASC, `version_id` ASC, `catalog_id` ASC, `contract_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_company_year`(`company_id` ASC, `fiscal_year` ASC) USING BTREE,
  INDEX `idx_version_catalog`(`version_id` ASC, `catalog_id` ASC) USING BTREE,
  INDEX `idx_contract_id`(`contract_id` ASC) USING BTREE,
  INDEX `idx_sheet_version_catalog_contract`(`version_id` ASC, `catalog_code` ASC, `contract_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_budget_sheet_product_line_id`(`product_line_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11090 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预算单据头表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_budget_version
-- ----------------------------
DROP TABLE IF EXISTS `crm_budget_version`;
CREATE TABLE `crm_budget_version`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL DEFAULT 1,
  `fiscal_year` int NOT NULL,
  `version_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '版本编码 (V1/V1-R1/V1-R2/V2)',
  `version_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '版本名称 (初稿/1月滚动/2月滚动)',
  `budget_scene` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ANNUAL' COMMENT 'ANNUAL(年度预算)/ROLLING(滚动预算)/ADJUST(调整预算)',
  `rolling_month` int NULL DEFAULT NULL COMMENT '滚动预算: 当前为第几月 (1-12)',
  `is_active` tinyint NOT NULL DEFAULT 0 COMMENT '当前生效版本 0否 1是',
  `approval_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT(草稿)/SUBMITTED(已提交)/APPROVED(已审批)/REJECTED(已驳回)',
  `effective_date` date NULL DEFAULT NULL,
  `expire_date` date NULL DEFAULT NULL,
  `parent_version_id` bigint NULL DEFAULT NULL COMMENT '父版本ID (基于哪个版本滚动)',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `owner_id` bigint NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `is_locked` tinyint NOT NULL DEFAULT 0,
  `is_finalized` tinyint NOT NULL DEFAULT 0 COMMENT '是否定稿：0=否（默认），1=是。仅年中调整版(ADJUST)使用',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_company_year_version_code`(`company_id` ASC, `fiscal_year` ASC, `version_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_active`(`company_id` ASC, `is_active` ASC) USING BTREE,
  INDEX `idx_budget_scene`(`budget_scene` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预算版本管理表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_company
-- ----------------------------
DROP TABLE IF EXISTS `crm_company`;
CREATE TABLE `crm_company`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '企业代码 (如: LY)',
  `company_fullname` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '企业全称 (如: 深圳市链宇技术有限公司)',
  `company_shortname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '企业简称 (如: 链宇技术)',
  `address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact_person` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `contact_phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `currency_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'CNY' COMMENT '记账本位币',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '公司状态 1启用 0禁用',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0=未删除, >0 表示已删除(id)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_company_code`(`company_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '企业信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_contract
-- ----------------------------
DROP TABLE IF EXISTS `crm_contract`;
CREATE TABLE `crm_contract`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL DEFAULT 1,
  `contract_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '合同号 (业务唯一键)',
  `sub_contract_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '子合同号(系统内部生成), 格式: 主合同号-NN',
  `project_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目号',
  `project_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `contract_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '合同名称',
  `customer_id` bigint NULL DEFAULT NULL COMMENT '客户ID (外键, 3NF关联)',
  `customer_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户名称(冗余, 用于分组/导出)',
  `customer_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户编码',
  `contract_type_id` bigint NULL DEFAULT NULL COMMENT '合同类型ID (外键, 3NF关联)',
  `contract_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同类型名称(冗余, 用于分组/导出)',
  `contract_type_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同类型编码',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID (关联 sys_org, 通常是产品线/BU级别)',
  `product_line` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品线(冗余, 用于分组/导出)',
  `product_line_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品线编码',
  `manager` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `sales_manager` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售经理',
  `contract_amount` decimal(18, 2) NOT NULL COMMENT '合同金额(含税/万元)',
  `sign_date` date NULL DEFAULT NULL COMMENT '合同签订日期',
  `expected_sign_date` date NULL DEFAULT NULL COMMENT '预计签约日期',
  `contract_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'UNSIGNED' COMMENT 'UNSIGNED(未签订)/SIGNED(已签订)/COMPLETED(已完成)/CANCELED(已取消)',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'MANUAL' COMMENT '数据来源: EXCEL/MANUAL/API',
  `source_file_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '来源Excel文件名',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `owner_id` bigint NULL DEFAULT NULL COMMENT '数据归属人ID (数据权限)',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '归属部门ID (数据权限)',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `contract_create_time` date NULL DEFAULT NULL COMMENT '合同创建时间',
  `contract_complete_time` date NULL DEFAULT NULL COMMENT '合同完成时间',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父合同ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sub_contract_no`(`company_id` ASC, `sub_contract_no` ASC, `deleted` ASC) USING BTREE,
  UNIQUE INDEX `uk_contract_biz`(`company_id` ASC, `contract_no` ASC, `org_id` ASC, `contract_type_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_company_year`(`company_id` ASC) USING BTREE,
  INDEX `idx_customer_id`(`customer_id` ASC) USING BTREE,
  INDEX `idx_contract_type_id`(`contract_type_id` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_sign_date`(`sign_date` ASC) USING BTREE,
  INDEX `idx_contract_fiscal_status`(`contract_status` ASC) USING BTREE,
  INDEX `idx_contract_sign_date`(`sign_date` ASC, `contract_status` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_contract_no`(`contract_no` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 67 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '合同主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_contract_milestone
-- ----------------------------
DROP TABLE IF EXISTS `crm_contract_milestone`;
CREATE TABLE `crm_contract_milestone`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL DEFAULT 1 COMMENT '关联合同ID',
  `company_id` bigint NOT NULL,
  `invoice_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'UNINVOICED' COMMENT '里程碑开票状态 UNINVOICED(未开票)/INVOICED(已开票)',
  `milestone_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '里程碑编码 (如: M0, M1, M2, M3, M4)',
  `milestone_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '里程碑名称',
  `payment_ratio` decimal(10, 4) NOT NULL COMMENT '收款比例 如 0.30 表示 30%',
  `plan_invoice_year` int NULL DEFAULT NULL COMMENT '计划开票年份',
  `milestone_amount` decimal(18, 2) NOT NULL COMMENT '里程碑金额 = 合同金额 × 收款比例',
  `plan_month` int NULL DEFAULT NULL COMMENT '计划开票月份 1-12 (未签订合同的收入归属)',
  `forecast_invoice_year` int NULL DEFAULT NULL COMMENT '预测开票年份',
  `plan_date` date NULL DEFAULT NULL COMMENT '计划开票日期',
  `forecast_month` int NULL DEFAULT NULL COMMENT '预测开票月份 (已签订未开票的收入归属)',
  `actual_invoice_year` int NULL DEFAULT NULL COMMENT '实际开票年份',
  `forecast_date` date NULL DEFAULT NULL COMMENT '预测开票日期',
  `actual_month` int NULL DEFAULT NULL COMMENT '实际开票月份 (已开票的收入归属)',
  `actual_date` date NULL DEFAULT NULL COMMENT '实际开票日期',
  `actual_amount` decimal(18, 2) NULL DEFAULT NULL COMMENT '实际收款金额',
  `expected_payment_date` date NULL DEFAULT NULL COMMENT '预计回款日期',
  `actual_payment_date` date NULL DEFAULT NULL COMMENT '实际回款日期',
  `expected_payment_amount` decimal(18, 2) NULL DEFAULT NULL COMMENT '预计回款金额(元)',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/FORECAST/DONE',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_contract_milestone`(`contract_id` ASC, `milestone_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_contract_id`(`contract_id` ASC) USING BTREE,
  INDEX `idx_company_year`(`company_id` ASC) USING BTREE,
  INDEX `idx_plan_month`(`plan_month` ASC) USING BTREE,
  INDEX `idx_forecast_month`(`forecast_month` ASC) USING BTREE,
  INDEX `idx_actual_month`(`actual_month` ASC) USING BTREE,
  INDEX `idx_milestone_actual_date`(`actual_date` ASC, `invoice_status` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_milestone_forecast_month`(`forecast_month` ASC, `invoice_status` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 91 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '合同里程碑明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_contract_opportunity
-- ----------------------------
DROP TABLE IF EXISTS `crm_contract_opportunity`;
CREATE TABLE `crm_contract_opportunity`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL COMMENT '合同ID',
  `opportunity_id` bigint NOT NULL COMMENT '商机ID',
  `created_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_contract`(`contract_id` ASC) USING BTREE,
  INDEX `idx_opportunity`(`opportunity_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '合同-商机关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_contract_project
-- ----------------------------
DROP TABLE IF EXISTS `crm_contract_project`;
CREATE TABLE `crm_contract_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL COMMENT '合同ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目编码(冗余)',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称(冗余)',
  `created_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_contract`(`contract_id` ASC) USING BTREE,
  INDEX `idx_project`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '合同-项目关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_customer
-- ----------------------------
DROP TABLE IF EXISTS `crm_customer`;
CREATE TABLE `crm_customer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户编号',
  `customer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '客户名称',
  `standard_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户标准全称',
  `customer_address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户地址',
  `map_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地图位置',
  `customer_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户类型',
  `customer_level` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户级别',
  `customer_source` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户来源',
  `customer_industry` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户行业',
  `industry` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '行业',
  `industry_l1` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '行业L1',
  `industry_l2` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '行业L2',
  `industry_l3` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '行业L3',
  `customer_scale` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户规模',
  `customer_nature` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户性质',
  `customer_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户状态',
  `call_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通话状态',
  `region` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区域',
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省份',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '城市',
  `listing_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '上市状态',
  `revenue_year` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '营收年份',
  `profit` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '盈利',
  `revenue_scale` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '营收规模',
  `market_value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '市值',
  `employee_count` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '员工数',
  `cooperation_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合作状态',
  `main_product` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '主要产品',
  `development_stage` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前开发阶段',
  `total_sales` decimal(18, 2) NULL DEFAULT NULL COMMENT '累计销售额',
  `first_order_date` date NULL DEFAULT NULL COMMENT '首次产单时间',
  `highest_customer_relation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最高客户关系',
  `ongoing_opportunity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '进行中商机',
  `match_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '匹配情况',
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '官网',
  `data_source` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '数据来源',
  `company_product` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公司产品',
  `company_tel` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公司总机',
  `salesman` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售员',
  `original_salesman` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原销售人员',
  `industry_manager` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '行业负责人',
  `cso_training_class` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'CSO培训班',
  `main_contact` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '主要联系人',
  `second_contact` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '第二联系人',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '客户负责人ID',
  `manager_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户负责人',
  `follower_id` bigint NULL DEFAULT NULL COMMENT '跟进人ID',
  `follower_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跟进人',
  `contact_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人姓名',
  `contact_position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人职务',
  `contact_mobile` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人手机',
  `contact_tel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人座机',
  `contact_email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人邮箱',
  `contact_wechat` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人微信',
  `contact_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人备注',
  `remark` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户备注',
  `customer_tags` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户标签(逗号分隔)',
  `deal_flag` int NOT NULL DEFAULT 0 COMMENT '是否已成交 0-否 1-是',
  `in_public_sea` int NOT NULL DEFAULT 0 COMMENT '是否在公海 0-否 1-是',
  `last_follow_time` datetime NULL DEFAULT NULL COMMENT '最后跟进时间',
  `recycle_time` datetime NULL DEFAULT NULL COMMENT '回收时间',
  `tenant_id` bigint NULL DEFAULT NULL COMMENT '租户ID',
  `create_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_customer_code`(`customer_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_follower_id`(`follower_id` ASC) USING BTREE,
  INDEX `idx_manager_id`(`manager_id` ASC) USING BTREE,
  INDEX `idx_customer_status`(`customer_status` ASC) USING BTREE,
  INDEX `idx_deal_flag`(`deal_flag` ASC) USING BTREE,
  INDEX `idx_in_public_sea`(`in_public_sea` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_customer_address
-- ----------------------------
DROP TABLE IF EXISTS `crm_customer_address`;
CREATE TABLE `crm_customer_address`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `address_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '地址类型(BILLING收单方/SHIPPING收货方)',
  `country_id` bigint NULL DEFAULT NULL COMMENT '国家ID',
  `country_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '国家名称',
  `province_id` bigint NULL DEFAULT NULL COMMENT '省份ID',
  `province_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省份名称',
  `city_id` bigint NULL DEFAULT NULL COMMENT '城市ID',
  `city_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '城市名称',
  `district_id` bigint NULL DEFAULT NULL COMMENT '区县ID',
  `district_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区县名称',
  `street` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '街道/乡镇',
  `detail_address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `postal_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮编',
  `longitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '经度',
  `latitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '纬度',
  `contact_person` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收件人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收件电话',
  `is_default` tinyint NULL DEFAULT 0 COMMENT '是否默认地址(0否1是)',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer_id`(`customer_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户地址表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_customer_contact
-- ----------------------------
DROP TABLE IF EXISTS `crm_customer_contact`;
CREATE TABLE `crm_customer_contact`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `contact_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系人姓名',
  `contact_title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '职位',
  `contact_gender` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '性别(MALE男/FEMALE女)',
  `contact_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `contact_mobile` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号码',
  `contact_email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `contact_qq` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'QQ',
  `contact_wechat` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信',
  `department` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '部门',
  `is_primary` tinyint NULL DEFAULT 0 COMMENT '是否主要联系人(0否1是)',
  `is_decision_maker` tinyint NULL DEFAULT 0 COMMENT '是否决策人(0否1是)',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer_id`(`customer_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 73 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户联系人表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_customer_follower
-- ----------------------------
DROP TABLE IF EXISTS `crm_customer_follower`;
CREATE TABLE `crm_customer_follower`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `user_id` bigint NOT NULL COMMENT '跟进人用户ID',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户姓名',
  `follower_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '跟进人类型(TECH技术人员/EXPERT业务专家/SALES销售人员)',
  `is_primary` tinyint NULL DEFAULT 0 COMMENT '是否主跟进人(0否1是)',
  `start_date` date NULL DEFAULT NULL COMMENT '开始跟进日期',
  `end_date` date NULL DEFAULT NULL COMMENT '结束跟进日期',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer_id`(`customer_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户跟进人表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_data_permission
-- ----------------------------
DROP TABLE IF EXISTS `crm_data_permission`;
CREATE TABLE `crm_data_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `module` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模块 CUSTOMER/OPPORTUNITY/CONTRACT',
  `biz_id` bigint NOT NULL COMMENT '业务数据ID',
  `grantee_id` bigint NOT NULL COMMENT '被授权用户ID',
  `grantee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '被授权用户姓名(冗余)',
  `perm_bits` int NOT NULL DEFAULT 1 COMMENT '权限位: 查看1 编辑2 删除4 (只读=1 全权=7)',
  `expire_date` date NULL DEFAULT NULL COMMENT '授权过期日(空=长期)',
  `company_id` bigint NULL DEFAULT 1 COMMENT '企业ID',
  `granted_by` bigint NULL DEFAULT NULL COMMENT '授权人ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_module_biz_grantee`(`module` ASC, `biz_id` ASC, `grantee_id` ASC) USING BTREE,
  INDEX `idx_grantee`(`grantee_id` ASC, `module` ASC) USING BTREE,
  INDEX `idx_biz`(`module` ASC, `biz_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据级共享授权(记录级ACL)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_dict
-- ----------------------------
DROP TABLE IF EXISTS `crm_dict`;
CREATE TABLE `crm_dict`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dict_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统类型',
  `dict_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典编码',
  `dict_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dict_code`(`dict_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 88 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_dict_item
-- ----------------------------
DROP TABLE IF EXISTS `crm_dict_item`;
CREATE TABLE `crm_dict_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dict_id` bigint NULL DEFAULT NULL COMMENT '字典类型ID',
  `item_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典项编码',
  `item_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典项名称',
  `item_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '字典项值',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 275 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典项表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_employee
-- ----------------------------
DROP TABLE IF EXISTS `crm_employee`;
CREATE TABLE `crm_employee`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `job_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工号',
  `employee_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '员工姓名',
  `user_id` bigint NULL DEFAULT NULL COMMENT '关联系统用户ID',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织名称',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `mobile_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '电话号码',
  `work_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '员工状态(ACTIVE在职/INACTIVE离职)',
  `employment_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '员工类型(FULL_TIME全职/PART_TIME兼职/INTERN实习/DISPATCH劳务派遣/EXTERNAL外部合作)',
  `is_consultant` int NULL DEFAULT 0 COMMENT '是否顾问：0-否，1-是',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_job_number`(`job_number` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_work_status`(`work_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_fiscal_year
-- ----------------------------
DROP TABLE IF EXISTS `crm_fiscal_year`;
CREATE TABLE `crm_fiscal_year`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` bigint NOT NULL DEFAULT 1 COMMENT '关联企业',
  `fiscal_year` int NOT NULL COMMENT '预算年度 (如: 2026)',
  `budget_month` tinyint NOT NULL DEFAULT 1 COMMENT '编制起始月份 1-12',
  `year_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE' COMMENT '年度状态: ACTIVE(启用)/CLOSED(已关闭)/ARCHIVED(归档)',
  `is_current_year` tinyint NOT NULL DEFAULT 0 COMMENT '是否当前默认年度 0否 1是 (同公司只能有1条=1)',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '年度备注',
  `start_date` date NULL DEFAULT NULL COMMENT '预算年度开始日期',
  `end_date` date NULL DEFAULT NULL COMMENT '预算年度结束日期',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_company_year`(`company_id` ASC, `fiscal_year` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_company_current`(`company_id` ASC, `is_current_year` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预算年度配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_login_log
-- ----------------------------
DROP TABLE IF EXISTS `crm_login_log`;
CREATE TABLE `crm_login_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名',
  `login_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录类型',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `browser` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浏览器',
  `os` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作系统',
  `status` int NULL DEFAULT NULL COMMENT '状态码',
  `msg` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '消息',
  `login_result` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录结果(SUCCESS成功/WRONG_PASSWORD密码错误/USER_DISABLED用户禁用/USER_LOCKED用户锁定)',
  `fail_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '失败原因',
  `client_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户端IP',
  `user_agent` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'User-Agent',
  `request_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求路径',
  `login_time` datetime NULL DEFAULT NULL COMMENT '登录时间',
  `response_time_ms` bigint NULL DEFAULT NULL COMMENT '响应时间(毫秒)',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_login_time`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 345 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `crm_operation_log`;
CREATE TABLE `crm_operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统类型',
  `module` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '模块名称',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作描述',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作类型',
  `request_method` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求方法(GET/POST/PUT/DELETE)',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作用户名',
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人姓名',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作IP',
  `request_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求URL',
  `request_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数',
  `response_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '响应结果',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `duration` bigint NULL DEFAULT NULL COMMENT '耗时(毫秒)',
  `status` int NULL DEFAULT NULL COMMENT '状态码',
  `method` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '调用方法',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`username` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_opportunity
-- ----------------------------
DROP TABLE IF EXISTS `crm_opportunity`;
CREATE TABLE `crm_opportunity`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL DEFAULT 1,
  `opportunity_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商机名称',
  `customer_id` bigint NULL DEFAULT NULL,
  `customer_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `customer_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `stage` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'STAGE_01' COMMENT 'STAGE_01目标客户/STAGE_02线索/STAGE_03验证机会点/STAGE_04推进机会点/STAGE_05评比与证明/STAGE_06合同与商务谈判/STAGE_07赢单',
  `stage_rate` int NOT NULL DEFAULT 5 COMMENT '赢率百分比(5/10/25/50/75/90/100)',
  `amount` decimal(18, 2) NULL DEFAULT NULL COMMENT '预计金额(万元)',
  `expected_deal_date` date NULL DEFAULT NULL COMMENT '预计成交时间',
  `expected_sign_date` date NULL DEFAULT NULL COMMENT '预计签单时间',
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商机来源',
  `customer_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '新老客户(新客户/老客户)',
  `industry` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '行业',
  `product_line` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品线',
  `competitor` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '竞争对手',
  `next_action` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '下一步行动',
  `decision_maker` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户决策人',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'IN_PROGRESS' COMMENT 'IN_PROGRESS(进行中)/WON(赢单)/LOST(输单)',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'MANUAL',
  `source_file_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `owner_id` bigint NULL DEFAULT NULL,
  `dept_id` bigint NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `sales_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售状态(字典SALES_STATUS)',
  `project_level` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目级别(字典PROJECT_LEVEL)',
  `sales_person` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售(姓名)',
  `company_owner` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公司责任人(姓名)',
  `win_record` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '赢单判断与记录',
  `project_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目详细信息与记录',
  `stage_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '阶段进展总结(只保留最近一次)',
  `close_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关闭原因',
  `demand_product` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '需求产品(商品)',
  `presales_resource` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '售前资源',
  `resource_config` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '资源配置',
  `opportunity_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商机号',
  `opportunity_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商机类型',
  `project_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目地址',
  `sales_resource` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售资源',
  `follow_plan` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跟进计划',
  `follow_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跟进状态',
  `sales_person_id` bigint NULL DEFAULT NULL,
  `company_owner_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_opp_no`(`company_id` ASC, `opportunity_no` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_company`(`company_id` ASC) USING BTREE,
  INDEX `idx_customer`(`customer_id` ASC) USING BTREE,
  INDEX `idx_stage`(`stage` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商机主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_opportunity_follow
-- ----------------------------
DROP TABLE IF EXISTS `crm_opportunity_follow`;
CREATE TABLE `crm_opportunity_follow`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL DEFAULT 1,
  `opportunity_id` bigint NOT NULL COMMENT '商机ID',
  `opportunity_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `customer_id` bigint NULL DEFAULT NULL,
  `customer_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `follow_time` datetime NULL DEFAULT NULL COMMENT '跟进时间',
  `follower` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跟进人',
  `contact_person` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '沟通人',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '沟通内容',
  `plan_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计划标题',
  `plan_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '计划内容',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `plan_time` datetime NULL DEFAULT NULL COMMENT '下次计划跟进时间',
  `plan_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING' COMMENT '计划状态 PENDING/DONE',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_opportunity`(`opportunity_id` ASC) USING BTREE,
  INDEX `idx_customer`(`customer_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商机跟进记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_org
-- ----------------------------
DROP TABLE IF EXISTS `crm_org`;
CREATE TABLE `crm_org`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父组织ID',
  `ancestors` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '祖级路径',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组织编码',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组织名称',
  `org_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织类型(GROUP集团/COMPANY公司/SUB_COMPANY分公司/BU业务单元/PRODUCT_LINE产品线/DEPT部门)',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '负责人ID',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织描述',
  `level` int NULL DEFAULT 1 COMMENT '层级',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_org_code`(`org_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组织架构表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_permission
-- ----------------------------
DROP TABLE IF EXISTS `crm_permission`;
CREATE TABLE `crm_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父权限ID',
  `permission_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限编码',
  `permission_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限名称',
  `permission_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限类型(MENU菜单/BUTTON按钮/API接口)',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统类型',
  `path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜单路径',
  `route_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由路径',
  `api_path` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'API路径，多个用逗号分隔，支持{id}占位',
  `http_method` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'HTTP方法，多个用逗号分隔',
  `icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  `component` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '前端组件',
  `tree_level` int NULL DEFAULT NULL COMMENT '树层级',
  `tree_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '树路径',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_permission_code`(`permission_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 97 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_product
-- ----------------------------
DROP TABLE IF EXISTS `crm_product`;
CREATE TABLE `crm_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL DEFAULT 1,
  `product_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品编号(业务唯一键)',
  `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计量单位(套/人天/个/人)',
  `sales_price` decimal(18, 2) NULL DEFAULT NULL COMMENT '销售价(元)',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ON_SHELF' COMMENT 'ON_SHELF(上架中)/OFF_SHELF(已下架)',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品分类(软件产品/维保服务/实施服务/咨询服务/培训服务)',
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品描述',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'MANUAL' COMMENT '数据来源: EXCEL/MANUAL/API',
  `source_file_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '来源Excel文件名',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `owner_id` bigint NULL DEFAULT NULL COMMENT '数据归属人ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '归属部门ID',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_product_code`(`company_id` ASC, `product_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_company`(`company_id` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_project
-- ----------------------------
DROP TABLE IF EXISTS `crm_project`;
CREATE TABLE `crm_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NULL DEFAULT NULL,
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目编码',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `project_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目类型',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父项目ID',
  `customer_id` bigint NULL DEFAULT NULL COMMENT '客户ID',
  `customer_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户编码',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户名称',
  `pm_id` bigint NULL DEFAULT NULL COMMENT '项目经理ID',
  `pm_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目经理',
  `sales_id` bigint NULL DEFAULT NULL COMMENT '销售负责人ID',
  `sales_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售负责人',
  `org_id` bigint NULL DEFAULT NULL COMMENT '所属部门ID',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所属部门',
  `planned_start_date` date NULL DEFAULT NULL COMMENT '计划开始',
  `planned_end_date` date NULL DEFAULT NULL COMMENT '计划结束',
  `actual_start_date` date NULL DEFAULT NULL COMMENT '实际开始',
  `actual_end_date` date NULL DEFAULT NULL COMMENT '实际结束',
  `budget_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '预算金额',
  `contract_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '合同金额',
  `actual_cost` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '实际成本',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PLANNING' COMMENT '项目状态',
  `progress` int NULL DEFAULT 0 COMMENT '进度%',
  `priority` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'MEDIUM' COMMENT '优先级',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `owner_id` bigint NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_code`(`project_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'CRM项目表(只读,源自pmt)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_region
-- ----------------------------
DROP TABLE IF EXISTS `crm_region`;
CREATE TABLE `crm_region`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父地区ID',
  `level` int NULL DEFAULT 1 COMMENT '层级(1国家2省3市4区县)',
  `region_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地区编码',
  `region_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '地区名称',
  `short_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '简称',
  `pinyin` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拼音',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 350 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '地区表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_role
-- ----------------------------
DROP TABLE IF EXISTS `crm_role`;
CREATE TABLE `crm_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色编码',
  `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色类型(SYSTEM系统角色/BUSINESS业务角色)',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色描述',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  `is_system` tinyint NOT NULL DEFAULT 0 COMMENT '是否系统预置角色(1=是,0=否),预置角色不可删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_code`(`role_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `crm_role_permission`;
CREATE TABLE `crm_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_perm`(`role_id` ASC, `permission_id` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2404 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_role_project
-- ----------------------------
DROP TABLE IF EXISTS `crm_role_project`;
CREATE TABLE `crm_role_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_project`(`role_id` ASC, `project_id` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色项目数据权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_sync_log
-- ----------------------------
DROP TABLE IF EXISTS `crm_sync_log`;
CREATE TABLE `crm_sync_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务标识',
  `task_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务名称',
  `trigger_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '触发方式(MANUAL/SCHEDULED)',
  `status` int NULL DEFAULT NULL COMMENT '状态(1成功0失败)',
  `message` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '消息',
  `added_count` int NULL DEFAULT 0 COMMENT '新增数量',
  `updated_count` int NULL DEFAULT 0 COMMENT '更新数量',
  `deleted_count` int NULL DEFAULT 0 COMMENT '删除数量',
  `total_count` int NULL DEFAULT 0 COMMENT '总数量',
  `duration` bigint NULL DEFAULT NULL COMMENT '耗时(毫秒)',
  `error_msg` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误信息',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人',
  `http_status` int NULL DEFAULT NULL COMMENT 'HTTP状态码',
  `response_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '响应体',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_key`(`task_key` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据同步日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_sync_task_config
-- ----------------------------
DROP TABLE IF EXISTS `crm_sync_task_config`;
CREATE TABLE `crm_sync_task_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务标识',
  `task_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `sync_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '同步类型(org/employee/overtime/attendance/leave/http)',
  `cron` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Cron表达式',
  `cron_desc` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Cron描述',
  `api_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '接口地址',
  `target_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '目标URL(HTTP任务)',
  `http_method` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'HTTP方法',
  `request_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求体',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `enabled` int NULL DEFAULT 1 COMMENT '是否启用(1启用0禁用)',
  `sys_built_in` int NULL DEFAULT 0 COMMENT '是否系统内置(1是0否)',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_task_key`(`task_key` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据同步任务配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_user
-- ----------------------------
DROP TABLE IF EXISTS `crm_user`;
CREATE TABLE `crm_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `employee_id` bigint NULL DEFAULT NULL,
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `employee_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `avatar_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `gender` int NULL DEFAULT 0,
  `dept_id` bigint NULL DEFAULT NULL,
  `position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `user_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` int NULL DEFAULT 1,
  `login_fail_count` int NULL DEFAULT 0,
  `lock_time` datetime NULL DEFAULT NULL,
  `last_login_time` datetime NULL DEFAULT NULL,
  `last_login_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `password_last_update_time` datetime NULL DEFAULT NULL,
  `need_change_password` tinyint NULL DEFAULT 0 COMMENT '是否需要首次登录修改密码(0-否,1-是)',
  `initial_password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '初始密码（用户修改密码后清空）',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for crm_user_role
-- ----------------------------
DROP TABLE IF EXISTS `crm_user_role`;
CREATE TABLE `crm_user_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_role`(`user_id` ASC, `role_id` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for hr_application_type
-- ----------------------------
DROP TABLE IF EXISTS `hr_application_type`;
CREATE TABLE `hr_application_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `type_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '申请类型编码',
  `type_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '申请类型名称',
  `biz_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务类型',
  `ref_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务子类型编码',
  `icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标标识',
  `route` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '前端表单路由',
  `is_common` tinyint NOT NULL DEFAULT 0 COMMENT '是否常用项目',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_application_type_code`(`type_code` ASC, `deleted` ASC) USING BTREE COMMENT '申请类型编码唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '申请类型目录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_approval_action
-- ----------------------------
DROP TABLE IF EXISTS `hr_approval_action`;
CREATE TABLE `hr_approval_action`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `task_id` bigint NULL DEFAULT NULL COMMENT '审批任务ID',
  `operator_id` bigint NOT NULL COMMENT '操作人用户ID',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作人姓名',
  `action` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批动作',
  `target_user_id` bigint NULL DEFAULT NULL COMMENT '转交或加签目标用户ID',
  `opinion` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '处理意见',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_approval_action_instance`(`instance_id` ASC, `create_time` ASC) USING BTREE COMMENT '审批时间线索引'
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批操作记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_approval_cc
-- ----------------------------
DROP TABLE IF EXISTS `hr_approval_cc`;
CREATE TABLE `hr_approval_cc`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `user_id` bigint NOT NULL COMMENT '抄送用户ID',
  `read_time` datetime NULL DEFAULT NULL COMMENT '查看时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '抄送时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_approval_cc_user`(`instance_id` ASC, `user_id` ASC) USING BTREE COMMENT '审批抄送用户唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批抄送记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_approval_config
-- ----------------------------
DROP TABLE IF EXISTS `hr_approval_config`;
CREATE TABLE `hr_approval_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置名称',
  `approval_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批类型',
  `approval_type_desc` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批类型描述',
  `approver_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批人类型',
  `approver_ids` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批人ID列表',
  `approver_names` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批人姓名列表',
  `level` int NULL DEFAULT NULL COMMENT '层级',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_type`(`approval_type` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_approval_flow
-- ----------------------------
DROP TABLE IF EXISTS `hr_approval_flow`;
CREATE TABLE `hr_approval_flow`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `business_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务类型',
  `business_type_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务类型名称',
  `flow_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流程名称',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '说明',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_business_type`(`business_type` ASC) USING BTREE COMMENT '审批流程定义表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批流程定义表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_approval_instance
-- ----------------------------
DROP TABLE IF EXISTS `hr_approval_instance`;
CREATE TABLE `hr_approval_instance`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `instance_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批实例编号',
  `flow_id` bigint NULL DEFAULT NULL COMMENT '流程定义ID',
  `business_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务类型',
  `business_id` bigint NOT NULL COMMENT '业务数据ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批标题',
  `applicant_id` bigint NOT NULL COMMENT '申请人用户ID',
  `applicant_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '申请人姓名',
  `proxy_user_id` bigint NULL DEFAULT NULL COMMENT '代发起账号用户ID',
  `proxy_user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '代发起账号姓名',
  `proxy_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '代发起原因',
  `previous_instance_id` bigint NULL DEFAULT NULL COMMENT '重新提交来源审批实例ID',
  `current_node_order` int NOT NULL DEFAULT 1 COMMENT '当前节点顺序',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '审批状态',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `cancel_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '撤回或作废原因',
  `terminated_by` bigint NULL DEFAULT NULL COMMENT '管理员终止人用户ID',
  `terminate_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '管理员终止原因',
  `terminate_time` datetime NULL DEFAULT NULL COMMENT '管理员终止时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_approval_instance_no`(`instance_no` ASC) USING BTREE COMMENT '审批实例编号唯一索引',
  INDEX `idx_approval_instance_business`(`business_type` ASC, `business_id` ASC) USING BTREE COMMENT '审批业务查询索引',
  INDEX `idx_approval_instance_applicant`(`applicant_id` ASC, `status` ASC) USING BTREE COMMENT '申请人审批查询索引',
  INDEX `idx_approval_instance_previous`(`previous_instance_id` ASC) USING BTREE COMMENT '重新提交来源流程索引'
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批实例表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_approval_instance_node
-- ----------------------------
DROP TABLE IF EXISTS `hr_approval_instance_node`;
CREATE TABLE `hr_approval_instance_node`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `node_order` int NOT NULL COMMENT '节点顺序',
  `node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '节点名称',
  `sign_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ANY' COMMENT '审批方式',
  `approver_user_ids` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批人用户ID列表',
  `handler_user_ids` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '处理人用户ID列表',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'WAITING' COMMENT '节点状态',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_instance_node_order`(`instance_id` ASC, `node_order` ASC) USING BTREE COMMENT '实例节点顺序唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批实例节点表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_approval_node
-- ----------------------------
DROP TABLE IF EXISTS `hr_approval_node`;
CREATE TABLE `hr_approval_node`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `flow_id` bigint NOT NULL COMMENT '流程ID',
  `node_order` int NOT NULL COMMENT '节点顺序',
  `node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '节点名称',
  `approver_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批人类型',
  `approver_role_id` bigint NULL DEFAULT NULL COMMENT '审批人角色ID',
  `approver_user_ids` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批人用户ID列表',
  `sign_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OR' COMMENT '签署方式',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '说明',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_flow_id`(`flow_id` ASC) USING BTREE COMMENT '审批流程节点表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批流程节点表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_approval_task
-- ----------------------------
DROP TABLE IF EXISTS `hr_approval_task`;
CREATE TABLE `hr_approval_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `instance_node_id` bigint NOT NULL COMMENT '审批实例节点ID',
  `assignee_id` bigint NOT NULL COMMENT '任务处理人用户ID',
  `task_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务类型',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '任务状态',
  `source_task_id` bigint NULL DEFAULT NULL COMMENT '转交或加签来源任务ID',
  `is_add_sign` tinyint NOT NULL DEFAULT 0 COMMENT '是否为加签任务',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_approval_task_assignee`(`assignee_id` ASC, `status` ASC) USING BTREE COMMENT '处理人待办查询索引',
  INDEX `idx_approval_task_instance`(`instance_id` ASC, `status` ASC) USING BTREE COMMENT '实例任务查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_adjustment_log
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_adjustment_log`;
CREATE TABLE `hr_attendance_adjustment_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `attendance_record_id` bigint NOT NULL COMMENT '考勤记录ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `attendance_date` date NOT NULL COMMENT '考勤日期',
  `source_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '来源类型:IMPORT/CORRECTION/MANUAL',
  `source_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '来源单号或批次号',
  `before_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '修改前JSON',
  `after_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '修改后JSON',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作人名称',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_adjustment_employee_date`(`employee_id` ASC, `attendance_date` ASC) USING BTREE COMMENT '考勤修正流水员工日期索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考勤修正流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_anomaly
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_anomaly`;
CREATE TABLE `hr_attendance_anomaly`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `anomaly_date` date NOT NULL COMMENT '异常日期',
  `anomaly_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '异常类型',
  `details` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '详情',
  `deduct_hours` decimal(4, 2) NOT NULL DEFAULT 0.00 COMMENT '扣减小时',
  `appeal_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NONE' COMMENT '申诉状态',
  `appeal_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '申诉原因',
  `manager_comment` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主管意见',
  `appeal_time` datetime NULL DEFAULT NULL COMMENT '申诉时间',
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `handler_id` bigint NULL DEFAULT NULL COMMENT '处理人ID',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_emp_date_type`(`employee_id` ASC, `anomaly_date` ASC, `anomaly_type` ASC) USING BTREE,
  INDEX `idx_appeal_status`(`appeal_status` ASC) USING BTREE COMMENT '考勤异常表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考勤异常表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_calendar
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_calendar`;
CREATE TABLE `hr_attendance_calendar`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `cal_date` date NOT NULL COMMENT '日历日期',
  `day_type` int NOT NULL DEFAULT 1 COMMENT '日期类型',
  `holiday_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '节假日名称',
  `shift_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次类型',
  `shift_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次编码',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `year` int NULL DEFAULT NULL COMMENT '年度',
  `month` int NULL DEFAULT NULL COMMENT '月份',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_cal_date`(`cal_date` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 731 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考勤日历表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_correction
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_correction`;
CREATE TABLE `hr_attendance_correction`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `approval_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批单号',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工工号',
  `employee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工姓名',
  `correction_date` date NOT NULL COMMENT '补卡日期',
  `correction_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '补卡类型',
  `correction_time` datetime NOT NULL COMMENT '补卡时间',
  `correction_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '补卡原因',
  `approval_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '审批状态',
  `quota_month` char(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '正式提交占用额度的月份',
  `current_approver_id` bigint NULL DEFAULT NULL COMMENT '当前审批人ID',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审批人ID',
  `approver_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批人名称',
  `approve_time` datetime NULL DEFAULT NULL COMMENT '审批时间',
  `approve_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批备注',
  `is_applied` tinyint NOT NULL DEFAULT 0 COMMENT '是否已应用',
  `apply_time` datetime NULL DEFAULT NULL COMMENT '申请时间',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `request_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '申请单号',
  `employee_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '员工工号',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织编码',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织名称',
  `attendance_record_id` bigint NULL DEFAULT NULL COMMENT '考勤记录ID',
  `attendance_date` date NULL DEFAULT NULL COMMENT '考勤日期',
  `corrected_check_in_time` datetime NULL DEFAULT NULL COMMENT '更正后签到时间',
  `corrected_check_out_time` datetime NULL DEFAULT NULL COMMENT '更正后签退时间',
  `current_approver` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前审批人',
  `instance_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批实例编号',
  `approved_time` datetime NULL DEFAULT NULL COMMENT '审批完成时间',
  `cancelled_time` datetime NULL DEFAULT NULL COMMENT '撤回时间',
  `cancel_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '撤回原因',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_approval_no`(`approval_no` ASC) USING BTREE,
  INDEX `idx_approval_status`(`approval_status` ASC) USING BTREE COMMENT '补卡申请表查询索引',
  INDEX `idx_correction_date`(`correction_date` ASC) USING BTREE COMMENT '补卡申请表查询索引',
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '补卡申请表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '补卡申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_correction_quota
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_correction_quota`;
CREATE TABLE `hr_attendance_correction_quota`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `quota_month` char(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '额度月份yyyy-MM',
  `used_count` int NOT NULL DEFAULT 0 COMMENT '已正式提交次数',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_employee_month`(`employee_id` ASC, `quota_month` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '补卡月度并发额度' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_import_batch
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_import_batch`;
CREATE TABLE `hr_attendance_import_batch`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `batch_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '导入批次号',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '原始文件名',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PREVIEW' COMMENT '状态:PREVIEW/IMPORTED/CANCELLED/FAILED',
  `total_count` int NOT NULL DEFAULT 0 COMMENT '总行数',
  `insert_count` int NOT NULL DEFAULT 0 COMMENT '新增数量',
  `update_count` int NOT NULL DEFAULT 0 COMMENT '覆盖数量',
  `conflict_count` int NOT NULL DEFAULT 0 COMMENT '冲突数量',
  `failed_count` int NOT NULL DEFAULT 0 COMMENT '失败数量',
  `error_message` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '批次错误信息',
  `confirmed_by` bigint NULL DEFAULT NULL COMMENT '确认导入人ID',
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '确认导入时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_attendance_import_batch_no`(`batch_no` ASC) USING BTREE,
  INDEX `idx_import_batch_status`(`status` ASC, `create_time` ASC) USING BTREE COMMENT '考勤导入批次状态索引'
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考勤导入批次表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_import_detail
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_import_detail`;
CREATE TABLE `hr_attendance_import_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `batch_id` bigint NOT NULL COMMENT '导入批次ID',
  `row_no` int NOT NULL COMMENT 'Excel行号',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '员工工号',
  `employee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '员工姓名',
  `attendance_date` date NULL DEFAULT NULL COMMENT '考勤日期',
  `check_in_time` datetime NULL DEFAULT NULL COMMENT '上班打卡时间',
  `check_out_time` datetime NULL DEFAULT NULL COMMENT '下班打卡时间',
  `attendance_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '考勤结果',
  `anomaly_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '异常类型',
  `exception_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '异常说明',
  `action_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '处理类型:INSERT/UPDATE/CONFLICT/SKIP',
  `validation_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'VALID' COMMENT '校验状态:VALID/INVALID',
  `error_message` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '校验错误',
  `row_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '原始行数据JSON',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_attendance_import_row`(`batch_id` ASC, `row_no` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_import_detail_batch`(`batch_id` ASC, `validation_status` ASC) USING BTREE COMMENT '考勤导入明细批次索引'
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考勤导入明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_record
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_record`;
CREATE TABLE `hr_attendance_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工工号',
  `employee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工姓名',
  `shift_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次类型',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织编码',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织名称',
  `attendance_date` date NOT NULL COMMENT '考勤日期',
  `check_in_time` datetime NULL DEFAULT NULL COMMENT '签到时间',
  `check_out_time` datetime NULL DEFAULT NULL COMMENT '签退时间',
  `check_in_location` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打卡上班地点',
  `check_out_location` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打卡下班地点',
  `attendance_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '考勤状态',
  `late_minutes` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '迟到分钟',
  `early_leave_minutes` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '早退请假分钟',
  `absent_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '缺勤小时',
  `outside_work_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '外勤工作小时',
  `work_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '工作时长',
  `normal_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '正常小时',
  `overtime_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '加班小时',
  `leave_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '请假小时',
  `business_travel_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '业务出差小时',
  `planned_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '当日计划工时',
  `leave_type_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当日主要请假类型编码',
  `is_workday` tinyint NOT NULL DEFAULT 1 COMMENT '当日是否应出勤',
  `is_absent` tinyint NOT NULL DEFAULT 0 COMMENT '是否缺勤',
  `is_late` tinyint NOT NULL DEFAULT 0 COMMENT '是否迟到',
  `is_early_leave` tinyint NOT NULL DEFAULT 0 COMMENT '是否早退请假',
  `is_outside_work` tinyint NOT NULL DEFAULT 0 COMMENT '是否外勤工作',
  `is_holiday` tinyint NOT NULL DEFAULT 0 COMMENT '是否节假日',
  `holiday_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '节假日类型',
  `is_weekend` tinyint NOT NULL DEFAULT 0 COMMENT '是否周末',
  `has_leave` tinyint NOT NULL DEFAULT 0 COMMENT '是否有请假',
  `has_overtime` tinyint NOT NULL DEFAULT 0 COMMENT '是否有加班',
  `has_business_travel` tinyint NOT NULL DEFAULT 0 COMMENT '是否有业务出差',
  `has_correction` tinyint NOT NULL DEFAULT 0 COMMENT '是否有补卡',
  `import_batch_id` bigint NULL DEFAULT NULL COMMENT '考勤导入批次ID',
  `anomaly_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '异常类型:LATE/EARLY_LEAVE/LATE_EARLY/MISSING_IN/MISSING_OUT/ABSENT',
  `exception_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '异常说明',
  `source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SYSTEM' COMMENT '数据来源',
  `device_info` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备信息',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_employee_date`(`employee_id` ASC, `attendance_date` ASC) USING BTREE,
  INDEX `idx_attendance_date`(`attendance_date` ASC) USING BTREE COMMENT '考勤记录表查询索引',
  INDEX `idx_attendance_status`(`attendance_status` ASC) USING BTREE COMMENT '考勤记录表查询索引',
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '考勤记录表查询索引',
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE COMMENT '考勤记录表查询索引',
  INDEX `idx_import_batch_id`(`import_batch_id` ASC) USING BTREE COMMENT '考勤记录导入批次索引'
) ENGINE = InnoDB AUTO_INCREMENT = 332 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考勤记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_rule
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_rule`;
CREATE TABLE `hr_attendance_rule`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '规则编码',
  `rule_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '规则名称',
  `rule_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'STANDARD' COMMENT '规则类型',
  `work_start_time` time NULL DEFAULT '08:30:00' COMMENT '工作开始时间',
  `work_end_time` time NULL DEFAULT '18:00:00' COMMENT '工作结束时间',
  `break_start_time` time NULL DEFAULT '12:00:00' COMMENT '休息开始时间',
  `break_end_time` time NULL DEFAULT '13:30:00' COMMENT '休息结束时间',
  `work_hours_per_day` decimal(4, 1) NULL DEFAULT 8.0 COMMENT '工作小时每日期',
  `work_days_per_week` int NULL DEFAULT 5 COMMENT '工作天数每每周',
  `late_threshold_minutes` int NULL DEFAULT 30 COMMENT '迟到阈值分钟',
  `early_leave_threshold` int NULL DEFAULT 0 COMMENT '早退请假阈值',
  `absent_threshold` int NULL DEFAULT 120 COMMENT '缺勤阈值',
  `allow_overtime` tinyint NULL DEFAULT 1 COMMENT '允许加班',
  `overtime_need_approve` tinyint NULL DEFAULT 1 COMMENT '加班需求审批',
  `flexible_core_start` time NULL DEFAULT NULL COMMENT '弹性核心开始',
  `flexible_core_end` time NULL DEFAULT NULL COMMENT '弹性核心结束',
  `effective_date` date NULL DEFAULT NULL COMMENT '生效日期',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '说明',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态',
  `is_default` tinyint NULL DEFAULT 0 COMMENT '是否默认',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_rule_code`(`rule_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE COMMENT '考勤规则表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考勤规则表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_attendance_writeback
-- ----------------------------
DROP TABLE IF EXISTS `hr_attendance_writeback`;
CREATE TABLE `hr_attendance_writeback`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `biz_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务类型',
  `biz_id` bigint NOT NULL COMMENT '业务单据ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `attendance_date` date NOT NULL COMMENT '考勤日期',
  `hours` decimal(8, 2) NOT NULL DEFAULT 0.00 COMMENT '写入工时',
  `leave_type_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '假期类型编码',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_writeback_biz_date`(`biz_type` ASC, `biz_id` ASC, `attendance_date` ASC) USING BTREE COMMENT '单据日期唯一索引',
  INDEX `idx_writeback_emp_date`(`employee_id` ASC, `attendance_date` ASC) USING BTREE COMMENT '员工日期查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '考勤回写台账' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_business_travel_request
-- ----------------------------
DROP TABLE IF EXISTS `hr_business_travel_request`;
CREATE TABLE `hr_business_travel_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `approval_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批单号',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工工号',
  `employee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工姓名',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `dept_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '部门名称',
  `travel_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'DOMESTIC' COMMENT '出差类型',
  `destination` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '目的地',
  `start_date` date NOT NULL COMMENT '开始日期',
  `end_date` date NOT NULL COMMENT '结束日期',
  `start_time` datetime NULL DEFAULT NULL COMMENT '精确开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '精确结束时间',
  `duration_days` decimal(10, 2) NULL DEFAULT NULL COMMENT '时长（天）',
  `travel_purpose` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '出差目的',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目名称',
  `origin` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出发地（历史记录可空，新申请必填）',
  `transport_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '交通方式类型（逗号分隔）',
  `transport_other` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '其他交通方式',
  `estimated_cost` decimal(18, 2) NULL DEFAULT NULL COMMENT '预计费用',
  `travel_advance` decimal(18, 2) NULL DEFAULT NULL COMMENT '出差预支',
  `approval_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '审批状态',
  `current_approver_id` bigint NULL DEFAULT NULL COMMENT '当前审批人ID',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目编码',
  `transportation_cost` decimal(12, 2) NULL DEFAULT NULL COMMENT '交通费用',
  `accommodation_cost` decimal(12, 2) NULL DEFAULT NULL COMMENT '住宿费用',
  `meal_cost` decimal(12, 2) NULL DEFAULT NULL COMMENT '餐饮费用',
  `other_cost` decimal(12, 2) NULL DEFAULT NULL COMMENT '其他费用',
  `companion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '同行人',
  `instance_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '实例ID',
  `approved_time` datetime NULL DEFAULT NULL COMMENT '已审批时间',
  `cancelled_time` datetime NULL DEFAULT NULL COMMENT '已取消时间',
  `cancel_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '取消原因',
  `is_applied` tinyint NOT NULL DEFAULT 0 COMMENT '是否已回写考勤',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_approval_no`(`approval_no` ASC) USING BTREE,
  INDEX `idx_approval_status`(`approval_status` ASC) USING BTREE COMMENT '出差申请表查询索引',
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '出差申请表查询索引',
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE COMMENT '出差申请表查询索引',
  INDEX `idx_travel_dates`(`start_date` ASC, `end_date` ASC) USING BTREE COMMENT '出差申请表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '出差申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_candidate
-- ----------------------------
DROP TABLE IF EXISTS `hr_candidate`;
CREATE TABLE `hr_candidate`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `candidate_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '候选人编号',
  `recruit_need_id` bigint NULL DEFAULT NULL COMMENT '招聘需求ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '姓名',
  `gender` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '性别',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '手机号码',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `education` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学历',
  `work_years` decimal(3, 1) NULL DEFAULT NULL COMMENT '工作年限',
  `source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '数据来源',
  `candidate_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NEW' COMMENT '候选人状态',
  `resume_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '简历地址',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_candidate_no`(`candidate_no` ASC) USING BTREE,
  INDEX `idx_phone`(`phone` ASC) USING BTREE COMMENT '候选人表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '候选人表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_candidate_stage_history
-- ----------------------------
DROP TABLE IF EXISTS `hr_candidate_stage_history`;
CREATE TABLE `hr_candidate_stage_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `candidate_id` bigint NOT NULL COMMENT '候选人ID',
  `from_stage` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原招聘阶段',
  `to_stage` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '目标招聘阶段',
  `result` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '阶段结果',
  `owner_id` bigint NOT NULL COMMENT '阶段负责人用户ID',
  `comment` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流转说明',
  `start_time` datetime NOT NULL COMMENT '阶段开始时间',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '阶段完成时间',
  `created_by` bigint NOT NULL COMMENT '操作人用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_candidate_stage_history`(`candidate_id` ASC, `create_time` ASC) USING BTREE COMMENT '候选人流转历史索引'
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '候选人阶段流转历史表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_consultant_project_alias
-- ----------------------------
DROP TABLE IF EXISTS `hr_consultant_project_alias`;
CREATE TABLE `hr_consultant_project_alias`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `consultant_id` bigint NOT NULL COMMENT '顾问ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `client_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '客户名称',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_consultant_id`(`consultant_id` ASC) USING BTREE COMMENT '顾问项目别名表查询索引',
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE COMMENT '顾问项目别名表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '顾问项目别名表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_contract_renewal
-- ----------------------------
DROP TABLE IF EXISTS `hr_contract_renewal`;
CREATE TABLE `hr_contract_renewal`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `employee_id` bigint NOT NULL,
  `current_end_date` date NULL DEFAULT NULL,
  `renewal_term` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '续期方式（字典 contract_renewal_term）',
  `new_end_date` date NULL DEFAULT NULL,
  `reason` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `approval_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_contract_renewal_emp`(`employee_id` ASC, `approval_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '劳动合同续期申请' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_dict
-- ----------------------------
DROP TABLE IF EXISTS `hr_dict`;
CREATE TABLE `hr_dict`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dict_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典类型',
  `dict_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典编码',
  `dict_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字典名称',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'HR' COMMENT '系统类型',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dict_code`(`dict_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '数据字典表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_dict_item
-- ----------------------------
DROP TABLE IF EXISTS `hr_dict_item`;
CREATE TABLE `hr_dict_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dict_id` bigint NOT NULL COMMENT '字典ID',
  `item_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '项目编码',
  `item_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '项目名称',
  `item_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '字典项值',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dict_item`(`dict_id` ASC, `item_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 120 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '数据字典项表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee`;
CREATE TABLE `hr_employee`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工工号',
  `employee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工姓名',
  `gender` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '性别',
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '身份证号码',
  `birthday` date NULL DEFAULT NULL COMMENT '出生日期',
  `nationality` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '国籍',
  `marital_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '婚姻状态',
  `political_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '政治面貌状态',
  `native_place` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '籍贯地点',
  `address` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '地址',
  `mobile_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '手机号码',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `work_email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工作邮箱',
  `wecom_user_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '企业微信用户唯一标识',
  `org_id` bigint NOT NULL COMMENT '组织ID',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织名称',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '直属负责人用户ID',
  `position_id` bigint NOT NULL COMMENT '岗位ID',
  `position_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '岗位名称',
  `position_level` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '岗位级别',
  `entry_date` date NOT NULL COMMENT '入职日期',
  `first_work_date` date NULL DEFAULT NULL COMMENT '首次参加工作日期，用于计算法定年假',
  `probation_months` int NOT NULL DEFAULT 3 COMMENT '试用期月数',
  `probation_end_date` date NULL DEFAULT NULL COMMENT '试用期结束日期',
  `regular_date` date NULL DEFAULT NULL COMMENT '转正日期',
  `contract_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '合同类型',
  `contract_start_date` date NULL DEFAULT NULL COMMENT '合同开始日期',
  `contract_end_date` date NULL DEFAULT NULL COMMENT '合同结束日期',
  `contract_company` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '劳动合同单位',
  `contract_sign_times` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '签署次数/方式，如新签订、续签',
  `work_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PROBATION' COMMENT '在职状态',
  `resign_date` date NULL DEFAULT NULL COMMENT '离职日期',
  `resign_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '离职原因',
  `exempt_attendance` tinyint NOT NULL DEFAULT 0 COMMENT '豁免考勤',
  `workplace` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作地点',
  `education` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学历',
  `graduate_school` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '毕业学校',
  `major` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '专业',
  `highest_graduate_date` date NULL DEFAULT NULL COMMENT '最高学历毕业时间',
  `first_education` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第一学历',
  `first_school` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第一学历学校',
  `first_major` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第一学历专业',
  `first_graduate_date` date NULL DEFAULT NULL COMMENT '第一学历毕业时间',
  `work1_period` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作1在职时间',
  `work1_company` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作1企业',
  `work1_position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作1岗位',
  `work2_period` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作2在职时间',
  `work2_company` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作2企业',
  `work2_position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作2岗位',
  `work3_period` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作3在职时间',
  `work3_company` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作3企业',
  `work3_position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '近3份工作3岗位',
  `emergency_contact` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '紧急联系人',
  `emergency_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '紧急电话',
  `emergency_relation` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '紧急联系人关系',
  `professional_title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '职称',
  `bank_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '银行名称',
  `bank_account` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '银行账户',
  `social_security_city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '社会保险城市',
  `social_security_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '社保电脑号',
  `housing_fund_city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '住房公积金城市',
  `housing_fund_account` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公积金账号',
  `avatar_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像地址',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `onboard_source` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '入职管理来源:DIRECT/IMPORT/OFFER，空表示非入职办理产生',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `is_attendance_exempt` tinyint NULL DEFAULT 0 COMMENT '是否考勤豁免',
  `is_consultant` tinyint NULL DEFAULT 0 COMMENT '是否顾问',
  `consultant_default_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '顾问默认名称',
  `nation` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '民族',
  `registered_address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '户籍地址',
  `employment_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用工类型',
  `consultant_level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '顾问级别',
  `primary_domain` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主要领域',
  `secondary_domain` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '次要领域',
  `skill_tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '技能标签',
  `consultant_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '顾问备注',
  `consultant_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '顾问类型',
  `hourly_rate` decimal(18, 2) NULL DEFAULT NULL COMMENT '顾问小时费率',
  `monthly_salary` decimal(18, 2) NULL DEFAULT NULL COMMENT '顾问月度成本',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_id_card`(`id_card` ASC) USING BTREE,
  UNIQUE INDEX `uk_employee_mobile_phone`(`mobile_phone` ASC) USING BTREE,
  UNIQUE INDEX `uk_employee_work_email`(`work_email` ASC) USING BTREE,
  UNIQUE INDEX `uk_job_number`(`job_number` ASC) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE COMMENT '员工档案表查询索引',
  INDEX `idx_work_status`(`work_status` ASC) USING BTREE COMMENT '员工档案表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工档案表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_annual_confirm
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_annual_confirm`;
CREATE TABLE `hr_employee_annual_confirm`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `year` int NOT NULL COMMENT '确认年度',
  `confirm_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CONFIRM' COMMENT 'CONFIRM/EDIT',
  `change_id` bigint NULL DEFAULT NULL COMMENT '关联的档案变更单',
  `created_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_emp_annual_confirm`(`employee_id` ASC, `year` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工年度信息确认' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_contract
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_contract`;
CREATE TABLE `hr_employee_contract`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `contract_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '合同编号',
  `contract_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '合同类型',
  `contract_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '合同状态',
  `start_date` date NOT NULL COMMENT '开始日期',
  `end_date` date NULL DEFAULT NULL COMMENT '结束日期',
  `probation_months` int NOT NULL DEFAULT 0 COMMENT '试用期月数',
  `probation_end_date` date NULL DEFAULT NULL COMMENT '试用期结束日期',
  `work_location` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作地点',
  `work_position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作岗位',
  `salary_standard` decimal(18, 2) NULL DEFAULT NULL COMMENT '薪资标准',
  `sign_date` date NULL DEFAULT NULL COMMENT '签署日期',
  `sign_org` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '签署组织',
  `is_current` tinyint NOT NULL DEFAULT 0 COMMENT '是否当前',
  `file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文件地址',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `probation_start_date` date NULL DEFAULT NULL COMMENT '试用期开始日期',
  `work_department` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '合同约定部门',
  `is_current_contract` tinyint NOT NULL DEFAULT 1 COMMENT '是否当前合同',
  `contract_file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '合同文件地址',
  `renewal_count` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '续签次数',
  `actual_end_date` date NULL DEFAULT NULL COMMENT '实际结束日期',
  `termination_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '终止原因',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_contract_no`(`contract_no` ASC) USING BTREE,
  INDEX `idx_contract_status`(`contract_status` ASC) USING BTREE COMMENT '员工合同表查询索引',
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '员工合同表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工合同表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_education
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_education`;
CREATE TABLE `hr_employee_education`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `education_level` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学历级别',
  `school_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学校名称',
  `major` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '专业',
  `degree` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学位',
  `start_date` date NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` date NULL DEFAULT NULL COMMENT '结束日期',
  `is_full_time` tinyint NOT NULL DEFAULT 1 COMMENT '是否全职时间',
  `certificate_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '证书编号',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `study_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学习形式',
  `is_highest_education` tinyint NOT NULL DEFAULT 0 COMMENT '是否最高学历',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '员工教育经历表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工教育经历表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_family
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_family`;
CREATE TABLE `hr_employee_family`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '姓名',
  `relationship` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关系',
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'ID证件',
  `birthday` date NULL DEFAULT NULL COMMENT '出生日期',
  `work_unit` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作单位',
  `position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '岗位',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码',
  `is_emergency` tinyint NOT NULL DEFAULT 0 COMMENT '是否紧急',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `birth_date` date NULL DEFAULT NULL COMMENT '出生日期',
  `is_emergency_contact` tinyint NOT NULL DEFAULT 0 COMMENT '是否紧急联系人',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '员工家庭成员表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工家庭成员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_material
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_material`;
CREATE TABLE `hr_employee_material`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `material_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资料编码',
  `material_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资料名称',
  `submitted` tinyint NOT NULL DEFAULT 0 COMMENT '是否已交',
  `file_id` bigint NULL DEFAULT NULL COMMENT '附件ID',
  `file_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附件原名',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_emp_material`(`employee_id` ASC, `material_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_emp_material_file`(`file_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 76 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工入职资料附件' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_profile_change
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_profile_change`;
CREATE TABLE `hr_employee_profile_change`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED/CANCELLED',
  `old_payload` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '变更前字段JSON',
  `new_payload` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '变更后字段JSON',
  `submitter_id` bigint NULL DEFAULT NULL COMMENT '提交人用户ID',
  `reviewer_id` bigint NULL DEFAULT NULL COMMENT '审核人用户ID',
  `review_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `review_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核意见',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_profile_change_emp`(`employee_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_profile_change_status`(`status` ASC, `create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工档案自助变更待审核' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_salary
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_salary`;
CREATE TABLE `hr_employee_salary`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `salary_plan_id` bigint NULL DEFAULT NULL COMMENT '薪资方案ID',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `expire_date` date NULL DEFAULT NULL COMMENT '失效日期',
  `base_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '基本工资',
  `post_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '岗位工资',
  `performance_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '绩效工资',
  `allowance` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '固定津贴',
  `social_security_base` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '社保缴费基数',
  `housing_fund_base` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '公积金缴费基数',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_employee_salary_effective`(`employee_id` ASC, `effective_date` ASC, `expire_date` ASC) USING BTREE COMMENT '员工生效薪资查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工薪资标准表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_shift
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_shift`;
CREATE TABLE `hr_employee_shift`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `shift_id` bigint NOT NULL COMMENT '班次ID',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `expire_date` date NULL DEFAULT NULL COMMENT '到期日期',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '员工班次关系表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工班次关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_tax_deduction
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_tax_deduction`;
CREATE TABLE `hr_employee_tax_deduction`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `year` int NOT NULL COMMENT '所属年度',
  `child_education` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '子女教育（每月）',
  `continuing_education` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '继续教育（每月）',
  `housing_loan_interest` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '住房贷款利息（每月）',
  `housing_rent` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '住房租金（每月）',
  `elderly_care` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '赡养老人（每月）',
  `infant_care` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '3岁以下婴幼儿照护（每月）',
  `serious_illness` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '大病医疗（年度汇算）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tax_deduction_emp_year`(`employee_id` ASC, `year` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_tax_deduction_year`(`year` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工个税专项附加扣除表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_employee_work_experience
-- ----------------------------
DROP TABLE IF EXISTS `hr_employee_work_experience`;
CREATE TABLE `hr_employee_work_experience`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公司名称',
  `industry` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '行业',
  `position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位',
  `department` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '部门',
  `start_date` date NOT NULL COMMENT '开始日期',
  `end_date` date NULL DEFAULT NULL COMMENT '结束日期',
  `work_years` decimal(4, 1) NULL DEFAULT NULL COMMENT '工作年限',
  `salary` decimal(18, 2) NULL DEFAULT NULL COMMENT '薪资',
  `leaving_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '离职原因',
  `reference_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '证明人名称',
  `reference_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '证明人电话',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `salary_currency` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '薪资币种',
  `work_months` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作月数',
  `reference_position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '证明人职位',
  `leave_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '离职原因',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '员工工作经历表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工工作经历表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_enterprise_setting
-- ----------------------------
DROP TABLE IF EXISTS `hr_enterprise_setting`;
CREATE TABLE `hr_enterprise_setting`  (
  `id` bigint NOT NULL COMMENT '主键ID，单企业固定为1',
  `company_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '企业全称',
  `company_short_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '企业简称',
  `system_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '系统显示名称',
  `logo_file_id` bigint NULL DEFAULT NULL COMMENT '企业Logo文件ID',
  `contact_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '企业联系人',
  `contact_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `contact_email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系邮箱',
  `address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '办公地址',
  `workday_start` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '08:30' COMMENT '默认上班时间',
  `workday_end` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '18:00' COMMENT '默认下班时间',
  `hr_approver_user_ids` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '全局HR审批人用户ID，逗号分隔',
  `annual_leave_expire_date` date NULL DEFAULT NULL COMMENT '年假到期日（人事指定）',
  `compensatory_leave_expire_date` date NULL DEFAULT NULL COMMENT '调休假到期日（人事指定）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '企业公共设置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_file
-- ----------------------------
DROP TABLE IF EXISTS `hr_file`;
CREATE TABLE `hr_file`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '原始文件名',
  `storage_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '相对存储键',
  `extension` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文件扩展名',
  `content_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'MIME类型',
  `file_size` bigint NOT NULL COMMENT '文件大小（字节）',
  `sha256` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文件SHA256摘要',
  `storage_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LOCAL' COMMENT '存储类型',
  `uploader_id` bigint NOT NULL COMMENT '上传人用户ID',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_file_storage_key`(`storage_key` ASC) USING BTREE COMMENT '存储键唯一索引',
  INDEX `idx_file_sha256`(`sha256` ASC) USING BTREE COMMENT '文件摘要查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文件元数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_file_relation
-- ----------------------------
DROP TABLE IF EXISTS `hr_file_relation`;
CREATE TABLE `hr_file_relation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `file_id` bigint NOT NULL COMMENT '文件ID',
  `business_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务类型',
  `business_id` bigint NOT NULL COMMENT '业务数据ID',
  `relation_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ATTACHMENT' COMMENT '关联类型',
  `created_by` bigint NOT NULL COMMENT '关联人用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关联时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_file_business_relation`(`file_id` ASC, `business_type` ASC, `business_id` ASC, `relation_type` ASC) USING BTREE COMMENT '文件业务关联唯一索引',
  INDEX `idx_file_relation_business`(`business_type` ASC, `business_id` ASC) USING BTREE COMMENT '业务附件查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文件业务关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_form_category
-- ----------------------------
DROP TABLE IF EXISTS `hr_form_category`;
CREATE TABLE `hr_form_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 1,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_form_category_code`(`category_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批单据分类' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_form_def
-- ----------------------------
DROP TABLE IF EXISTS `hr_form_def`;
CREATE TABLE `hr_form_def`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NOT NULL,
  `form_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `form_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `flow_business_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'FORM',
  `status` tinyint NOT NULL DEFAULT 1,
  `sort_order` int NOT NULL DEFAULT 0,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_form_def_code`(`form_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '可配置审批单据定义' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_form_field
-- ----------------------------
DROP TABLE IF EXISTS `hr_form_field`;
CREATE TABLE `hr_form_field`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `form_id` bigint NOT NULL,
  `field_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `field_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `field_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `required` tinyint NOT NULL DEFAULT 0,
  `options_json` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 1,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_form_field_form`(`form_id` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '可配置审批单据字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_form_instance
-- ----------------------------
DROP TABLE IF EXISTS `hr_form_instance`;
CREATE TABLE `hr_form_instance`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `form_id` bigint NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `applicant_id` bigint NOT NULL,
  `field_values_json` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `approval_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_form_instance_applicant`(`applicant_id` ASC, `approval_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '可配置审批单据实例' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_interview
-- ----------------------------
DROP TABLE IF EXISTS `hr_interview`;
CREATE TABLE `hr_interview`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `interview_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '面试编号',
  `candidate_id` bigint NOT NULL COMMENT '候选人ID',
  `candidate_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '候选人姓名',
  `interview_round` int NOT NULL DEFAULT 1 COMMENT '面试轮次',
  `interview_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ONSITE' COMMENT '面试类型',
  `interview_time` datetime NOT NULL COMMENT '面试时间',
  `duration_minutes` int NOT NULL DEFAULT 60 COMMENT '时长分钟',
  `location` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '地点',
  `interviewers` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '面试官',
  `interviewer_names` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '面试官姓名列表',
  `interview_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SCHEDULED' COMMENT '面试状态',
  `interview_feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '面试反馈',
  `interview_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '面试评分',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_interview_no`(`interview_no` ASC) USING BTREE,
  INDEX `idx_candidate_id`(`candidate_id` ASC) USING BTREE COMMENT '招聘面试表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '招聘面试表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_leave_balance
-- ----------------------------
DROP TABLE IF EXISTS `hr_leave_balance`;
CREATE TABLE `hr_leave_balance`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `leave_type_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '假期类型编码',
  `year` int NOT NULL COMMENT '归属年度',
  `total_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '发放总额（小时）',
  `used_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '已使用额度（小时）',
  `frozen_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '审批中冻结额度（小时）',
  `expire_date` date NULL DEFAULT NULL COMMENT '失效日期',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_emp_type_year`(`employee_id` ASC, `leave_type_code` ASC, `year` ASC, `deleted` ASC) USING BTREE COMMENT '员工年度假期类型唯一索引',
  INDEX `idx_leave_balance_employee`(`employee_id` ASC, `year` ASC) USING BTREE COMMENT '员工年度额度查询索引',
  INDEX `idx_leave_balance_expire`(`expire_date` ASC) USING BTREE COMMENT '额度失效扫描索引'
) ENGINE = InnoDB AUTO_INCREMENT = 43 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工假期余额表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_leave_ledger
-- ----------------------------
DROP TABLE IF EXISTS `hr_leave_ledger`;
CREATE TABLE `hr_leave_ledger`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `leave_type_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '假期类型编码',
  `year` int NOT NULL COMMENT '归属年度',
  `change_amount` decimal(8, 2) NOT NULL COMMENT '变更数量',
  `balance_after` decimal(8, 2) NOT NULL COMMENT '变更后余额',
  `change_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '变更类型',
  `business_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联业务类型',
  `business_id` bigint NULL DEFAULT NULL COMMENT '关联业务ID',
  `expire_date` date NULL DEFAULT NULL COMMENT '失效日期',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '变更原因',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_leave_ledger_employee`(`employee_id` ASC, `leave_type_code` ASC, `year` ASC) USING BTREE COMMENT '员工假期流水查询索引',
  INDEX `idx_leave_ledger_business`(`business_type` ASC, `business_id` ASC) USING BTREE COMMENT '假期关联业务索引'
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工假期余额流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_leave_request
-- ----------------------------
DROP TABLE IF EXISTS `hr_leave_request`;
CREATE TABLE `hr_leave_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `approval_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批单号',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `leave_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请假类型',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `duration_days` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '时长（天）',
  `duration_hours` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '时长（小时）',
  `reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原因',
  `approval_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '审批状态',
  `current_approver_id` bigint NULL DEFAULT NULL COMMENT '当前审批人ID',
  `approval_process` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '审批流程',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `start_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `is_applied` tinyint NOT NULL DEFAULT 0 COMMENT '是否已回写考勤',
  `revoked_hours` decimal(8, 2) NOT NULL DEFAULT 0.00 COMMENT '已销假冲销小时',
  `revoke_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销假原因',
  `revoke_time` datetime NULL DEFAULT NULL COMMENT '销假时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_approval_no`(`approval_no` ASC) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '请假申请表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '请假申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_leave_type
-- ----------------------------
DROP TABLE IF EXISTS `hr_leave_type`;
CREATE TABLE `hr_leave_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `type_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '假期类型编码',
  `type_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '假期类型名称',
  `unit` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'HOUR' COMMENT '计量单位，统一使用小时',
  `paid` tinyint NOT NULL DEFAULT 0 COMMENT '是否带薪',
  `balance_required` tinyint NOT NULL DEFAULT 0 COMMENT '是否校验余额',
  `min_unit` decimal(4, 2) NOT NULL DEFAULT 0.50 COMMENT '最小申请单位',
  `icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '申请入口图标标识',
  `is_common` tinyint NOT NULL DEFAULT 0 COMMENT '是否常用项目',
  `max_hours_per_request` decimal(8, 2) NULL DEFAULT NULL COMMENT '单次申请上限小时',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_leave_type_code_deleted`(`type_code` ASC, `deleted` ASC) USING BTREE COMMENT '假期类型编码唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '假期类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_login_log
-- ----------------------------
DROP TABLE IF EXISTS `hr_login_log`;
CREATE TABLE `hr_login_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '登录账号',
  `login_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '登录类型',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `browser` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '浏览器',
  `os` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作系统',
  `status` int NULL DEFAULT 1 COMMENT '状态',
  `msg` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '消息',
  `login_result` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '登录结果',
  `fail_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '失败原因',
  `client_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户IP',
  `user_agent` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户代理信息',
  `request_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求路径',
  `login_time` datetime NULL DEFAULT NULL COMMENT '登录时间',
  `response_time_ms` bigint NULL DEFAULT NULL COMMENT '响应时间毫秒',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE COMMENT '登录日志表查询索引',
  INDEX `idx_username`(`username` ASC) USING BTREE COMMENT '登录日志表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 75 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '登录日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_message
-- ----------------------------
DROP TABLE IF EXISTS `hr_message`;
CREATE TABLE `hr_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `receiver_id` bigint NOT NULL COMMENT '接收人用户ID',
  `message_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息类型',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息标题',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息摘要',
  `business_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务类型',
  `business_id` bigint NULL DEFAULT NULL COMMENT '业务数据ID',
  `route_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '前端跳转路径',
  `read_status` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_message_receiver`(`receiver_id` ASC, `read_status` ASC, `create_time` ASC) USING BTREE COMMENT '用户消息查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '站内消息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_monthly_attendance_summary
-- ----------------------------
DROP TABLE IF EXISTS `hr_monthly_attendance_summary`;
CREATE TABLE `hr_monthly_attendance_summary`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `month` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '月份',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工工号',
  `employee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工姓名',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织名称',
  `position_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '岗位',
  `entry_date` date NULL DEFAULT NULL COMMENT '入职日期',
  `resign_date` date NULL DEFAULT NULL COMMENT '离职日期',
  `should_work_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '应工作天数',
  `not_arrived_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '未到岗天数',
  `actual_work_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '实际工作天数',
  `normal_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '正常天数',
  `late_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '迟到天数',
  `early_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '早退天数',
  `absent_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '缺勤天数',
  `absent_work_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '旷工天数',
  `leave_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '请假天数',
  `personal_leave_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '个人请假天数',
  `late_early_count` int NOT NULL DEFAULT 0 COMMENT '迟到早退次数',
  `late_early_deduct_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '迟到早退缺卡扣除小时',
  `correction_count` int NOT NULL DEFAULT 0 COMMENT '补卡次数',
  `attendance_rate` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '考勤比例',
  `personal_leave_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '个人请假小时',
  `sick_leave_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '病假请假天数',
  `annual_leave_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '年度请假天数',
  `compensatory_leave_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '调休假天数',
  `marriage_leave_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '婚假天数',
  `maternity_paternity_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '产假陪产假天数',
  `prenatal_leave_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '产检假天数',
  `bereavement_leave_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '丧假天数',
  `wfh_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '居家办公天数',
  `out_work_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '外出公干天数',
  `summary_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `business_trip_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '业务出差天数',
  `overtime_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '加班小时',
  `overtime_pay_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '加班发薪小时',
  `should_work_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '应出勤小时',
  `actual_work_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '实际出勤小时',
  `absent_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '缺勤小时',
  `leave_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '请假合计小时',
  `paid_leave_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '带薪假小时',
  `unpaid_leave_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '无薪假小时',
  `annual_leave_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '年假小时',
  `sick_leave_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '病假小时',
  `other_leave_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '其他假期小时',
  `business_trip_hours` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '出差小时',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_month_emp`(`month` ASC, `employee_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 82 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '月度考勤汇总表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_offer
-- ----------------------------
DROP TABLE IF EXISTS `hr_offer`;
CREATE TABLE `hr_offer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `offer_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '录用通知编号',
  `candidate_id` bigint NOT NULL COMMENT '候选人ID',
  `candidate_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '候选人姓名',
  `position_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位名称',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  `dept_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门名称',
  `offer_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '录用通知金额',
  `entry_date` date NULL DEFAULT NULL COMMENT '入职日期',
  `probation_months` int NOT NULL DEFAULT 3 COMMENT '试用期月数',
  `offer_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'STANDARD' COMMENT '录用类型',
  `offer_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '录用通知状态',
  `approval_instance_id` bigint NULL DEFAULT NULL COMMENT '审批实例ID',
  `issued_time` datetime NULL DEFAULT NULL COMMENT '发放时间',
  `response_time` datetime NULL DEFAULT NULL COMMENT '候选人反馈时间',
  `offer_file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '录用通知文件地址',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_offer_no`(`offer_no` ASC) USING BTREE,
  INDEX `idx_candidate_id`(`candidate_id` ASC) USING BTREE COMMENT '录用通知表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '录用通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_onsite_report
-- ----------------------------
DROP TABLE IF EXISTS `hr_onsite_report`;
CREATE TABLE `hr_onsite_report`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `report_date` date NOT NULL COMMENT '填报日期',
  `onsite_days` decimal(5, 2) NOT NULL COMMENT '现场服务人天',
  `work_content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工作内容',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_onsite_project_date`(`project_id` ASC, `report_date` ASC) USING BTREE COMMENT '项目现场服务查询索引',
  INDEX `idx_onsite_employee_date`(`employee_id` ASC, `report_date` ASC) USING BTREE COMMENT '员工现场服务查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '顾问现场服务填报表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `hr_operation_log`;
CREATE TABLE `hr_operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `module` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务模块',
  `business_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务对象ID',
  `operation` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作',
  `method` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '方法',
  `request_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '请求参数',
  `before_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '变更前数据（敏感字段已脱敏）',
  `after_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '变更后数据（敏感字段已脱敏）',
  `response_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '响应数据',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作人名称',
  `operator_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作人IP',
  `cost_time` int NULL DEFAULT NULL COMMENT '费用时间',
  `status` int NULL DEFAULT NULL COMMENT '状态',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '错误信息',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'HR' COMMENT '系统类型',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '说明',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型',
  `request_method` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求方法',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '登录账号',
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户端标识',
  `request_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求地址',
  `response_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '响应结果',
  `duration` bigint NULL DEFAULT NULL COMMENT '执行时长',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE COMMENT '操作审计日志表查询索引',
  INDEX `idx_operator_id`(`operator_id` ASC) USING BTREE COMMENT '操作审计日志表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 95 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作审计日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_org
-- ----------------------------
DROP TABLE IF EXISTS `hr_org`;
CREATE TABLE `hr_org`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '上级ID',
  `ancestors` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '祖级路径',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织编码',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织名称',
  `org_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组织类型',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '负责人ID',
  `level` int NOT NULL DEFAULT 1 COMMENT '层级',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_org_code`(`org_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组织机构表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_org_type
-- ----------------------------
DROP TABLE IF EXISTS `hr_org_type`;
CREATE TABLE `hr_org_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `type_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '类型编码',
  `type_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '类型名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '上级ID',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序号',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `type_level` int NULL DEFAULT NULL COMMENT '类型级别',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_type_code`(`type_code` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE COMMENT '组织类型表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组织类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_overtime_request
-- ----------------------------
DROP TABLE IF EXISTS `hr_overtime_request`;
CREATE TABLE `hr_overtime_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `approval_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '审批单号',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `overtime_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '加班类型',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `apply_time` datetime NOT NULL COMMENT '申请时间',
  `gross_duration_hours` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '总时长小时',
  `net_duration_hours` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '净时长小时',
  `is_late_apply` tinyint NOT NULL DEFAULT 0 COMMENT '是否迟到申请',
  `warning_flag` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '预警标记',
  `reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原因',
  `approval_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '审批状态',
  `convert_to_comp` tinyint NOT NULL DEFAULT 0 COMMENT '转换为调休',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `current_approver_id` bigint NULL DEFAULT NULL COMMENT '当前审批人ID',
  `is_applied` tinyint NOT NULL DEFAULT 0 COMMENT '是否已回写考勤',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_approval_no`(`approval_no` ASC) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '加班申请表查询索引',
  INDEX `idx_is_late_apply`(`is_late_apply` ASC) USING BTREE COMMENT '加班申请表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '加班申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_payroll
-- ----------------------------
DROP TABLE IF EXISTS `hr_payroll`;
CREATE TABLE `hr_payroll`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `payroll_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工资批次编号',
  `payroll_month` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工资批次月份',
  `payroll_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工资批次名称',
  `payroll_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '工资批次状态',
  `total_employees` int NOT NULL DEFAULT 0 COMMENT '总计员工人数',
  `total_gross_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '总计总薪资',
  `total_net_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '总计净薪资',
  `total_tax` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '总计个税',
  `pay_time` date NULL DEFAULT NULL COMMENT '发薪时间',
  `creator_id` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `creator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人姓名',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_payroll_month`(`payroll_month` ASC) USING BTREE,
  UNIQUE INDEX `uk_payroll_no`(`payroll_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工资批次表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_payroll_item
-- ----------------------------
DROP TABLE IF EXISTS `hr_payroll_item`;
CREATE TABLE `hr_payroll_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `payroll_id` bigint NOT NULL COMMENT '工资批次ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工工号',
  `employee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工姓名',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织名称',
  `work_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '工作天数',
  `actual_work_days` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '实际工作天数',
  `base_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '基本工资',
  `post_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '岗位薪资',
  `performance_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '绩效薪资',
  `gross_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '应发工资',
  `social_security_personal` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '社会保险个人',
  `housing_fund_personal` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '住房公积金个人',
  `tax_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '个人所得税',
  `special_deduction` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '本月专项附加扣除合计',
  `cumulative_income` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '本年累计应税收入',
  `cumulative_tax_paid` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '本年累计已预扣税额（不含本月）',
  `company_cost` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '单位承担的社保公积金合计',
  `net_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '实发工资',
  `slip_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNSENT' COMMENT '工资条状态',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_payroll_emp`(`payroll_id` ASC, `employee_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE COMMENT '工资明细表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工资明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_payroll_item_detail
-- ----------------------------
DROP TABLE IF EXISTS `hr_payroll_item_detail`;
CREATE TABLE `hr_payroll_item_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `payroll_id` bigint NOT NULL COMMENT '工资批次ID',
  `payroll_item_id` bigint NOT NULL COMMENT '员工工资单ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `item_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '薪资项编码',
  `item_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '薪资项名称',
  `item_category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '薪资项分组',
  `amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '金额',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '展示顺序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_detail_item`(`payroll_item_id` ASC) USING BTREE,
  INDEX `idx_detail_payroll`(`payroll_id` ASC, `item_category` ASC) USING BTREE,
  INDEX `idx_detail_employee`(`employee_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工资明细项表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_payroll_version
-- ----------------------------
DROP TABLE IF EXISTS `hr_payroll_version`;
CREATE TABLE `hr_payroll_version`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `payroll_id` bigint NOT NULL COMMENT '工资批次ID',
  `version_no` int NOT NULL COMMENT '工资版本号',
  `change_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '版本变更原因',
  `snapshot_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工资批次快照',
  `created_by` bigint NOT NULL COMMENT '创建人用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_payroll_version_no`(`payroll_id` ASC, `version_no` ASC) USING BTREE COMMENT '工资批次版本唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工资批次版本表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_perf_cycle
-- ----------------------------
DROP TABLE IF EXISTS `hr_perf_cycle`;
CREATE TABLE `hr_perf_cycle`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `cycle_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '周期编码',
  `cycle_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '周期名称',
  `cycle_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '周期类型',
  `year` int NOT NULL COMMENT '年度',
  `start_date` date NOT NULL COMMENT '开始日期',
  `end_date` date NOT NULL COMMENT '结束日期',
  `cycle_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NOT_STARTED' COMMENT '周期状态',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_cycle_code`(`cycle_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '绩效周期表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_perf_plan
-- ----------------------------
DROP TABLE IF EXISTS `hr_perf_plan`;
CREATE TABLE `hr_perf_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `plan_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '方案编码',
  `plan_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '方案名称',
  `cycle_id` bigint NOT NULL COMMENT '周期ID',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `plan_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '计划状态',
  `self_weight` int NOT NULL DEFAULT 30 COMMENT '自评权重百分比',
  `manager_weight` int NOT NULL DEFAULT 70 COMMENT '主管评分权重百分比',
  `grade_a_min` decimal(5, 2) NOT NULL DEFAULT 90.00 COMMENT 'A级最低分',
  `grade_b_min` decimal(5, 2) NOT NULL DEFAULT 80.00 COMMENT 'B级最低分',
  `grade_c_min` decimal(5, 2) NOT NULL DEFAULT 70.00 COMMENT 'C级最低分',
  `grade_d_min` decimal(5, 2) NOT NULL DEFAULT 60.00 COMMENT 'D级最低分',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_plan_code`(`plan_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '绩效计划表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_perf_result
-- ----------------------------
DROP TABLE IF EXISTS `hr_perf_result`;
CREATE TABLE `hr_perf_result`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `plan_id` bigint NOT NULL COMMENT '计划ID',
  `cycle_id` bigint NOT NULL COMMENT '周期ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工工号',
  `employee_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '员工姓名',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组织名称',
  `self_score` decimal(10, 2) NULL DEFAULT NULL COMMENT '自评评分',
  `self_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '自评意见',
  `manager_score` decimal(10, 2) NULL DEFAULT NULL COMMENT '主管评分',
  `manager_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '主管意见',
  `final_score` decimal(10, 2) NULL DEFAULT NULL COMMENT '最终评分',
  `grade` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '等级',
  `result_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NOT_STARTED' COMMENT '结果状态',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_plan_emp`(`plan_id` ASC, `employee_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '绩效结果表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_permission
-- ----------------------------
DROP TABLE IF EXISTS `hr_permission`;
CREATE TABLE `hr_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '上级ID',
  `permission_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限编码',
  `permission_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限名称',
  `permission_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限类型',
  `path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '路径',
  `route_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '路由路径',
  `api_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '接口路径',
  `http_method` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'HTTP方法',
  `icon` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标',
  `component` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '组件',
  `tree_level` int NULL DEFAULT NULL COMMENT '树形级别',
  `tree_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '树形路径',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'HR' COMMENT '系统类型',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_permission_code`(`permission_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 69 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_position
-- ----------------------------
DROP TABLE IF EXISTS `hr_position`;
CREATE TABLE `hr_position`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `position_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位编码',
  `position_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位名称',
  `position_seq` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位序列',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `level_range` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '级别范围',
  `job_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '岗位描述',
  `requirement` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '任职要求',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_position_code`(`position_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '岗位表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_project
-- ----------------------------
DROP TABLE IF EXISTS `hr_project`;
CREATE TABLE `hr_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '项目编码',
  `project_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '项目名称',
  `project_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DELIVERY' COMMENT '项目类型',
  `customer_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '客户名称',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '项目负责人用户ID',
  `manager_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目负责人姓名',
  `start_date` date NULL DEFAULT NULL COMMENT '计划开始日期',
  `end_date` date NULL DEFAULT NULL COMMENT '计划结束日期',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PLANNING' COMMENT '项目状态',
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目说明',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_code_deleted`(`project_code` ASC, `deleted` ASC) USING BTREE COMMENT '项目编码唯一索引',
  INDEX `idx_project_status`(`status` ASC) USING BTREE COMMENT '项目状态查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '项目信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_project_authorization
-- ----------------------------
DROP TABLE IF EXISTS `hr_project_authorization`;
CREATE TABLE `hr_project_authorization`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '授权用户ID',
  `project_id` bigint NOT NULL COMMENT '授权项目ID',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_authorization`(`user_id` ASC, `project_id` ASC) USING BTREE COMMENT '用户项目授权唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户项目数据授权表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_project_member
-- ----------------------------
DROP TABLE IF EXISTS `hr_project_member`;
CREATE TABLE `hr_project_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `project_role` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '项目角色',
  `allocation_rate` decimal(5, 2) NOT NULL DEFAULT 100.00 COMMENT '项目投入比例',
  `is_manager` tinyint NOT NULL DEFAULT 0 COMMENT '是否项目负责人',
  `is_primary` tinyint NOT NULL DEFAULT 0 COMMENT '是否该员工的主项目(1是0否，可多主)',
  `join_date` date NOT NULL COMMENT '加入日期',
  `leave_date` date NULL DEFAULT NULL COMMENT '退出日期',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_employee_deleted`(`project_id` ASC, `employee_id` ASC, `deleted` ASC) USING BTREE COMMENT '项目成员唯一索引',
  INDEX `idx_project_member_employee`(`employee_id` ASC, `status` ASC) USING BTREE COMMENT '员工项目查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '项目成员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_recruit_need
-- ----------------------------
DROP TABLE IF EXISTS `hr_recruit_need`;
CREATE TABLE `hr_recruit_need`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `need_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '需求编号',
  `need_title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '需求标题',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  `dept_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '部门名称',
  `position_id` bigint NOT NULL COMMENT '岗位ID',
  `position_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '岗位名称',
  `headcount` int NOT NULL DEFAULT 1 COMMENT '招聘人数',
  `work_location` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作地点',
  `salary_range` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '薪资范围',
  `urgency` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NORMAL' COMMENT '紧急程度',
  `applicant_id` bigint NULL DEFAULT NULL COMMENT '申请人ID',
  `need_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '需求状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '说明',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_need_no`(`need_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '招聘需求表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_region
-- ----------------------------
DROP TABLE IF EXISTS `hr_region`;
CREATE TABLE `hr_region`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '上级ID',
  `level` tinyint NOT NULL DEFAULT 1 COMMENT '层级',
  `region_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '行政区划编码',
  `region_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '行政区划名称',
  `short_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '简称名称',
  `pinyin` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '拼音',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_level`(`level` ASC) USING BTREE COMMENT '行政区划表查询索引',
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE COMMENT '行政区划表查询索引',
  INDEX `idx_region_code`(`region_code` ASC) USING BTREE COMMENT '行政区划表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '行政区划表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_resignation
-- ----------------------------
DROP TABLE IF EXISTS `hr_resignation`;
CREATE TABLE `hr_resignation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `resignation_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '离职单号',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `resignation_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '离职类型',
  `apply_date` date NOT NULL COMMENT '申请日期',
  `expected_date` date NOT NULL COMMENT '预计离职日期',
  `actual_date` date NULL DEFAULT NULL COMMENT '实际离职日期',
  `reason` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '离职原因',
  `handover_user_id` bigint NOT NULL COMMENT '工作交接人用户ID',
  `approval_instance_id` bigint NULL DEFAULT NULL COMMENT '审批实例ID',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT' COMMENT '业务状态',
  `hr_opinion` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '人事处理意见',
  `manager_opinion` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '负责人处理意见',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_resignation_no`(`resignation_no` ASC) USING BTREE COMMENT '离职单号唯一索引',
  INDEX `idx_resignation_employee_status`(`employee_id` ASC, `status` ASC) USING BTREE COMMENT '员工离职状态索引'
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工离职申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_resume_version
-- ----------------------------
DROP TABLE IF EXISTS `hr_resume_version`;
CREATE TABLE `hr_resume_version`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `candidate_id` bigint NOT NULL COMMENT '候选人ID',
  `version_no` int NOT NULL COMMENT '简历版本号',
  `file_id` bigint NOT NULL COMMENT '简历文件ID',
  `is_current` tinyint NOT NULL DEFAULT 1 COMMENT '是否当前版本',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '版本说明',
  `created_by` bigint NOT NULL COMMENT '上传人用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_resume_candidate_version`(`candidate_id` ASC, `version_no` ASC) USING BTREE COMMENT '候选人简历版本唯一索引',
  INDEX `idx_resume_candidate_current`(`candidate_id` ASC, `is_current` ASC) USING BTREE COMMENT '当前简历查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '候选人简历版本表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_role
-- ----------------------------
DROP TABLE IF EXISTS `hr_role`;
CREATE TABLE `hr_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色编码',
  `role_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `role_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色类型',
  `data_scope` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SELF' COMMENT '数据范围:SELF本人/DEPT本部门/DEPT_AND_CHILDREN本部门及下级/ALL全公司',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '说明',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_code`(`role_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `hr_role_permission`;
CREATE TABLE `hr_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_perm`(`role_id` ASC, `permission_id` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 168 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色权限关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_salary_config
-- ----------------------------
DROP TABLE IF EXISTS `hr_salary_config`;
CREATE TABLE `hr_salary_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置编码',
  `config_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置名称',
  `config_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置类型',
  `salary_item_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '薪资项目类型',
  `calc_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'FIXED' COMMENT '计算类型',
  `fixed_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '固定金额',
  `formula` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '计算公式',
  `rate` decimal(8, 4) NULL DEFAULT NULL COMMENT '比例',
  `is_taxable` tinyint NULL DEFAULT 1 COMMENT '是否计税',
  `is_social_security` tinyint NULL DEFAULT 0 COMMENT '是否社会保险',
  `is_housing_fund` tinyint NULL DEFAULT 0 COMMENT '是否住房公积金',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序号',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '说明',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_code`(`config_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_config_type`(`config_type` ASC) USING BTREE COMMENT '薪资配置表查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '薪资配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_salary_item
-- ----------------------------
DROP TABLE IF EXISTS `hr_salary_item`;
CREATE TABLE `hr_salary_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `item_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '薪资项编码',
  `item_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '薪资项名称',
  `item_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '薪资项类型',
  `calc_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'FIXED' COMMENT '计算方式',
  `formula` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '计算公式',
  `taxable` tinyint NOT NULL DEFAULT 1 COMMENT '是否计税',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_salary_item_code_deleted`(`item_code` ASC, `deleted` ASC) USING BTREE COMMENT '薪资项编码唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '薪资项目表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_salary_plan
-- ----------------------------
DROP TABLE IF EXISTS `hr_salary_plan`;
CREATE TABLE `hr_salary_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `plan_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '方案编码',
  `plan_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '方案名称',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `effective_date` date NOT NULL COMMENT '生效日期',
  `base_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '基本工资',
  `post_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '岗位薪资',
  `performance_salary` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '绩效薪资',
  `allowance` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '津贴',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_plan_code`(`plan_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '薪资方案表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_scheduled_job
-- ----------------------------
DROP TABLE IF EXISTS `hr_scheduled_job`;
CREATE TABLE `hr_scheduled_job`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `job_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务编码（对应内置处理器）',
  `job_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务名称',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务说明',
  `schedule_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '调度类型 DAILY/WEEKLY/MONTHLY/YEARLY',
  `execute_time` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '01:00' COMMENT '执行时刻 HH:mm',
  `day_of_week` int NULL DEFAULT NULL COMMENT '每周几执行（1-7，周一为1，WEEKLY用）',
  `day_of_month` int NULL DEFAULT NULL COMMENT '每月几号执行（1-31，MONTHLY/YEARLY用，超过月末按月末）',
  `month_of_year` int NULL DEFAULT NULL COMMENT '每年几月执行（1-12，YEARLY用）',
  `params` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务参数（可空，各任务自行解析）',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态 1启用 0停用',
  `next_run_time` datetime NULL DEFAULT NULL COMMENT '下次自动执行时间',
  `last_run_time` datetime NULL DEFAULT NULL COMMENT '最近执行时间',
  `last_run_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最近执行状态 SUCCESS/FAILED/RUNNING',
  `last_run_result` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最近执行结果',
  `last_run_duration_ms` bigint NULL DEFAULT NULL COMMENT '最近执行耗时(毫秒)',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_scheduled_job_code`(`job_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_scheduled_job_next`(`status` ASC, `next_run_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '定时任务配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_scheduled_job_log
-- ----------------------------
DROP TABLE IF EXISTS `hr_scheduled_job_log`;
CREATE TABLE `hr_scheduled_job_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `job_id` bigint NOT NULL COMMENT '任务配置ID',
  `job_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务编码',
  `job_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务名称',
  `trigger_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '触发方式 AUTO自动/MANUAL手动',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `duration_ms` bigint NULL DEFAULT NULL COMMENT '耗时(毫秒)',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行状态 SUCCESS/FAILED',
  `result` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '执行结果',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '手动执行的操作人用户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_job_log_job`(`job_id` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 77 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '定时任务执行记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_social_security_policy
-- ----------------------------
DROP TABLE IF EXISTS `hr_social_security_policy`;
CREATE TABLE `hr_social_security_policy`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '城市',
  `policy_year` int NOT NULL COMMENT '政策年度',
  `base_min` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '基数下限',
  `base_max` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '基数上限',
  `pension_personal_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '养老保险个人比例',
  `pension_company_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '养老保险公司比例',
  `medical_personal_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '医疗保险个人比例',
  `medical_company_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '医疗保险公司比例',
  `unemployment_personal_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '失业保险个人比例',
  `unemployment_company_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '失业保险单位比例',
  `injury_company_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '工伤保险单位比例（个人不缴）',
  `maternity_company_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '生育保险单位比例（个人不缴）',
  `medical_extra_personal` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '大病医疗个人固定金额',
  `housing_fund_personal_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '住房公积金个人比例',
  `housing_fund_company_rate` decimal(6, 4) NOT NULL DEFAULT 0.0000 COMMENT '住房公积金公司比例',
  `housing_base_min` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '公积金基数下限',
  `housing_base_max` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '公积金基数上限',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_city_year`(`city` ASC, `policy_year` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '社保公积金政策表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_user
-- ----------------------------
DROP TABLE IF EXISTS `hr_user`;
CREATE TABLE `hr_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '员工ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录账号',
  `password_hash` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'BCrypt密码摘要',
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '真实姓名',
  `employee_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '员工工号',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码',
  `avatar_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像地址',
  `gender` int NULL DEFAULT NULL COMMENT '性别',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '岗位',
  `user_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户类型',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态',
  `login_fail_count` int NOT NULL DEFAULT 0 COMMENT '登录失败次数',
  `lock_time` datetime NULL DEFAULT NULL COMMENT '锁定时间',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最近登录时间',
  `last_login_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最近登录IP',
  `password_last_update_time` datetime NULL DEFAULT NULL COMMENT '密码最近更新时间',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_user_contact
-- ----------------------------
DROP TABLE IF EXISTS `hr_user_contact`;
CREATE TABLE `hr_user_contact`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `owner_user_id` bigint NOT NULL COMMENT '联系人记录所属用户ID',
  `contact_user_id` bigint NOT NULL COMMENT '被选择的联系人用户ID',
  `use_count` int NOT NULL DEFAULT 0 COMMENT '选择次数',
  `last_used_time` datetime NULL DEFAULT NULL COMMENT '最近选择时间',
  `is_pinned` tinyint NOT NULL DEFAULT 0 COMMENT '是否置顶',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_contact_owner`(`owner_user_id` ASC, `contact_user_id` ASC) USING BTREE COMMENT '用户联系人唯一索引',
  INDEX `idx_user_contact_recent`(`owner_user_id` ASC, `is_pinned` ASC, `last_used_time` ASC) USING BTREE COMMENT '常用联系人查询索引'
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户常用联系人表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_user_role
-- ----------------------------
DROP TABLE IF EXISTS `hr_user_role`;
CREATE TABLE `hr_user_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_role`(`user_id` ASC, `role_id` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户角色关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for hr_work_shift
-- ----------------------------
DROP TABLE IF EXISTS `hr_work_shift`;
CREATE TABLE `hr_work_shift`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `shift_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '班次编码',
  `shift_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '班次名称',
  `shift_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'FIXED' COMMENT '班次类型',
  `work_start_time` time NOT NULL COMMENT '工作开始时间',
  `work_end_time` time NOT NULL COMMENT '工作结束时间',
  `break_start_time` time NULL DEFAULT NULL COMMENT '休息开始时间',
  `break_end_time` time NULL DEFAULT NULL COMMENT '休息结束时间',
  `late_threshold_min` int NOT NULL DEFAULT 15 COMMENT '迟到阈值下限',
  `early_leave_threshold_min` int NOT NULL DEFAULT 15 COMMENT '早退请假阈值下限',
  `work_hours_per_day` decimal(4, 2) NOT NULL DEFAULT 8.00 COMMENT '工作小时每日期',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_shift_code`(`shift_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工作班次表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pmt_approval_business_type
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_business_type`;
CREATE TABLE `pmt_approval_business_type`  (
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务类型编码（唯一标识，如TIMESHEET/CONTRACT/PROJECT_APPROVAL）',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务类型名称（如工时审批/合同审批/立项审批）',
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'OTHER' COMMENT '分类：PROJECT(项目类)/FINANCE(财务类)/HR(人事类)/OTHER(其他)',
  `table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '对应业务数据库表名（用于关联查询，可为空）',
  `primary_key_column` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'id' COMMENT '业务表主键列名（默认id）',
  `no_column` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '业务单号列名（用于展示，如timesheet_no/contract_no）',
  `title_template` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标题模板，支持变量：${applicantName} ${projectName} ${businessNo}等，为空时自动生成',
  `detail_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '前端详情页路由路径（如/pmt/timesheet/detail，审批实例可跳转）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=启用，0=禁用',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序号',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注说明',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`code`) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批业务类型注册表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_approval_config
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_config`;
CREATE TABLE `pmt_approval_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置名称',
  `approval_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '审批类型',
  `approval_type_desc` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批类型描述',
  `approver_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人类型',
  `approver_ids` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人ID列表',
  `approver_names` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人姓名列表',
  `level` int NULL DEFAULT NULL COMMENT '审批层级',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_approval_type`(`approval_type` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_approval_flow
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_flow`;
CREATE TABLE `pmt_approval_flow`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `business_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '业务类型',
  `flow_version` int NOT NULL DEFAULT 1 COMMENT '流程版本号，修改后自动升版',
  `is_published` tinyint NOT NULL DEFAULT 1 COMMENT '是否已发布：1=已发布（可使用），0=草稿',
  `business_type_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '业务类型名称',
  `flow_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程名称',
  `flow_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '流程编码（可选）',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '流程描述',
  `pm_approver_enabled` tinyint NOT NULL DEFAULT 0 COMMENT '是否启用项目经理审批人特殊配置 0=否 1=是',
  `pm_approver_user_ids` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目经理审批人用户ID列表，逗号分隔',
  `pm_approver_sign_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'OR' COMMENT 'PM审批人会签类型 OR=或签 AND=会签',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批流程表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_approval_flow_binding
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_flow_binding`;
CREATE TABLE `pmt_approval_flow_binding`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `business_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务类型编码（关联pmt_approval_business_type）',
  `scope_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '范围类型：GLOBAL=全局，ORG=组织，DEPT=部门，PROJECT=项目',
  `scope_id` bigint NULL DEFAULT NULL COMMENT '范围ID：全局为NULL，项目为project_id，部门为dept_id，组织为org_id',
  `scope_ids` varchar(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '范围ID列表（逗号分隔）：用于PROJECT类型绑定多个项目',
  `flow_id` bigint NOT NULL COMMENT '绑定的审批流程ID',
  `priority` int NOT NULL DEFAULT 0 COMMENT '优先级：数值越大优先级越高（项目级建议100，部门级50，全局0）',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用：1=启用，0=禁用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_biz_scope`(`business_type` ASC, `scope_type` ASC, `scope_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_business_type`(`business_type` ASC) USING BTREE,
  INDEX `idx_scope`(`scope_type` ASC, `scope_id` ASC) USING BTREE,
  INDEX `idx_flow`(`flow_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批流程范围绑定表（支持全局/组织/部门/项目多级配置）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_approval_instance
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_instance`;
CREATE TABLE `pmt_approval_instance`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `instance_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '审批实例编号',
  `flow_id` bigint NULL DEFAULT NULL COMMENT '审批流程ID',
  `flow_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批流程名称',
  `flow_version` int NULL DEFAULT 1 COMMENT '发起审批时的流程版本',
  `business_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '业务类型',
  `business_id` bigint NULL DEFAULT NULL COMMENT '业务数据ID',
  `business_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '业务单据编号',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批标题',
  `business_snapshot` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '业务数据快照（JSON格式）',
  `applicant_id` bigint NULL DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '申请人姓名',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `department_id` bigint NULL DEFAULT NULL COMMENT '发起部门ID',
  `current_node_id` bigint NULL DEFAULT NULL COMMENT '当前节点ID',
  `current_node_order` int NULL DEFAULT NULL COMMENT '当前节点顺序',
  `current_node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前节点名称',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING' COMMENT '审批状态(PENDING待审批/APPROVED已通过/REJECTED已驳回/CANCELED已取消)',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_instance_no`(`instance_no` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 150 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批实例表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_approval_instance_node
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_instance_node`;
CREATE TABLE `pmt_approval_instance_node`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `node_order` int NOT NULL COMMENT '节点顺序(从1开始)',
  `node_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '节点名称',
  `approver_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ROLE' COMMENT '审批人类型：ROLE角色/USER指定人/PROJECT_MANAGER项目经理/DEPT_LEADER部门负责人/SELF申请人上级',
  `approver_role_id` bigint NULL DEFAULT NULL COMMENT '审批角色ID',
  `approver_user_ids` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '指定审批人ID列表(逗号分隔)',
  `sign_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ANY' COMMENT '签批类型：ANY或签/ALL会签',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING待审批/APPROVED通过/REJECTED驳回/SKIPPED跳过',
  `actual_approver_id` bigint NULL DEFAULT NULL COMMENT '实际处理人ID(或签时第一个处理的人)',
  `actual_approver_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `action_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批意见',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_instance`(`instance_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 164 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批实例节点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_approval_node
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_node`;
CREATE TABLE `pmt_approval_node`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `flow_id` bigint NULL DEFAULT NULL COMMENT '审批流程ID',
  `node_order` int NULL DEFAULT 0 COMMENT '节点顺序',
  `node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '节点名称',
  `approver_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人类型',
  `approver_role_id` bigint NULL DEFAULT NULL COMMENT '审批角色ID',
  `approver_user_ids` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人ID列表',
  `sign_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '签批类型(ANY或签/ALL会签)',
  `condition_expression` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '条件表达式（SpEL），满足条件才进入该节点，为空表示无条件',
  `pass_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批通过后业务状态(为空流转下一节点)',
  `reject_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'REJECTED' COMMENT '审批驳回后业务状态',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '节点描述',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_flow_id`(`flow_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批节点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_approval_record
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_record`;
CREATE TABLE `pmt_approval_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `node_id` bigint NULL DEFAULT NULL COMMENT '审批节点ID',
  `node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '节点名称',
  `action_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作类型(APPROVE通过/REJECT驳回/TRANSFER转审/RECALL撤回)',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人姓名',
  `action_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批意见',
  `target_user_id` bigint NULL DEFAULT NULL COMMENT '目标用户ID(转审)',
  `target_user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '目标用户姓名',
  `action_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_instance_id`(`instance_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_approval_task
-- ----------------------------
DROP TABLE IF EXISTS `pmt_approval_task`;
CREATE TABLE `pmt_approval_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `node_id` bigint NULL DEFAULT NULL COMMENT '审批节点ID',
  `node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '节点名称',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审批人ID',
  `approver_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人姓名',
  `task_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING' COMMENT '任务状态(PENDING待处理/APPROVED已通过/REJECTED已驳回/TRANSFERRED已转审)',
  `action_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `action_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批意见',
  `is_read` int NULL DEFAULT 0 COMMENT '是否已读(0否1是)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_instance_id`(`instance_id` ASC) USING BTREE,
  INDEX `idx_approver_id`(`approver_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_attendance_calendar
-- ----------------------------
DROP TABLE IF EXISTS `pmt_attendance_calendar`;
CREATE TABLE `pmt_attendance_calendar`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cal_date` date NOT NULL,
  `day_type` int NOT NULL DEFAULT 1 COMMENT '日期类型：1-工作日 2-休息日 3-法定节假日 4-调休上班',
  `holiday_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '节假日名称',
  `shift_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '班次：standard-标准班 rest-休息',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `cal_year` int NULL DEFAULT NULL,
  `cal_month` int NULL DEFAULT NULL,
  `sync_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '同步时间',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NULL DEFAULT 0,
  `deleted` bigint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_cal_date`(`cal_date` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 679 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '考勤日历（PMT，由HR同步）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_contract
-- ----------------------------
DROP TABLE IF EXISTS `pmt_contract`;
CREATE TABLE `pmt_contract`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `contract_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同编号',
  `contract_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '合同名称',
  `contract_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同类型',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父合同ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目编码',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',
  `customer_id` bigint NULL DEFAULT NULL COMMENT '客户ID',
  `customer_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户编码',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户名称',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织编码',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织名称',
  `pm_id` bigint NULL DEFAULT NULL COMMENT '项目经理ID',
  `pm_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目经理姓名',
  `sales_id` bigint NULL DEFAULT NULL COMMENT '销售负责人ID',
  `sales_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售负责人姓名',
  `owner_id` bigint NULL DEFAULT NULL COMMENT '合同负责人ID',
  `owner_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同负责人姓名',
  `contract_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '合同金额(含税)',
  `contract_amount_excl_tax` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '合同金额(不含税)',
  `currency` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'CNY' COMMENT '币种',
  `exchange_rate` decimal(10, 4) NULL DEFAULT 1.0000 COMMENT '汇率',
  `tax_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '税额',
  `sign_date` date NULL DEFAULT NULL COMMENT '签订日期',
  `expected_sign_date` date NULL DEFAULT NULL COMMENT '预计签订日期',
  `start_date` date NULL DEFAULT NULL COMMENT '合同开始日期',
  `end_date` date NULL DEFAULT NULL COMMENT '合同结束日期',
  `contract_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'DRAFT' COMMENT '合同状态(DRAFT草稿/PENDING_APPROVAL审批中/APPROVED已生效/EXECUTING执行中/COMPLETED已完成/TERMINATED已终止)',
  `invoice_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'NOT_STARTED' COMMENT '开票状态(NOT_STARTED未开始/PARTIAL部分开票/COMPLETED已完成)',
  `payment_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'UNPAID' COMMENT '收款状态(UNPAID未收款/PARTIAL部分收款/PAID已收款)',
  `payment_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '付款方式',
  `payment_terms` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '付款条款',
  `warranty_clause` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '保修条款',
  `breach_clause` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '违约条款',
  `contract_file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同附件URL',
  `signed_file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '已签章合同URL',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_contract_no`(`contract_no` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '合同表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_contract_line
-- ----------------------------
DROP TABLE IF EXISTS `pmt_contract_line`;
CREATE TABLE `pmt_contract_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `contract_id` bigint NOT NULL COMMENT '合同ID',
  `line_no` int NULL DEFAULT NULL COMMENT '行号',
  `material_id` bigint NULL DEFAULT NULL COMMENT '物料ID',
  `material_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料编码',
  `material_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料名称',
  `material_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料类型',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计量单位',
  `unit_price` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '单价',
  `quantity` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '数量',
  `tax_rate` decimal(5, 4) NULL DEFAULT 0.0000 COMMENT '税率',
  `amount_excl_tax` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '不含税金额',
  `tax_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '税额',
  `amount_incl_tax` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '含税金额',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '描述',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_contract_id`(`contract_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '合同明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_cost_actual
-- ----------------------------
DROP TABLE IF EXISTS `pmt_cost_actual`;
CREATE TABLE `pmt_cost_actual`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `cost_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成本单号',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目编码',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',
  `contract_id` bigint NULL DEFAULT NULL COMMENT '合同ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '成本分类ID',
  `category_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成本分类名称',
  `cost_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成本类型',
  `cost_date` date NULL DEFAULT NULL COMMENT '成本发生日期',
  `cost_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '成本金额',
  `cost_source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成本来源',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单据ID',
  `source_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '来源单据编号',
  `applicant_id` bigint NULL DEFAULT NULL COMMENT '申请人ID',
  `applicant_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '申请人姓名',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '成本说明',
  `attachment_urls` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '附件URL列表',
  `cost_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'DRAFT' COMMENT '成本状态(DRAFT草稿/PENDING_APPROVAL审批中/APPROVED已通过/REJECTED已驳回)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '实际成本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_cost_budget
-- ----------------------------
DROP TABLE IF EXISTS `pmt_cost_budget`;
CREATE TABLE `pmt_cost_budget`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `budget_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '预算单号',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目编码',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',
  `contract_id` bigint NULL DEFAULT NULL COMMENT '合同ID',
  `budget_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '预算名称',
  `budget_version` int NULL DEFAULT 1 COMMENT '预算版本号',
  `budget_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'DRAFT' COMMENT '预算状态(DRAFT草稿/PENDING_APPROVAL审批中/APPROVED已通过/REJECTED已驳回)',
  `total_budget` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '预算总金额',
  `used_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '已使用金额',
  `remain_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '剩余金额',
  `start_date` date NULL DEFAULT NULL COMMENT '预算开始日期',
  `end_date` date NULL DEFAULT NULL COMMENT '预算结束日期',
  `approver_id` bigint NULL DEFAULT NULL COMMENT '审批人ID',
  `approve_time` datetime NULL DEFAULT NULL COMMENT '审批时间',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '成本预算表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_cost_budget_item
-- ----------------------------
DROP TABLE IF EXISTS `pmt_cost_budget_item`;
CREATE TABLE `pmt_cost_budget_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `budget_id` bigint NOT NULL COMMENT '预算ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '成本分类ID',
  `category_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成本分类名称',
  `cost_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成本类型',
  `budget_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '预算金额',
  `used_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '已使用金额',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_budget_id`(`budget_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '成本预算明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_cost_category
-- ----------------------------
DROP TABLE IF EXISTS `pmt_cost_category`;
CREATE TABLE `pmt_cost_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `category_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类编码',
  `category_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父分类ID',
  `category_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类路径',
  `cost_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成本类型',
  `is_settlement` int NULL DEFAULT 0 COMMENT '是否参与结算(0否1是)',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_category_code`(`category_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '成本分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_customer
-- ----------------------------
DROP TABLE IF EXISTS `pmt_customer`;
CREATE TABLE `pmt_customer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户编码',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '客户名称',
  `customer_short_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户简称',
  `customer_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户类型(ENTERPRISE企业/GOVERNMENT政府/PERSONAL个人)',
  `customer_classify` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户分类(A/B/C)',
  `customer_scale` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户规模',
  `industry` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所属行业',
  `customer_industry` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所属行业',
  `contact_person` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `contact_email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系邮箱',
  `address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系地址',
  `register_address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '注册地址',
  `tax_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '纳税人识别号',
  `unified_social_credit` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '统一社会信用代码',
  `bank_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '开户银行',
  `bank_account` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '银行账号',
  `website` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公司网址',
  `credit_level` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '信用等级',
  `payment_cycle` int NULL DEFAULT 30 COMMENT '回款周期(天)',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '上级客户ID',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '客户状态',
  `data_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '数据状态(ACTIVE生效/INACTIVE失效)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_customer_code`(`customer_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_customer_address
-- ----------------------------
DROP TABLE IF EXISTS `pmt_customer_address`;
CREATE TABLE `pmt_customer_address`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `address_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '地址类型(BILLING收单方/SHIPPING收货方)',
  `country_id` bigint NULL DEFAULT NULL COMMENT '国家ID',
  `country_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '国家名称',
  `province_id` bigint NULL DEFAULT NULL COMMENT '省份ID',
  `province_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省份名称',
  `city_id` bigint NULL DEFAULT NULL COMMENT '城市ID',
  `city_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '城市名称',
  `district_id` bigint NULL DEFAULT NULL COMMENT '区县ID',
  `district_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区县名称',
  `street` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '街道/乡镇',
  `detail_address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `postal_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮编',
  `longitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '经度',
  `latitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '纬度',
  `contact_person` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收件人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收件电话',
  `is_default` tinyint NULL DEFAULT 0 COMMENT '是否默认地址(0否1是)',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer_id`(`customer_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 63 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户地址表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_customer_contact
-- ----------------------------
DROP TABLE IF EXISTS `pmt_customer_contact`;
CREATE TABLE `pmt_customer_contact`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `contact_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系人姓名',
  `contact_title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '职位',
  `contact_gender` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '性别(MALE男/FEMALE女)',
  `contact_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `contact_mobile` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号码',
  `contact_email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `contact_qq` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'QQ',
  `contact_wechat` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信',
  `department` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '部门',
  `is_primary` tinyint NULL DEFAULT 0 COMMENT '是否主要联系人(0否1是)',
  `is_decision_maker` tinyint NULL DEFAULT 0 COMMENT '是否决策人(0否1是)',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer_id`(`customer_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 48 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户联系人表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_customer_follower
-- ----------------------------
DROP TABLE IF EXISTS `pmt_customer_follower`;
CREATE TABLE `pmt_customer_follower`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `user_id` bigint NOT NULL COMMENT '跟进人用户ID',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户姓名',
  `follower_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '跟进人类型(TECH技术人员/EXPERT业务专家/SALES销售人员)',
  `is_primary` tinyint NULL DEFAULT 0 COMMENT '是否主跟进人(0否1是)',
  `start_date` date NULL DEFAULT NULL COMMENT '开始跟进日期',
  `end_date` date NULL DEFAULT NULL COMMENT '结束跟进日期',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '状态',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer_id`(`customer_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户跟进人表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_data_permission
-- ----------------------------
DROP TABLE IF EXISTS `pmt_data_permission`;
CREATE TABLE `pmt_data_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `subject_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '授权主体类型：USER-指定用户 / ROLE-指定角色',
  `subject_id` bigint NOT NULL COMMENT '授权主体ID（user_id 或 role_id）',
  `resource_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源类型：PROJECT-项目 / CONTRACT-合同 / SETTLEMENT-结算 等',
  `resource_id` bigint NOT NULL COMMENT '资源ID（项目ID、合同ID 等）',
  `can_view` tinyint NOT NULL DEFAULT 0 COMMENT '是否可查看：1是 0否',
  `can_edit` tinyint NOT NULL DEFAULT 0 COMMENT '是否可编辑：1是 0否',
  `can_approve` tinyint NOT NULL DEFAULT 0 COMMENT '是否可审批：1是 0否',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：1启用 0停用',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_subject_resource`(`subject_type` ASC, `subject_id` ASC, `resource_type` ASC, `resource_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_resource`(`resource_type` ASC, `resource_id` ASC) USING BTREE,
  INDEX `idx_subject`(`subject_type` ASC, `subject_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通用数据权限授权表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_dict
-- ----------------------------
DROP TABLE IF EXISTS `pmt_dict`;
CREATE TABLE `pmt_dict`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dict_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统类型',
  `dict_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典编码',
  `dict_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dict_code`(`dict_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_dict_item
-- ----------------------------
DROP TABLE IF EXISTS `pmt_dict_item`;
CREATE TABLE `pmt_dict_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dict_id` bigint NULL DEFAULT NULL COMMENT '字典类型ID',
  `item_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典项编码',
  `item_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典项名称',
  `item_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '字典项值',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 81 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典项表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_employee
-- ----------------------------
DROP TABLE IF EXISTS `pmt_employee`;
CREATE TABLE `pmt_employee`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `job_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工号',
  `employee_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '员工姓名',
  `user_id` bigint NULL DEFAULT NULL COMMENT '关联系统用户ID',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织名称',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `mobile_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '电话号码',
  `work_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE' COMMENT '员工状态(ACTIVE在职/INACTIVE离职)',
  `employment_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '员工类型(FULL_TIME全职/PART_TIME兼职/INTERN实习/DISPATCH劳务派遣/EXTERNAL外部合作)',
  `is_consultant` int NULL DEFAULT 0 COMMENT '是否顾问：0-否，1-是',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_job_number`(`job_number` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_work_status`(`work_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 115 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_invoice
-- ----------------------------
DROP TABLE IF EXISTS `pmt_invoice`;
CREATE TABLE `pmt_invoice`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `invoice_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发票号码',
  `invoice_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发票代码',
  `invoice_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发票类型',
  `contract_id` bigint NULL DEFAULT NULL COMMENT '合同ID',
  `contract_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同编号',
  `customer_id` bigint NULL DEFAULT NULL COMMENT '客户ID',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户名称',
  `milestone_id` bigint NULL DEFAULT NULL COMMENT '里程碑ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `invoice_date` date NULL DEFAULT NULL COMMENT '开票日期',
  `invoice_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '发票金额(含税)',
  `invoice_amount_excl_tax` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '发票金额(不含税)',
  `tax_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '税额',
  `tax_rate` decimal(5, 4) NULL DEFAULT 0.0000 COMMENT '税率',
  `currency` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'CNY' COMMENT '币种',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发票抬头',
  `tax_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '纳税人识别号',
  `bank_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '开户银行',
  `bank_account` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '银行账号',
  `address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址电话',
  `invoice_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'DRAFT' COMMENT '发票状态(DRAFT草稿/PENDING_APPROVAL审批中/ISSUED已开具/CANCELED已作废)',
  `invoice_file_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发票文件URL',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '发票表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_invoice_line
-- ----------------------------
DROP TABLE IF EXISTS `pmt_invoice_line`;
CREATE TABLE `pmt_invoice_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `invoice_id` bigint NOT NULL COMMENT '发票ID',
  `milestone_id` bigint NULL DEFAULT NULL COMMENT '里程碑ID',
  `material_id` bigint NULL DEFAULT NULL COMMENT '物料ID',
  `material_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品描述',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计量单位',
  `quantity` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '数量',
  `unit_price` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '单价',
  `amount_excl_tax` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '不含税金额',
  `tax_rate` decimal(5, 4) NULL DEFAULT 0.0000 COMMENT '税率',
  `tax_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '税额',
  `amount_incl_tax` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '含税金额',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_invoice_id`(`invoice_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '发票明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_leave_request
-- ----------------------------
DROP TABLE IF EXISTS `pmt_leave_request`;
CREATE TABLE `pmt_leave_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `approval_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批单号',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '员工ID',
  `leave_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请假类型: annual/personal/sick/marriage/maternity/paternity/bereavement/compensatory/other',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `apply_time` datetime NULL DEFAULT NULL COMMENT '申请时间',
  `duration_days` decimal(10, 2) NULL DEFAULT NULL COMMENT '请假天数',
  `duration_hours` decimal(10, 2) NULL DEFAULT NULL COMMENT '请假小时数',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请假原因',
  `approval_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批状态: DRAFT/PENDING/APPROVED/REJECTED/CANCELED',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `sync_time` datetime NULL DEFAULT NULL COMMENT '同步时间',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NULL DEFAULT 0,
  `deleted` bigint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE,
  INDEX `idx_approval_no`(`approval_no` ASC) USING BTREE,
  INDEX `idx_start_time`(`start_time` ASC) USING BTREE,
  INDEX `idx_approval_status`(`approval_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '请假申请表（从HR同步）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_login_log
-- ----------------------------
DROP TABLE IF EXISTS `pmt_login_log`;
CREATE TABLE `pmt_login_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名',
  `login_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录类型',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `browser` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浏览器',
  `os` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作系统',
  `status` int NULL DEFAULT NULL COMMENT '状态码',
  `msg` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '消息',
  `login_result` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录结果(SUCCESS成功/WRONG_PASSWORD密码错误/USER_DISABLED用户禁用/USER_LOCKED用户锁定)',
  `fail_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '失败原因',
  `client_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户端IP',
  `user_agent` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'User-Agent',
  `request_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求路径',
  `login_time` datetime NULL DEFAULT NULL COMMENT '登录时间',
  `response_time_ms` bigint NULL DEFAULT NULL COMMENT '响应时间(毫秒)',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_login_time`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 520 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_material
-- ----------------------------
DROP TABLE IF EXISTS `pmt_material`;
CREATE TABLE `pmt_material`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `material_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料编码',
  `material_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物料名称',
  `material_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料类型',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计量单位',
  `standard_price` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '标准单价',
  `currency` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'CNY' COMMENT '币种',
  `tax_rate` decimal(5, 4) NULL DEFAULT 0.0000 COMMENT '税率',
  `is_active` int NULL DEFAULT 1 COMMENT '是否启用(0否1是)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '物料描述',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_material_code`(`material_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物料表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_milestone
-- ----------------------------
DROP TABLE IF EXISTS `pmt_milestone`;
CREATE TABLE `pmt_milestone`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `milestone_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '里程碑编码',
  `milestone_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '里程碑名称',
  `contract_id` bigint NULL DEFAULT NULL COMMENT '合同ID',
  `payment_unit_id` bigint NULL DEFAULT NULL COMMENT '付款单位ID',
  `payment_percent` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '付款比例(%)',
  `payment_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '付款金额',
  `planned_date` date NULL DEFAULT NULL COMMENT '计划完成日期',
  `actual_date` date NULL DEFAULT NULL COMMENT '实际完成日期',
  `invoice_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '开票状态',
  `payment_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款状态',
  `invoiced_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '已开票金额',
  `paid_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '已收款金额',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING' COMMENT '里程碑状态(PENDING待开始/IN_PROGRESS进行中/COMPLETED已完成)',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '里程碑描述',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_contract_id`(`contract_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '里程碑表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `pmt_operation_log`;
CREATE TABLE `pmt_operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统类型',
  `module` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '模块名称',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作描述',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作类型',
  `request_method` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求方法(GET/POST/PUT/DELETE)',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作用户名',
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人姓名',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作IP',
  `request_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求URL',
  `request_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数',
  `response_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '响应结果',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `duration` bigint NULL DEFAULT NULL COMMENT '耗时(毫秒)',
  `status` int NULL DEFAULT NULL COMMENT '状态码',
  `method` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '调用方法',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`username` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 558 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_org
-- ----------------------------
DROP TABLE IF EXISTS `pmt_org`;
CREATE TABLE `pmt_org`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父组织ID',
  `ancestors` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '祖级路径',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组织编码',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组织名称',
  `org_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织类型(GROUP集团/COMPANY公司/SUB_COMPANY分公司/BU业务单元/PRODUCT_LINE产品线/DEPT部门)',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '负责人ID',
  `manager` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人姓名',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织描述',
  `level` int NULL DEFAULT 1 COMMENT '层级',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_org_code`(`org_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_manager`(`manager` ASC) USING BTREE,
  INDEX `idx_manager_id`(`manager_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 75 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组织架构表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_overtime_request
-- ----------------------------
DROP TABLE IF EXISTS `pmt_overtime_request`;
CREATE TABLE `pmt_overtime_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `approval_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '审批单号',
  `employee_id` bigint NOT NULL COMMENT '员工ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '所属项目ID',
  `overtime_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加班类型 weekday/weekend/holiday',
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `apply_time` datetime NULL DEFAULT NULL,
  `gross_duration_hours` decimal(8, 2) NULL DEFAULT NULL COMMENT '总时长',
  `net_duration_hours` decimal(8, 2) NULL DEFAULT NULL COMMENT '有效时长',
  `is_late_apply` tinyint NULL DEFAULT 0 COMMENT '是否事后补申请',
  `reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '加班原因',
  `approval_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DRAFT',
  `convert_to_comp` tinyint NULL DEFAULT 0 COMMENT '是否转调休',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sync_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '同步时间',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NULL DEFAULT 0,
  `deleted` bigint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE,
  INDEX `idx_start_time`(`start_time` ASC) USING BTREE,
  INDEX `idx_approval_status`(`approval_status` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_exec_ot_emp_proj_approval`(`employee_id` ASC, `project_id` ASC, `approval_status` ASC, `deleted` ASC, `start_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '加班申请（PMT，由HR同步）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_payment_receipt
-- ----------------------------
DROP TABLE IF EXISTS `pmt_payment_receipt`;
CREATE TABLE `pmt_payment_receipt`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `receipt_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款单号',
  `batch_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `receipt_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款类型',
  `contract_id` bigint NULL DEFAULT NULL COMMENT '合同ID',
  `contract_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同编号',
  `customer_id` bigint NULL DEFAULT NULL COMMENT '客户ID',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户名称',
  `invoice_id` bigint NULL DEFAULT NULL COMMENT '发票ID',
  `invoice_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发票号码',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `receipt_date` date NULL DEFAULT NULL COMMENT '收款日期',
  `receipt_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '收款金额',
  `exchange_rate` decimal(10, 4) NULL DEFAULT 1.0000 COMMENT '汇率',
  `currency` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'CNY' COMMENT '币种',
  `payment_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '付款方式',
  `payer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '付款人名称',
  `payer_bank_account` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '付款人银行账号',
  `receiver_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款人名称',
  `receiver_bank_account` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款人银行账号',
  `receipt_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'CONFIRMED' COMMENT '收款状态(CONFIRMED已确认/PENDING待确认)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收款记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_payment_receipt_line
-- ----------------------------
DROP TABLE IF EXISTS `pmt_payment_receipt_line`;
CREATE TABLE `pmt_payment_receipt_line`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `receipt_id` bigint NOT NULL COMMENT '收款记录ID',
  `milestone_id` bigint NULL DEFAULT NULL COMMENT '里程碑ID',
  `invoice_id` bigint NULL DEFAULT NULL COMMENT '发票ID',
  `write_off_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '核销金额',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_receipt_id`(`receipt_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收款明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_payment_unit
-- ----------------------------
DROP TABLE IF EXISTS `pmt_payment_unit`;
CREATE TABLE `pmt_payment_unit`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `contract_id` bigint NULL DEFAULT NULL COMMENT '合同ID',
  `contract_line_id` bigint NULL DEFAULT NULL COMMENT '合同明细ID',
  `unit_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '付款阶段编码',
  `unit_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '付款阶段名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '付款条件描述',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_contract_id`(`contract_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '付款单位表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_permission
-- ----------------------------
DROP TABLE IF EXISTS `pmt_permission`;
CREATE TABLE `pmt_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父权限ID',
  `permission_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限编码',
  `permission_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限名称',
  `permission_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限类型(MENU菜单/BUTTON按钮/API接口)',
  `system_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统类型',
  `path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜单路径',
  `route_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由路径',
  `api_path` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'API路径，多个用逗号分隔，支持{id}占位',
  `http_method` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'HTTP方法，多个用逗号分隔',
  `icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  `component` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '前端组件',
  `tree_level` int NULL DEFAULT NULL COMMENT '树层级',
  `tree_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '树路径',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_permission_code`(`permission_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1446 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_project
-- ----------------------------
DROP TABLE IF EXISTS `pmt_project`;
CREATE TABLE `pmt_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目编码',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `project_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目类型(CONSULTING咨询/IT_IMPLEMENT IT实施/CONSULTING_IT 咨询+IT实施/IT_OPERATION IT运维/TRAINING培训)',
  `project_level` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目等级(LARGE大型/MEDIUM中型/SMALL小型)',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父项目ID',
  `parent_project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '父项目编码',
  `project_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目路径',
  `customer_id` bigint NULL DEFAULT NULL COMMENT '客户ID',
  `customer_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户编码',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户名称',
  `signed_company` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '签约主体公司',
  `pm_id` bigint NULL DEFAULT NULL COMMENT '项目经理ID',
  `pm_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目经理姓名',
  `sales_id` bigint NULL DEFAULT NULL COMMENT '销售负责人ID',
  `sales_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售负责人姓名',
  `org_id` bigint NULL DEFAULT NULL COMMENT '组织ID',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织编码',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织名称',
  `planned_start_date` date NULL DEFAULT NULL COMMENT '计划开始日期',
  `planned_end_date` date NULL DEFAULT NULL COMMENT '计划结束日期',
  `actual_start_date` date NULL DEFAULT NULL COMMENT '实际开始日期',
  `actual_end_date` date NULL DEFAULT NULL COMMENT '实际结束日期',
  `planned_days` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '计划工期(天)',
  `actual_days` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '实际工期(天)',
  `estimated_work_days` decimal(10, 2) NULL DEFAULT NULL COMMENT '预计工时天',
  `budget_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '预算总金额',
  `budget_labor_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '人工预算金额',
  `budget_expense_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '费用预算金额',
  `contract_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '合同金额',
  `actual_cost` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '实际成本',
  `actual_labor_cost` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '实际人工成本',
  `actual_expense_cost` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '实际费用成本',
  `cost_variance` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '成本偏差',
  `cost_variance_rate` decimal(10, 4) NULL DEFAULT 0.0000 COMMENT '成本偏差率',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PLANNING' COMMENT '项目状态(PREPARING筹备/IN_PROGRESS进行中/PAUSED已暂停/COMPLETED已结项/CANCELLED已取消)',
  `progress` int NULL DEFAULT 0 COMMENT '项目进度(%)',
  `current_milestone` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前里程碑',
  `sign_date` date NULL DEFAULT NULL COMMENT '签约日期',
  `priority` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'MEDIUM' COMMENT '优先级(LOW低/MEDIUM中/HIGH高/URGENT紧急)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述',
  `business_background` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '业务背景',
  `technical_requirements` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '技术要求',
  `deliverables` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '交付物',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `project_address` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目实施地址',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_code`(`project_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_project_manager
-- ----------------------------
DROP TABLE IF EXISTS `pmt_project_manager`;
CREATE TABLE `pmt_project_manager`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID(指定用户)',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工号',
  `manager_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'PM' COMMENT 'PM项目经理/APPROVER审批人/OBSERVER观察者',
  `can_approve` tinyint NOT NULL DEFAULT 1 COMMENT '是否可审批该项目工时',
  `can_edit` tinyint NOT NULL DEFAULT 1 COMMENT '是否可编辑/调整',
  `can_view_all` tinyint NOT NULL DEFAULT 1 COMMENT '是否可见本项目所有工时',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用0停用',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_proj_user`(`project_id` ASC, `user_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_project`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 70 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目可管理人员（工时数据权限）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_project_member
-- ----------------------------
DROP TABLE IF EXISTS `pmt_project_member`;
CREATE TABLE `pmt_project_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目编码',
  `user_id` bigint NULL DEFAULT NULL COMMENT '关联系统用户ID',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '员工ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工号',
  `member_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成员姓名',
  `role_in_project` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目角色(PM项目经理/CONSULTANT顾问/DEVELOPER开发/TESTER测试/IMPLEMENT实施)',
  `work_duty` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目工作职责',
  `work_nature` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'NON_SETTLE' COMMENT '工时性质：SETTLE=结算，NON_SETTLE=不结算',
  `estimated_work_days` decimal(10, 2) NULL DEFAULT NULL COMMENT '预计工时天',
  `join_date` date NULL DEFAULT NULL COMMENT '加入日期',
  `leave_date` date NULL DEFAULT NULL COMMENT '离开日期',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 97 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目成员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_project_member_period
-- ----------------------------
DROP TABLE IF EXISTS `pmt_project_member_period`;
CREATE TABLE `pmt_project_member_period`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `member_id` bigint NOT NULL COMMENT '成员ID，关联pmt_project_member.id',
  `planned_join_date` date NULL DEFAULT NULL COMMENT '计划加入时间',
  `planned_leave_date` date NULL DEFAULT NULL COMMENT '计划退出时间',
  `actual_join_date` date NULL DEFAULT NULL COMMENT '实际加入时间',
  `actual_leave_date` date NULL DEFAULT NULL COMMENT '实际退出时间',
  `workload_ratio` decimal(5, 2) NULL DEFAULT 100.00 COMMENT '投入工时占比(%)',
  `estimated_work_days` decimal(10, 2) NULL DEFAULT NULL COMMENT '预计工时天',
  `is_active` tinyint NULL DEFAULT 1 COMMENT '是否在职:1=在职,0=已退出',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `period_order` int NULL DEFAULT 1 COMMENT '时间段序号',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本',
  `deleted` bigint NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_member_id`(`member_id` ASC) USING BTREE,
  INDEX `idx_project_dates`(`member_id` ASC, `planned_join_date` ASC, `planned_leave_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 304 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目成员时间段表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_region
-- ----------------------------
DROP TABLE IF EXISTS `pmt_region`;
CREATE TABLE `pmt_region`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父地区ID',
  `level` int NULL DEFAULT 1 COMMENT '层级(1国家2省3市4区县)',
  `region_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地区编码',
  `region_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '地区名称',
  `short_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '简称',
  `pinyin` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拼音',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 350 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '地区表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_role
-- ----------------------------
DROP TABLE IF EXISTS `pmt_role`;
CREATE TABLE `pmt_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色编码',
  `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色类型(SYSTEM系统角色/BUSINESS业务角色)',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色描述',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态(1启用0禁用)',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  `is_system` tinyint NOT NULL DEFAULT 0 COMMENT '是否系统预置角色(1=是,0=否),预置角色不可删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_code`(`role_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `pmt_role_permission`;
CREATE TABLE `pmt_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_perm`(`role_id` ASC, `permission_id` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4911 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_role_project
-- ----------------------------
DROP TABLE IF EXISTS `pmt_role_project`;
CREATE TABLE `pmt_role_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_project`(`role_id` ASC, `project_id` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色项目数据权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_seq_no
-- ----------------------------
DROP TABLE IF EXISTS `pmt_seq_no`;
CREATE TABLE `pmt_seq_no`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `seq_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '序列类型：TIMESHEET/APPROVAL',
  `seq_date` date NOT NULL COMMENT '日期',
  `current_no` int NOT NULL DEFAULT 0 COMMENT '当前序号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_type_date`(`seq_type` ASC, `seq_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '单据号序列表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_settlement_batch
-- ----------------------------
DROP TABLE IF EXISTS `pmt_settlement_batch`;
CREATE TABLE `pmt_settlement_batch`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `batch_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `batch_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次名称',
  `settlement_month` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结算月份',
  `work_month` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工作月份',
  `batch_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次类型',
  `batch_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次状态(DRAFT草稿/CONFIRMED已确认/CLOSED已关闭)',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `start_date` date NULL DEFAULT NULL COMMENT '结算开始日期',
  `end_date` date NULL DEFAULT NULL COMMENT '结算结束日期',
  `total_work_days` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '总工作天数',
  `total_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '总结算金额',
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '确认时间',
  `close_time` datetime NULL DEFAULT NULL COMMENT '关闭时间',
  `creator_id` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `creator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人姓名',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_batch_no`(`batch_no` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '结算批次表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_settlement_order
-- ----------------------------
DROP TABLE IF EXISTS `pmt_settlement_order`;
CREATE TABLE `pmt_settlement_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结算单号',
  `batch_id` bigint NULL DEFAULT NULL COMMENT '结算批次ID',
  `batch_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结算批次号',
  `work_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工作类型',
  `customer_id` bigint NULL DEFAULT NULL COMMENT '客户ID',
  `customer_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户名称',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',
  `contract_id` bigint NULL DEFAULT NULL COMMENT '合同ID',
  `contract_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合同编号',
  `payment_unit_id` bigint NULL DEFAULT NULL COMMENT '付款单位ID',
  `milestone_id` bigint NULL DEFAULT NULL COMMENT '里程碑ID',
  `work_nature` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工作性质',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工号',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户姓名',
  `work_month` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工作月份',
  `settlement_month` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结算月份',
  `executed_days` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已执行天数',
  `this_settlement_days` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '本次结算天数',
  `settled_days` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已结算天数',
  `settlement_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结算状态',
  `order_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单据状态',
  `unit_price` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '单价',
  `settlement_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '结算金额',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_batch_id`(`batch_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '结算单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_settlement_order_item
-- ----------------------------
DROP TABLE IF EXISTS `pmt_settlement_order_item`;
CREATE TABLE `pmt_settlement_order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` bigint NOT NULL COMMENT '结算单ID',
  `timesheet_item_id` bigint NULL DEFAULT NULL COMMENT '工时明细ID',
  `work_date` date NULL DEFAULT NULL COMMENT '工作日期',
  `work_hours` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '工作小时数',
  `work_days` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '工作天数',
  `settlement_days` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '结算天数',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '结算单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_sync_log
-- ----------------------------
DROP TABLE IF EXISTS `pmt_sync_log`;
CREATE TABLE `pmt_sync_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务key',
  `task_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务名称',
  `trigger_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'MANUAL' COMMENT '触发方式: MANUAL-手动 SCHEDULED-定时',
  `status` int NOT NULL DEFAULT 1 COMMENT '执行状态 1-成功 0-失败',
  `message` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '执行结果消息',
  `added_count` int NULL DEFAULT 0 COMMENT '新增数量',
  `updated_count` int NULL DEFAULT 0 COMMENT '更新数量',
  `deleted_count` int NULL DEFAULT 0 COMMENT '删除数量',
  `total_count` int NULL DEFAULT 0 COMMENT '总同步数量',
  `duration` bigint NULL DEFAULT 0 COMMENT '耗时(毫秒)',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人',
  `http_status` int NULL DEFAULT NULL COMMENT 'HTTP响应状态码（自定义HTTP任务）',
  `response_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'HTTP响应体摘要（自定义HTTP任务）',
  `created_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `version` int NULL DEFAULT 0,
  `deleted` bigint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_key`(`task_key` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据同步执行日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_sync_task_config
-- ----------------------------
DROP TABLE IF EXISTS `pmt_sync_task_config`;
CREATE TABLE `pmt_sync_task_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务唯一标识key',
  `task_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `sync_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '同步类型: org/employee/overtime/leave/attendance/http',
  `cron` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Cron表达式',
  `cron_desc` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '执行周期描述',
  `api_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手动触发接口URL（只读）',
  `target_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '自定义HTTP调用目标URL（sync_type=http时使用）',
  `http_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'POST' COMMENT 'HTTP请求方法 GET/POST',
  `request_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'HTTP请求体JSON（sync_type=http时使用）',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务描述',
  `enabled` int NOT NULL DEFAULT 1 COMMENT '是否启用 1-启用 0-禁用',
  `sys_built_in` int NOT NULL DEFAULT 0 COMMENT '是否系统内置 1-内置 0-自定义',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NULL DEFAULT 0,
  `deleted` bigint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_task_key`(`task_key` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据同步任务配置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_timesheet
-- ----------------------------
DROP TABLE IF EXISTS `pmt_timesheet`;
CREATE TABLE `pmt_timesheet`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `timesheet_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工时单号(TS+yyyyMMdd+6位序列)',
  `user_id` bigint NOT NULL COMMENT '填报用户ID',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '员工ID(pmt_employee.id)',
  `job_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '员工工号',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '员工姓名',
  `week_start_date` date NOT NULL COMMENT '周起始日(周一)',
  `week_end_date` date NOT NULL COMMENT '周结束日(周日)',
  `week_year` int NULL DEFAULT NULL COMMENT '年(ISO周)',
  `week_of_year` int NULL DEFAULT NULL COMMENT '周次(1-53)',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目编码',
  `project_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',
  `total_hours` decimal(6, 2) NULL DEFAULT 0.00 COMMENT '总工时(小时)=明细合计',
  `total_days` decimal(6, 2) NULL DEFAULT 0.00 COMMENT '总工天=total_hours/8',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DRAFT' COMMENT '工时状态：DRAFT草稿/PENDING审批中/APPROVED已审批/REJECTED已驳回/LOCKED已锁定',
  `current_node_id` bigint NULL DEFAULT NULL COMMENT '当前审批节点ID',
  `current_node_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前审批节点名称',
  `current_node_order` int NULL DEFAULT NULL COMMENT '当前审批节点顺序',
  `flow_id` bigint NULL DEFAULT NULL COMMENT '使用的审批流程ID',
  `instance_id` bigint NULL DEFAULT NULL COMMENT '审批实例ID',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `approve_time` datetime NULL DEFAULT NULL COMMENT '最终审批通过时间',
  `reject_time` datetime NULL DEFAULT NULL COMMENT '驳回时间',
  `reject_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '驳回原因',
  `is_settlement` tinyint NULL DEFAULT 0 COMMENT '是否已进入结算批次 0否1是',
  `settlement_batch_id` bigint NULL DEFAULT NULL COMMENT '结算批次ID',
  `settlement_batch_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结算批次号',
  `settlement_time` datetime NULL DEFAULT NULL COMMENT '结算时间',
  `source` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PC' COMMENT '来源：PC/MOBILE',
  `task_description` varchar(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务描述',
  `shortage_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工时不足原因',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  `locked` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0未锁定 1已锁定（只有结算性质成员APPROVED后才可锁定）',
  `settled` tinyint NOT NULL DEFAULT 0 COMMENT '结算状态 0=未结算 1=已结算 2=部分结算',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_emp_week_proj`(`job_number` ASC, `week_start_date` ASC, `project_id` ASC, `deleted` ASC) USING BTREE,
  UNIQUE INDEX `uk_timesheet_no`(`timesheet_no` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_week_start`(`week_start_date` ASC) USING BTREE,
  INDEX `idx_flow_status`(`flow_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_exec_emp_proj_week_status`(`employee_id` ASC, `project_id` ASC, `week_start_date` ASC, `status` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_timesheet_locked`(`locked` ASC) USING BTREE,
  INDEX `idx_timesheet_settled`(`settled` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 121 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工时单（按员工+周+项目一张）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_timesheet_anomaly
-- ----------------------------
DROP TABLE IF EXISTS `pmt_timesheet_anomaly`;
CREATE TABLE `pmt_timesheet_anomaly`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `timesheet_id` bigint NULL DEFAULT NULL COMMENT '工时单ID',
  `timesheet_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工时单号',
  `timesheet_item_id` bigint NULL DEFAULT NULL COMMENT '工时明细ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '系统用户ID',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '员工ID',
  `employee_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '员工姓名',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID',
  `project_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',
  `work_date` date NULL DEFAULT NULL COMMENT '异常发生日期',
  `anomaly_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '异常类型：LEAVE_CONFLICT-请假冲突，OVERTIME_CONFLICT-加班冲突，OTHER-其他',
  `anomaly_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '异常原因描述',
  `work_hours` decimal(10, 2) NULL DEFAULT NULL COMMENT '异常当天填报工时',
  `ref_hours` decimal(10, 2) NULL DEFAULT NULL COMMENT '参考小时数（如请假小时数）',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'OPEN' COMMENT '异常状态：OPEN-未消除，RESOLVED-已消除',
  `resolved_by` bigint NULL DEFAULT NULL COMMENT '消除人ID',
  `resolved_by_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '消除人姓名',
  `resolved_time` datetime NULL DEFAULT NULL COMMENT '消除时间',
  `resolve_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '消除备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本',
  `deleted` bigint NULL DEFAULT 0 COMMENT '逻辑删除标志',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_timesheet_id`(`timesheet_id` ASC) USING BTREE,
  INDEX `idx_employee_id`(`employee_id` ASC) USING BTREE,
  INDEX `idx_work_date`(`work_date` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工时异常表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_timesheet_approval_log
-- ----------------------------
DROP TABLE IF EXISTS `pmt_timesheet_approval_log`;
CREATE TABLE `pmt_timesheet_approval_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `timesheet_id` bigint NOT NULL COMMENT '工时单ID',
  `timesheet_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工时单号',
  `node_id` bigint NULL DEFAULT NULL COMMENT '审批节点ID',
  `node_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '节点名称',
  `action_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '动作类型：SUBMIT提交/APPROVE通过/REJECT驳回/WITHDRAW撤回/DELEGATE转交',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人姓名',
  `operator_role` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人角色',
  `action_result` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PASS' COMMENT '审批结果：PASS通过/REJECT驳回/PENDING待处理',
  `action_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '意见/原因',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_timesheet_id`(`timesheet_id` ASC) USING BTREE,
  INDEX `idx_operator_id`(`operator_id` ASC) USING BTREE,
  INDEX `idx_action_time`(`action_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 247 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工时审批记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_timesheet_budget
-- ----------------------------
DROP TABLE IF EXISTS `pmt_timesheet_budget`;
CREATE TABLE `pmt_timesheet_budget`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `employee_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工号',
  `employee_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '成员姓名',
  `employee_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '在职' COMMENT '成员状态：在职/离职',
  `project_role` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目角色',
  `project_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目号',
  `project_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目名称',
  `week_start_date` date NOT NULL COMMENT '周开始日期',
  `week_label` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '周标签（如02/07/26）',
  `work_nature` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工时性质：SETTLE=结算 / NON_SETTLE=不结算',
  `budget_version` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '预算版本号 YYYYMMDD；同日多次导入会先删除该版本所有行再插入',
  `planned_hours` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '计划工时',
  `actual_hours` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '实际工时（从工时单汇总）',
  `total_actual_hours` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '实际工时（员工+项目汇总，导入值）',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NULL DEFAULT 0,
  `deleted` bigint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_proj_emp_week`(`project_code` ASC, `employee_no` ASC, `week_start_date` ASC, `deleted` ASC, `budget_version` ASC) USING BTREE,
  INDEX `idx_project_code`(`project_code` ASC) USING BTREE,
  INDEX `idx_employee_no`(`employee_no` ASC) USING BTREE,
  INDEX `idx_week_start_date`(`week_start_date` ASC) USING BTREE,
  INDEX `idx_budget_version`(`budget_version` ASC) USING BTREE,
  INDEX `idx_version_project`(`budget_version` ASC, `project_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3515 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工时预算表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_timesheet_item
-- ----------------------------
DROP TABLE IF EXISTS `pmt_timesheet_item`;
CREATE TABLE `pmt_timesheet_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `timesheet_id` bigint NOT NULL COMMENT '工时单ID',
  `timesheet_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工时单号(冗余)',
  `user_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NOT NULL,
  `project_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `work_date` date NOT NULL COMMENT '工时日期',
  `day_of_week` tinyint NOT NULL COMMENT '星期几：1周一...7周日',
  `work_hours` decimal(4, 1) NOT NULL DEFAULT 0.0 COMMENT '工时数(0-8，步长0.5)',
  `work_days` decimal(4, 2) NULL DEFAULT 0.00 COMMENT '工天=work_hours/8',
  `work_nature` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'BILLABLE' COMMENT '工时性质：BILLABLE结算/NON_BILLABLE不结算/NOT_APPLICABLE不涉及',
  `is_remote` tinyint NOT NULL DEFAULT 1 COMMENT '是否远程 1=远程 0=现场',
  `work_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '工作内容描述',
  `milestone_id` bigint NULL DEFAULT NULL COMMENT '里程碑ID(可选)',
  `milestone_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `settlement_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'UNSETTLED' COMMENT '结算状态：UNSETTLED未结算/SETTLED已结算',
  `settlement_batch_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结算批次号',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_timesheet_id`(`timesheet_id` ASC) USING BTREE,
  INDEX `idx_user_date`(`user_id` ASC, `work_date` ASC) USING BTREE,
  INDEX `idx_project_date`(`project_id` ASC, `work_date` ASC) USING BTREE,
  INDEX `idx_work_date`(`work_date` ASC) USING BTREE,
  INDEX `idx_exec_item_timesheet_workdate`(`timesheet_id` ASC, `work_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 916 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工时明细表（每日一项）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_user
-- ----------------------------
DROP TABLE IF EXISTS `pmt_user`;
CREATE TABLE `pmt_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `employee_id` bigint NULL DEFAULT NULL,
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `employee_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `avatar_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `gender` int NULL DEFAULT 0,
  `dept_id` bigint NULL DEFAULT NULL,
  `position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `user_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` int NULL DEFAULT 1,
  `login_fail_count` int NULL DEFAULT 0,
  `lock_time` datetime NULL DEFAULT NULL,
  `last_login_time` datetime NULL DEFAULT NULL,
  `last_login_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `password_last_update_time` datetime NULL DEFAULT NULL,
  `need_change_password` tinyint NULL DEFAULT 0 COMMENT '是否需要首次登录修改密码(0-否,1-是)',
  `initial_password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '初始密码（用户修改密码后清空）',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 67 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pmt_user_role
-- ----------------------------
DROP TABLE IF EXISTS `pmt_user_role`;
CREATE TABLE `pmt_user_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_role`(`user_id` ASC, `role_id` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 83 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_app
-- ----------------------------
DROP TABLE IF EXISTS `sys_app`;
CREATE TABLE `sys_app`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '应用编码：SYS/HR/PMT/FIN',
  `app_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '应用名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '访问路径',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1启用0禁用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_app_code`(`app_code` ASC, `deleted` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '应用表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_approval_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_approval_config`;
CREATE TABLE `sys_approval_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `system_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'SYS' COMMENT '系统类型：SYS/HR/PMT/FIN',
  `config_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置编码(唯一)',
  `config_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置名称',
  `business_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务类型：LEAVE/OVERTIME/RESIGN/EXPENSE/PROJECT等',
  `approval_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'FIXED' COMMENT '审批类型：FIXED固定审批/FREE自由审批/LEVEL逐级审批',
  `levels` int NULL DEFAULT 1 COMMENT '审批级数',
  `approver_config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '审批人配置JSON',
  `form_config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '表单配置JSON',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1启用0禁用',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_code`(`config_code` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_system_type`(`system_type` ASC) USING BTREE,
  INDEX `idx_business_type`(`business_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_approval_flow
-- ----------------------------
DROP TABLE IF EXISTS `sys_approval_flow`;
CREATE TABLE `sys_approval_flow`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `flow_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程编码',
  `flow_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程名称',
  `biz_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务类型: TIMESHEET=工时, LEAVE=请假, OVERTIME=加班, COST=成本, BUDGET=预算, BUSINESS_TRAVEL=出差, CORRECTION=补卡, OTHER=其他',
  `org_id` bigint NULL DEFAULT NULL COMMENT '适用组织ID(NULL表示全局)',
  `flow_status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=禁用, 1=启用',
  `description` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '流程描述',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_flow_code`(`flow_code` ASC) USING BTREE,
  INDEX `idx_biz_type`(`biz_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批流定义表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_approval_flow_node
-- ----------------------------
DROP TABLE IF EXISTS `sys_approval_flow_node`;
CREATE TABLE `sys_approval_flow_node`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `flow_id` bigint NOT NULL COMMENT '流程ID',
  `node_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '节点编码',
  `node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '节点名称',
  `node_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'APPROVE' COMMENT '节点类型: START=开始, APPROVE=审批, CC=抄送, END=结束',
  `approver_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'USER' COMMENT '审批人类型: USER=指定用户, ROLE=指定角色, LEADER=直属上级, DEPT_LEADER=部门负责人, PROJECT_PM=项目经理, INITIATOR=发起人自选',
  `approver_ids` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人ID列表(逗号分隔)',
  `approver_names` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人姓名列表',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '节点顺序',
  `sign_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ANY' COMMENT '签批类型: ANY=或签(任一人), ALL=会签(所有人)',
  `is_allow_commit` tinyint NOT NULL DEFAULT 1 COMMENT '是否允许转审',
  `is_allow_reject` tinyint NOT NULL DEFAULT 1 COMMENT '是否允许驳回',
  `is_allow_recall` tinyint NOT NULL DEFAULT 1 COMMENT '是否允许撤回',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_flow_id`(`flow_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批流节点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_approval_instance
-- ----------------------------
DROP TABLE IF EXISTS `sys_approval_instance`;
CREATE TABLE `sys_approval_instance`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `instance_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实例编号',
  `flow_id` bigint NOT NULL COMMENT '流程ID',
  `flow_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程名称',
  `biz_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务类型',
  `biz_id` bigint NOT NULL COMMENT '业务单据ID',
  `biz_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务单据编号',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '审批标题',
  `initiator_id` bigint NOT NULL COMMENT '发起人ID',
  `initiator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发起人姓名',
  `org_id` bigint NULL DEFAULT NULL COMMENT '发起人部门ID',
  `current_node_id` bigint NULL DEFAULT NULL COMMENT '当前节点ID',
  `current_node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前节点名称',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'APPROVING' COMMENT '状态: DRAFT=草稿, APPROVING=审批中, APPROVED=已通过, REJECTED=已驳回, CANCELLED=已取消, RECALLED=已撤回',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_instance_no`(`instance_no` ASC) USING BTREE,
  INDEX `idx_biz`(`biz_type` ASC, `biz_id` ASC) USING BTREE,
  INDEX `idx_initiator`(`initiator_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批实例表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_approval_record
-- ----------------------------
DROP TABLE IF EXISTS `sys_approval_record`;
CREATE TABLE `sys_approval_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `node_id` bigint NULL DEFAULT NULL COMMENT '节点ID',
  `node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '节点名称',
  `action_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型: SUBMIT=提交, APPROVE=通过, REJECT=驳回, TRANSFER=转审, CC=抄送, CANCEL=取消, RECALL=撤回',
  `operator_id` bigint NOT NULL COMMENT '操作人ID',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作人姓名',
  `action_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批意见',
  `target_user_id` bigint NULL DEFAULT NULL COMMENT '目标用户ID(转审目标)',
  `target_user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '目标用户姓名',
  `action_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_instance`(`instance_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批流转记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_approval_task
-- ----------------------------
DROP TABLE IF EXISTS `sys_approval_task`;
CREATE TABLE `sys_approval_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `instance_id` bigint NOT NULL COMMENT '审批实例ID',
  `node_id` bigint NOT NULL COMMENT '节点ID',
  `node_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '节点名称',
  `approver_id` bigint NOT NULL COMMENT '审批人ID',
  `approver_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '审批人姓名',
  `task_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'PENDING' COMMENT '任务状态: PENDING=待审批, APPROVED=已同意, REJECTED=已驳回, TRANSFERRED=已转审, CC=已抄送',
  `action_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `action_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批意见',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读: 0=未读, 1=已读',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_instance`(`instance_id` ASC) USING BTREE,
  INDEX `idx_approver`(`approver_id` ASC, `task_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审批任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_dict
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict`;
CREATE TABLE `sys_dict`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dict_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典编码',
  `dict_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典名称',
  `system_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'SYS' COMMENT '系统类型：SYS/HR/PMT',
  `description` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=禁用, 1=启用',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dict_code`(`dict_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 60 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据字典表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_dict_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_item`;
CREATE TABLE `sys_dict_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dict_id` bigint NOT NULL COMMENT '字典ID',
  `item_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项编码',
  `item_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项名称',
  `item_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项值',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=禁用, 1=启用',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dict_item`(`dict_id` ASC, `item_code` ASC) USING BTREE,
  INDEX `idx_dict_id`(`dict_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 297 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据字典项表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_login_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_login_log`;
CREATE TABLE `sys_login_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录账号',
  `login_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'LOGIN' COMMENT '类型: LOGIN=登录, LOGOUT=登出',
  `login_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态: SUCCESS=成功, FAIL=失败',
  `fail_reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '失败原因',
  `ip_address` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浏览器UA',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 78 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_operation_log`;
CREATE TABLE `sys_operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `system_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'SYS' COMMENT '所属系统',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作模块',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作描述',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'OTHER' COMMENT '操作类型',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '类方法',
  `request_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求URL',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求方式',
  `request_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数',
  `response_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '返回结果',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `duration` int NULL DEFAULT NULL COMMENT '耗时(ms)',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态:1成功0失败',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '异常信息',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `deleted` bigint NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_system_type`(`system_type` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_org
-- ----------------------------
DROP TABLE IF EXISTS `sys_org`;
CREATE TABLE `sys_org`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `org_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组织编码',
  `org_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组织名称',
  `org_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DEPT' COMMENT '类型: COMPANY=公司, DEPT=部门, TEAM=小组',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父组织ID',
  `org_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织层级路径',
  `leader_id` bigint NULL DEFAULT NULL COMMENT '负责人ID',
  `manager` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人姓名',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=禁用, 1=启用',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_org_code`(`org_code` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组织架构表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `perm_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限编码: 模块:资源:操作',
  `perm_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限名称',
  `perm_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型: MENU=菜单, BUTTON=按钮, API=接口',
  `system_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '系统类型：SYS/PMT/HR',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父权限ID(菜单层级)',
  `path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '前端路由路径',
  `component` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '前端组件路径',
  `icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜单图标',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=禁用, 1=启用',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_perm_code`(`perm_code` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4141 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `role_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色编码',
  `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `description` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色描述',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=禁用, 1=启用',
  `system_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '系统类型：SYS/PMT/HR',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` int NOT NULL DEFAULT 0,
  `deleted` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_code`(`role_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 70 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_perm`(`role_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `idx_permission_id`(`permission_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 281 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `company_id` bigint NULL DEFAULT NULL COMMENT '公司ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password_hash` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt加密)',
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '真实姓名',
  `employee_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工号',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `avatar_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `gender` tinyint NULL DEFAULT 0 COMMENT '性别: 0=未知, 1=男, 2=女',
  `org_id` bigint NULL DEFAULT NULL COMMENT '所属组织ID',
  `position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '岗位',
  `user_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户类型',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=禁用, 1=启用, 2=锁定',
  `login_fail_count` int NOT NULL DEFAULT 0 COMMENT '连续登录失败次数',
  `lock_time` datetime NULL DEFAULT NULL COMMENT '账户锁定时间',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `password_last_update_time` datetime NULL DEFAULT NULL COMMENT '密码最后修改时间',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_org_id`(`org_id` ASC) USING BTREE,
  INDEX `idx_employee_no`(`employee_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_user_app
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_app`;
CREATE TABLE `sys_user_app`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `app_id` bigint NOT NULL COMMENT '应用ID',
  `app_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '应用编码',
  `is_admin` tinyint NULL DEFAULT 0 COMMENT '是否应用管理员',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1启用0禁用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_app`(`user_id` ASC, `app_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_app_id`(`app_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户应用关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `system_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'SYS' COMMENT '系统类型',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_role`(`user_id` ASC, `role_id` ASC) USING BTREE,
  INDEX `idx_role_id`(`role_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;
