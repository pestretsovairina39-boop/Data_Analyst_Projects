

-- Data Cleaning 
-- checking the dataset for empty and null values
 Select *
 from orders_table;
 
SELECT 
    COUNT(*) AS total_rows_in_table,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS empty_order_id,
    SUM(CASE WHEN price IS NULL OR TRIM(price) = '' THEN 1 ELSE 0 END) AS empty_price,
    SUM(CASE WHEN order_status IS NULL OR TRIM(order_status) = '' THEN 1 ELSE 0 END) AS empty_order_status,
    SUM(CASE WHEN preparation_time IS NULL THEN 1 ELSE 0 END) AS empty_preparation_time,
    SUM(CASE WHEN payment_method IS NULL OR TRIM(payment_method) = '' THEN 1 ELSE 0 END) AS empty_payment_method,
    SUM(CASE WHEN order_date IS NULL OR TRIM(order_date) = '' THEN 1 ELSE 0 END) AS empty_order_date
FROM 
    orders_table;
    
SELECT
    SUM(order_id IS NULL) AS null_ids,
    SUM(price IS NULL) AS null_prices,
    SUM(order_date IS NULL) AS null_date,
    SUM(order_status IS NULL) AS null_statuses,
    SUM(preparation_time IS NULL) AS null_prep_times,
    SUM(payment_method IS NULL) AS null_payments
FROM 
    orders_table;


SELECT 
    COUNT(*) AS total_rows_in_table,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS empty_order_id,
    SUM(CASE WHEN dish_id IS NULL OR TRIM(dish_id) = '' THEN 1 ELSE 0 END) AS empty_dish_id,
    SUM(CASE WHEN dish_name IS NULL OR TRIM(dish_name) = '' THEN 1 ELSE 0 END) AS empty_dish_name,
    SUM(CASE WHEN ingredient_id IS NULL OR TRIM(ingredient_id) = '' THEN 1 ELSE 0 END) AS empty_ingredient_id,
    SUM(CASE WHEN product_category IS NULL OR TRIM(product_category) = ''  THEN 1 ELSE 0 END) AS empty_product_category,
    SUM(CASE WHEN size IS NULL OR TRIM(size) = ''  THEN 1 ELSE 0 END) AS empty_size,
    SUM(CASE WHEN dish_price IS NULL OR TRIM(dish_price) = ''  THEN 1 ELSE 0 END) AS empty_dish_price,
    SUM(CASE WHEN quantity IS NULL OR TRIM(quantity) = ''  THEN 1 ELSE 0 END) AS empty_quantity
FROM dishes_table;

SELECT
    SUM(order_id IS NULL) AS null_ids,
    SUM(dish_id IS NULL) AS null_dish_ids,
    SUM(dish_name IS NULL) AS null_dish_name,
    SUM(ingredient_id IS NULL) AS null_ing_id,
    SUM(product_category IS NULL) AS null_prod_cat,
    SUM(size IS NULL) AS null_size,
    SUM(dish_price IS NULL) AS null_dish_price
FROM 
    dishes_table;


SELECT 
    COUNT(*) AS total_rows_in_table,
    SUM(CASE WHEN ingredient_id IS NULL OR TRIM(ingredient_id) = '' THEN 1 ELSE 0 END) AS empty_ingredient_id,
    SUM(CASE WHEN manufacturing_city IS NULL OR TRIM(manufacturing_city) = '' THEN 1 ELSE 0 END) AS empty_manufacturing_city,
    SUM(CASE WHEN shipping_time IS NULL OR TRIM(shipping_time) = '' THEN 1 ELSE 0 END) AS empty_shipping_time,
    SUM(CASE WHEN ingredient_name IS NULL OR TRIM(ingredient_name) = '' THEN 1 ELSE 0 END) AS empty_ingredient_name
FROM 
    ingredients_table;
    
SELECT
    SUM(ingredient_id IS NULL) AS null_ids,
    SUM(manufacturing_city IS NULL) AS null_man_city,
    SUM(shipping_time IS NULL) AS null_ship_time,
    SUM(ingredient_name IS NULL) AS null_ing_name
