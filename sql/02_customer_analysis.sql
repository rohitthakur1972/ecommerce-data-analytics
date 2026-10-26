-- =========================================================
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- 02 - CUSTOMER ANALYSIS
-- =========================================================


-- =========================================================
-- 1. Total Unique Customers
-- =========================================================

SELECT
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM olist_customers_dataset;


-- =========================================================
-- 2. Customers by State
-- =========================================================

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;


-- =========================================================
-- 3. Customers by City
-- =========================================================

SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset
GROUP BY
    customer_city,
    customer_state
ORDER BY total_customers DESC
LIMIT 20;


-- =========================================================
-- 4. Orders per Customer
-- =========================================================

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 20;


-- =========================================================
-- 5. Repeat Customers
-- =========================================================

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        c.customer_unique_id
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) AS repeat_customer_list;


-- =========================================================
-- 6. One-Time Customers
-- =========================================================

SELECT
    COUNT(*) AS one_time_customers
FROM (
    SELECT
        c.customer_unique_id
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) = 1
) AS one_time_customer_list;


-- =========================================================
-- 7. Repeat Customer Percentage
-- =========================================================

SELECT
    ROUND(
        100.0 *
        COUNT(*) FILTER (WHERE total_orders > 1)
        / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;


-- =========================================================
-- 8. Average Orders per Customer
-- =========================================================

SELECT
    ROUND(
        AVG(total_orders)::numeric,
        2
    ) AS average_orders_per_customer
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;


-- =========================================================
-- 9. Top Customers by Total Spending
-- =========================================================

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
LIMIT 20;


-- =========================================================
-- 10. Average Customer Spending
-- =========================================================

SELECT
    ROUND(
        AVG(total_spending)::numeric,
        2
    ) AS average_customer_spending
FROM (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spending
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
) AS customer_spending;


-- =========================================================
-- 11. Customer Lifetime Value - Top 20
-- =========================================================

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS lifetime_value
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY lifetime_value DESC
LIMIT 20;


-- =========================================================
-- 12. Revenue by Customer State
-- =========================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.payment_value)::numeric, 2) AS revenue
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- =========================================================
-- 13. Average Spending by Customer State
-- =========================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(
        SUM(p.payment_value)::numeric
        / COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS average_spending_per_customer
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY average_spending_per_customer DESC;


-- =========================================================
-- 14. Customer Order Frequency Distribution
-- =========================================================

SELECT
    total_orders,
    COUNT(*) AS number_of_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders
GROUP BY total_orders
ORDER BY total_orders;


-- =========================================================
-- 15. Customers with 3+ Orders
-- =========================================================

SELECT
    COUNT(*) AS customers_with_3_or_more_orders
FROM (
    SELECT
        c.customer_unique_id
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) >= 3
) AS frequent_customers;


-- =========================================================
-- 16. Customer Acquisition by Year
-- =========================================================

SELECT
    EXTRACT(
        YEAR FROM MIN(o.order_purchase_timestamp::timestamp)
    ) AS acquisition_year,
    COUNT(*) AS new_customers
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY acquisition_year;


-- =========================================================
-- 17. Monthly New Customers
-- =========================================================

SELECT
    DATE_TRUNC(
        'month',
        MIN(o.order_purchase_timestamp::timestamp)
    ) AS acquisition_month,
    COUNT(*) AS new_customers
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY acquisition_month;


-- =========================================================
-- 18. Top 20 Customer Cities by Revenue
-- =========================================================

SELECT
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
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
LIMIT 20;


-- =========================================================
-- 19. Highest Spending Customer by State
-- =========================================================

WITH customer_spending AS (
    SELECT
        c.customer_state,
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spending
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    GROUP BY
        c.customer_state,
        c.customer_unique_id
),
ranked_customers AS (
    SELECT
        customer_state,
        customer_unique_id,
        total_spending,
        RANK() OVER (
            PARTITION BY customer_state
            ORDER BY total_spending DESC
        ) AS customer_rank
    FROM customer_spending
)
SELECT
    customer_state,
    customer_unique_id,
    ROUND(total_spending::numeric, 2) AS total_spending
FROM ranked_customers
WHERE customer_rank = 1
ORDER BY total_spending DESC;


-- =========================================================
-- 20. Customer Segmentation by Order Frequency
-- =========================================================

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        WHEN total_orders BETWEEN 2 AND 3 THEN 'Repeat Customer'
        WHEN total_orders >= 4 THEN 'Loyal Customer'
    END AS customer_segment,
    COUNT(*) AS customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders
GROUP BY customer_segment
ORDER BY customers DESC;