-- ============================================
-- Business Question: Analyze customer purchase
-- patterns and rank performance using
-- window functions
-- Dataset: E-commerce orders (Olist/synthetic)
-- ============================================

-- 1. Rank customers by total spend within each state
SELECT
    c.customer_id,
    c.customer_state,
    SUM(oi.price)                          AS total_spend,
    RANK() OVER (
        PARTITION BY c.customer_state
        ORDER BY SUM(oi.price) DESC
    )                                       AS spend_rank_in_state
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_id, c.customer_state
ORDER BY c.customer_state, spend_rank_in_state;


-- 2. Running total of monthly revenue
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)  AS order_month,
    SUM(oi.price)                                     AS monthly_revenue,
    SUM(SUM(oi.price)) OVER (
        ORDER BY DATE_TRUNC('month', o.order_purchase_timestamp)
    )                                                 AS running_total
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


-- 3. Month over month revenue change
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)  AS order_month,
        SUM(oi.price)                                     AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month)           AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_month))
        / LAG(revenue) OVER (ORDER BY order_month) * 100
    , 2)                                               AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_month;


-- 4. Top 3 products per category by revenue
WITH product_revenue AS (
    SELECT
        p.product_category_name,
        p.product_id,
        SUM(oi.price)                                  AS total_revenue,
        RANK() OVER (
            PARTITION BY p.product_category_name
            ORDER BY SUM(oi.price) DESC
        )                                              AS revenue_rank
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.product_category_name, p.product_id
)
SELECT *
FROM product_revenue
WHERE revenue_rank <= 3
ORDER BY product_category_name, revenue_rank;
