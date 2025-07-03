-- 🍜 Week 1 - Danny's Diner SQL Solutions
-- Author: [Your Name]
-- Date: [Date]

-- Q1: What is the total amount each customer spent at the restaurant?

SELECT 
  s.customer_id,
  SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Q2: How many days has each customer visited the restaurant?

SELECT 
  customer_id,
  COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;

-- Q3: What was the first item from the menu purchased by each customer?

WITH first_orders AS (
  SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS order_rank
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
)
SELECT 
  customer_id,
  product_name
FROM first_orders
WHERE order_rank = 1;
