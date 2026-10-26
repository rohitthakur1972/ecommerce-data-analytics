-- =========================================================
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- 01 - BUSINESS KPIs
-- =========================================================


-- =========================================================
-- KPI 1: Total Orders
-- =========================================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset;


-- =========================================================
-- KPI 2: Total Customers
-- =========================================================

SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset;


-- =========================================================
-- KPI 3: Total Revenue
-- =========================================================

SELECT
    ROUND(SUM(payment_value)::numeric, 2) AS total_revenue
FROM olist_order_payments_dataset;


-- =========================================================
-- KPI 4: Average Order Value (AOV)
-- =========================================================

SELECT
    ROUND(
        SUM(payment_value)::numeric
        / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM olist_order_payments_dataset;


-- =========================================================
-- KPI 5: Total Products Sold
-- =========================================================

SELECT
    COUNT(*) AS total_items_sold
FROM olist_order_items_dataset;


-- =========================================================
-- KPI 6: Average Order Items
-- =========================================================

SELECT
    ROUND(
        AVG(item_count)::numeric,
        2
    ) AS avg_items_per_order
FROM (
    SELECT
        order_id,
        COUNT(*) AS item_count
    FROM olist_order_items_dataset
    GROUP BY order_id
) AS order_items;


-- =========================================================
-- KPI 7: Delivered Order Percentage
-- =========================================================

SELECT
    ROUND(
        100.0 *
        COUNT(*) FILTER (WHERE order_status = 'delivered')
        / COUNT(*),
        2
    ) AS delivered_percentage
FROM olist_orders_dataset;


-- =========================================================
-- KPI 8: Cancelled Order Percentage
-- =========================================================

SELECT
    ROUND(
        100.0 *
        COUNT(*) FILTER (WHERE order_status = 'canceled')
        / COUNT(*),
        2
    ) AS cancelled_percentage
FROM olist_orders_dataset;


-- =========================================================
-- KPI 9: Average Review Score
-- =========================================================

SELECT
    ROUND(AVG(review_score)::numeric, 2) AS average_review_score
FROM olist_order_reviews_dataset;


-- =========================================================
-- KPI 10: Total Sellers
-- =========================================================

SELECT
    COUNT(DISTINCT seller_id) AS total_sellers
FROM olist_sellers_dataset;


-- =========================================================
-- KPI 11: Total Products
-- =========================================================

SELECT
    COUNT(DISTINCT product_id) AS total_products
FROM olist_products_dataset;


-- =========================================================
-- KPI 12: Orders by Status
-- =========================================================

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- =========================================================
-- KPI 13: Revenue by Payment Type
-- =========================================================

SELECT
    payment_type,
    ROUND(SUM(payment_value)::numeric, 2) AS revenue
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY revenue DESC;


-- =========================================================
-- KPI 14: Top 10 Sellers by Revenue
-- =========================================================

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;


-- =========================================================
-- KPI 15: Revenue by State
-- =========================================================

SELECT
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;


-- =========================================================
-- KPI 16: Orders by Year
-- =========================================================

SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp::timestamp) AS year,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY year
ORDER BY year;


-- =========================================================
-- KPI 17: Revenue by Year
-- =========================================================

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp::timestamp) AS year,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY year
ORDER BY year;


-- =========================================================
-- KPI 18: Monthly Revenue
-- =========================================================

SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp::timestamp
    ) AS month,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;


-- =========================================================
-- KPI 19: Monthly Orders
-- =========================================================

SELECT
    DATE_TRUNC(
        'month',
        order_purchase_timestamp::timestamp
    ) AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY month
ORDER BY month;


-- =========================================================
-- KPI 20: Top 10 Cities by Seller Revenue
-- =========================================================

SELECT
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;