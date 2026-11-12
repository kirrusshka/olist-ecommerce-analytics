-- Продажи: даты оформления доставленных заказов, товарная стоимость без доставки
-- Выручка здесь = SUM(order_items.price), НЕ прибыль маркетплейса.

-- Контроль качества и распределение статусов
SELECT order_status, COUNT(*) AS orders_count
FROM orders
GROUP BY order_status
ORDER BY orders_count DESC;

-- Месячные KPI: одна строка заказа может содержать несколько товаров
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.price), 2) AS product_value,
    ROUND(SUM(oi.price) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS aov
FROM orders AS o
JOIN order_items AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;
