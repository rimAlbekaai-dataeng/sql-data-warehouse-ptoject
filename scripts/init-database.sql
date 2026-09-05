/*
===============================================================================
Create Database and Schemas
===============================================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

use master;

if exists (select 1 from sys.databases where name = 'DataWarehouse')
begin alter DATABASE Datawarehouse set SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE Datawarehouse;
END;
GO

--CREATE THE 'DATAWAREHOUSE' DATABASE
create database DataWarehouse;
use DataWarehouse;
GO
--CREATE SHEMAS
Create SCHEMA bronze;
GO
Create SCHEMA silver;
go
Create SCHEMA gold;
go