FROM 
    ingredients_table;

-- percentage of NULL values
SELECT 
    ROUND((SUM(CASE WHEN order_date IS NULL OR TRIM(order_date) = '' THEN 1 ELSE 0 END)/COUNT(*))*100 ) as empty_date_percentage
FROM 
    orders_table;


-- Data standardization

UPDATE orders_table
SET payment_method = CASE 
WHEN  payment_method LIKE '%card%' THEN 'Card'
WHEN payment_method LIKE '%cash%' THEN 'Cash'
WHEN payment_method LIKE '%mobile%' THEN 'Mobile'
END;

UPDATE orders_table
SET order_status = CASE 
WHEN  order_status LIKE '%completed%' THEN 'Completed'
WHEN order_status LIKE '%cancelled%' THEN 'Cancelled'
END;

UPDATE dishes_table
SET dish_name = CASE 
WHEN dish_name LIKE '%americano%' THEN 'Americano'
WHEN dish_name LIKE '%Brownie%' THEN 'Brownie'
WHEN dish_name LIKE '%Cappuccino%' THEN 'Cappuccino'
WHEN dish_name LIKE '%Cheesecake%' THEN 'Cheesecake'
WHEN dish_name LIKE '%Cinnamon%Roll%' THEN 'Cinnamon Roll'
WHEN dish_name LIKE '%Croissant%' THEN 'Croissant'
WHEN dish_name LIKE '%Espresso%' THEN 'Espresso'
WHEN dish_name LIKE '%Flat%White%' THEN 'Flat White'
WHEN dish_name LIKE '%Latte%' THEN 'Latte'
WHEN dish_name LIKE '%Tea%' THEN 'Tea'
END;

SELECT DISTINCT d.dish_name, d.size, o.price
FROM orders_table o 
JOIN dishes_table d ON o.order_id = d.order_id;


UPDATE dishes_table
SET product_category = 'Coffee' 
WHERE dish_name LIKE '%Latte%';

UPDATE dishes_table
SET size = CASE 
WHEN size LIKE '%S%' THEN 'Small'
WHEN size LIKE '%L%' THEN 'Large'
WHEN size LIKE '%M%' THEN 'Medium'
END;

-- checking and removing Duplicates

SELECT * 
FROM orders_table
WHERE order_id IN (
    SELECT order_id 
    FROM orders_table
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
ORDER BY order_id;

SELECT 
    order_id, 
    dish_id, 
    size,
    COUNT(*) AS appearance_count
FROM dishes_table GROUP BY 
    order_id, 
    dish_id, 
    size
HAVING COUNT(*) > 1;

SELECT * 
FROM ingredients_table
WHERE ingredient_id IN (
    SELECT ingredient_id
    FROM ingredients_table
    GROUP BY ingredient_id
    HAVING COUNT(*) > 1
)
ORDER BY ingredient_id;




ALTER TABLE dishes_table
ADD quantity int;


UPDATE dishes_table d
JOIN (
    SELECT order_id, dish_id, size, COUNT(*) as cnt
    FROM dishes_table
    GROUP BY order_id, dish_id, size
) src ON d.order_id = src.order_id AND d.dish_id = src.dish_id
SET d.quantity = src.cnt;

CREATE TABLE dishes_temp AS
SELECT 
    order_id, 
    dish_id, 
    dish_name, ingredient_id,
    product_category,
    size, dish_price,
    COUNT(*) as quantity 
FROM dishes_table
GROUP BY order_id, dish_id, dish_name, ingredient_id, product_category, size, dish_price;


TRUNCATE TABLE dishes_table;

INSERT INTO dishes_table (order_id, dish_id, dish_name, ingredient_id, product_category, size, dish_price, quantity)
SELECT order_id, dish_id, dish_name, ingredient_id, product_category, size, dish_price, quantity
FROM dishes_temp;


DROP TABLE dishes_temp;


-- EDA
-- Total ravenue for Completed orders
SELECT SUM(price) AS total
FROM orders_table
WHERE order_status = 'Completed';

-- Total ravenue for Cancelled orders
SELECT SUM(price) AS total
FROM orders_table
WHERE order_status != 'Completed';

-- Cancelled and completed orders percentages
SELECT 
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(CASE WHEN order_status = 'Completed' THEN 1 END) / COUNT(*), 2) AS completed_percentage,
    ROUND(100.0 * COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) / COUNT(*), 2) AS cancelled_percentage
