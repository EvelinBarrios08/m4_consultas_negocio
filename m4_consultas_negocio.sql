-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- TechStore - Consultas SQL de Negocio
-- Autora: Barrios Evelin Eliana
-- Módulo 4 - Pre-entrega 4
-- Base de datos: Ventas_Tech_DB
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

USE Ventas_Tech_DB;
GO

-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- CONSULTA 1 - RESUMEN EJECUTIVO MENSUAL
-- Total facturado, cantidad de pedidos y ticket promedio por mes agrupados por mes.
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    CAST(AVG(cantidad * precio_unitario) AS DECIMAL(10,2)) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;



-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- CONSULTA 2 - RANKING DE PRODUCTOS
-- Top 5 productos por total facturado.
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

SELECT TOP 5 id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;



-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- CONSULTA 3 - CLIENTES RECURRENTES
-- Clientes con más de un pedido.
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;



-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- CONSULTA 4 - COMPARACIÓN CON EL PROMEDIO MENSUAL
-- Compara la facturación de cada mes con el promedio de facturación mensual de todos los meses registrados.
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════


SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    CASE
        WHEN SUM(cantidad * precio_unitario) >
        (
            SELECT AVG(total_mensual)
            FROM
            (
                SELECT
                    MONTH(fecha_venta) AS mes,
                    SUM(cantidad * precio_unitario) AS total_mensual
                FROM ventas
                GROUP BY MONTH(fecha_venta)
            ) AS promedio_mensual
        )
        THEN 'Por encima'

        WHEN SUM(cantidad * precio_unitario) <
        (
            SELECT AVG(total_mensual)
            FROM
            (
                SELECT
                    MONTH(fecha_venta) AS mes,
                    SUM(cantidad * precio_unitario) AS total_mensual
                FROM ventas
                GROUP BY MONTH(fecha_venta)
            ) AS promedio_mensual
        )
        THEN 'Por debajo'

        ELSE 'Igual al promedio'
    END AS comparacion_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- HALLAZGOS DE NEGOCIO
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════


-- 1. El producto 1 genera la mayor facturación, con $3.600,
--    lo que representa aproximadamente el 56,64 % de los
--    $6.356 facturados en total.

-- 2. Los cinco clientes registrados realizaron dos compras
--    cada uno, por lo que todos cumplen el criterio de
--    clientes recurrentes de esta muestra.

-- 3. El producto 2 registra el mayor volumen de unidades
--    vendidas, con 13 unidades, pero genera $364.
--    Esto demuestra que vender más unidades no implica
--    necesariamente generar la mayor facturación.