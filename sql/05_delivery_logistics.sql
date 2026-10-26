-- ============================================================
-- 05 DELIVERY & LOGISTICS ANALYSIS
-- ============================================================


-- 1. Overall Order Delivery Performance

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN order_status = 'delivered'
        THEN order_id
    END) AS delivered_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN order_status = 'delivered'
            THEN order_id
        END)::numeric
        / COUNT(DISTINCT order_id) * 100,
        2
    ) AS delivery_rate_percentage
FROM olist_orders_dataset;


-- 2. Orders by Status

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- 3. Average Delivery Time

SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_delivered_customer_date, '')::timestamp
                    - NULLIF(order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_purchase_timestamp, '') IS NOT NULL;


-- 4. Average Estimated Delivery Time

SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_estimated_delivery_date, '')::timestamp
                    - NULLIF(order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_estimated_delivery_days
FROM olist_orders_dataset
WHERE NULLIF(order_estimated_delivery_date, '') IS NOT NULL
  AND NULLIF(order_purchase_timestamp, '') IS NOT NULL;


-- 5. Actual vs Estimated Delivery

SELECT
    CASE
        WHEN NULLIF(order_delivered_customer_date, '')::timestamp
             <= NULLIF(order_estimated_delivery_date, '')::timestamp
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_performance,
    COUNT(*) AS orders
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL
GROUP BY
    CASE
        WHEN NULLIF(order_delivered_customer_date, '')::timestamp
             <= NULLIF(order_estimated_delivery_date, '')::timestamp
        THEN 'On Time'
        ELSE 'Late'
    END
ORDER BY orders DESC;


-- 6. Percentage of Orders Delivered Late

SELECT
    ROUND(
        COUNT(
            CASE
                WHEN NULLIF(order_delivered_customer_date, '')::timestamp
                     > NULLIF(order_estimated_delivery_date, '')::timestamp
                THEN 1
            END
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS late_delivery_percentage
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL;


-- 7. Average Days Late

SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_delivered_customer_date, '')::timestamp
                    - NULLIF(order_estimated_delivery_date, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_days_late
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL
  AND NULLIF(order_delivered_customer_date, '')::timestamp
      > NULLIF(order_estimated_delivery_date, '')::timestamp;


-- 8. Average Delivery Time by Customer State

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(o.order_delivered_customer_date, '')::timestamp
                    - NULLIF(o.order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE NULLIF(o.order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;


-- 9. Delivery Performance by Customer State

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(
        DISTINCT CASE
            WHEN NULLIF(o.order_delivered_customer_date, '')::timestamp
                 > NULLIF(o.order_estimated_delivery_date, '')::timestamp
            THEN o.order_id
        END
    ) AS late_orders,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN NULLIF(o.order_delivered_customer_date, '')::timestamp
                     > NULLIF(o.order_estimated_delivery_date, '')::timestamp
                THEN o.order_id
            END
        )::numeric
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS late_delivery_percentage
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE NULLIF(o.order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(o.order_estimated_delivery_date, '') IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY late_delivery_percentage DESC;


-- 10. Average Shipping Preparation Time

SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_delivered_carrier_date, '')::timestamp
                    - NULLIF(order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_shipping_preparation_days
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_carrier_date, '') IS NOT NULL
  AND NULLIF(order_purchase_timestamp, '') IS NOT NULL;


-- 11. Average Carrier → Customer Delivery Time

SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_delivered_customer_date, '')::timestamp
                    - NULLIF(order_delivered_carrier_date, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_carrier_delivery_days
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_delivered_carrier_date, '') IS NOT NULL;


-- 12. Monthly Delivery Performance

SELECT
    DATE_TRUNC(
        'month',
        NULLIF(order_purchase_timestamp, '')::timestamp
    ) AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(
        DISTINCT CASE
            WHEN NULLIF(order_delivered_customer_date, '')::timestamp
                 <= NULLIF(order_estimated_delivery_date, '')::timestamp
            THEN order_id
        END
    ) AS on_time_orders,
    COUNT(
        DISTINCT CASE
            WHEN NULLIF(order_delivered_customer_date, '')::timestamp
                 > NULLIF(order_estimated_delivery_date, '')::timestamp
            THEN order_id
        END
    ) AS late_orders
FROM olist_orders_dataset
WHERE NULLIF(order_purchase_timestamp, '') IS NOT NULL
  AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_estimated_delivery_date, '') IS NOT NULL
GROUP BY month
ORDER BY month;


-- 13. Top 25 Longest Delivery Orders

SELECT
    order_id,
    ROUND(
        EXTRACT(
            EPOCH FROM (
                NULLIF(order_delivered_customer_date, '')::timestamp
                - NULLIF(order_purchase_timestamp, '')::timestamp
            )
        ) / 86400,
        2
    ) AS delivery_days
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_purchase_timestamp, '') IS NOT NULL
ORDER BY delivery_days DESC
LIMIT 25;


-- 14. Orders Over 30 Days

SELECT
    COUNT(DISTINCT order_id) AS orders_over_30_days
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(order_purchase_timestamp, '') IS NOT NULL
  AND EXTRACT(
        EPOCH FROM (
            NULLIF(order_delivered_customer_date, '')::timestamp
            - NULLIF(order_purchase_timestamp, '')::timestamp
        )
      ) / 86400 > 30;


-- 15. Orders by Status

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- 16. Orders with Missing Delivery Date

SELECT
    COUNT(*) AS orders_missing_delivery_date
FROM olist_orders_dataset
WHERE NULLIF(order_delivered_customer_date, '') IS NULL;


-- 17. Orders with Missing Estimated Delivery Date

SELECT
    COUNT(*) AS orders_missing_estimated_date
FROM olist_orders_dataset
WHERE NULLIF(order_estimated_delivery_date, '') IS NULL;


-- 18. Delivery Performance by Customer City

SELECT
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(o.order_delivered_customer_date, '')::timestamp
                    - NULLIF(o.order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE NULLIF(o.order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
GROUP BY
    c.customer_city,
    c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 50
ORDER BY avg_delivery_days DESC
LIMIT 25;


-- 19. Best Customer States by Delivery Speed

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(o.order_delivered_customer_date, '')::timestamp
                    - NULLIF(o.order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE NULLIF(o.order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY avg_delivery_days ASC
LIMIT 10;


-- 20. Worst Customer States by Delivery Speed

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(o.order_delivered_customer_date, '')::timestamp
                    - NULLIF(o.order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE NULLIF(o.order_delivered_customer_date, '') IS NOT NULL
  AND NULLIF(o.order_purchase_timestamp, '') IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY avg_delivery_days DESC
LIMIT 10;


-- ============================================================
-- 21. FINAL DELIVERY PERFORMANCE SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(
        DISTINCT CASE
            WHEN order_status = 'delivered'
            THEN order_id
        END
    ) AS delivered_orders,

    COUNT(
        DISTINCT CASE
            WHEN NULLIF(order_delivered_customer_date, '')::timestamp
                 <= NULLIF(order_estimated_delivery_date, '')::timestamp
            THEN order_id
        END
    ) AS on_time_orders,

    COUNT(
        DISTINCT CASE
            WHEN NULLIF(order_delivered_customer_date, '')::timestamp
                 > NULLIF(order_estimated_delivery_date, '')::timestamp
            THEN order_id
        END
    ) AS late_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_delivered_customer_date, '')::timestamp
                    - NULLIF(order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_delivery_days,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    NULLIF(order_estimated_delivery_date, '')::timestamp
                    - NULLIF(order_purchase_timestamp, '')::timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_estimated_days

FROM olist_orders_dataset
WHERE NULLIF(order_purchase_timestamp, '') IS NOT NULL;