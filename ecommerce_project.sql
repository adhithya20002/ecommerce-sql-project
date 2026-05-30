CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;
CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    city VARCHAR(50),
    signup_date DATE
);
CREATE TABLE dim_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    brand VARCHAR(50)
);
CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    order_status VARCHAR(20)
);
INSERT INTO dim_customers VALUES
(1, 'Asha', 'Female', 'Kollam', '2024-01-10'),
(2, 'Rahul', 'Male', 'Kochi', '2024-02-15'),
(3, 'Neha', 'Female', 'Trivandrum', '2024-03-20');
SELECT * FROM dim_customers;
INSERT INTO dim_products VALUES
(101, 'Phone X', 'Electronics', 'Mobiles', 'Apple'),
(102, 'Shoes Pro', 'Fashion', 'Footwear', 'Nike'),
(103, 'Watch Z', 'Accessories', 'Watches', 'Samsung');
SELECT * FROM dim_products;
INSERT INTO fact_orders VALUES
(1001, 1, 101, '2024-06-01', 1, 50000, 50000, 'Delivered'),
(1002, 2, 102, '2024-06-02', 2, 3000, 6000, 'Delivered'),
(1003, 1, 103, '2024-06-03', 1, 8000, 8000, 'Returned');
SELECT * FROM fact_orders;
SELECT SUM(total_amount) AS total_revenue
FROM fact_orders;
SELECT customer_id, SUM(total_amount) AS total_spent
FROM fact_orders
GROUP BY customer_id;
SELECT product_id, SUM(total_amount) AS revenue
FROM fact_orders
GROUP BY product_id
ORDER BY revenue DESC;
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_spent,
    AVG(total_amount) AS avg_order_value
FROM fact_orders
GROUP BY customer_id;
SELECT 
    customer_id,
    MAX(order_date) AS last_purchase_date
FROM fact_orders
GROUP BY customer_id;
SELECT 
    customer_id,
    COUNT(order_id) AS frequency
FROM fact_orders
GROUP BY customer_id;
SELECT 
    customer_id,
    SUM(total_amount) AS monetary_value
FROM fact_orders
GROUP BY customer_id;
SELECT 
    customer_id,
    
    MAX(order_date) AS last_purchase_date,
    COUNT(order_id) AS frequency,
    SUM(total_amount) AS monetary_value

FROM fact_orders
GROUP BY customer_id;
SELECT 
    customer_id,
    SUM(total_amount) AS monetary_value,
    NTILE(4) OVER (ORDER BY SUM(total_amount) DESC) AS m_score
FROM fact_orders
GROUP BY customer_id;
WITH rfm AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_purchase_date,
        COUNT(order_id) AS frequency,
        SUM(total_amount) AS monetary
    FROM fact_orders
    GROUP BY customer_id
)

SELECT 
    customer_id,
    frequency,
    monetary,
    NTILE(4) OVER (ORDER BY frequency DESC) AS freq_score,
    NTILE(4) OVER (ORDER BY monetary DESC) AS monetary_score
FROM rfm;
SELECT 
    customer_id,
    MIN(order_date) AS first_purchase_date
FROM fact_orders
GROUP BY customer_id;
SELECT 
    customer_id,
    DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
FROM fact_orders
GROUP BY customer_id;
WITH cohort AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM fact_orders
    GROUP BY customer_id
)

SELECT 
    f.customer_id,
    c.cohort_month,
    DATE_FORMAT(f.order_date, '%Y-%m') AS order_month
FROM fact_orders f
JOIN cohort c
ON f.customer_id = c.customer_id;
WITH cohort AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_date
    FROM fact_orders
    GROUP BY customer_id
)

SELECT 
    f.customer_id,
    TIMESTAMPDIFF(MONTH, c.first_date, f.order_date) AS month_index
FROM fact_orders f
JOIN cohort c
ON f.customer_id = c.customer_id;
WITH cohort AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_date
    FROM fact_orders
    GROUP BY customer_id
),

base AS (
    SELECT 
        f.customer_id,
        c.first_date,
        f.order_date,
        TIMESTAMPDIFF(MONTH, c.first_date, f.order_date) AS month_index
    FROM fact_orders f
    JOIN cohort c
    ON f.customer_id = c.customer_id
)
