/********************************************************************************************
    Description   : This script creates base tables in the 'bronze' schema for the DataWarehouse.
                    These tables serve as the raw data landing zone (Bronze Layer) in a 
                    Medallion Architecture setup.
                    
                    It checks for each table's existence and drops it if already present,
                    then creates a fresh table structure to prepare for bulk data loading.
                    

    NOTE          : Use this script only in development or staging environments.
                    Dropping tables will permanently delete all existing data.
********************************************************************************************/


-- ================================================
-- CRM Source Tables
-- ================================================

-- Drop and create bronze.crm_cust_info
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO


-- Drop and create bronze.crm_prd_info
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id         INT,
    prd_key        NVARCHAR(50),
    prd_nm         NVARCHAR(50),
    prd_cost       INT,
    prd_line       NVARCHAR(50),
    prd_start_dt   DATE,
    prd_end_dt     DATE
);
GO


-- Drop and create bronze.crm_sales_details
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num    NVARCHAR(50),
    sls_prd_key    NVARCHAR(50),
    sls_cust_id    INT,
    sls_order_dt   DATE,
    sls_ship_dt    DATE,
    sls_due_dt     DATE,
    sls_sales      INT,
    sls_quantity   INT,
    sls_price      INT
);
GO


-- ================================================
-- ERP Source Tables
-- ================================================

-- Drop and create bronze.erp_cust_az12
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid     NVARCHAR(50),
    bdate   DATE,
    gen     NVARCHAR(50)
);
GO


-- Drop and create bronze.erp_loc_a101
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid     NVARCHAR(50),
    cntry   NVARCHAR(50)
);
GO


-- Drop and create bronze.erp_px_cat_g1v2
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);
GO

PRINT 'Bronze layer tables created successfully.';
