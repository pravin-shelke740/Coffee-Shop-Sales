CREATE DATABASE Coffee_Sales;
select * from coffee_shop_sales;
DESC coffee_shop_sales;

-- DATA VALIDATION

#Changing data type of transaction date to date
UPDATE coffee_shop_sales
SET transaction_date = 
STR_TO_DATE(transaction_date, '%m/%d/%Y');
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE coffee_shop_sales
MODIFY transaction_date Date;

#ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE
ALTER TABLE coffee_shop_sales
MODIFY transaction_time TIME;

ALTER TABLE coffee_shop_sales
CHANGE COLUMN `ï»¿transaction_id` transaction_id INT;

DESC coffee_shop_sales;

#Check for NULL Values

SELECT
	SUM(transaction_id IS NULL) AS null_transaction_id,
    SUM(transaction_date IS NULL) AS null_transaction_date,
    SUM(transaction_time IS NULL) AS null_transaction_time,
    SUM(transaction_qty IS NULL) AS null_transaction_qty,
    SUM(store_id IS NULL) AS null_store_id,
    SUM(store_location IS NULL) AS null_store_location,
    SUM(product_id IS NULL) AS null_product_id
FROM coffee_shop_sales;

#Check for Invalid Quantities
SELECT * FROM coffee_shop_sales WHERE transaction_qty <= 0;

#Check for Invalid Prices
SELECT * FROM coffee_shop_sales WHERE unit_price <= 0;

#Duplicate Transaction check
SELECT transaction_id, COUNT(*) AS duplicate_count
FROM coffee_shop_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- DATA TRANSAFORMATION (Derived Fields)

-- Create a view with Revenue Calculation
CREATE VIEW revenue AS 
SELECT
	transaction_id,
    transaction_date,
    transaction_time,
    transaction_qty,
    store_id,
    store_location,
    product_id,
    unit_price,
    product_category,
    product_type,
    product_detail,
    transaction_qty * unit_price AS revenue
FROM coffee_shop_sales;

SELECT * FROM revenue;

#Add Time-Based Attributes
CREATE VIEW trend_data AS 
SELECT
	*,
    HOUR(transaction_time) AS sales_hour,
    DAYNAME(transaction_date) AS sales_day,
    MONTH(transaction_date) AS sales_month,
    YEAR(transaction_date) AS sales_year
FROM revenue;

SELECT * FROM trend_data;

#Exploratory Business Analysis Using SQL

