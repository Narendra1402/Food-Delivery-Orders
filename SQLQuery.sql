-- Q1 How many rolls are Ordered ?

--SELECT COUNT(*) 
--FROM customer_orders;

---- Q2 How many unique Customer order made ?

--SELECT COUNT(DISTINCT customer_id) 
--FROM customer_orders;

-- Q3 How many successful Orders were delivered by each driver ?

--SELECT driver_id, COUNT(DISTINCT order_id) AS Order_Count
--FROM driver_order
--WHERE cancellation NOT LIKE '%Cancellation%'
--GROUP BY driver_id;

-- Q4 How Many of each type of roll Delivered ?

--WITH filtered_orders AS (
--    SELECT order_id
--    FROM driver_order
--    WHERE CASE 
--             WHEN cancellation IN ('Cancellation', 'Customer Cancellation') THEN 'C'
--             ELSE 'NC'
--             END = 'NC'  
--)
--SELECT r.roll_name,COUNT(co.roll_id) AS Roll_Count
--FROM customer_orders co
--JOIN filtered_orders fo ON co.order_id = fo.order_id
--JOIN rolls r on r.roll_id = co.roll_id
--GROUP BY r.roll_name;


-- Q5 How Many Veg and Non-Veg Rolls were Delivered by each Customer ?

--WITH filtered_orders AS (
--    SELECT order_id
--    FROM driver_order
--    WHERE CASE 
--             WHEN cancellation IN ('Cancellation', 'Customer Cancellation') THEN 'C'
--             ELSE 'NC'
--          END = 'NC'
--)
--SELECT co.customer_id, r.roll_name, COUNT(co.roll_id) AS Roll_Count
--FROM customer_orders co
--JOIN filtered_orders fo ON co.order_id = fo.order_id
--JOIN rolls r ON co.roll_id = r.roll_id
--GROUP BY co.customer_id, r.roll_name;

-- Q6 How Many Veg and Non-Veg Rolls were Order by each Customer ?

--SELECT co.customer_id, r.roll_name, Count(roll_Name) AS roll_Count
--FROM customer_orders co
--JOIN rolls r ON co.roll_id = r.roll_id
--GROUP BY r.roll_name, co.customer_id


-- Q7 What was the maximum number of rolls delivered in Single order ?


--WITH filtered_order AS (
--    SELECT order_id
--    FROM driver_order
--    WHERE CASE 
--             WHEN cancellation IN ('Cancellation', 'Customer Cancellation') THEN 'C'
--             ELSE 'NC'
--         END = 'NC'
--)
--SELECT TOP 1 co.order_id,COUNT(co.roll_id) AS cnt,
--    RANK() OVER (ORDER BY COUNT(co.roll_id) DESC) AS rank
--FROM customer_orders co
--JOIN filtered_order fo ON co.order_id = fo.order_id
--GROUP BY co.order_id
--ORDER BY cnt DESC;


--Q8 For Each Customer, how may delivered rools had at least 1 change and how many had no changes ?

--WITH temp_customer_orders AS (
--    SELECT order_id, customer_id,roll_id,        
--        COALESCE(NULLIF(not_include_items, ''), '0') AS new_not_include_items,    
--        COALESCE(NULLIF(extra_items_included, ''), '0') AS new_extra_items_included, 
--        order_date 
--    FROM customer_orders
--    WHERE COALESCE(extra_items_included, '') NOT IN ('NaN', 'NULL')
--),   
--temp_driver_order AS (
--    SELECT order_id, driver_id,pickup_time,distance,duration, 
--        CASE WHEN cancellation IN ('cancellation', 'customer cancellation') THEN 0
--             ELSE 1 END AS new_cancellation FROM driver_order           
--)
--SELECT customer_id,Chg_no_chg,COUNT(order_id) AS atleast_ones_change        
--FROM ( SELECT  *,CASE 
--            WHEN new_not_include_items = '0' AND new_extra_items_included = '0' 
--            THEN 'No change'ELSE 'Change'END AS Chg_no_chg FROM temp_customer_orders
--    WHERE order_id IN (SELECT order_id FROM temp_driver_order WHERE new_cancellation != 0)    
--) AS a GROUP BY customer_id, Chg_no_chg;


-- Q9 How many rools were delivered that had both exclusions and extras ?

--WITH temp_customer_orders AS (
--    SELECT  order_id,       
--        CASE WHEN COALESCE(not_include_items, '') = '' THEN '0' 
--            ELSE not_include_items END AS new_not_include_items,
--		CASE WHEN COALESCE(extra_items_included, '') IN ('', 'NaN', 'NULL') THEN '0' 
--            ELSE extra_items_included END AS new_extra_items_included FROM customer_orders ),
--temp_driver_order AS (
--    SELECT order_id,
--	    CASE WHEN cancellation IN ('cancellation', 'customer cancellation') THEN 0 
--            ELSE 1 END AS new_cancellation FROM driver_order)
--SELECT Chg_no_chg,COUNT(*) AS order_count 
--FROM (
--    SELECT order_id,
--		CASE WHEN new_not_include_items != '0' AND new_extra_items_included != '0' 
--            THEN 'Both inc exc' ELSE 'Either 1 inc or exc' END AS Chg_no_chg
--		FROM temp_customer_orders  WHERE order_id IN  (
--    SELECT order_id FROM temp_driver_order WHERE new_cancellation != 0)) AS subquery
--GROUP BY Chg_no_chg;        
        
    

