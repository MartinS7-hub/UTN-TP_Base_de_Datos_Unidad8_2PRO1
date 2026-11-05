-- ============================================================================
-- Dip&Cheese - Base de datos del microemprendimiento
-- 04_queries.sql - Consultas de explotación del modelo
--
-- Ejecutar con: psql -v ON_ERROR_STOP=1 -f sql/04_queries.sql
-- ============================================================================

SET search_path TO dipcheese, public;

-- ---------------------------------------------------------------------------
-- 1. Estado de resultados (mayo-octubre 2026)
-- ---------------------------------------------------------------------------
SELECT * FROM vw_estado_resultados_detalle;

SELECT
    ventas,
    costo_productos_vendidos,
    resultado_bruto,
    gastos_operativos,
    resultado_neto,
    margen_bruto_pct,
    margen_neto_pct
FROM vw_estado_resultados;

-- ---------------------------------------------------------------------------
-- 2. Estado de situación patrimonial
-- ---------------------------------------------------------------------------
SELECT * FROM vw_estado_patrimonial_detalle;

SELECT
    activo_corriente,
    activo_no_corriente,
    activo_total,
    pasivo,
    patrimonio_neto,
    pasivo_mas_patrimonio,
    diferencia_ecuacion
FROM vw_estado_patrimonial;

-- ---------------------------------------------------------------------------
-- 3. Punto de equilibrio por mes
-- ---------------------------------------------------------------------------
SELECT
    periodo,
    unidades_vendidas,
    unidades_equilibrio,
    resultado_calculado,
    resultado_reportado,
    diferencia,
    control
FROM vw_punto_equilibrio;

-- Totales del período
SELECT
    SUM(unidades_vendidas)   AS unidades_vendidas,
    SUM(unidades_equilibrio) AS unidades_equilibrio,
    SUM(unidades_vendidas - unidades_equilibrio) AS resultado_calculado,
    SUM(resultado_reportado) AS resultado_reportado
FROM punto_equilibrio_mensual;

-- ---------------------------------------------------------------------------
-- 4. Ventas por canal y conciliación con el estado de resultados
-- ---------------------------------------------------------------------------
SELECT * FROM vw_ventas_por_canal;
SELECT * FROM vw_reconciliacion_ventas;

-- Detalle de ventas registradas
SELECT
    v.id,
    v.fecha,
    v.canal,
    e.nombre AS evento,
    v.medio_pago,
    v.total,
    v.nota
FROM venta v
LEFT JOIN evento e ON e.id = v.evento_id
ORDER BY v.fecha, v.id;

-- ---------------------------------------------------------------------------
-- 5. Capital, aportes y distribución de ganancias
-- ---------------------------------------------------------------------------
SELECT * FROM vw_capital_social;
SELECT * FROM vw_aportes_por_socio;
SELECT * FROM vw_distribucion_ganancias;

-- Retorno sobre la inversión inicial
SELECT
    ci.capital_inicial,
    er.resultado_neto,
    ROUND(100.0 * er.resultado_neto / NULLIF(ci.capital_inicial, 0), 2) AS retorno_sobre_capital_pct
FROM vw_capital_social ci
CROSS JOIN vw_estado_resultados er;

-- ---------------------------------------------------------------------------
-- 6. Cumplimiento de objetivos
-- ---------------------------------------------------------------------------
SELECT * FROM vw_cumplimiento_objetivos;

-- ---------------------------------------------------------------------------
-- 7. Encuestas: resultados e indicadores
-- ---------------------------------------------------------------------------
SELECT
    encuesta,
    codigo,
    pregunta,
    opcion,
    cantidad,
    porcentaje
FROM vw_encuesta_resultados
ORDER BY encuesta_id, codigo, porcentaje DESC;

SELECT * FROM vw_encuesta_indicadores;

-- Satisfacción: porcentaje de recompra
SELECT
    cantidad AS respuestas_si,
    porcentaje AS pct_recompra
FROM vw_encuesta_resultados
WHERE codigo = 'recompra' AND opcion = 'Sí';

-- ---------------------------------------------------------------------------
-- 8. Proveedores e insumos
-- ---------------------------------------------------------------------------
SELECT * FROM vw_proveedores_insumos;

SELECT
    p.nombre AS proveedor,
    p.tipo,
    i.nombre AS insumo,
    pi.unidad_compra,
    pi.minimo_compra,
    pi.descuento_unitario
FROM proveedor p
JOIN proveedor_insumo pi ON pi.proveedor_id = p.id
JOIN insumo i ON i.id = pi.insumo_id
ORDER BY p.tipo, p.nombre, i.nombre;

-- ---------------------------------------------------------------------------
-- 9. Márgenes por producto
--    (solo se calculan cuando hay precio y costo cargados)
-- ---------------------------------------------------------------------------
SELECT * FROM vw_margen_producto;

-- ---------------------------------------------------------------------------
-- 10. Producción y costo por docena de chipá
-- ---------------------------------------------------------------------------
SELECT * FROM vw_costo_docena;

-- ---------------------------------------------------------------------------
-- 11. Indicadores generales del emprendimiento
-- ---------------------------------------------------------------------------
SELECT
    (SELECT ventas FROM vw_estado_resultados)                    AS ventas_totales,
    (SELECT resultado_neto FROM vw_estado_resultados)            AS ganancia_neta,
    (SELECT margen_neto_pct FROM vw_estado_resultados)           AS margen_neto_pct,
    (SELECT capital_inicial FROM vw_capital_social)              AS inversion_inicial,
    (SELECT COUNT(*) FROM socio)                                 AS socios,
    (SELECT COUNT(*) FROM evento)                                AS actos,
    (SELECT COALESCE(SUM(total), 0) FROM venta
      WHERE canal = 'encargo_congelado')                         AS ventas_congelados,
    (SELECT COALESCE(SUM(monto), 0) FROM rendimiento_financiero) AS rendimientos_financieros;

-- ---------------------------------------------------------------------------
-- 12. Revisión de consistencia del documento fuente
-- ---------------------------------------------------------------------------
SELECT * FROM vw_verificacion_integridad;
SELECT * FROM vw_inconsistencias;
