-- ============================================================
-- 14 CUSTOMER & SELLER PERFORMANCE ANALYSIS
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- ============================================================


-- ============================================================
-- 1. TOP SELLERS BY REVENUE
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_product_price
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 25;


-- ============================================================
-- 2. TOP SELLERS BY NUMBER OF ORDERS
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_orders DESC
LIMIT 25;


-- ============================================================
-- 3. SELLER PERFORMANCE BY STATE
-- ============================================================

SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS total_sellers,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(
        (
            SUM(oi.price) /
            NULLIF(COUNT(DISTINCT oi.order_id), 0)
        )::numeric,
        2
    ) AS revenue_per_order
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;


-- ============================================================
-- 4. CUSTOMER VALUE BY STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(op.payment_value)::numeric, 2) AS total_revenue,
    ROUND(
        (
            SUM(op.payment_value) /
            NULLIF(COUNT(DISTINCT c.customer_unique_id), 0)
        )::numeric,
        2
    ) AS revenue_per_customer
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset op
    ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ============================================================
-- 5. CUSTOMER ORDER FREQUENCY
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

frequency_groups AS (
    SELECT
        CASE
            WHEN order_count = 1 THEN '1 Order'
            WHEN order_count = 2 THEN '2 Orders'
            WHEN order_count BETWEEN 3 AND 5 THEN '3-5 Orders'
            ELSE '6+ Orders'
        END AS customer_frequency,
        COUNT(*) AS customers
    FROM customer_orders
    GROUP BY
        CASE
            WHEN order_count = 1 THEN '1 Order'
            WHEN order_count = 2 THEN '2 Orders'
            WHEN order_count BETWEEN 3 AND 5 THEN '3-5 Orders'
            ELSE '6+ Orders'
        END
)

SELECT
    customer_frequency,
    customers,
    ROUND(
        (
            customers * 100.0 /
            SUM(customers) OVER ()
        )::numeric,
        2
    ) AS customer_percentage
FROM frequency_groups
ORDER BY
    CASE
        WHEN customer_frequency = '1 Order' THEN 1
        WHEN customer_frequency = '2 Orders' THEN 2
        WHEN customer_frequency = '3-5 Orders' THEN 3
        ELSE 4
    END;

-- ============================================================
-- 6. HIGH-VALUE CUSTOMERS
-- ============================================================

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(op.payment_value) AS total_spending
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    total_orders,
    ROUND(total_spending::numeric, 2) AS total_spending
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 25;


-- ============================================================
-- 7. FINAL CUSTOMER & SELLER PERFORMANCE SUMMARY
-- ============================================================

WITH seller_summary AS (
    SELECT
        COUNT(DISTINCT seller_id) AS total_sellers,
        COUNT(DISTINCT order_id) AS seller_orders,
        COUNT(*) AS units_sold,
        SUM(price) AS seller_revenue
    FROM olist_order_items_dataset
),

customer_summary AS (
    SELECT
        COUNT(DISTINCT c.customer_unique_id) AS total_customers,
        COUNT(DISTINCT o.order_id) AS customer_orders,
        SUM(op.payment_value) AS customer_revenue
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset op
        ON o.order_id = op.order_id
)

SELECT
    ss.total_sellers,
    ss.seller_orders,
    ss.units_sold,
    ROUND(ss.seller_revenue::numeric, 2) AS seller_revenue,
    cs.total_customers,
    cs.customer_orders,
    ROUND(cs.customer_revenue::numeric, 2) AS customer_revenue,
    ROUND(
        (
            cs.customer_revenue /
            NULLIF(cs.total_customers, 0)
        )::numeric,
        2
    ) AS avg_customer_value
FROM seller_summary ss
CROSS JOIN customer_summary cs;