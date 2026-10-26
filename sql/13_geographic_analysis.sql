-- ============================================================
-- 13 GEOGRAPHIC / REGIONAL ANALYSIS
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS BY STATE
-- ============================================================

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;


-- ============================================================
-- 2. TOP 25 CITIES BY CUSTOMER COUNT
-- ============================================================

SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_city, customer_state
ORDER BY total_customers DESC
LIMIT 25;


-- ============================================================
-- 3. REVENUE BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(op.payment_value)::numeric, 2) AS revenue,
    ROUND(
        (
            SUM(op.payment_value)
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset op
    ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- ============================================================
-- 4. TOP 25 CITIES BY REVENUE
-- ============================================================

SELECT
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(op.payment_value)::numeric, 2) AS revenue
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset op
    ON o.order_id = op.order_id
GROUP BY c.customer_city, c.customer_state
ORDER BY revenue DESC
LIMIT 25;


-- ============================================================
-- 5. STATE-WISE AVERAGE ORDER VALUE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        (
            SUM(op.payment_value)
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset op
    ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY average_order_value DESC;


-- ============================================================
-- 6. STATE-WISE CUSTOMER REVENUE CONTRIBUTION
-- ============================================================

WITH state_revenue AS (
    SELECT
        c.customer_state,
        SUM(op.payment_value) AS revenue
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset op
        ON o.order_id = op.order_id
    GROUP BY c.customer_state
)
SELECT
    customer_state,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (
            revenue / NULLIF(SUM(revenue) OVER (), 0)
        * 100
        )::numeric,
        2
    ) AS revenue_percentage
FROM state_revenue
ORDER BY revenue DESC;


-- ============================================================
-- 7. CUSTOMER DENSITY BY STATE
-- ============================================================

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS customers,
    COUNT(DISTINCT customer_city) AS cities,
    ROUND(
        (
            COUNT(DISTINCT customer_unique_id)::numeric
            / NULLIF(COUNT(DISTINCT customer_city), 0)
        ),
        2
    ) AS customers_per_city
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY customers DESC;


-- ============================================================
-- 8. FINAL GEOGRAPHIC PERFORMANCE SUMMARY
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(op.payment_value)::numeric, 2) AS revenue,
    ROUND(
        (
            SUM(op.payment_value)
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset op
    ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;