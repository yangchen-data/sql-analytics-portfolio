-- ============================================
-- Business Question: Analyze the e-commerce
-- purchase funnel to identify where customers
-- drop off and optimize conversion
-- Dataset: E-commerce orders (Olist/synthetic)
-- ============================================

-- 1. Overall funnel conversion rates
WITH funnel_stages AS (
    SELECT
        COUNT(DISTINCT session_id)                        AS total_sessions,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'product_view' 
            THEN session_id END)                          AS product_views,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'add_to_cart' 
            THEN session_id END)                          AS add_to_cart,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'checkout_start' 
            THEN session_id END)                          AS checkout_started,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'purchase' 
            THEN session_id END)                          AS purchases
    FROM user_events
)
SELECT
    total_sessions,
    product_views,
    add_to_cart,
    checkout_started,
    purchases,
    ROUND(product_views * 100.0 / total_sessions, 2)      AS session_to_view_pct,
    ROUND(add_to_cart * 100.0 / product_views, 2)         AS view_to_cart_pct,
    ROUND(checkout_started * 100.0 / add_to_cart, 2)      AS cart_to_checkout_pct,
    ROUND(purchases * 100.0 / checkout_started, 2)        AS checkout_to_purchase_pct,
    ROUND(purchases * 100.0 / total_sessions, 2)          AS overall_conversion_pct
FROM funnel_stages;


-- 2. Funnel breakdown by device type
WITH device_funnel AS (
    SELECT
        device_type,
        COUNT(DISTINCT session_id)                        AS total_sessions,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'product_view' 
            THEN session_id END)                          AS product_views,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'add_to_cart' 
            THEN session_id END)                          AS add_to_cart,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'purchase' 
            THEN session_id END)                          AS purchases
    FROM user_events
    GROUP BY device_type
)
SELECT
    device_type,
    total_sessions,
    product_views,
    add_to_cart,
    purchases,
    ROUND(purchases * 100.0 / total_sessions, 2)          AS overall_conversion_pct
FROM device_funnel
ORDER BY overall_conversion_pct DESC;


-- 3. Weekly funnel trend to detect drop off over time
WITH weekly_funnel AS (
    SELECT
        DATE_TRUNC('week', event_timestamp)               AS event_week,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'product_view' 
            THEN session_id END)                          AS product_views,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'add_to_cart' 
            THEN session_id END)                          AS add_to_cart,
        COUNT(DISTINCT CASE 
            WHEN event_type = 'purchase' 
            THEN session_id END)                          AS purchases
    FROM user_events
    GROUP BY 1
)
SELECT
    event_week,
    product_views,
    add_to_cart,
    purchases,
    ROUND(purchases * 100.0 / NULLIF(product_views, 0), 2) AS view_to_purchase_pct
FROM weekly_funnel
ORDER BY event_week;
