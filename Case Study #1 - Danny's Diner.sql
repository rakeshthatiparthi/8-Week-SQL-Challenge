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

--  customer_id | Total_Spent 
-- -------------+--------------
--  A           |           76
--  B           |           74
--  C           |           36


-- 2 . How many days has each customer visited the restaurant?

SELECT
	customer_id,
	COUNT(DISTINCT(order_date)) as no_of_days_visited
FROM sales
GROUP BY customer_id;

-- Output

--  customer_id | no_of_days_visited 
-- -------------+--------------------
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

with cte2 as (WITH cte AS (
	SELECT
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
    DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY popular_item_count DESC) as rankings
    FROM cte)
    SELECT
    	customer_id,
        product_name,
        popular_item_count
    FROM cte2 WHERE rankings =1;

-- Output

--  customer_id | product_name | popular_item_count 
-- -------------+--------------+-------------
--  A           | ramen        |    3 
--  B           | curry        |    2 
--  B           | sushi        |    2
--  B           | ramen        |    2 
--  C           | ramen        |    3


 -- 6. Which item was purchased first by the customer after they became a member?
 
 WITH cte as(SELECT
	me.customer_id,
    me.join_date,
    s.order_date,
    m.product_name,
    RANK() OVER (PARTITION BY me.customer_id order by s.order_date) as rankings
 FROM members me
 JOIN sales s
	ON me.customer_id = s.customer_id
 JOIN menu m
	ON s.product_id = m.product_id
    WHERE s.order_date >= me.join_date)
    SELECT customer_id,product_name FROM cte where rankings =1 ;
    
-- Output

--  customer_id | product_name 
-- -------------+--------------
--  A           | curry
--  B           | sushi    



 -- 7. Which item was purchased just before the customer became a member?
 
 WITH cte as(SELECT
	me.customer_id,
    me.join_date,
    s.order_date,
    m.product_name,
    RANK() OVER (PARTITION BY me.customer_id order by s.order_date desc) as rankings
 FROM members me
 JOIN sales s
	ON me.customer_id = s.customer_id
 JOIN menu m
	ON s.product_id = m.product_id
    WHERE s.order_date < me.join_date)
    SELECT customer_id,product_name FROM cte where rankings =1 ;
    
    
-- Output

--  customer_id | product_name 
-- -------------+--------------
--  A           | sushi
--  A           | curry
--  B           | sushi


 -- 8 What is the total items and amount spent for each member before they became a member?
 
 SELECT
 	me.customer_id,
	COUNT(m.product_id) as total_items,
	SUM(m.price) as amount_spent
FROM members me
JOIN sales s
	ON me.customer_id = s.customer_id 
JOIN menu m
	ON s.product_id = m.product_id
WHERE s.order_date < me.join_date
        GROUP BY me.customer_id;
	
-- Output

--  customer_id | total_items | amount_spent
-- -------------+-------------+-------------
--  A           |           2 |     25
--  B           |           3 |     40


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
	s.customer_id,
	SUM(case
		when m.product_name = 'sushi' then m.price*20
        	else price*10
	end) as points_earned
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Output

--  customer_id | points_earned 
-- -------------+--------
--  A           |    860
--  B           |    940
--  C           |    360

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
	me.customer_id,
	SUM(m.price*20)  as points_earned_in_first_week
FROM members me
JOIN sales s
	ON me.customer_id = s.customer_id
JOIN menu m
	ON s.product_id = m.product_id
WHERE s.order_date between me.join_date and DATE_ADD(me.join_date, INTERVAL 7 DAY)
GROUP BY me.customer_id;

-- Output

--  customer_id | points_earned_in_first_week 
-- -------------+----------------------------
--  B           |   440
--  A           |    1020
