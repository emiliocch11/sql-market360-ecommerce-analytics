

USE [Market360]

--Pregunta 1: ¿Cuántas ventas se realizaron?
SELECT COUNT(DISTINCT order_id) AS total_ventas
FROM olist_orders
WHERE order_status NOT IN ('canceled', 'unavailable');
-- 98,207 ventas

--Pregunta 2 — ¿Cuál fue el monto total vendido?
SELECT SUM(payment_value) AS monto_total_vendido
FROM olist_order_payments;
-- monto total vendido $160,088,872.12

--Pregunta 3 — ¿Cuál es el ticket promedio?
SELECT AVG(total_por_pedido) AS ticket_promedio
FROM (
    SELECT order_id, SUM(payment_value) AS total_por_pedido
    FROM olist_order_payments
    GROUP BY order_id
) sub;
--ticket promedio $160.9902

--Pregunta 4 — ¿Cuáles son las categorías más vendidas?
SELECT TOP 10
    p.product_category_name,
    COUNT(oi.order_id) AS cantidad_items_vendidos,
    SUM(oi.price) AS ingreso_total
FROM olist_order_items oi
JOIN olist_products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY ingreso_total DESC;

--Pregunta 5 — ¿Cómo evolucionan las ventas por mes?
SELECT
    YEAR(o.order_purchase_timestamp) AS anio,
    MONTH(o.order_purchase_timestamp) AS mes,
    COUNT(DISTINCT o.order_id) AS num_pedidos,
    SUM(oi.price) AS ingreso_mensual
FROM olist_orders o
JOIN olist_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
ORDER BY anio, mes;