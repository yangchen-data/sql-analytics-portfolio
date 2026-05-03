-- ============================================
-- Business Question: Analyze customer retention
-- by cohort to understand how well we retain
-- customers over time
-- Dataset: E-commerce orders (Olist/synthetic)
-- ============================================

-- 1. Define cohorts by first purchase month
WITH customer_cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_purchase_timestamp)) AS cohort_month
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
),

-- 2. Get all subsequent orders per customer
customer_orders AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)    AS order_month
    FROM orders o
    WHERE o.order_status = 'delivered'
),

-- 3. Calculate months since first purchase
cohort_data AS (
    SELECT
        cc.cohort_month,
        co.order_month,
        COUNT(DISTINCT co.customer_id)                     AS active_customers,
        DATEDIFF('month', cc.cohort_month, co.order_month) AS month_number
    FROM customer_cohorts cc
    JOIN customer_orders co
        ON cc.customer_id = co.customer_id
    GROUP BY cc.cohort_month, co.order_month
),

-- 4. Get cohort size (month 0)
cohort_size AS (
    SELECT
        cohort_month,
        active_customers AS cohort_size
    FROM cohort_data
    WHERE month_number = 0
)

-- 5. Final retention table
SELECT
    cd.cohort_month,
    cd.month_number,
    cd.active_customers,
    cs.cohort_size,
    ROUND(cd.active_customers * 100.0 / cs.cohort_size, 2) AS retention_rate
FROM cohort_data cd
JOIN cohort_size cs
    ON cd.cohort_month = cs.cohort_month
ORDER BY cd.cohort_month, cd.month_number;
