# Market360 | E-Commerce Analytics con SQL

![SQL Server](https://img.shields.io/badge/SQL_Server-T--SQL-CC2927?style=flat-square) ![Data Modeling](https://img.shields.io/badge/Modelado-Esquema_estrella-234E70?style=flat-square) ![Analytics](https://img.shields.io/badge/Análisis-E--commerce-168AAD?style=flat-square)

**Autor:** Emilio Caldas  
**Programa:** Data Analyst Expert — Ciencia de Datos Ecuador  
**Módulo:** Analítica y Modelado de Datos con SQL  
**Tipo:** Proyecto académico aplicado a un caso de negocio  
**Datos:** Olist Brazilian E-Commerce Public Dataset

## Resumen ejecutivo

Market360 es una **empresa de e-commerce ficticia dentro del caso académico**. El proyecto plantea investigar el comportamiento de las ventas, el desempeño por categoría, las posibles señales de insatisfacción y la actividad de los clientes. Para el análisis se utilizó el dataset público brasileño Olist, mediante consultas T-SQL y un modelo dimensional descrito en la entrega 2.

El proyecto está documentado en **tres entregas**: exploración del negocio (semana 1), modelado dimensional y segmentación (semana 2), y presentación ejecutiva y consultas reutilizables mediante vistas (semana 3).

## Preguntas de negocio

1. ¿Qué categorías presentan posibles señales de caída en ventas?
2. ¿Qué categorías muestran mayor insatisfacción y deberían revisarse?
3. ¿Qué clientes llevan largos períodos sin comprar?
4. ¿Qué segmentos de clientes, productos o categorías priorizar?

> **Alcance:** la entrega exploratoria no demuestra por sí sola una caída de ventas por categoría. La consulta de reseñas `review_score <= 2` mide bajas calificaciones, **no devoluciones efectivas**. El indicador de 90 días mide inactividad histórica relativa a la última fecha del dataset, no una probabilidad estadística de abandono.

## Datos y herramientas

- **Fuente:** Olist Brazilian E-Commerce Public Dataset; los CSV originales no están incluidos.
- **Entorno de consultas:** Microsoft SQL Server / T-SQL (`TOP`, `YEAR`, `DATEDIFF`, `IDENTITY`).
- **Técnicas observables:** `COUNT`, `SUM`, `AVG`, `JOIN`, `GROUP BY`, `CTE`, subconsultas, filtros de estados y segmentación por promedio.
- **Modelado documentado:** tabla de hechos `Fact_Ventas` a nivel ítem de pedido y cinco dimensiones: `Dim_Cliente`, `Dim_Producto`, `Dim_Categoria`, `Dim_Fecha`, `Dim_Pago`.

## Metodología

### Entrega 1 · Exploración y diagnóstico

1. Identificación de las entidades de pedidos, clientes, productos, pagos, reseñas y vendedores.
2. Revisión de identificadores y relaciones entre tablas transaccionales.
3. Consultas para contar pedidos, sumar pagos, calcular el ticket por pedido, identificar categorías y describir tendencias mensuales.
4. Interpretación de resultados en un reporte analítico.

Consulta de ejemplo — ticket promedio por pedido:

```sql
SELECT AVG(total_por_pedido) AS ticket_promedio
FROM (
    SELECT order_id, SUM(payment_value) AS total_por_pedido
    FROM olist_order_payments
    GROUP BY order_id
) AS sub;
```

### Entrega 2 · Modelo dimensional y segmentación

1. Documentación de claves primarias y foráneas.
2. Diseño de un modelo de datos tipo estrella, con un registro por ítem de pedido en la tabla de hechos.
3. Consultas analíticas por categoría y cliente.
4. Segmentación por media mediante CTE y subconsultas, para comparar el gasto de clientes, las unidades por producto y los ingresos por categoría.
5. Interpretación de concentraciones y oportunidades de mejora en el reporte técnico.

### Entrega 3 · Vistas, seguimiento y reporte ejecutivo

1. Documentación de **tres vistas SQL**: `vw_ventas_categoria`, `vw_clientes_frecuentes` y `vw_resumen_ejecutivo`, sobre el modelo dimensional descrito en la semana 2.
2. Preparación de consultas sobre las vistas para explorar ingresos y calificaciones por categoría, actividad de clientes recurrentes e indicadores consolidados.
3. Integración de hallazgos en un **reporte ejecutivo final** con recomendaciones priorizadas de retención, revisión de catálogo y calidad.
4. La consigna también pedía procedimientos `sp_top_productos`, `sp_clientes_inactivos`, `sp_recompras` y evidencia de optimización. El reporte final declara esas implementaciones y una disminución del **51,3 % de lecturas de disco**; sin embargo, **no se recibieron sus scripts ni planes de ejecución**, por lo que dichas implementaciones y la mejora no son reproducibles con los archivos actuales.

> **Nota técnica:** `04-vistas-original.sql` conserva exactamente el archivo enviado. Para facilitar la ejecución desde SQL Server Management Studio, `04-vistas-ssms.sql` agrega los separadores `GO` necesarios para que cada `CREATE VIEW` comience su lote. No se han probado los scripts en un motor SQL Server ni se han modificado sus cálculos.

## Principales resultados reportados

| Indicador | Resultado | Procedencia |
| --- | ---: | --- |
| Pedidos contabilizados, excluyendo cancelados y no disponibles | **98.207** | Entrega 1 |
| Suma de `payment_value` | **160.088.872,12** | Entrega 1 |
| Ticket medio por pedido, según consulta de pagos | **160,99** | Entrega 1 |
| Gasto medio calculado por cliente con `SUM(price)` | **R$ 143,15** | Entrega 2 |
| Clientes por encima del gasto medio | **26.987 (28,7%)** | Entrega 2 |
| Productos por debajo de la media de unidades | **23.371 (72,3%)** | Entrega 2 |
| Categorías por debajo del ingreso medio | **53 de 73 (72,6%)** | Entrega 2 |

**Interpretación:** Según el reporte técnico, un 28,7 % de los clientes concentra el 66,6 % del gasto analizado, mientras que 20 categorías aportan el 85,1 % del ingreso por artículos del modelo. Son señales de concentración que ayudan a priorizar segmentos.

**Precaución:** las cifras se transcriben de los reportes académicos y comentarios de los scripts; **no fueron recalculadas aquí** contra una base SQL. Las consultas mezclan métricas de pagos (`payment_value`) y precios de ítems (`price`), y pueden utilizar diferentes universos de pedidos. No se deben comparar directamente sin conciliación. Aunque el reporte inicial usa `$`, los datos Olist proceden de Brasil; para evitar atribuir una moneda incorrecta, se conserva el valor numérico de pagos sin especificar divisa en la tabla.

## Hallazgos del informe ejecutivo final (semana 3)

Según el **reporte final** (resultados documentados, no recalculados aquí):

- **Concentración de clientes:** el 28,7 % de los clientes representa el 66,6 % del gasto analizado; se recomienda priorizar fidelización.
- **Catálogo de baja rotación:** 23.371 SKU (72,3 %) están por debajo de la media de unidades, y 17.638 de ellos registran una sola unidad vendida durante el período.
- **Clientes inactivos:** 84.642 clientes presentan más de 90 días desde su última compra, medidos respecto a la fecha de referencia histórica del conjunto de datos, no respecto a hoy.
- **Concentración por categoría:** 20 de 73 categorías representan el 85,1 % de los ingresos por artículos analizados.
- **Señales de insatisfacción:** se destaca `telefonia` como categoría a investigar, pero las calificaciones bajas se usan como *proxy*, no como evidencia de devoluciones confirmadas.
- **Optimización:** el informe afirma una reducción del 51,3 % en lecturas de disco, sin adjuntar el plan de ejecución ni los scripts de índices para verificar el resultado.

**Criterio de prudencia:** estas cifras y afirmaciones proceden del reporte académico; métricas de `payment_value`, `price` y promedios por ítem no son equivalentes. Tampoco es posible calcular retorno económico real de programas de fidelización con los materiales adjuntos.

## Recomendaciones de negocio

- Explorar las categorías por período antes de concluir que están perdiendo ventas.
- Diferenciar productos de alto volumen y productos de alto valor monetario.
- Investigar los productos/categorías con reseñas bajas y cruzar con datos reales de devoluciones si están disponibles.
- Priorizar análisis de retención y recompra para clientes valiosos, distinguiendo inactividad histórica de predicción de churn.
- Considerar la mediana y la distribución de ingresos, no solamente la media, antes de clasificar categorías como poco rentables.

## Estructura del repositorio

```text
.
├── README.md
├── sql/
│   ├── 01-exploracion-ventas.sql
│   ├── 02-consultas-analiticas-y-subconsultas-original.sql
│   ├── 03-subconsultas.sql
│   ├── 04-vistas-original.sql
│   └── 04-vistas-ssms.sql
├── reports/
│   ├── entrega-1-reporte-analitico.docx
│   ├── entrega-2-reporte-tecnico.docx
│   └── entrega-3-reporte-ejecutivo-final.docx
└── docs/
    ├── instrucciones-semana-1.pdf
    ├── instrucciones-semana-2.pdf
    └── instrucciones-semana-3.pdf
```

## Cómo revisar el proyecto

1. Leer los **tres** reportes en `reports/` para comprender la lógica y los resultados obtenidos.
2. Abrir los scripts de `sql/` para inspeccionar las consultas originales.
3. Para ejecutarlos, disponer de **SQL Server** y cargar previamente el dataset Olist en tablas con los nombres utilizados (`olist_orders`, `olist_order_payments`, etc.).
4. Las consultas de la semana 2 dependen de `Fact_Ventas` y tablas `Dim_*`; **no se incluye un script completo ejecutable de creación y carga del modelo**, por lo que esa parte no puede reproducirse automáticamente con lo adjuntado.

### Limitaciones técnicas verificadas

- En `02-consultas-analiticas-y-subconsultas-original.sql`, la línea `//* Desarrollar consultas para identificar:*//` **no es un comentario válido en T-SQL**. Debe sustituirse por `-- Desarrollar consultas para identificar` antes de ejecutar ese archivo.
- Un conteo de reseñas bajas no equivale a una devolución real.
- Contar clientes con más de 90 días sin comprar, tomando el máximo del calendario, no demuestra por sí solo abandono ni permite estimar una probabilidad de churn.
- Las cifras reportadas requieren validación posterior con la base de origen y las reglas de filtrado aplicadas.
- `04-vistas-original.sql` tiene varios `CREATE VIEW` en un mismo lote, así que en SQL Server debe ejecutarse con separadores `GO`; para ello se aporta `04-vistas-ssms.sql`.
- Aunque el reporte final describe procedimientos almacenados e índices, **sus definiciones, scripts de creación y planes de ejecución no se entregaron**. No se incluyen como código implementado en este repositorio.
- En la vista `vw_resumen_ejecutivo`, `AVG(fv.price)` es el **precio medio por ítem**, no el ticket medio por pedido; el alias original ya lo distingue.

## Próximos pasos

- Incorporar el script completo de generación y carga del esquema estrella si está disponible.
- Incorporar los scripts de procedimientos almacenados y evidencias de optimización de la semana 3 si están disponibles.
- Adjuntar capturas del esquema y resultados de ejecución, y conciliar las métricas antes de publicar una versión final auditada.

---

**Emilio Caldas** · [LinkedIn](https://www.linkedin.com/in/emiliocaldas/) · [Email](mailto:emiliocch11@gmail.com)
