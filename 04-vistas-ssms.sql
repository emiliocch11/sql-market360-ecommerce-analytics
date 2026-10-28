-- Version con separadores de lotes GO para SQL Server Management Studio.
-- Basada en views.sql original. Requiere Fact_Ventas y tablas Dim_* previamente creadas.
-- No altera calculos ni criterios de consultas originales.
---------------------------------------------------------------------------------------------
-- vw_ventas_categoria
---------------------------------------------------------------------------------------------
GO
CREATE VIEW vw_ventas_categoria AS
SELECT
    dcat.product_category_name,
    COUNT(fv.venta_key)      AS cantidad_items,
    SUM(fv.price)              AS ingreso_total,
    AVG(fv.price)                AS precio_promedio,
    AVG(fv.review_score)           AS calificacion_promedio
FROM Fact_Ventas fv
JOIN Dim_Categoria dcat ON fv.categoria_key = dcat.categoria_key
GROUP BY dcat.product_category_name;
---------------------------------------------------------------------------------------------
-- Uso vw_ventas_categoria
---------------------------------------------------------------------------------------------
GO
SELECT * FROM vw_ventas_categoria ORDER BY ingreso_total DESC;
GO
SELECT * FROM vw_ventas_categoria WHERE calificacion_promedio < 3;
---------------------------------------------------------------------------------------------
-- vw_clientes_frecuentes
---------------------------------------------------------------------------------------------
GO
CREATE VIEW vw_clientes_frecuentes AS
SELECT
    dc.customer_unique_id,
    dc.customer_city,
    dc.customer_state,
    COUNT(DISTINCT fv.order_id) AS num_pedidos,
    SUM(fv.price)                  AS gasto_total,
    MAX(df.fecha)                    AS fecha_ultima_compra
FROM Fact_Ventas fv
JOIN Dim_Cliente dc ON fv.cliente_key = dc.cliente_key
JOIN Dim_Fecha df   ON fv.fecha_key = df.fecha_key
GROUP BY dc.customer_unique_id, dc.customer_city, dc.customer_state
HAVING COUNT(DISTINCT fv.order_id) > 1;
---------------------------------------------------------------------------------------------
-- Uso vw_clientes_frecuentes
---------------------------------------------------------------------------------------------
GO
SELECT * FROM vw_clientes_frecuentes 
WHERE fecha_ultima_compra BETWEEN '2018-08-01' AND '2018-09-01'
---------------------------------------------------------------------------------------------
-- vw_resumen_ejecutivo
---------------------------------------------------------------------------------------------
GO
CREATE VIEW vw_resumen_ejecutivo AS
SELECT
    COUNT(DISTINCT fv.order_id)                    AS total_pedidos,
    COUNT(DISTINCT dc.customer_unique_id)             AS total_clientes,
    SUM(fv.price)                                       AS ingreso_total,
    AVG(fv.price)                                          AS ticket_promedio_item,
    AVG(fv.review_score)                                      AS calificacion_promedio_general,
    (SELECT COUNT(*) FROM Dim_Categoria)                        AS total_categorias
FROM Fact_Ventas fv
JOIN Dim_Cliente dc ON fv.cliente_key = dc.cliente_key;
---------------------------------------------------------------------------------------------
-- Uso vw_resumen_ejecutivo
---------------------------------------------------------------------------------------------
GO
SELECT * FROM vw_resumen_ejecutivo;
---------------------------------------------------------------------------------------------


SELECT name, type_desc
FROM sys.objects
WHERE type IN ('P', 'V')  -- P = Procedimiento, V = Vista
  AND name IN ('sp_top_productos', 'sp_clientes_inactivos', 'sp_recompras',
               'vw_ventas_categoria', 'vw_clientes_frecuentes', 'vw_resumen_ejecutivo');