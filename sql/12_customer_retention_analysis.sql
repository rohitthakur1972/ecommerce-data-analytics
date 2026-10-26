-- ============================================================
-- 12 CUSTOMER RETENTION & COHORT ANALYSIS
-- ============================================================

-- 1. CUSTOMER COHORT MONTH
WITH customer_first_order AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC(
            'month',
            MIN(NULLIF(o.order_purchase_timestamp, '')::timestamp)
        ) AS cohort_month
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
    GROUP BY c.customer_unique_id
)
SELECT
    cohort_month,
    COUNT(*) AS customers
FROM customer_first_order
GROUP BY cohort_month
ORDER BY cohort_month;


-- 2. MONTHLY ACTIVE CUSTOMERS
SELECT
    DATE_TRUNC(
        'month',
        NULLIF(o.order_purchase_timestamp, '')::timestamp
    ) AS month,
    COUNT(DISTINCT c.customer_unique_id) AS active_customers
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
WHERE NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- 3. NEW VS RETURNING CUSTOMERS
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        DATE_TRUNC(
            'month',
            NULLIF(o.order_purchase_timestamp, '')::timestamp
        ) AS order_month,
        MIN(
            DATE_TRUNC(
                'month',
                NULLIF(o.order_purchase_timestamp, '')::timestamp
            )
        ) OVER (
            PARTITION BY c.customer_unique_id
        ) AS first_order_month
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    WHERE NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
)
SELECT
    order_month,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    COUNT(DISTINCT CASE
        WHEN order_month = first_order_month
        THEN customer_unique_id
    END) AS new_customers,
    COUNT(DISTINCT CASE
        WHEN order_month > first_order_month
        THEN customer_unique_id
    END) AS returning_customers
FROM customer_orders
GROUP BY order_month
ORDER BY order_month;


-- 4. REPEAT PURCHASE RATE
WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE order_count >= 2
    ) AS repeat_customers,
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE order_count >= 2
            )::numeric
            / NULLIF(COUNT(*), 0)
        ) * 100,
        2
    ) AS repeat_customer_percentage
FROM customer_order_counts;


-- ============================================================
-- 5. CUSTOMER ORDER FREQUENCY
-- ============================================================

WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
frequency AS (
    SELECT
        CASE
            WHEN order_count = 1 THEN '1 Order'
            WHEN order_count = 2 THEN '2 Orders'
            WHEN order_count = 3 THEN '3 Orders'
            WHEN order_count >= 4 THEN '4+ Orders'
        END AS customer_frequency,
        COUNT(*) AS customers
    FROM customer_order_counts
    GROUP BY 1
)
SELECT
    customer_frequency,
    customers
FROM frequency
ORDER BY
    CASE customer_frequency
        WHEN '1 Order' THEN 1
        WHEN '2 Orders' THEN 2
        WHEN '3 Orders' THEN 3
        WHEN '4+ Orders' THEN 4
    END;


-- 6. CUSTOMER LIFETIME VALUE
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(op.payment_value) AS lifetime_value
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS customers,
    ROUND(AVG(lifetime_value)::numeric, 2) AS avg_customer_lifetime_value,
    ROUND(MAX(lifetime_value)::numeric, 2) AS highest_customer_lifetime_value,
    ROUND(MIN(lifetime_value)::numeric, 2) AS lowest_customer_lifetime_value,
    ROUND(AVG(total_orders)::numeric, 2) AS avg_orders_per_customer
FROM customer_revenue;


-- 7. TOP 25 CUSTOMERS BY LIFETIME VALUE
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(op.payment_value) AS lifetime_value
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
    ROUND(lifetime_value::numeric, 2) AS lifetime_value
FROM customer_revenue
ORDER BY lifetime_value DESC
LIMIT 25;


-- 8. FINAL CUSTOMER RETENTION SUMMARY
WITH customer_orders AS (
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
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE total_orders = 1
    ) AS one_time_customers,
    COUNT(*) FILTER (
        WHERE total_orders >= 2
    ) AS repeat_customers,
    ROUND(AVG(total_orders)::numeric, 2) AS avg_orders_per_customer,
    ROUND(AVG(total_spending)::numeric, 2) AS avg_customer_lifetime_value,
    ROUND(SUM(total_spending)::numeric, 2) AS total_customer_revenue
FROM customer_orders;