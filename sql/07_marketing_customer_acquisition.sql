-- ============================================================
-- 07 MARKETING & CUSTOMER ACQUISITION ANALYSIS
-- ============================================================


-- 1. CUSTOMERS BY STATE

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY customers DESC;


-- 2. CUSTOMERS BY CITY

SELECT
    customer_city,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM olist_customers_dataset
GROUP BY customer_city
ORDER BY customers DESC
LIMIT 25;


-- 3. ORDERS BY CUSTOMER STATE

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(
        COUNT(DISTINCT o.order_id)::numeric /
        NULLIF(COUNT(DISTINCT c.customer_unique_id), 0),
        2
    ) AS orders_per_customer
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- 4. REVENUE BY CUSTOMER STATE

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue,
    ROUND(
        (
            SUM(p.payment_value) /
            NULLIF(COUNT(DISTINCT c.customer_unique_id), 0)
        )::numeric,
        2
    ) AS revenue_per_customer
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- 5. TOP CUSTOMER CITIES BY REVENUE

SELECT
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY
    c.customer_city,
    c.customer_state
ORDER BY revenue DESC
LIMIT 25;


-- 6. NEW VS RETURNING CUSTOMERS

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'New / One-time Customer'
        ELSE 'Returning Customer'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM customer_orders
GROUP BY 1
ORDER BY customers DESC;


-- 7. CUSTOMER ACQUISITION BY MONTH

SELECT
    DATE_TRUNC(
        'month',
        NULLIF(o.order_purchase_timestamp, '')::timestamp
    )::date AS acquisition_month,
    COUNT(DISTINCT c.customer_unique_id) AS new_customers
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- 8. MONTHLY NEW CUSTOMER REVENUE

WITH first_orders AS (
    SELECT
        c.customer_unique_id,
        MIN(
            NULLIF(o.order_purchase_timestamp, '')::timestamp
        ) AS first_order_date
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    DATE_TRUNC('month', f.first_order_date)::date AS acquisition_month,
    COUNT(DISTINCT f.customer_unique_id) AS new_customers,
    ROUND(
        SUM(p.payment_value)::numeric,
        2
    ) AS acquisition_revenue
FROM first_orders f
JOIN olist_customers_dataset c
    ON f.customer_unique_id = c.customer_unique_id
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
WHERE DATE_TRUNC('month', f.first_order_date)
      = DATE_TRUNC(
            'month',
            NULLIF(o.order_purchase_timestamp, '')::timestamp
        )
GROUP BY 1
ORDER BY 1;


-- 9. TOP CUSTOMERS BY TOTAL SPENDING

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_spending
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC
LIMIT 25;


-- 10. TOP CUSTOMERS BY ORDER FREQUENCY

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_spending
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC, total_spending DESC
LIMIT 25;


-- 11. CUSTOMER LIFETIME VALUE

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS lifetime_value,
    ROUND(
        (
            SUM(p.payment_value) /
            COUNT(DISTINCT o.order_id)
        )::numeric,
        2
    ) AS average_order_value
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY lifetime_value DESC
LIMIT 25;


-- 12. CUSTOMER RETENTION BY STATE

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT CASE
        WHEN customer_order_count.order_count > 1
        THEN c.customer_unique_id
    END) AS returning_customers,
    ROUND(
        (
            COUNT(DISTINCT CASE
                WHEN customer_order_count.order_count > 1
                THEN c.customer_unique_id
            END) * 100.0
            /
            NULLIF(COUNT(DISTINCT c.customer_unique_id), 0)
        )::numeric,
        2
    ) AS retention_percentage
FROM olist_customers_dataset c
JOIN (
    SELECT
        c2.customer_unique_id,
        COUNT(DISTINCT o2.order_id) AS order_count
    FROM olist_customers_dataset c2
    JOIN olist_orders_dataset o2
        ON c2.customer_id = o2.customer_id
    GROUP BY c2.customer_unique_id
) customer_order_count
    ON c.customer_unique_id = customer_order_count.customer_unique_id
GROUP BY c.customer_state
ORDER BY retention_percentage DESC;


-- 13. CUSTOMER ORDER FREQUENCY DISTRIBUTION

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    order_count,
    COUNT(*) AS customers
FROM customer_orders
GROUP BY order_count
ORDER BY order_count;


-- 14. HIGH-VALUE CUSTOMERS

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spending
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_spending >= 1000 THEN 'High Value'
        WHEN total_spending >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(total_spending)::numeric, 2) AS total_revenue,
    ROUND(AVG(total_spending)::numeric, 2) AS avg_customer_value
FROM customer_spending
GROUP BY 1
ORDER BY total_revenue DESC;


-- 15. FINAL CUSTOMER ACQUISITION SUMMARY

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(p.payment_value) AS spending
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE order_count = 1) AS one_time_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS returning_customers,
    ROUND(AVG(order_count)::numeric, 2) AS avg_orders_per_customer,
    ROUND(AVG(spending)::numeric, 2) AS avg_customer_value,
    ROUND(MAX(spending)::numeric, 2) AS highest_customer_value
FROM customer_orders;