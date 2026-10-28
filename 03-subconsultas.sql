
--1 — Clientes por encima del promedio de compra

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

--2 — Productos por debajo del promedio de ventas
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

--3 — Categorías con desempeño inferior a la media
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