FROM orders_table;

-- verification of the consistency in quantity of orders between the orders and dishes tables
SELECT DISTINCT order_id
FROM dishes_table;

-- verification total ravenue in the orders table by dishes table
SELECT sum(d.dish_price*d.quantity) AS total
FROM dishes_table d 
LEFT JOIN orders_table o ON d.order_id = o.order_id
WHERE o.price IS NOT NULL;

-- max and min price per dish
SELECT MAX(dish_price) AS max_price, MIN(dish_price) AS min_price
FROM dishes_table;

-- count orders by payment method
SELECT payment_method, COUNT(*) AS payment_method_count
FROM orders_table
GROUP BY payment_method;

-- Longest and lowest preparation time per order
SELECT MAX(preparation_time) AS Longest_prep_time, MIN(preparation_time) AS lowest_prep_time
FROM orders_table;


-- Adding separate columns for date and time for further analysis
ALTER TABLE orders_table
ADD COLUMN order_only_date DATE,
ADD COLUMN order_only_time TIME;

-- populating new columns
UPDATE orders_table
SET 
    order_only_date = DATE(order_date),
    order_only_time = TIME(order_date)
    where order_date != '';

-- identifying rush hours
SELECT 
    HOUR(order_only_time) AS order_hour, 
    COUNT(*) AS total_orders
FROM orders_table
GROUP BY HOUR(order_only_time)
ORDER BY order_hour;

-- Sales distribution by month
SELECT 
    month(order_only_date) AS order_month, 
    COUNT(*) AS total_orders
FROM orders_table
GROUP BY month(order_only_date)
ORDER BY order_month;

-- Sales distribution by day of the week
SELECT 
    DAYNAME(order_only_date) AS day_of_week, 
    COUNT(*) AS total_orders
FROM orders_table
WHERE order_date IS NOT NULL
GROUP BY day_of_week, WEEKDAY(order_only_date)
ORDER BY WEEKDAY(order_only_date);

-- Identifying the most popular category
SELECT product_category, SUM(quantity) AS popular_category
FROM dishes_table
GROUP BY product_category;

-- Identifying the most popular product 
SELECT dish_name, SUM(quantity), SUM(quantity*dish_price) AS popular_product
FROM dishes_table
GROUP BY dish_name;

-- Identifying the most popular size
SELECT size, SUM(quantity) AS popular_size
FROM dishes_table
GROUP BY size;

-- fixing inconsistent data
UPDATE dishes_table
SET size = 'Standart'
WHERE product_category = 'Dessert' OR product_category = 'Pastry';

-- Identifying the most popular size for drinks

SELECT dish_name, size, SUM(quantity) AS popular_drink_size
FROM (
    SELECT *
    FROM dishes_table
    WHERE product_category = 'Coffee' OR product_category = 'Other drink'
) AS drinks
GROUP BY dish_name, size
ORDER BY popular_drink_size DESC;

SELECT*
FROM ingredients_table;

-- Longest and shortest shipping time
SELECT MAX(shipping_time) AS longest_ship, MIN(shipping_time) AS fast_ship
FROM ingredients_table;

SELECT*
FROM orders_table;

-- Analysis of the hours with the highest number of cancelled orders
SELECT 
    HOUR(order_only_time) AS order_hour, 
    count(*) AS total_orders
FROM orders_table
where order_status = 'Cancelled'
GROUP BY HOUR(order_only_time)
ORDER BY order_hour;

