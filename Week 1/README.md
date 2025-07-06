# Case Study #1: Danny's Diner 
<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

## Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

***

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 

***

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

***

## Question and Solution
**1. What is the total amount each customer spent at the restaurant?**

````sql
SELECT A.customer_id,
       SUM(B.price) AS total_spent
FROM sales A
LEFT JOIN menu B
ON A.product_id = B.product_id
GROUP BY A.customer_id
````
#### Answer:
| customer_id | total_spent |
| ----------- | ----------- |
| B           | 74          |
| C           | 36          |
| A           | 76          |

***

**2. How many days has each customer visited the restaurant?**

````sql
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS visit_days
FROM
	sales
GROUP BY customer_id
;
````
#### Answer:
| customer_id | visit_days |
| ----------- | ---------- |
| A           | 4          |
| C           | 2          |
| B           | 6          |

***

**3. What was the first item from the menu purchased by each customer?**

````sql
SELECT DISTINCT
    customer_id,
    product_name,
    order_date   
FROM 
    (SELECT
    A.customer_id,
    A.product_id,
    B.product_name,
    A.order_date,
    DENSE_RANK() OVER (PARTITION BY A.customer_id ORDER BY A.order_date) AS row_number
FROM sales A
LEFT JOIN menu B
ON A.product_id = B.product_id) AS R
WHERE  R.row_number = 1
````
#### Answer:
| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | curry        | 2021-01-01 |
| A           | sushi        | 2021-01-01 |
| B           | curry        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |

***

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
SELECT 
    product_id,
    product_name,
    sale_count
FROM (
    SELECT 
        A.product_id,
        A.product_name,
        COUNT(B.product_id) AS sale_count,
        DENSE_RANK() OVER (ORDER BY COUNT(B.product_id) DESC) AS rnk
    FROM menu A
    LEFT JOIN sales B ON A.product_id = B.product_id
    GROUP BY A.product_id, A.product_name
) AS C
WHERE C.rnk = 1;
````
#### Answer:
| product_id | product_name | sale_count |
| ---------- | ------------ | ---------- |
| 3          | ramen        | 8          |

***

**5. Which item was the most popular for each customer?**

````sql
 SELECT
      customer_id,
      product_name,
      count
    FROM (
      SELECT
        customer_id,
        product_name,
        DENSE_RANK () OVER (PARTITION BY customer_id ORDER BY COUNT(menu.product_id) DESC) as order_time,
       COUNT(menu.product_id) as count
      FROM sales
      LEFT JOIN menu
        ON sales.product_id = menu.product_id
      GROUP BY customer_id, product_name
    ) as subquery_1
    WHERE order_time = 1
    ORDER BY COUNT DESC;
````
#### Answer:
| customer_id | product_name | count |
| ----------- | ------------ | ----- |
| A           | ramen        | 3     |
| C           | ramen        | 3     |
| B           | ramen        | 2     |
| B           | sushi        | 2     |
| B           | curry        | 2     |

***

**6. Which item was purchased first by the customer after they became a member?**

```sql
    WITH member_order AS (
      SELECT 
      	s.customer_id,
        s.order_date,
        s.product_id,
        DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) as date_rank
      FROM sales AS s
      JOIN members AS m
      ON s.customer_id = m.customer_id
      WHERE s.order_date >= m.join_date
      )
      SELECT 
      	customer_id,
        order_date,
        menu.product_id,
        product_name
      FROM member_order
      JOIN menu
      ON member_order.product_id = menu.product_id
      WHERE date_rank = 1
      ;
```
#### Answer:
| customer_id | order_date | product_id | product_name |
| ----------- | ---------- | ---------- | ------------ |
| B           | 2021-01-11 | 1          | sushi        |
| A           | 2021-01-07 | 2          | curry        |

***

**7. Which item was purchased just before the customer became a member?**

````sql
   WITH nonmember_order AS (
          SELECT 
            s.customer_id,
            s.order_date,
            s.product_id,
            DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) as date_rank
          FROM sales AS s
          JOIN members AS m
          ON s.customer_id = m.customer_id
          WHERE s.order_date < m.join_date
          )
          SELECT 
          	customer_id,
            order_date,
            menu.product_id,
            product_name
          FROM nonmember_order
          JOIN menu
          ON nonmember_order.product_id = menu.product_id
          WHERE date_rank = 1
          ;
````
#### Answer:
| customer_id | order_date | product_id | product_name |
| ----------- | ---------- | ---------- | ------------ |
| B           | 2021-01-04 | 1          | sushi        |
| A           | 2021-01-01 | 1          | sushi        |
| A           | 2021-01-01 | 2          | curry        |

***

**8. What is the total items and amount spent for each member before they became a member?**

```sql
    WITH before_member AS (
              SELECT 
               m.customer_id,
               s.product_id   	   
              FROM sales AS s
              JOIN members AS m
              ON s.customer_id = m.customer_id
              WHERE s.order_date < m.join_date
         )
         SELECT 
         	bm.customer_id, 
            COUNT(DISTINCT bm.product_id) AS total_item,
            SUM(menu.price) AS total_spent
          FROM before_member AS bm
          JOIN menu
          ON bm.product_id = menu.product_id
          GROUP BY bm.customer_id
            ;
```
#### Answer:
| customer_id | total_item | total_spent |
| ----------- | ---------- | ----------- |
| A           | 2          | 25          |
| B           | 2          | 40          |

***

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?**

```sql
    SELECT 
    	sales.customer_id,
        SUM(
        CASE
          WHEN menu.product_name = 'sushi' THEN price * 10 * 2
          ELSE price * 10
        END
      ) AS total_point
    FROM sales
    JOIN menu
    ON sales.product_id = menu.product_id
    GROUP BY customer_id
    ORDER BY total_point DESC
    ;
```
#### Answer:
| customer_id | total_point |
| ----------- | ----------- |
| B           | 940         |
| A           | 860         |
| C           | 360         |

***

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

```sql
  SELECT 
    	first_week.customer_id,
        SUM((menu.price*10)*2)
    FROM(
    SELECT 
    	members.customer_id,
        sales.product_id,
        sales.order_date
    FROM members
    JOIN sales
    ON members.customer_id = sales.customer_id
    WHERE order_date >= join_date
      AND order_date <= join_date + INTERVAL '7 days') AS first_week
    JOIN menu
    ON first_week.product_id = menu.product_id
    WHERE first_week.customer_id IN ('A', 'B')
    GROUP BY first_week.customer_id
    ;
```
#### Answer:
| customer_id | sum  |
| ----------- | ---- |
| B           | 440  |
| A           | 1020 |
