

--ACTIVIDAD 3 CONSULTAS ANALITICAS

--Pregunta 1 — ¿Qué categorías generan más ingresos?
SELECT
    dcat.product_category_name,
    COUNT(fv.venta_key) AS cantidad_items,
    SUM(fv.price) AS ingreso_total
FROM Fact_Ventas fv
JOIN Dim_Categoria dcat ON fv.categoria_key = dcat.categoria_key
GROUP BY dcat.product_category_name
ORDER BY ingreso_total DESC;

--Pregunta 2 — ¿Qué categorías presentan mayor volumen de devoluciones?
SELECT
    dcat.product_category_name,
    COUNT(fv.venta_key) AS total_items_vendidos,
    SUM(CASE WHEN fv.review_score <= 2 THEN 1 ELSE 0 END) AS items_con_baja_calificacion,
    CAST(SUM(CASE WHEN fv.review_score <= 2 THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(fv.venta_key), 0) * 100 AS porcentaje_insatisfaccion
FROM Fact_Ventas fv
JOIN Dim_Categoria dcat ON fv.categoria_key = dcat.categoria_key
GROUP BY dcat.product_category_name
HAVING COUNT(fv.venta_key) > 50   -- filtra categorías con muestra muy pequeña
ORDER BY porcentaje_insatisfaccion DESC;


--Pregunta 3 — ¿Cuál es el valor promedio de compra por cliente?

WITH gasto_por_cliente AS (
    SELECT
        dc.customer_unique_id,
        SUM(fv.price) AS gasto_total_cliente
    FROM Fact_Ventas fv
    JOIN Dim_Cliente dc ON fv.cliente_key = dc.cliente_key
    GROUP BY dc.customer_unique_id
)
SELECT AVG(gasto_total_cliente) AS valor_promedio_compra_cliente
FROM gasto_por_cliente;
-- VALOR PROMEDIO COMPRA CLIENTE $143.15

--Pregunta 4 — ¿Cuántos clientes no compran desde hace más de 90 días?

WITH ultima_compra_cliente AS (
    SELECT
        dc.customer_unique_id,
        MAX(df.fecha) AS fecha_ultima_compra
    FROM Fact_Ventas fv
    JOIN Dim_Cliente dc ON fv.cliente_key = dc.cliente_key
    JOIN Dim_Fecha df   ON fv.fecha_key = df.fecha_key
    GROUP BY dc.customer_unique_id
)
SELECT COUNT(*) AS clientes_inactivos_90_dias
FROM ultima_compra_cliente
WHERE DATEDIFF(DAY, fecha_ultima_compra, (SELECT MAX(fecha) FROM Dim_Fecha)) > 90;

--CLIENTES INACTICOS 90 DIAS = 84642


--ACTIVIDAD 4 SUBCONSULTAS

//* Desarrollar consultas para identificar:*//

--Clientes por encima del promedio de compra.
WITH gasto_por_cliente AS (
    SELECT
        dc.customer_unique_id,
        SUM(fv.price) AS gasto_total
    FROM Fact_Ventas fv
    JOIN Dim_Cliente dc ON fv.cliente_key = dc.cliente_key
    GROUP BY dc.customer_unique_id
)
SELECT
    customer_unique_id,
    gasto_total
FROM gasto_por_cliente
WHERE gasto_total > (
    SELECT AVG(gasto_total) FROM gasto_por_cliente
)
ORDER BY gasto_total DESC;


--Productos por debajo del promedio de ventas.
WITH ventas_por_producto AS (
    SELECT
        dp.product_id,
        COUNT(fv.venta_key) AS unidades_vendidas
    FROM Fact_Ventas fv
    JOIN Dim_Producto dp ON fv.producto_key = dp.producto_key
    GROUP BY dp.product_id
)
SELECT
    product_id,
    unidades_vendidas
FROM ventas_por_producto
WHERE unidades_vendidas < (
    SELECT AVG(unidades_vendidas) FROM ventas_por_producto
)
ORDER BY unidades_vendidas ASC;


--Categorías con desempeño inferior a la media 
WITH ingreso_por_categoria AS (
    SELECT
        dcat.product_category_name,
        SUM(fv.price) AS ingreso_total
    FROM Fact_Ventas fv
    JOIN Dim_Categoria dcat ON fv.categoria_key = dcat.categoria_key
    GROUP BY dcat.product_category_name
)
SELECT
    product_category_name,
    ingreso_total
FROM ingreso_por_categoria
WHERE ingreso_total < (
    SELECT AVG(ingreso_total) FROM ingreso_por_categoria
)
ORDER BY ingreso_total ASC;

