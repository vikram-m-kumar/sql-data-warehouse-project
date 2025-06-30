CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time     DATETIME;
    DECLARE @end_time       DATETIME;
    DECLARE @silver_start   DATETIME;
    DECLARE @silver_end     DATETIME;

    BEGIN TRY
        SET @silver_start = GETDATE();

        PRINT '================================================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================================================';

        /********************************************************************************
            Load CRM Tables
        ********************************************************************************/
        PRINT '--------------------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------------------------------------------------------------------';

        -- Table 1: crm_cust_info
        SET @start_time = GETDATE();
        PRINT 'Table-1: silver.crm_cust_info';

        PRINT '>> Truncating table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting data into silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, 
            cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'NA'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'NA'
            END,
            cst_create_date
        FROM (
            SELECT * FROM (
                SELECT *, ROW_NUMBER() OVER (
                    PARTITION BY cst_id ORDER BY cst_create_date DESC
                ) AS flag_last
                FROM bronze.crm_cust_info
                WHERE cst_id IS NOT NULL
            ) AS t1
            WHERE flag_last = 1
        ) AS t2;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';

        -- Table 2: crm_prd_info
        SET @start_time = GETDATE();
        PRINT 'Table-2: silver.crm_prd_info';

        PRINT '>> Truncating table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting data into silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id, cat_id, prd_key, prd_nm, 
            prd_cost, prd_line, prd_start_dt, prd_end_dt
        )
        SELECT 
            prd_id,
            REPLACE(LEFT(prd_key, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            COALESCE(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'R' THEN 'Road'
                WHEN 'M' THEN 'Mountain'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'NA'
            END,
            prd_start_dt,
            DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt))
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';

        -- Table 3: crm_sales_details
        SET @start_time = GETDATE();
        PRINT 'Table-3: silver.crm_sales_details';

        PRINT '>> Truncating table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting data into silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id, 
            sls_order_dt, sls_ship_dt, sls_due_dt, 
            sls_sales, sls_quantity, sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END,
            CASE 
                WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,
            sls_quantity,
            CASE 
                WHEN sls_price <= 0 OR sls_price IS NULL
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';

        /********************************************************************************
            Load ERP Tables
        ********************************************************************************/
        PRINT '--------------------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '--------------------------------------------------------------------------------';

        -- Table 1: erp_cust_az12
        SET @start_time = GETDATE();
        PRINT 'Table-1: silver.erp_cust_az12';

        PRINT '>> Truncating table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting data into silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT 
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END,
            CASE 
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END,
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'NA'
            END
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';

        -- Table 2: erp_loc_a101
        SET @start_time = GETDATE();
        PRINT 'Table-2: silver.erp_loc_a101';

        PRINT '>> Truncating table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting data into silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT 
            REPLACE(cid, '-', ''),
            CASE
                WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
                WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'NA'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';

        -- Table 3: erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT 'Table-3: silver.erp_px_cat_g1v2';

        PRINT '>> Truncating table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting data into silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';

        -- Final summary
        SET @silver_end = GETDATE();
        PRINT '================================================================================';
        PRINT 'Loading Silver Layer Completed';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @silver_start, @silver_end) AS NVARCHAR) + ' seconds';
        PRINT '================================================================================';

    END TRY

    BEGIN CATCH
        PRINT '================================================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error State : ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT '================================================================================';
    END CATCH
END;
