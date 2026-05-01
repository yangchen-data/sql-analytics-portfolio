-- ============================================
-- Business Question: Identify high value customers
-- and analyze their purchasing behavior
-- using CTEs and subqueries
-- Dataset: E-commerce orders (Olist/synthetic)
-- ============================================

-- 1. CTE: Identify high value customers (top 20% by spend)
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id)    AS total_orders,
        SUM(oi.price)                 AS total_spend,
        ROUND(AVG(oi.price), 2)       AS avg_order_value
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id, c.customer_state
),
spend_threshold AS (
    SELECT PERCENTILE_CONT(0.8) 
           WITHIN GROUP (ORDER BY total_spend) AS p80_spend
    FROM customer_spending
)
SELECT
    cs.customer_id,
    cs.customer_state,
    cs.total_orders,
    cs.total_spend,
    cs.avg_order_value
FROM customer_spending cs
CROSS JOIN spend_threshold st
WHERE cs.total_spend >= st.p80_spend
ORDER BY cs.total_spend DESC;


-- 2. Subquery: Categories purchased by high value customers only
WITH customer_spending AS (
    SELECT
        c.customer_id,
        SUM(oi.price) AS total_spend
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
),
high_value_customers AS (
    SELECT customer_id
    FROM customer_spending
    WHERE total_spend >= (
        SELECT PERCENTILE_CONT(0.8)
               WITHIN GROUP (ORDER BY total_spend)
        FROM customer_spending
    )
)
SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.order_id)       AS total_orders,
    SUM(oi.price)                     AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.customer_id IN (SELECT customer_id FROM high_value_customers)
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;
