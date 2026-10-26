-- ============================================================
-- 11 PRODUCT PERFORMANCE & CATEGORY REVENUE ANALYSIS
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- ============================================================


-- ============================================================
-- 1. TOP 25 PRODUCTS BY UNITS SOLD
-- ============================================================

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS product_revenue
FROM olist_order_items_dataset oi
GROUP BY oi.product_id
ORDER BY units_sold DESC
LIMIT 25;


-- ============================================================
-- 2. TOP 25 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS product_revenue
FROM olist_order_items_dataset oi
GROUP BY oi.product_id
ORDER BY product_revenue DESC
LIMIT 25;


-- ============================================================
-- 3. PRODUCT CATEGORY PERFORMANCE
-- ============================================================

SELECT
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC
LIMIT 25;


-- ============================================================
-- 4. TOP 10 CATEGORIES BY UNITS SOLD
-- ============================================================

SELECT
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS units_sold
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY units_sold DESC
LIMIT 10;


-- ============================================================
-- 5. TOP 10 CATEGORIES BY REVENUE
-- ============================================================

SELECT
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- 6. CATEGORY AVERAGE PRODUCT PRICE
-- ============================================================

SELECT
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS units_sold,
    ROUND(AVG(oi.price)::numeric, 2) AS average_product_price,
    ROUND(MIN(oi.price)::numeric, 2) AS minimum_price,
    ROUND(MAX(oi.price)::numeric, 2) AS maximum_price
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
HAVING COUNT(*) >= 50
ORDER BY average_product_price DESC
LIMIT 25;


-- ============================================================
-- 7. TOP PRODUCTS WITH CATEGORY
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    oi.product_id,
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC
LIMIT 25;


-- ============================================================
-- 8. CATEGORY REVENUE SHARE
-- ============================================================

WITH category_revenue AS (
    SELECT
        COALESCE(
            pt.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS product_category,
        SUM(oi.price) AS revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation pt
        ON p.product_category_name = pt.product_category_name
    GROUP BY
        COALESCE(
            pt.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)

SELECT
    product_category,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (
            revenue /
            NULLIF(SUM(revenue) OVER (), 0)
            * 100
        )::numeric,
        2
    ) AS revenue_share_percentage
FROM category_revenue
ORDER BY revenue DESC
LIMIT 25;


-- ============================================================
-- 9. PRODUCT PRICE SEGMENTATION
-- ============================================================

SELECT
    CASE
        WHEN price < 50 THEN 'Under 50'
        WHEN price < 100 THEN '50 - 99'
        WHEN price < 250 THEN '100 - 249'
        WHEN price < 500 THEN '250 - 499'
        WHEN price < 1000 THEN '500 - 999'
        ELSE '1000+'
    END AS price_segment,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price)::numeric, 2) AS revenue,
    ROUND(AVG(price)::numeric, 2) AS average_price
FROM olist_order_items_dataset
GROUP BY
    CASE
        WHEN price < 50 THEN 'Under 50'
        WHEN price < 100 THEN '50 - 99'
        WHEN price < 250 THEN '100 - 249'
        WHEN price < 500 THEN '250 - 499'
        WHEN price < 1000 THEN '500 - 999'
        ELSE '1000+'
    END
ORDER BY
    CASE
        WHEN MIN(price) < 50 THEN 1
        WHEN MIN(price) < 100 THEN 2
        WHEN MIN(price) < 250 THEN 3
        WHEN MIN(price) < 500 THEN 4
        WHEN MIN(price) < 1000 THEN 5
        ELSE 6
    END;

-- ============================================================
-- 10. PRODUCTS WITH HIGH SALES VOLUME
-- ============================================================

SELECT
    product_id,
    COUNT(*) AS units_sold,
    ROUND(SUM(price)::numeric, 2) AS revenue,
    ROUND(AVG(price)::numeric, 2) AS average_price
FROM olist_order_items_dataset
GROUP BY product_id
HAVING COUNT(*) >= 100
ORDER BY units_sold DESC;


-- ============================================================
-- 11. PRODUCTS WITH HIGH REVENUE BUT LOWER VOLUME
-- ============================================================

SELECT
    product_id,
    COUNT(*) AS units_sold,
    ROUND(SUM(price)::numeric, 2) AS revenue,
    ROUND(AVG(price)::numeric, 2) AS average_price
FROM olist_order_items_dataset
GROUP BY product_id
HAVING COUNT(*) BETWEEN 10 AND 100
ORDER BY revenue DESC
LIMIT 25;


-- ============================================================
-- 12. FINAL PRODUCT PERFORMANCE SUMMARY
-- ============================================================

WITH category_summary AS (
    SELECT
        COALESCE(
            pt.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS product_category,
        COUNT(DISTINCT oi.product_id) AS unique_products,
        COUNT(*) AS units_sold,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS revenue,
        AVG(oi.price) AS average_price
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation pt
        ON p.product_category_name = pt.product_category_name
    GROUP BY
        COALESCE(
            pt.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)

SELECT
    product_category,
    unique_products,
    units_sold,
    total_orders,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(average_price::numeric, 2) AS average_price
FROM category_summary
ORDER BY revenue DESC;