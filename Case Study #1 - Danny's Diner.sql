/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
    s.customer_id,
    SUM(m.price) AS Total_spent
FROM sales s
JOIN menu m 
  ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Output

--  customer_id | Toat_Spent 
-- -------------+--------------
--  B           |           74
--  C           |           36
--  A           |           76


-- 2 . How many days has each customer visited the restaurant?

SELECT
  customer_id,
  COUNT(DISTINCT(order_date)) as no_of_days_visited
FROM sales
GROUP BY customer_id;

-- Output

--  customer_id | no_of_days_visited 
-- -------------+--------------
--  A           |            4
--  B           |            6
--  C           |            2




-- 3. What was the first item from the menu purchased by each customer?

with cte AS (
SELECT
	s.customer_id,
	m.product_name,
	RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS ranking
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id)
SELECT
	customer_id,
	product_name
FROM cte
	WHERE ranking =1;

-- Output

--  customer_id | product_name 
-- -------------+--------------
--  A           | curry
--  A           | sushi
--  B           | curry
--  C           | ramen
--  C           | ramen

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
	s.customer_id,
	m.product_name,
	COUNT(*) as no_of_times
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
	where m.product_name =
	(SELECT
		m.product_name
	FROM sales s
	JOIN menu m
		ON s.product_id = m.product_id
    GROUP BY m.product_name
    ORDER BY count(*) DESC
    LIMIT 1)
GROUP BY s.customer_id;

-- Output

--  customer_id | product_name | no_of_times 
-- -------------+--------------+-------------
--  A           | ramen        |    3 
--  B           | ramen        |    2 
--  C           | ramen        |    3 


-- 5. Which item was the most popular for each customer?

with cte2 as (WITH cte AS (SELECT
	s.customer_id,
    m.product_name,
    count(m.product_name) as popular_item_count
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id
    GROUP BY s.customer_id,m.product_name)
    SELECT 
    customer_id,
    product_name,
    popular_item_count,
    DENSE_RANK() OVER (PARTITION BY customer_id order by popular_item_count DESC) as rankings
    FROM cte)
    select 
		customer_id,
        product_name,
        popular_item_count
    from cte2 where rankings =1;

-- Output

--  customer_id | product_name | popular_item_count 
-- -------------+--------------+-------------
--  A           | ramen        |    3 
--  B           | curry        |    2 
--  B           | sushi        |    2
--  B           | ramen        |    2 
--  C           | ramen        |    3
