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

#Total Revenue
SELECT SUM(revenue) AS total_revenue
FROM revenue;

#Revenue by store Location
SELECT 
	store_location,
    SUM(revenue) AS total_revenue
FROM revenue
GROUP BY store_location
ORDER BY total_revenue DESC;

#Revenue by product category
SELECT 
	product_category,
    SUM(revenue) AS total_revenue
FROM revenue
GROUP BY product_category
ORDER BY total_revenue DESC;

# Top 10 Products by revenue
SELECT 
	product_detail,
    SUM(revenue) AS total_revenue
FROM revenue
GROUP BY product_detail
ORDER BY total_revenue DESC
LIMIT 10;

SELECT * FROM coffee_shop_sales;
SELECT 
	sales_hour,
    SUM(revenue) AS hourly_revenue
FROM trend_data
GROUP BY sales_hour
ORDER BY sales_hour;

#Daily Sales Trend
SELECT 
	transaction_date,
    SUM(revenue) As daily_revenue
FROM trend_data
GROUP BY transaction_date
ORDER BY transaction_date;

#Monthly Sales Trend
SELECT 
	sales_year,
    sales_month,
    SUM(revenue) AS monthly_revenue
FROM trend_data
GROUP BY sales_year, sales_month
ORDER BY sales_year, sales_month;

SELECT store_location, sales_day,product_category, sum(revenue) as Total_revenue
from trend_data group by store_location, sales_day, product_category;

#To get sales from monday to sunday for month of may
SELECT 
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wedneday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
	END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM
	coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 -- Filtering for may (month number 5)
GROUP BY 
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wedneday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
	END;
    
    -- CORE KPI calculations
    #1. Total Orders
    SELECT
		COUNT(DISTINCT transaction_id) AS total_orders
	FROM coffee_shop_sales;
    
    #2. Total Revenue
    SELECT
		ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
	FROM coffee_shop_sales;
    
    #3. Average Order Value(AOV)
    -- How much each customer spends on each visit
    SELECT ROUND(SUM(transaction_qty * unit_price) / COUNT(DISTINCT transaction_id), 2)
    AS avg_order_value FROM coffee_shop_sales;
    
    #4 Peak sales hour
    SELECT 
		HOUR(transaction_time) AS sales_hour,
        ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
	FROM coffee_shop_sales
    GROUP BY sales_hour
    ORDER BY revenue DESC
    LIMIT 1;
    
#5. Weekday vs Weekend Sales
SELECT
	CASE
		WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
	END AS day_type,
    ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_shop_sales
GROUP BY day_type;

select * from coffee_shop_sales;
