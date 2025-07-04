# Data Catalog – Gold Layer

This is the **Data Catalog for the Gold Layer** of the current SQL Data Warehouse project, designed using **Medallion Architecture** (Bronze → Silver → Gold).

The **Gold Layer** contains curated, business-ready data used for reporting, dashboards, and analytics. Below are the core tables with field-level documentation for ease of use and governance.

---

## How to Use This Data Catalog

- **Data Analysts** can use the catalog to understand field meanings and relationships for accurate querying.  
- **Engineers** can maintain consistency across pipelines using this metadata.  
- **Business Users** can refer to this for understanding metrics and dimensions in dashboards and reports.  

---

## 📂 Table: `dim_customers`

**Purpose:** Stores cleaned and standardized customer details used for analysis and joining with sales data.

| **Column Name**   | **Data Type** | **Description**                                              |
| ----------------- | ------------- | ------------------------------------------------------------ |
| `customer_key`    | INT           | Surrogate primary key for customer records.                  |
| `customer_id`     | INT           | Original customer ID from source systems.                    |
| `customer_number` | NVARCHAR(50)  | Unique alphanumeric identifier for a customer.               |
| `first_name`      | NVARCHAR(50)  | First name of the customer.                                  |
| `last_name`       | NVARCHAR(50)  | Last name of the customer.                                   |
| `country`         | NVARCHAR(50)  | Country where the customer resides.                          |
| `marital_status`  | NVARCHAR(50)  | Marital status of the customer; values: `Married`, `Single`. |
| `gender`          | NVARCHAR(50)  | Gender of the customer; values: `Male`, `Female`, `NA`.      |
| `birthdate`       | DATE          | Customer's date of birth.                                    |

---

## 📂 Table: `dim_products`

**Purpose:** Contains metadata about products for categorization and analysis in sales reporting.

| **Column Name**  | **Data Type** | **Description**                                                                     |
| ---------------- | ------------- | ----------------------------------------------------------------------------------- |
| `product_key`    | INT           | Surrogate primary key for product records.                                          |
| `product_id`     | INT           | Original product ID from source systems.                                            |
| `product_number` | NVARCHAR(50)  | Unique identifier/code for the product.                                             |
| `product_name`   | NVARCHAR(50)  | Name of the product.                                                                |
| `category_id`    | NVARCHAR(50)  | Identifier for the product category.                                                |
| `category`       | NVARCHAR(50)  | Product category; values: `Accessories`, `Bikes`, `Clothing`, `Components`, `NULL`. |
| `subcategory`    | NVARCHAR(50)  | Sub-category of the product within the main category.                               |
| `maintenance`    | NVARCHAR(50)  | Indicates if product requires maintenance; values: `Yes`, `No`, `NULL`.            |
| `product_cost`   | INT           | Cost incurred to produce or procure the product.                                    |
| `product_line`   | INT           | Business product line classification (usually numeric).                             |
| `start_date`     | DATE          | Date when the product became available.                                             |

---

## 📂 Table: `fact_sales`

**Purpose:** Captures transactional sales data that links customers and products with associated sales metrics.

| **Column Name** | **Data Type** | **Description**                                                         |
| --------------- | ------------- | ----------------------------------------------------------------------- |
| `order_number`  | NVARCHAR(50)  | Unique identifier for each sales order.                                 |
| `product_key`   | INT           | Foreign key linking to `dim_products.product_key`.                      |
| `customer_key`  | INT           | Foreign key linking to `dim_customers.customer_key`.                    |
| `order_date`    | DATE          | Date the order was placed.                                              |
| `shipping_date` | DATE          | Date the product was shipped.                                           |
| `due_date`      | DATE          | Expected delivery or payment due date.                                  |
| `price`         | INT           | Unit price of the product at the time of sale.                          |
| `quantity`      | INT           | Number of units sold in the order.                                      |
| `sales`         | INT           | Total sales amount for the line item; calculated as `price * quantity`. |

---
