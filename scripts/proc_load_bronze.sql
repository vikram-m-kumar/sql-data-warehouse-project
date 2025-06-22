/********************************************************************************************
    Description    : This stored procedure loads raw data into the Bronze Layer from source 
                     CSV files using BULK INSERT. It includes data from CRM and ERP systems.

                     The procedure first truncates each Bronze table, then loads data from 
                     the respective CSV files, and logs the time taken to load each table
                     as well as the total time for the entire Bronze layer.

    Note           : This procedure assumes the tables already exist in the bronze schema
                     and source CSV files are present in the specified file paths.

    WARNING        : BULK INSERT depends on correct file paths and schema match with table structure.
********************************************************************************************/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
    DECLARE @start_time     DATETIME;
    DECLARE @end_time       DATETIME;
    DECLARE @bronze_start   DATETIME;
    DECLARE @bronze_end     DATETIME;

    BEGIN TRY
        SET @bronze_start = GETDATE();

        PRINT '================================================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================================================';

        /********************************************************************************
            Load CRM Tables
        ********************************************************************************/
        PRINT '--------------------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------------------------------------------------------------------';

        -- Table 1: crm_cust_info
        SET @start_time = GETDATE();
        PRINT 'Table-1: bronze.crm_cust_info';

        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Vicky\SAU\DATA ANALYSIS\SQL\SQL Data Warehousing Project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';


        -- Table 2: crm_prd_info
        SET @start_time = GETDATE();
        PRINT 'Table-2: bronze.crm_prd_info';

        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Vicky\SAU\DATA ANALYSIS\SQL\SQL Data Warehousing Project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';


        -- Table 3: crm_sales_details
        SET @start_time = GETDATE();
        PRINT 'Table-3: bronze.crm_sales_details';

        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Vicky\SAU\DATA ANALYSIS\SQL\SQL Data Warehousing Project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

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
        PRINT 'Table-1: bronze.erp_cust_az12';

        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Vicky\SAU\DATA ANALYSIS\SQL\SQL Data Warehousing Project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';


        -- Table 2: erp_loc_a101
        SET @start_time = GETDATE();
        PRINT 'Table-2: bronze.erp_loc_a101';

        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Vicky\SAU\DATA ANALYSIS\SQL\SQL Data Warehousing Project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';


        -- Table 3: erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT 'Table-3: bronze.erp_px_cat_g1v2';

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Vicky\SAU\DATA ANALYSIS\SQL\SQL Data Warehousing Project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '--------------------------------------------------------------------------------';


        -- Final summary
        SET @bronze_end = GETDATE();
        PRINT '================================================================================';
        PRINT 'Loading Bronze Layer Completed';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND, @bronze_start, @bronze_end) AS NVARCHAR) + ' seconds';
        PRINT '================================================================================';

    END TRY

    BEGIN CATCH
        PRINT '================================================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT '================================================================================';
    END CATCH

END;