-- Analysis of orders cancellation rate percentage by hour
SELECT 
    HOUR(order_only_time) AS order_hour,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
GROUP BY 
    HOUR(order_only_time)
ORDER BY 
    order_hour ASC;

-- Analysis of orders cancellation rate percentage by payment method
SELECT 
    payment_method,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
GROUP BY 
    payment_method;
    
-- Analysis of orders cancellation rate percentage by hour and payment method
SELECT 
	hour(order_only_time) as order_hour,
    payment_method,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
GROUP BY 
	hour(order_only_time),
    payment_method
ORDER BY 
order_hour ASC,
cancellation_rate_percentage DESC;

-- Analysis of orders cancellation rate percentage by month and payment method
SELECT 
	month(order_only_date) AS order_month,
    payment_method,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
GROUP BY 
	month(order_only_date),
    payment_method
ORDER BY 
order_month ASC,
cancellation_rate_percentage DESC;

-- Analysis of orders cancellation rate percentage by day and payment method in January
SELECT
    DAY(order_only_date) AS order_date,
    MONTH(order_only_date) AS order_month,
    payment_method,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
WHERE 
    MONTH(order_only_date) = 1 
GROUP BY 
    MONTH(order_only_date),   
    DAY(order_only_date),
    payment_method
ORDER BY 
    order_date ASC,
    cancellation_rate_percentage DESC;
    

-- Analysis of orders cancellation rate percentage by day and payment method in April   
SELECT
    DAY(order_only_date) AS order_date,
    MONTH(order_only_date) AS order_month,
    payment_method,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
WHERE 
    MONTH(order_only_date) = 4 
GROUP BY 
    MONTH(order_only_date),   
    DAY(order_only_date),
    payment_method
ORDER BY 
    order_date ASC,
    cancellation_rate_percentage DESC;

-- Analysis of orders cancellation rate percentage by day and payment method in June
SELECT
    DAY(order_only_date) AS order_date,
    MONTH(order_only_date) AS order_month,
    payment_method,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
WHERE 
    MONTH(order_only_date) = 6 
GROUP BY 
    MONTH(order_only_date),   
    DAY(order_only_date),
    payment_method
ORDER BY 
    order_date ASC,
    cancellation_rate_percentage DESC;

-- Analysis of orders cancellation rate percentage by day and payment method in June 12
    SELECT
    DAY(order_only_date) AS order_date,
    MONTH(order_only_date) AS order_month,
    payment_method,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
WHERE 
    MONTH(order_only_date) = 6 AND DAY(order_only_date) = 12
GROUP BY 
    MONTH(order_only_date),   
    DAY(order_only_date),
    payment_method
ORDER BY 
    order_date ASC,
    cancellation_rate_percentage DESC;

-- Analysis of orders cancellation rate percentage by month
SELECT 
    month(order_only_date) AS order_month,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
GROUP BY 
    month(order_only_date)
ORDER BY 
    order_month ASC;
    
 -- Analysis of orders cancellation rate percentage by day of week
 SELECT 
	DAYNAME(order_only_date) AS day_of_week,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
GROUP BY 
   day_of_week
ORDER BY 
    day_of_week ASC;

