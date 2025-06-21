/********************************************************************************************

    Description   : This script creates a new database named 'DataWarehouse'.
                    Before creation, it checks if a database with the same name already exists.
                    If it exists, the script will delete (drop) the existing database 
                    after forcing all active connections to close.
                    
                    After creating the new database, the script sets up three schemas:
                    - bronze : for raw data
                    - silver : for cleaned/processed data
                    - gold   : for business-ready, aggregated data

    
    WARNING       : This script will permanently DELETE the existing 'DataWarehouse' database.
                    All data will be lost. Use with caution, especially in production environments.
********************************************************************************************/

-- Switch to master context to allow dropping the database
USE master;
GO

/********************************************************************************************
    Step 1: Check if the 'DataWarehouse' database exists.
            If it does, force disconnect users and drop it.
********************************************************************************************/
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
    PRINT 'Database "DataWarehouse" exists. Dropping it now...';

    -- Set to SINGLE_USER mode to disconnect all users immediately
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    -- Drop the database
    DROP DATABASE DataWarehouse;

    PRINT 'Database "DataWarehouse" dropped successfully.';
END;
GO

/********************************************************************************************
    Step 2: Create a new 'DataWarehouse' database.
********************************************************************************************/
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the new DataWarehouse
USE DataWarehouse;
GO

/********************************************************************************************
    Step 3: Create schemas for Medallion Architecture:
            - bronze: Raw ingestion layer
            - silver: Cleaned and conformed data
            - gold  : Business-ready, aggregated data
********************************************************************************************/
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

