-- ============================================================
-- 10 GEOGRAPHIC / REGIONAL ANALYSIS
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
-- 2. CUSTOMERS BY CITY
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
-- 3. ORDERS BY STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- ============================================================
-- 4. REVENUE BY STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue,
    ROUND(
        (SUM(p.payment_value) / COUNT(DISTINCT o.order_id))::numeric,
        2
    ) AS average_order_value
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ============================================================
-- 5. TOP 10 STATES BY REVENUE
-- ============================================================

SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 6. TOP 10 CITIES BY REVENUE
-- ============================================================

SELECT
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_city, c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 7. AVERAGE ORDER VALUE BY STATE
-- ============================================================

WITH order_value AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(p.payment_value) AS order_value
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    GROUP BY o.order_id, c.customer_state
)

SELECT
    customer_state,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_value)::numeric, 2) AS average_order_value
FROM order_value
GROUP BY customer_state
ORDER BY average_order_value DESC;


-- ============================================================
-- 8. DELIVERY PERFORMANCE BY STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'delivered'
        THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        (
            COUNT(DISTINCT CASE
                WHEN o.order_status = 'delivered'
                THEN o.order_id
            END)::numeric
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        ) * 100,
        2
    ) AS delivery_rate_percentage
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY delivery_rate_percentage DESC;


-- ============================================================
-- 9. CUSTOMER DISTRIBUTION BY REGION
-- ============================================================

SELECT
    CASE
        WHEN customer_state IN
            ('AC','AP','AM','PA','RO','RR','TO')
            THEN 'North'
        WHEN customer_state IN
            ('AL','BA','CE','MA','PB','PE','PI','RN','SE')
            THEN 'Northeast'
        WHEN customer_state IN
            ('DF','GO','MT','MS')
            THEN 'Central-West'
        WHEN customer_state IN
            ('ES','MG','RJ','SP')
            THEN 'Southeast'
        WHEN customer_state IN
            ('PR','RS','SC')
            THEN 'South'
        ELSE 'Unknown'
    END AS region,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset
GROUP BY 1
ORDER BY total_customers DESC;


-- ============================================================
-- 10. REVENUE BY REGION
-- ============================================================

WITH regional_revenue AS (
    SELECT
        CASE
            WHEN c.customer_state IN
                ('AC','AP','AM','PA','RO','RR','TO')
                THEN 'North'
            WHEN c.customer_state IN
                ('AL','BA','CE','MA','PB','PE','PI','RN','SE')
                THEN 'Northeast'
            WHEN c.customer_state IN
                ('DF','GO','MT','MS')
                THEN 'Central-West'
            WHEN c.customer_state IN
                ('ES','MG','RJ','SP')
                THEN 'Southeast'
            WHEN c.customer_state IN
                ('PR','RS','SC')
                THEN 'South'
            ELSE 'Unknown'
        END AS region,
        o.order_id,
        p.payment_value
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
)

SELECT
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value)::numeric, 2) AS total_revenue,
    ROUND(
        (
            SUM(payment_value)
            / NULLIF(COUNT(DISTINCT order_id), 0)
        )::numeric,
        2
    ) AS average_order_value
FROM regional_revenue
GROUP BY region
ORDER BY total_revenue DESC;


-- ============================================================
-- 11. TOP 10 STATES BY CUSTOMER SPENDING
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue,
    ROUND(
        (
            SUM(p.payment_value)
            / NULLIF(COUNT(DISTINCT c.customer_unique_id), 0)
        )::numeric,
        2
    ) AS revenue_per_customer
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue_per_customer DESC
LIMIT 10;


-- ============================================================
-- 12. FINAL GEOGRAPHIC PERFORMANCE SUMMARY
-- ============================================================

WITH geographic_summary AS (
    SELECT
        c.customer_state,
        COUNT(DISTINCT c.customer_unique_id) AS customers,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(p.payment_value) AS revenue
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    GROUP BY c.customer_state
)

SELECT
    customer_state,
    customers,
    orders,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (revenue / NULLIF(orders, 0))::numeric,
        2
    ) AS average_order_value,
    ROUND(
        (revenue / NULLIF(customers, 0))::numeric,
        2
    ) AS revenue_per_customer
FROM geographic_summary
ORDER BY revenue DESC;