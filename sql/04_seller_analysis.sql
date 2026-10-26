-- ============================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- 04 - SELLER ANALYSIS
-- ============================================================


-- ============================================================
-- 1. TOTAL NUMBER OF SELLERS
-- ============================================================

SELECT
    COUNT(*) AS total_sellers
FROM olist_sellers_dataset;


-- ============================================================
-- 2. SELLERS BY STATE
-- ============================================================

SELECT
    seller_state,
    COUNT(*) AS total_sellers
FROM olist_sellers_dataset
GROUP BY seller_state
ORDER BY total_sellers DESC;


-- ============================================================
-- 3. SELLERS BY CITY
-- ============================================================

SELECT
    seller_city,
    seller_state,
    COUNT(*) AS total_sellers
FROM olist_sellers_dataset
GROUP BY seller_city, seller_state
ORDER BY total_sellers DESC
LIMIT 20;


-- ============================================================
-- 4. TOP SELLERS BY NUMBER OF ORDERS
-- ============================================================

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM olist_order_items_dataset oi
GROUP BY oi.seller_id
ORDER BY total_orders DESC
LIMIT 20;


-- ============================================================
-- 5. TOP SELLERS BY UNITS SOLD
-- ============================================================

SELECT
    oi.seller_id,
    COUNT(*) AS units_sold
FROM olist_order_items_dataset oi
GROUP BY oi.seller_id
ORDER BY units_sold DESC
LIMIT 20;


-- ============================================================
-- 6. TOP SELLERS BY REVENUE
-- ============================================================

SELECT
    oi.seller_id,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================
-- 7. SELLER PERFORMANCE SUMMARY
-- ============================================================

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS average_item_price
FROM olist_order_items_dataset oi
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================
-- 8. TOP SELLERS WITH LOCATION
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================
-- 9. SELLER REVENUE BY STATE
-- ============================================================

SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS sellers,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;


-- ============================================================
-- 10. AVERAGE SELLER REVENUE BY STATE
-- ============================================================

WITH seller_revenue AS (
    SELECT
        s.seller_state,
        oi.seller_id,
        SUM(oi.price) AS revenue
    FROM olist_order_items_dataset oi
    JOIN olist_sellers_dataset s
        ON oi.seller_id = s.seller_id
    GROUP BY
        s.seller_state,
        oi.seller_id
)

SELECT
    seller_state,
    COUNT(*) AS active_sellers,
    ROUND(AVG(revenue)::numeric, 2) AS avg_seller_revenue,
    ROUND(MAX(revenue)::numeric, 2) AS highest_seller_revenue
FROM seller_revenue
GROUP BY seller_state
ORDER BY avg_seller_revenue DESC;


-- ============================================================
-- 11. SELLERS WITH HIGH ORDER VOLUME
-- ============================================================

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(price)::numeric, 2) AS revenue
FROM olist_order_items_dataset
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 100
ORDER BY total_orders DESC;


-- ============================================================
-- 12. SELLERS WITH HIGH REVENUE
-- ============================================================

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(price)::numeric, 2) AS revenue
FROM olist_order_items_dataset
GROUP BY seller_id
HAVING SUM(price) >= 100000
ORDER BY revenue DESC;


-- ============================================================
-- 13. SELLER AVERAGE ORDER VALUE
-- ============================================================

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price)::numeric, 2) AS total_revenue,
    ROUND(
        (SUM(price) / COUNT(DISTINCT order_id))::numeric,
        2
    ) AS revenue_per_order
FROM olist_order_items_dataset
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 20
ORDER BY revenue_per_order DESC
LIMIT 20;


-- ============================================================
-- 14. SELLER FREIGHT PERFORMANCE
-- ============================================================

SELECT
    seller_id,
    COUNT(*) AS units_sold,
    ROUND(AVG(freight_value)::numeric, 2) AS avg_freight_cost,
    ROUND(SUM(freight_value)::numeric, 2) AS total_freight_cost
FROM olist_order_items_dataset
GROUP BY seller_id
ORDER BY total_freight_cost DESC
LIMIT 20;


-- ============================================================
-- 15. SELLERS WITH HIGHEST FREIGHT PER ITEM
-- ============================================================

SELECT
    seller_id,
    COUNT(*) AS units_sold,
    ROUND(AVG(freight_value)::numeric, 2) AS avg_freight,
    ROUND(AVG(price)::numeric, 2) AS avg_product_price
