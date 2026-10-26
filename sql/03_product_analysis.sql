-- ============================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- 03 - PRODUCT ANALYSIS
-- ============================================================


-- ============================================================
-- 1. TOTAL NUMBER OF PRODUCTS
-- ============================================================

SELECT 
    COUNT(*) AS total_products
FROM olist_products_dataset;


-- ============================================================
-- 2. PRODUCTS BY CATEGORY
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    COUNT(*) AS total_products
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY total_products DESC;


-- ============================================================
-- 3. TOP PRODUCT CATEGORIES BY NUMBER OF ORDERS
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY total_orders DESC
LIMIT 15;


-- ============================================================
-- 4. TOP PRODUCT CATEGORIES BY QUANTITY SOLD
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    COUNT(*) AS units_sold
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY units_sold DESC
LIMIT 15;


-- ============================================================
-- 5. TOP PRODUCT CATEGORIES BY REVENUE
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY total_revenue DESC
LIMIT 15;


-- ============================================================
-- 6. AVERAGE PRODUCT PRICE BY CATEGORY
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    ROUND(AVG(oi.price)::numeric, 2) AS average_price
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
HAVING COUNT(*) >= 20
ORDER BY average_price DESC
LIMIT 20;


-- ============================================================
-- 7. MOST EXPENSIVE PRODUCT CATEGORIES
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    ROUND(MAX(oi.price)::numeric, 2) AS highest_product_price
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY highest_product_price DESC
LIMIT 15;


-- ============================================================
-- 8. TOP 20 PRODUCTS BY NUMBER OF SALES
-- ============================================================

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue
FROM olist_order_items_dataset oi
GROUP BY oi.product_id
ORDER BY units_sold DESC
LIMIT 20;


-- ============================================================
-- 9. TOP 20 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
GROUP BY oi.product_id
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================
-- 10. PRODUCT CATEGORY + AVERAGE FREIGHT COST
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    ROUND(AVG(oi.freight_value)::numeric, 2) AS average_freight_cost
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
HAVING COUNT(*) >= 20
ORDER BY average_freight_cost DESC
LIMIT 20;


-- ============================================================
-- 11. PRODUCT CATEGORIES WITH HIGHEST TOTAL FREIGHT COST
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS total_freight_cost
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY total_freight_cost DESC
LIMIT 15;


-- ============================================================
-- 12. PRODUCT CATEGORY SALES PERFORMANCE
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price)::numeric, 2) AS product_revenue,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS freight_revenue,
    ROUND((SUM(oi.price) + SUM(oi.freight_value))::numeric, 2)
        AS total_value
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY total_value DESC
LIMIT 20;


-- ============================================================
-- 13. PRODUCT CATEGORY BY AVERAGE CUSTOMER REVIEW SCORE
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    ROUND(AVG(r.review_score)::numeric, 2) AS average_review_score,
    COUNT(r.review_id) AS total_reviews
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
JOIN olist_order_reviews_dataset r
    ON oi.order_id = r.order_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
HAVING COUNT(r.review_id) >= 20
ORDER BY average_review_score DESC;


-- ============================================================
-- 14. LOW-RATED PRODUCT CATEGORIES
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    ROUND(AVG(r.review_score)::numeric, 2) AS average_review_score,
    COUNT(r.review_id) AS total_reviews
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
JOIN olist_order_reviews_dataset r
    ON oi.order_id = r.order_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
HAVING COUNT(r.review_id) >= 20
ORDER BY average_review_score ASC
LIMIT 15;


-- ============================================================
-- 15. PRODUCT SIZE VS FREIGHT COST
-- ============================================================

SELECT
    CASE
        WHEN p.product_weight_g < 1000 THEN 'Under 1 kg'
        WHEN p.product_weight_g < 3000 THEN '1-3 kg'
        WHEN p.product_weight_g < 5000 THEN '3-5 kg'
        ELSE '5+ kg'
    END AS weight_category,
    COUNT(*) AS products_sold,
    ROUND(AVG(oi.freight_value)::numeric, 2) AS average_freight,
    ROUND(AVG(oi.price)::numeric, 2) AS average_price
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE p.product_weight_g IS NOT NULL
GROUP BY
    CASE
        WHEN p.product_weight_g < 1000 THEN 'Under 1 kg'
        WHEN p.product_weight_g < 3000 THEN '1-3 kg'
        WHEN p.product_weight_g < 5000 THEN '3-5 kg'
        ELSE '5+ kg'
    END
ORDER BY average_freight DESC;


-- ============================================================
-- 16. PRODUCT CATEGORY REVENUE SHARE
-- ============================================================

WITH category_revenue AS (
    SELECT
        COALESCE(pt.product_category_name_english, 
                 p.product_category_name, 
                 'Unknown') AS product_category,
        SUM(oi.price) AS revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation pt
        ON p.product_category_name = pt.product_category_name
    GROUP BY
        COALESCE(pt.product_category_name_english, 
                 p.product_category_name, 
                 'Unknown')
)

SELECT
    product_category,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (revenue / SUM(revenue) OVER () * 100)::numeric,
        2
    ) AS revenue_percentage
FROM category_revenue
ORDER BY revenue DESC
LIMIT 20;


-- ============================================================
-- 17. PRODUCTS WITH HIGH SALES AND HIGH REVENUE
-- ============================================================

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS average_price
FROM olist_order_items_dataset oi
GROUP BY oi.product_id
HAVING COUNT(*) >= 50
ORDER BY revenue DESC
LIMIT 20;


-- ============================================================
-- 18. PRODUCT CATEGORIES WITH LARGE PRODUCT VARIETY
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    COUNT(DISTINCT p.product_id) AS unique_products
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY unique_products DESC
LIMIT 20;


-- ============================================================
-- 19. CATEGORY: REVENUE VS ORDERS
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue,
    ROUND(
        (SUM(oi.price) / COUNT(DISTINCT oi.order_id))::numeric,
        2
    ) AS revenue_per_order
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
HAVING COUNT(DISTINCT oi.order_id) >= 20
ORDER BY revenue_per_order DESC
LIMIT 20;


-- ============================================================
-- 20. FINAL PRODUCT PERFORMANCE SUMMARY
-- ============================================================

SELECT
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown') AS product_category,
    COUNT(DISTINCT p.product_id) AS unique_products,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_price,
    ROUND(AVG(oi.freight_value)::numeric, 2) AS avg_freight
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY
    COALESCE(pt.product_category_name_english, 
             p.product_category_name, 
             'Unknown')
ORDER BY revenue DESC
LIMIT 25;


-- ============================================================
-- END OF PRODUCT ANALYSIS
-- ============================================================