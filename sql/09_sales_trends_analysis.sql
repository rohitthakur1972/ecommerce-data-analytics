-- ============================================================
-- 09 SALES & ORDER TRENDS ANALYSIS
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- ============================================================


-- ============================================================
-- 1. MONTHLY ORDER TREND
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        NULLIF(order_purchase_timestamp, '')::timestamp
    )::date AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 2. MONTHLY REVENUE TREND
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        NULLIF(o.order_purchase_timestamp, '')::timestamp
    )::date AS month,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 3. MONTHLY ORDERS + REVENUE
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        NULLIF(o.order_purchase_timestamp, '')::timestamp
    )::date AS month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(p.payment_value)::numeric,
        2
    ) AS revenue,

    ROUND(
        (
            SUM(p.payment_value)
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value

FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id

GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 4. YEARLY SALES PERFORMANCE
-- ============================================================

SELECT
    EXTRACT(
        YEAR FROM NULLIF(o.order_purchase_timestamp, '')::timestamp
    ) AS year,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(p.payment_value)::numeric,
        2
    ) AS total_revenue,

    ROUND(
        (
            SUM(p.payment_value)
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value

FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id

GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 5. DAY OF WEEK ORDER PATTERN
-- ============================================================

SELECT
    TO_CHAR(
        NULLIF(order_purchase_timestamp, '')::timestamp,
        'Day'
    ) AS day_of_week,

    EXTRACT(
        ISODOW FROM NULLIF(order_purchase_timestamp, '')::timestamp
    ) AS day_number,

    COUNT(DISTINCT order_id) AS total_orders

FROM olist_orders_dataset

GROUP BY 1, 2
ORDER BY day_number;


-- ============================================================
-- 6. MONTHLY ORDER GROWTH
-- ============================================================

WITH monthly_orders AS (
    SELECT
        DATE_TRUNC(
            'month',
            NULLIF(order_purchase_timestamp, '')::timestamp
        )::date AS month,

        COUNT(DISTINCT order_id) AS total_orders

    FROM olist_orders_dataset
    GROUP BY 1
)

SELECT
    month,
    total_orders,

    LAG(total_orders) OVER (
        ORDER BY month
    ) AS previous_month_orders,

    ROUND(
        (
            (
                total_orders
                - LAG(total_orders) OVER (ORDER BY month)
            ) * 100.0
            / NULLIF(
                LAG(total_orders) OVER (ORDER BY month),
                0
            )
        )::numeric,
        2
    ) AS growth_percentage

FROM monthly_orders
ORDER BY month;


-- ============================================================
-- 7. MONTHLY REVENUE GROWTH
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC(
            'month',
            NULLIF(o.order_purchase_timestamp, '')::timestamp
        )::date AS month,

        SUM(p.payment_value) AS revenue

    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id

    GROUP BY 1
)

SELECT
    month,

    ROUND(revenue::numeric, 2) AS revenue,

    ROUND(
        LAG(revenue) OVER (
            ORDER BY month
        )::numeric,
        2
    ) AS previous_month_revenue,

    ROUND(
        (
            (
                revenue
                - LAG(revenue) OVER (ORDER BY month)
            ) * 100.0
            / NULLIF(
                LAG(revenue) OVER (ORDER BY month),
                0
            )
        )::numeric,
        2
    ) AS revenue_growth_percentage

FROM monthly_revenue
ORDER BY month;


-- ============================================================
-- 8. PEAK ORDER HOURS
-- ============================================================

SELECT
    EXTRACT(
        HOUR FROM NULLIF(order_purchase_timestamp, '')::timestamp
    ) AS order_hour,

    COUNT(DISTINCT order_id) AS total_orders

FROM olist_orders_dataset

GROUP BY 1
ORDER BY total_orders DESC;


-- ============================================================
-- 9. PEAK ORDER DAYS
-- ============================================================

SELECT
    TO_CHAR(
        NULLIF(order_purchase_timestamp, '')::timestamp,
        'Day'
    ) AS day_of_week,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        (
            COUNT(DISTINCT order_id) * 100.0
            / SUM(COUNT(DISTINCT order_id)) OVER ()
        )::numeric,
        2
    ) AS order_percentage

FROM olist_orders_dataset

GROUP BY 1
ORDER BY total_orders DESC;


-- ============================================================
-- 10. HIGHEST REVENUE MONTHS
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        NULLIF(o.order_purchase_timestamp, '')::timestamp
    )::date AS month,

    ROUND(
        SUM(p.payment_value)::numeric,
        2
    ) AS revenue

FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id

GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 11. HIGHEST ORDER VOLUME MONTHS
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        NULLIF(order_purchase_timestamp, '')::timestamp
    )::date AS month,

    COUNT(DISTINCT order_id) AS total_orders

FROM olist_orders_dataset

GROUP BY 1
ORDER BY total_orders DESC
LIMIT 10;


-- ============================================================
-- 12. FINAL SALES TREND SUMMARY
-- ============================================================

SELECT

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(p.payment_value)::numeric,
        2
    ) AS total_revenue,

    ROUND(
        (
            SUM(p.payment_value)
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value,

    MIN(
        NULLIF(o.order_purchase_timestamp, '')::timestamp
    )::date AS first_order_date,

    MAX(
        NULLIF(o.order_purchase_timestamp, '')::timestamp
    )::date AS last_order_date

FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id;