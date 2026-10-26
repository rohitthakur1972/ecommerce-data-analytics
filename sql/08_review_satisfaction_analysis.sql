-- ============================================================
-- 08 REVIEW & CUSTOMER SATISFACTION ANALYSIS
-- OLIST E-COMMERCE ANALYTICS PROJECT
-- ============================================================


-- ============================================================
-- 1. OVERALL REVIEW PERFORMANCE
-- ============================================================

SELECT
    COUNT(*) AS total_reviews,
    ROUND(AVG(review_score)::numeric, 2) AS average_review_score,
    COUNT(*) FILTER (WHERE review_score = 5) AS five_star_reviews,
    COUNT(*) FILTER (WHERE review_score = 4) AS four_star_reviews,
    COUNT(*) FILTER (WHERE review_score = 3) AS three_star_reviews,
    COUNT(*) FILTER (WHERE review_score = 2) AS two_star_reviews,
    COUNT(*) FILTER (WHERE review_score = 1) AS one_star_reviews
FROM olist_order_reviews_dataset;


-- ============================================================
-- 2. REVIEW SCORE DISTRIBUTION
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS review_percentage
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score DESC;


-- ============================================================
-- 3. POSITIVE VS NEGATIVE REVIEWS
-- ============================================================

SELECT
    CASE
        WHEN review_score >= 4 THEN 'Positive'
        WHEN review_score = 3 THEN 'Neutral'
        ELSE 'Negative'
    END AS review_category,
    COUNT(*) AS reviews,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM olist_order_reviews_dataset
GROUP BY 1
ORDER BY reviews DESC;


-- ============================================================
-- 4. AVERAGE REVIEW SCORE BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o
    ON r.order_id = o.order_id
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_review_score DESC;


-- ============================================================
-- 5. STATES WITH THE MOST NEGATIVE REVIEWS
-- ============================================================

SELECT
    c.customer_state,
    COUNT(*) AS negative_reviews,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_negative_reviews
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o
    ON r.order_id = o.order_id
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE r.review_score <= 2
GROUP BY c.customer_state
ORDER BY negative_reviews DESC
LIMIT 10;


-- ============================================================
-- 6. REVIEW SCORE BY ORDER STATUS
-- ============================================================

SELECT
    o.order_status,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o
    ON r.order_id = o.order_id
GROUP BY o.order_status
ORDER BY avg_review_score DESC;


-- ============================================================
-- 7. DELIVERY STATUS VS CUSTOMER SATISFACTION
-- ============================================================

WITH delivery_analysis AS (
    SELECT
        r.review_score,
        CASE
            WHEN o.order_delivered_customer_date IS NULL
                THEN 'Not Delivered'

            WHEN o.order_estimated_delivery_date IS NULL
                THEN 'Unknown'

            WHEN o.order_delivered_customer_date
                 <= o.order_estimated_delivery_date
                THEN 'On Time'

            ELSE 'Late'
        END AS delivery_performance
    FROM olist_order_reviews_dataset r
    JOIN olist_orders_dataset o
        ON r.order_id = o.order_id
)

SELECT
    delivery_performance,
    COUNT(*) AS reviews,
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score
FROM delivery_analysis
GROUP BY delivery_performance
ORDER BY avg_review_score DESC;


-- ============================================================
-- 8. LOW-RATED REVIEWS BY PRODUCT CATEGORY
-- ============================================================

SELECT
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS negative_reviews,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset oi
    ON r.order_id = oi.order_id
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
WHERE r.review_score <= 2
GROUP BY 1
ORDER BY negative_reviews DESC
LIMIT 20;


-- ============================================================
-- 9. TOP PRODUCT CATEGORIES BY CUSTOMER SATISFACTION
-- ============================================================

SELECT
    COALESCE(
        pt.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS total_reviews,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset oi
    ON r.order_id = oi.order_id
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name
GROUP BY 1
HAVING COUNT(*) >= 50
ORDER BY avg_review_score DESC
LIMIT 20;


-- ============================================================
-- 10. REVIEW COMMENT AVAILABILITY
-- ============================================================

SELECT
    COUNT(*) AS total_reviews,

    COUNT(*) FILTER (
        WHERE review_comment_message IS NOT NULL
        AND TRIM(review_comment_message) <> ''
    ) AS reviews_with_comments,

    COUNT(*) FILTER (
        WHERE review_comment_message IS NULL
        OR TRIM(review_comment_message) = ''
    ) AS reviews_without_comments,

    ROUND(
        COUNT(*) FILTER (
            WHERE review_comment_message IS NOT NULL
            AND TRIM(review_comment_message) <> ''
        ) * 100.0 / COUNT(*),
        2
    ) AS comment_percentage
FROM olist_order_reviews_dataset;


-- ============================================================
-- 11. REVIEW SCORE AND COMMENT PRESENCE
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS total_reviews,
    COUNT(*) FILTER (
        WHERE review_comment_message IS NOT NULL
        AND TRIM(review_comment_message) <> ''
    ) AS reviews_with_comments,
    ROUND(
        COUNT(*) FILTER (
            WHERE review_comment_message IS NOT NULL
            AND TRIM(review_comment_message) <> ''
        ) * 100.0 / COUNT(*),
        2
    ) AS comment_percentage
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score DESC;


-- ============================================================
-- 12. FINAL REVIEW & SATISFACTION SUMMARY
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
        COUNT(*) FILTER (
            WHERE review_score >= 4
        ) * 100.0 / COUNT(*),
        2
    ) AS positive_review_percentage,

    ROUND(
        COUNT(*) FILTER (
            WHERE review_score <= 2
        ) * 100.0 / COUNT(*),
        2
    ) AS negative_review_percentage,

    ROUND(
        COUNT(*) FILTER (
            WHERE review_comment_message IS NOT NULL
            AND TRIM(review_comment_message) <> ''
        ) * 100.0 / COUNT(*),
        2
    ) AS comment_percentage

FROM olist_order_reviews_dataset;