-- ============================================================
-- 06 PAYMENT & REVENUE ANALYSIS
-- ============================================================


-- 1. TOTAL REVENUE

SELECT
    ROUND(SUM(payment_value)::numeric, 2) AS total_revenue
FROM olist_order_payments_dataset;


-- 2. REVENUE BY PAYMENT TYPE

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value)::numeric, 2) AS revenue,
    ROUND(
        (
            SUM(payment_value) * 100.0 /
            SUM(SUM(payment_value)) OVER ()
        )::numeric,
        2
    ) AS revenue_percentage
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY revenue DESC;


-- 3. AVERAGE PAYMENT VALUE BY PAYMENT TYPE

SELECT
    payment_type,
    COUNT(*) AS transactions,
    ROUND(AVG(payment_value)::numeric, 2) AS avg_payment_value,
    ROUND(MIN(payment_value)::numeric, 2) AS min_payment,
    ROUND(MAX(payment_value)::numeric, 2) AS max_payment
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY avg_payment_value DESC;


-- 4. PAYMENT INSTALLMENT ANALYSIS

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value)::numeric, 2) AS revenue,
    ROUND(AVG(payment_value)::numeric, 2) AS avg_payment
FROM olist_order_payments_dataset
GROUP BY payment_installments
ORDER BY payment_installments;


-- 5. REVENUE BY NUMBER OF INSTALLMENTS

SELECT
    payment_installments,
    ROUND(SUM(payment_value)::numeric, 2) AS total_revenue,
    ROUND(
        (
            SUM(payment_value) * 100.0 /
            SUM(SUM(payment_value)) OVER ()
        )::numeric,
        2
    ) AS revenue_percentage
FROM olist_order_payments_dataset
GROUP BY payment_installments
ORDER BY total_revenue DESC;


-- 6. MONTHLY REVENUE

SELECT
    DATE_TRUNC(
        'month',
        NULLIF(o.order_purchase_timestamp, '')::timestamp
    )::date AS month,
    COUNT(DISTINCT p.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue,
    ROUND(AVG(p.payment_value)::numeric, 2) AS avg_order_value
FROM olist_order_payments_dataset p
JOIN olist_orders_dataset o
    ON p.order_id = o.order_id
GROUP BY 1
ORDER BY 1;


-- 7. MONTH-OVER-MONTH REVENUE GROWTH

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC(
            'month',
            NULLIF(o.order_purchase_timestamp, '')::timestamp
        )::date AS month,
        SUM(p.payment_value) AS revenue
    FROM olist_order_payments_dataset p
    JOIN olist_orders_dataset o
        ON p.order_id = o.order_id
    GROUP BY 1
)

SELECT
    month,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (
            (revenue - LAG(revenue) OVER (ORDER BY month))
            * 100.0
            / NULLIF(LAG(revenue) OVER (ORDER BY month), 0)
        )::numeric,
        2
    ) AS revenue_growth_percentage
FROM monthly_revenue
ORDER BY month;


-- 8. AVERAGE ORDER VALUE

SELECT
    ROUND(
        (
            SUM(payment_value) /
            COUNT(DISTINCT order_id)
        )::numeric,
        2
    ) AS average_order_value
FROM olist_order_payments_dataset;


-- 9. TOP ORDERS BY PAYMENT VALUE

SELECT
    order_id,
    ROUND(SUM(payment_value)::numeric, 2) AS order_value
FROM olist_order_payments_dataset
GROUP BY order_id
ORDER BY order_value DESC
LIMIT 25;


-- 10. PAYMENT TYPE + INSTALLMENT ANALYSIS

SELECT
    payment_type,
    payment_installments,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value)::numeric, 2) AS revenue
FROM olist_order_payments_dataset
GROUP BY
    payment_type,
    payment_installments
ORDER BY revenue DESC;


-- 11. REVENUE BY ORDER STATUS

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue,
    ROUND(AVG(p.payment_value)::numeric, 2) AS avg_order_value
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY o.order_status
ORDER BY revenue DESC;


-- 12. DELIVERED VS CANCELLED REVENUE

SELECT
    CASE
        WHEN o.order_status = 'delivered' THEN 'Delivered'
        WHEN o.order_status = 'canceled' THEN 'Cancelled'
        ELSE 'Other'
    END AS order_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY 1
ORDER BY revenue DESC;


-- 13. HIGHEST REVENUE PAYMENT TYPE

SELECT
    payment_type,
    ROUND(SUM(payment_value)::numeric, 2) AS total_revenue
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_revenue DESC
LIMIT 1;


-- 14. PAYMENT TYPE MARKET SHARE

WITH payment_revenue AS (
    SELECT
        payment_type,
        SUM(payment_value) AS revenue
    FROM olist_order_payments_dataset
    GROUP BY payment_type
)

SELECT
    payment_type,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (revenue * 100.0 / SUM(revenue) OVER ())::numeric,
        2
    ) AS market_share_percentage
FROM payment_revenue
ORDER BY revenue DESC;


-- 15. FINAL PAYMENT & REVENUE SUMMARY

SELECT
    COUNT(DISTINCT p.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue,
    ROUND(
        (
            SUM(p.payment_value) /
            COUNT(DISTINCT p.order_id)
        )::numeric,
        2
    ) AS average_order_value,
    COUNT(DISTINCT p.payment_type) AS payment_methods,
    ROUND(AVG(p.payment_installments)::numeric, 2) AS avg_installments
FROM olist_order_payments_dataset p;