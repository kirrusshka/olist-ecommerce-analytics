-- RFM: срез по дате оформления доставленных заказов до 2018-09-01.
-- Recency: дней от даты среза до последнего оформленного доставленного заказа.
-- Frequency: число доставленных заказов; Monetary: стоимость товаров без доставки.
SELECT
    c.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_purchase_date,
    DATE '2018-09-01' - MAX(o.order_purchase_timestamp)::date AS recency_days,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.price), 2) AS total_spent
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp < TIMESTAMP '2018-09-01'
GROUP BY c.customer_unique_id
ORDER BY orders_count DESC, total_spent DESC;

-- Покупатели с повторными доставленными заказами за тот же период
WITH customer_orders AS (
    SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS orders_count
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp < TIMESTAMP '2018-09-01'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE orders_count > 1) AS repeat_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE orders_count > 1)
           / NULLIF(COUNT(*), 0), 2) AS repeat_purchase_rate_pct
FROM customer_orders;