FROM olist_order_items_dataset
GROUP BY seller_id
HAVING COUNT(*) >= 20
ORDER BY avg_freight DESC
LIMIT 20;


-- ============================================================
-- 16. SELLER REVIEW PERFORMANCE
-- ============================================================

SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score)::numeric, 2) AS average_review_score,
    COUNT(r.review_id) AS total_reviews
FROM olist_order_items_dataset oi
JOIN olist_order_reviews_dataset r
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING COUNT(r.review_id) >= 20
ORDER BY average_review_score DESC
LIMIT 20;


-- ============================================================
-- 17. LOW-RATED SELLERS
-- ============================================================

SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score)::numeric, 2) AS average_review_score,
    COUNT(r.review_id) AS total_reviews
FROM olist_order_items_dataset oi
JOIN olist_order_reviews_dataset r
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING COUNT(r.review_id) >= 20
ORDER BY average_review_score ASC
LIMIT 20;


-- ============================================================
-- 18. SELLER PERFORMANCE BY STATE
-- ============================================================

SELECT
    s.seller_state,
    COUNT(DISTINCT oi.seller_id) AS active_sellers,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC;


-- ============================================================
-- 19. SELLER REVENUE SHARE
-- ============================================================

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
)

SELECT
    seller_id,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (revenue / SUM(revenue) OVER () * 100)::numeric,
        2
    ) AS revenue_percentage
FROM seller_revenue
ORDER BY revenue DESC
LIMIT 20;


-- ============================================================
-- 20. SELLER RANKING
-- ============================================================

WITH seller_performance AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(*) AS units_sold,
        SUM(price) AS revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
)

SELECT
    seller_id,
    total_orders,
    units_sold,
    ROUND(revenue::numeric, 2) AS revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM seller_performance
ORDER BY revenue_rank
LIMIT 25;


-- ============================================================
-- 21. SELLER PERFORMANCE SEGMENTATION
-- ============================================================

WITH seller_performance AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(price) AS revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
)

SELECT
    CASE
        WHEN revenue >= 100000 THEN 'Top Seller'
        WHEN revenue >= 50000 THEN 'High Performer'
        WHEN revenue >= 10000 THEN 'Medium Performer'
        ELSE 'Low Performer'
    END AS seller_segment,
    COUNT(*) AS sellers,
    ROUND(SUM(revenue)::numeric, 2) AS total_revenue,
    ROUND(AVG(revenue)::numeric, 2) AS average_revenue
FROM seller_performance
GROUP BY
    CASE
        WHEN revenue >= 100000 THEN 'Top Seller'
        WHEN revenue >= 50000 THEN 'High Performer'
        WHEN revenue >= 10000 THEN 'Medium Performer'
        ELSE 'Low Performer'
    END
ORDER BY total_revenue DESC;


-- ============================================================
-- 22. TOP SELLERS BY REVENUE + REVIEW SCORE
-- ============================================================

WITH seller_sales AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(price) AS revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
),

seller_reviews AS (
    SELECT
        oi.seller_id,
        AVG(r.review_score) AS avg_review_score,
        COUNT(r.review_id) AS total_reviews
    FROM olist_order_items_dataset oi
    JOIN olist_order_reviews_dataset r
        ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
)

SELECT
    ss.seller_id,
    ss.total_orders,
    ROUND(ss.revenue::numeric, 2) AS revenue,
    ROUND(sr.avg_review_score::numeric, 2) AS average_review_score,
    sr.total_reviews
FROM seller_sales ss
LEFT JOIN seller_reviews sr
    ON ss.seller_id = sr.seller_id
ORDER BY ss.revenue DESC
LIMIT 25;


-- ============================================================
-- 23. SELLER LOCATION PERFORMANCE
-- ============================================================

SELECT
    s.seller_state,
    s.seller_city,
    COUNT(DISTINCT oi.seller_id) AS sellers,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY
    s.seller_state,
    s.seller_city
ORDER BY revenue DESC
LIMIT 25;


-- ============================================================
-- 24. TOP SELLER: REVENUE, ORDERS AND PRODUCTS
-- ============================================================

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_product_price
FROM olist_order_items_dataset oi
GROUP BY oi.seller_id
ORDER BY revenue DESC
LIMIT 25;


-- ============================================================
-- 25. FINAL SELLER PERFORMANCE SUMMARY
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price,
    ROUND(AVG(oi.freight_value)::numeric, 2) AS avg_freight
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 25;


-- ============================================================
-- END OF SELLER ANALYSIS
-- ============================================================