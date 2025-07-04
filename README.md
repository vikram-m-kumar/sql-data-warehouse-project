# 🏗️ SQL Data Warehouse Project – Medallion Architecture

## 📘 Overview

This project demonstrates a full-stack SQL Data Warehouse built using the **Medallion Architecture** (Bronze → Silver → Gold layers). It integrates data from two source systems – **CRM** and **ERP** – and transforms them into business-ready tables and views.

The project is automated using stored procedures and includes a comprehensive **Data Catalog** to enable self-service analytics for Data Analysts, Scientists, and Business Users.

---

## 📂 Data Sources

1. **CRM System**  
   Provides customer, product, and sales data.

2. **ERP System**  
   Contributes demographic enrichment (e.g., birthdate, gender), location data, and product category mappings.

---

## 🥉 Bronze Layer (Raw Zone)

### Description:
- This is the **raw data landing zone**.
- CSV files exported from Excel sheets are bulk loaded here.
- No transformation is applied in this layer.

### Key Features:
- Source-specific table creation (`bronze.crm_cust_info`, `bronze.erp_cust_az12`, etc.)
- Stored Procedure: `bronze.load_bronze`  
  Automates:
  - Table truncation
  - CSV file ingestion via `BULK INSERT`
  - Logging load duration

---

## 🥈 Silver Layer (Clean Zone)

### Description:
- Represents **cleaned, standardized, and conformed data**.
- Prepares data for analytics and modeling.

### Key Features:
- Stored Procedure: `silver.load_silver`
- Major Transformations:
  - ✅ Duplicate removal (ROW_NUMBER partitioning)
  - 🧩 Derived columns (e.g., `dwh_create_date`)
  - ✂️ Column splitting and trimming (e.g., first/last names)
  - 🔁 Data type conversions
  - 🧼 Null handling
  - 🧾 Business logic standardization (e.g., `M` → `Married`, `S` → `Single`)

---

## 🥇 Gold Layer (Business Zone)

### Description:
- Final layer containing **business-ready views**.
- Joins CRM and ERP dimensions with fact tables using proper surrogate keys.

### Key Features:
- Views Created:
  - `gold.dim_customers`
  - `gold.dim_products`
  - `gold.fact_sales`
- Business Logic Applied:
  - Surrogate keys via `ROW_NUMBER()`
  - Proper FK relationships
  - Date cleansing and field harmonization
- Naming conventions standardized for business readability.

---

## 📚 Data Catalog

### Purpose:
Provides a **field-level metadata** reference to assist all users in understanding data structure, types, and relationships.

### Catalog Tables:
- #dim_customers
- #dim_products
- #fact_sales

### How to Use:
- **Data Analysts**: Understand relationships and query confidently.
- **Engineers**: Maintain schema and pipeline consistency.
- **Business Users**: Use as a reference while building dashboards or reports.

👉 [View Full Data Catalog in Markdown](other_docs/data_catalog.md)

---

## 🧪 Tech Stack

| Component      | Description                                      |
|----------------|--------------------------------------------------|
| SQL Server     | Core database engine                             |
| T-SQL          | Used for all DDL/DML and stored procedures       |
| Excel / CSV    | Source files ingested into the Bronze layer      |
| GitHub         | Version control and project documentation        |

---


## 🚀 Getting Started

1. Run the `init_database.sql` to set up schemas and database.
2. Execute the Bronze layer scripts.
3. Run `EXEC bronze.load_bronze` to ingest raw data.
4. Execute the Silver table creation and run `EXEC silver.load_silver`.
5. Deploy views from `gold/gold_views.sql`.
6. Review the `data_catalog.md` to understand final tables.

---

## 🔒 Best Practices Followed

- ❌ No hard deletes or blind overwrites in Silver/Gold layers
- ✅ Separation of raw, clean, and curated layers
- 🛠️ Repeatable and idempotent procedures
- 🔍 Logging and traceability through PRINT statements

---