-- Q10 What was the total Number of rolls ordered for each hour of the day?
--WITH HourlyBuckets AS (
--    SELECT 
--        CONCAT(FORMAT(order_date, 'HH'), '-',              
--        FORMAT(DATEADD(HOUR, 1, order_date), 'HH')) AS Hrs_bucket
--    FROM customer_orders
--)
--SELECT Hrs_bucket, COUNT(*) AS order_count    
--FROM HourlyBuckets
--GROUP BY Hrs_bucket
--ORDER BY Hrs_bucket;

-- Q11 What was the number of orders for each day of the weeks ?

--SELECT 
--    DATENAME(WEEKDAY, order_date) AS Day_of_Week, 
--    COUNT(DISTINCT order_id) AS order_count
--FROM customer_orders
--GROUP BY DATENAME(WEEKDAY, order_date), DATEPART(WEEKDAY, order_date) 
--ORDER BY DATEPART(WEEKDAY, order_date);


-- Q12 What was the average time in minutes it took for each driver to arrive at resturent to pick the food?

--SELECT driver_id, AVG(diff) AS Avg_time_min
--FROM (
--    SELECT b.driver_id, 
--           DATEDIFF(MINUTE, a.order_date, b.pickup_time) AS diff,
--           ROW_NUMBER() OVER (PARTITION BY a.order_id ORDER BY b.pickup_time) AS rnk
--    FROM customer_orders a
--    INNER JOIN driver_order b ON a.order_id = b.order_id
--    WHERE b.pickup_time IS NOT NULL
--) filtered_orders
--WHERE rnk = 1
--GROUP BY driver_id;


-- Q13 Is there any relationship between the number of roll and how long the order takes places?  

--WITH CTE_FilteredOrders AS (
--SELECT a.order_id, a.roll_id,
--        DATEDIFF(MINUTE, a.order_date, b.pickup_time) AS diff    
--        FROM customer_orders a   
--        INNER JOIN driver_order b ON a.order_id = b.order_id
--        WHERE b.pickup_time IS NOT NULL
--)
--SELECT order_id,count(roll_id) as Ctn,sum(diff)/COUNT(roll_id) AS TimeTaken 
--FROM CTE_FilteredOrders
--GROUP BY order_id;

-- Q14 what was the average distance travelled for each customer.   

--WITH CTE_FilteredOrders AS (
--    SELECT a.order_id, a.customer_id,
--          CAST(TRIM(REPLACE(LOWER(b.distance), 'Km', ' ')) AS DECIMAL(4,2)) AS distance,
--          ROW_NUMBER() OVER (PARTITION BY a.order_id ORDER BY b.pickup_time) AS rnk
--    FROM customer_orders a
--    INNER JOIN driver_order b ON a.order_id = b.order_id
--    WHERE b.pickup_time IS NOT NULL
--)
--SELECT customer_id,
--       CAST(ROUND(AVG(distance), 2) AS DECIMAL(4,2)) AS Avg_distance
--FROM CTE_FilteredOrders    
--WHERE rnk = 1
--GROUP BY customer_id;


-- Q15 What was the difference between the longest and shortest delivery times for all orders ? 

--WITH CTE_FilteredOrders AS (  
--        SELECT CASE WHEN duration LIKE '%min%' THEN 
--		CAST(LEFT(duration, CHARINDEX('m', duration) - 1) AS INT)
--        ELSE CAST(duration AS INT) END AS Duration  
--    FROM driver_order
--    WHERE duration IS NOT NULL
--)
--SELECT MAX(Duration) - MIN(Duration) AS Diff   
--FROM CTE_FilteredOrders;


-- Q16 What was the average speed for each driver for each delivery and do you notice any trend for these values?
--WITH cte_driver_order AS (
--    SELECT order_id, driver_id,
--         CASE WHEN duration LIKE '%min%' THEN CAST(LEFT(duration, CHARINDEX('m', duration) - 1) AS INT)
--         ELSE CAST(duration AS INT)END AS duration,
--         CAST(TRIM(REPLACE(LOWER(distance), 'km', '')) AS DECIMAL(4,2)) AS distance
--    FROM driver_order WHERE distance IS NOT NULL ),
--cte_customer_orders AS (
--    SELECT order_id, COUNT(roll_id) AS cnt
--    FROM customer_orders GROUP BY order_id )
--SELECT cco.order_id, cdo.driver_id,
--       CAST((cdo.distance / cdo.duration) AS DECIMAL(6,2)) AS speed, 
--       cco.cnt
--FROM cte_driver_order AS cdo
--INNER JOIN cte_customer_orders AS cco ON cdo.order_id = cco.order_id;

 
  --Q17 What is the successful delivery percentage for each driver ?


--SELECT driver_id,
--       CAST(ROUND((SUM(CASE 
--           WHEN lower(cancellation) NOT LIKE '%cancel%' THEN 1
--           ELSE 0
--       END) * 1.0 / COUNT(driver_id)) * 100, 1) AS DECIMAL(5,1)) AS successrate
--FROM driver_order
--GROUP BY driver_id;