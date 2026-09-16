/*
===================================================================
Quality Checks
===================================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading silver layer.
    - Investigate and resolve any discrepancies found during the checks.
===================================================================
*/
--======================================================
--checking 'silver.crm_cust_info'
--======================================================
--check for nulls or duplicates in primary key
--expectation : no results
SELECT cst_id, COUNT(*) FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1
OR cst_id IS NULL;


--check unwanted spaces
--expectation no result
select cst_firstname 
FROM bronze.crm_cust_info
where cst_firstname != TRIM(cst_firstname);

--data standardization & consistency
SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info;

--======================================================
--checking 'silver.crm_prd_info'
--======================================================

--check for unwanted spaces
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
--Data standardization & consistency
SELECT DISTINCT prd_nm
FROM silver.crm_prd_info

--check for nulls or negative numbers
--expectation :No Result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
--check for invalid DATA Orders 
select *
from silver.crm_prd_info
WHERE prd_end_dt <prd_start_dt

SELECT DISTINCT prd_line
FROM silver.crm_prd_info
--======================================================
--checking 'silver.crm_sales_details'
--======================================================
--check for Invalid Dates
--expectation :no invalid dates
SELECT 
NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101;

--check for invalid date orders (oredr date > ship/duedate)
--expectation: no result
select * 
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt  OR sls_order_dt > sls_due_dt;
--check data consistency: sales = quantity * price
SELECT DISTINCT 
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
   ELSE sls_sales
   END sls_sales,
   CASE WHEN sls_price IS NULL OR sls_price <=0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity  IS NULL OR sls_price IS NULL 
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity,sls_price




--======================================================
--checking 'silver.erp_cust_az12'
--======================================================
--Identify out_of_rang Dates
--Expectation: Birtfdates between 1942-01-01 and today
SELECT DISTINCT
   bdate
   FROM silver.erp_cust_az12
   WHERE bdate <'1942-01-01'
      OR bdate >GETDATE();

--Data standardization & consistency
SELECT DISTINCT 
  gen
  FROM silver.erp_cust_az12;
--======================================================
--checking 'silver.erp_loc_a101'
--======================================================
--Data standardization & consistency
SELECT DISTINCT 
  country
  FROM silver.erp_loc_a101
  order BY country;
--======================================================
--checking 'silver.erp_px_cat_g1v2'
--======================================================
--check for Unwanted spaces
--Expectation: No Results
select * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);

--Data standerdization & consistency
SELECT DISTINCT 
  maintenance
  FROM silver.erp_px_cat_g1v2;
