/******************************************************************************************
    SQL Script: gold_layer_views.sql
    Description: This script creates business-ready views for the Gold Layer of the 
                 Data Warehouse using Medallion Architecture.
                 These views are built from cleaned and conformed Silver Layer tables.
******************************************************************************************/

/******************************************************************************************
    View: gold.dim_customers
    Purpose: Provides standardized customer dimension data for reporting and analysis.
******************************************************************************************/

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'NA' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'NA')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM 
    silver.crm_cust_info ci
LEFT JOIN 
    silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN 
    silver.erp_loc_a101 la ON ci.cst_key = la.cid;
GO

/******************************************************************************************
    View: gold.dim_products
    Purpose: Contains enriched product metadata for linking and categorization in sales data.
******************************************************************************************/

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance AS maintenance,
    pn.prd_cost AS product_cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM 
    silver.crm_prd_info pn
LEFT JOIN 
    silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE 
    pn.prd_end_dt IS NULL;
GO

/******************************************************************************************
    View: gold.fact_sales
    Purpose: Links customer and product dimensions to transactional sales facts.
******************************************************************************************/

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS 
SELECT 
    sd.sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_price AS price,
    sd.sls_quantity AS quantity,
    sd.sls_sales AS sales
FROM 
    silver.crm_sales_details sd
LEFT JOIN 
    gold.dim_products dp ON sd.sls_prd_key = dp.product_number
LEFT JOIN 
    gold.dim_customers dc ON sd.sls_cust_id = dc.customer_id;
GO