-- Analysis of orders cancellation rate percentage by dish
SELECT 
	d.dish_name,
    COUNT(o.order_id) AS total_orders,
    COUNT(IF(o.order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(o.order_status = 'Cancelled', 1, NULL)) / COUNT(o.order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table o 
    LEFT JOIN dishes_table d ON o.order_id = d.order_id
GROUP BY 
   d.dish_name
ORDER BY 
    d.dish_name ASC;
    
-- Analysis of orders cancellation rate percentage by dish and month   
SELECT 
	d.dish_name,
    MONTH(o.order_only_date) AS order_month,
    COUNT(o.order_id) AS total_orders,
    COUNT(IF(o.order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(o.order_status = 'Cancelled', 1, NULL)) / COUNT(o.order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table o 
    LEFT JOIN dishes_table d ON o.order_id = d.order_id
GROUP BY 
	MONTH(o.order_only_date),
   d.dish_name
ORDER BY 
    d.dish_name ASC,
    order_month ASC;
-- Analysis of orders cancellation rate for "Tea"
SELECT 
	d.dish_name,
    MONTH(o.order_only_date) AS order_month,
    COUNT(o.order_id) AS total_orders,
    COUNT(IF(o.order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(o.order_status = 'Cancelled', 1, NULL)) / COUNT(o.order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table o 
    LEFT JOIN dishes_table d ON o.order_id = d.order_id
WHERE dish_name = 'Tea'
GROUP BY 
	MONTH(o.order_only_date),
   d.dish_name
ORDER BY 
    d.dish_name ASC,
    order_month ASC;

-- assessing the difference between average price with long preparation time and with short preparation time
SELECT COUNT(*), AVG(price)
FROM orders_table
WHERE preparation_time > 15;

SELECT COUNT(*), AVG(price)
FROM orders_table
WHERE preparation_time < 15;

SELECT  AVG(price), AVG(preparation_time)
FROM orders_realistic;


-- Analysis of orders cancellation rate percentage by preparation time 
SELECT 
    CASE 
        WHEN preparation_time <= 10 THEN '0-10 mins'
        WHEN preparation_time > 10 AND preparation_time <= 20 THEN '10-20 mins'
        WHEN preparation_time > 20 AND preparation_time <= 30 THEN '20-30 mins'
        ELSE 'Over 30 mins'
    END AS prep_time_range,
    COUNT(order_id) AS total_orders,
    COUNT(IF(order_status = 'Cancelled', 1, NULL)) AS cancelled_orders,
    ROUND(
        (COUNT(IF(order_status = 'Cancelled', 1, NULL)) / COUNT(order_id)) * 100, 
        2
    ) AS cancellation_rate_percentage
FROM 
    orders_table
GROUP BY 
    CASE 
        WHEN preparation_time <= 10 THEN '0-10 mins'
        WHEN preparation_time > 10 AND preparation_time <= 20 THEN '10-20 mins'
        WHEN preparation_time > 20 AND preparation_time <= 30 THEN '20-30 mins'
        ELSE 'Over 30 mins'
    END
ORDER BY 
    MIN(preparation_time) ASC;
-- Checking whether rush hours affect long preparation time    

SELECT COUNT(*), AVG(preparation_time)
FROM orders_table
WHERE hour(order_only_time) = 8;

SELECT COUNT(*), AVG(preparation_time)
FROM orders_table
WHERE hour(order_only_time) = 9;

SELECT COUNT(*), AVG(preparation_time)
FROM orders_table
WHERE hour(order_only_time) = 10;


SELECT count(*), AVG(preparation_time)
FROM orders_table
WHERE hour(order_only_time) = 13;

-- average preparation time  during off-peak hours
SELECT COUNT(*), AVG(preparation_time)
FROM orders_table
WHERE hour(order_only_time) = 15;

SELECT COUNT(*), AVG(preparation_time)
FROM orders_table
WHERE hour(order_only_time) = 16;


SELECT COUNT(*), AVG(preparation_time)
FROM orders_table
WHERE hour(order_only_time) = 20;

SELECT COUNT(*), AVG(preparation_time)
FROM orders_table
WHERE hour(order_only_time) = 21;

-- searching for hours with the highest-paying orders 
SELECT 
    HOUR(order_only_time) AS order_hour, AVG(price),
    COUNT(*) AS total_orders
FROM orders_table
GROUP BY HOUR(order_only_time)
ORDER BY order_hour;


-- search for popular dish combination
SELECT
	t1.dish_name AS dish_1,
	t2.dish_name AS dish_2,
	COUNT(DISTINCTt1.order_id) AS combination_count
FROM dishes_table t1
INNER JOIN dishes_table t2
ON t1.order_id = t2.order_id AND t1.dish_name < t2.dish_name
GROUP BY t1.dish_name, t2.dish_name
ORDER BY combination_count DESC;
 




