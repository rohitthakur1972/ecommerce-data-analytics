-- ============================================================
-- 15 FINAL EXECUTIVE BUSINESS SUMMARY
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- ============================================================


-- ============================================================
-- 1. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    COUNT(DISTINCT oi.product_id) AS total_products,

    COUNT(DISTINCT oi.seller_id) AS total_sellers,

    COUNT(*) AS total_items_sold,

    ROUND(SUM(op.payment_value)::numeric, 2) AS total_revenue,

    ROUND(
        (
            SUM(op.payment_value) /
            NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value

FROM olist_orders_dataset o

LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id

LEFT JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

LEFT JOIN olist_order_payments_dataset op
    ON o.order_id = op.order_id;


-- ============================================================
-- 2. ORDER STATUS PERFORMANCE
-- ============================================================

SELECT
    order_status,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        (
            COUNT(DISTINCT order_id) * 100.0 /
            SUM(COUNT(DISTINCT order_id)) OVER ()
        )::numeric,
        2
    ) AS order_percentage

FROM olist_orders_dataset

GROUP BY order_status

ORDER BY total_orders DESC;


-- ============================================================
-- 3. TOP 10 CUSTOMER STATES BY REVENUE
-- ============================================================

SELECT
    c.customer_state,

    COUNT(DISTINCT c.customer_unique_id) AS customers,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(SUM(op.payment_value)::numeric, 2) AS revenue,

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

ORDER BY revenue DESC

LIMIT 10;


-- ============================================================
-- 4. TOP 10 SELLERS BY REVENUE
-- ============================================================

SELECT
    oi.seller_id,

    s.seller_city,

    s.seller_state,

    COUNT(DISTINCT oi.order_id) AS orders,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price)::numeric, 2) AS revenue

FROM olist_order_items_dataset oi

JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY revenue DESC

LIMIT 10;


-- ============================================================
-- 5. TOP 10 PRODUCT CATEGORIES BY REVENUE
-- ============================================================

SELECT
    p.product_category_name AS product_category,

    COUNT(DISTINCT oi.product_id) AS unique_products,

    COUNT(*) AS units_sold,

    COUNT(DISTINCT oi.order_id) AS orders,

    ROUND(SUM(oi.price)::numeric, 2) AS revenue

FROM olist_order_items_dataset oi

JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

GROUP BY p.product_category_name

ORDER BY revenue DESC

LIMIT 10;


-- ============================================================
-- 6. CUSTOMER RETENTION OVERVIEW
-- ============================================================

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

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE order_count = 1
    ) AS one_time_customers,

    COUNT(*) FILTER (
        WHERE order_count > 1
    ) AS repeat_customers,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE order_count > 1
            ) * 100.0 /
            NULLIF(COUNT(*), 0)
        )::numeric,
        2
    ) AS repeat_customer_percentage,

    ROUND(
        AVG(order_count)::numeric,
        2
    ) AS average_orders_per_customer

FROM customer_orders;


-- ============================================================
-- 7. REVIEW & CUSTOMER SATISFACTION
-- ============================================================

SELECT

    COUNT(*) AS total_reviews,

    ROUND(
        AVG(review_score)::numeric,
        2
    ) AS average_review_score,

    COUNT(*) FILTER (
        WHERE review_score >= 4
    ) AS positive_reviews,

    COUNT(*) FILTER (
        WHERE review_score <= 2
    ) AS negative_reviews,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE review_score >= 4
            ) * 100.0 /
            NULLIF(COUNT(*), 0)
        )::numeric,
        2
    ) AS positive_review_percentage,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE review_score <= 2
            ) * 100.0 /
            NULLIF(COUNT(*), 0)
        )::numeric,
        2
    ) AS negative_review_percentage

FROM olist_order_reviews_dataset;


-- ============================================================
-- 8. DELIVERY PERFORMANCE
-- ============================================================

SELECT

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE order_status = 'delivered'
        AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
        AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL
        AND NULLIF(order_delivered_customer_date, '')::timestamp
            <= NULLIF(order_estimated_delivery_date, '')::timestamp
    ) AS on_time_orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE order_status = 'delivered'
        AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
        AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL
        AND NULLIF(order_delivered_customer_date, '')::timestamp
            > NULLIF(order_estimated_delivery_date, '')::timestamp
    ) AS late_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_delivered_customer_date, '')::timestamp
                    -
                    NULLIF(order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS average_delivery_days

FROM olist_orders_dataset

WHERE
    NULLIF(order_delivered_customer_date, '') IS NOT NULL
    AND NULLIF(order_purchase_timestamp, '') IS NOT NULL;


-- ============================================================
-- 9. PAYMENT METHOD ANALYSIS
-- ============================================================

SELECT

    payment_type,

    COUNT(*) AS payment_transactions,

    ROUND(
        SUM(payment_value)::numeric,
        2
    ) AS total_payment_value,

    ROUND(
        AVG(payment_value)::numeric,
        2
    ) AS average_payment_value,

    ROUND(
        (
            SUM(payment_value) * 100.0 /
            SUM(SUM(payment_value)) OVER ()
        )::numeric,
        2
    ) AS revenue_percentage

FROM olist_order_payments_dataset

GROUP BY payment_type

ORDER BY total_payment_value DESC;

-- ============================================================
-- 10. FINAL PROJECT KPI DASHBOARD
-- ============================================================

WITH business AS (

    SELECT
        COUNT(DISTINCT o.order_id) AS total_orders,

        COUNT(DISTINCT c.customer_unique_id) AS total_customers,

        COUNT(DISTINCT oi.product_id) AS total_products,

        COUNT(DISTINCT oi.seller_id) AS total_sellers,

        COUNT(*) AS total_items_sold

    FROM olist_orders_dataset o

    LEFT JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id

    LEFT JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
),

revenue AS (

    SELECT
        SUM(payment_value) AS total_revenue
    FROM olist_order_payments_dataset
),

reviews AS (

    SELECT
        AVG(review_score) AS average_review_score
    FROM olist_order_reviews_dataset
),

delivery AS (

    SELECT
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_delivered_customer_date, '')::timestamp
                    -
                    NULLIF(order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        ) AS average_delivery_days

    FROM olist_orders_dataset

    WHERE
        NULLIF(order_delivered_customer_date, '') IS NOT NULL
        AND NULLIF(order_purchase_timestamp, '') IS NOT NULL
)

SELECT

    b.total_orders,

    b.total_customers,

    b.total_products,

    b.total_sellers,

    b.total_items_sold,

    ROUND(r.total_revenue::numeric, 2)
        AS total_revenue,

    ROUND(
        (
            r.total_revenue /
            NULLIF(b.total_orders, 0)
        )::numeric,
        2
    ) AS average_order_value,

    ROUND(rv.average_review_score::numeric, 2)
        AS average_review_score,

    ROUND(d.average_delivery_days::numeric, 2)
        AS average_delivery_days

FROM business b

CROSS JOIN revenue r

CROSS JOIN reviews rv

CROSS JOIN delivery d;