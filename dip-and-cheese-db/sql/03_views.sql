-- ============================================================================
-- Dip&Cheese - Base de datos del microemprendimiento
-- 03_views.sql - Vistas de negocio, control y verificación
-- ============================================================================

BEGIN;
SET search_path TO dipcheese, public;

-- ---------------------------------------------------------------------------
-- Estados contables
-- ---------------------------------------------------------------------------

CREATE VIEW vw_estado_resultados_detalle AS
SELECT orden, codigo, concepto, tipo, monto, nota
FROM estado_resultado_concepto
ORDER BY orden;

CREATE VIEW vw_estado_resultados AS
WITH r AS (
    SELECT
        COALESCE(SUM(monto) FILTER (WHERE tipo = 'ingreso'), 0)::numeric(14,2) AS ventas,
        COALESCE(SUM(monto) FILTER (WHERE tipo = 'costo'),   0)::numeric(14,2) AS costo_productos_vendidos,
        COALESCE(SUM(monto) FILTER (WHERE tipo = 'gasto'),   0)::numeric(14,2) AS gastos_operativos
    FROM estado_resultado_concepto
),
calc AS (
    SELECT
        ventas,
        costo_productos_vendidos,
        ventas - costo_productos_vendidos AS resultado_bruto,
        gastos_operativos,
        ventas - costo_productos_vendidos - gastos_operativos AS resultado_neto
    FROM r
)
SELECT
    ventas,
    costo_productos_vendidos,
    resultado_bruto,
    gastos_operativos,
    resultado_neto,
    ROUND(100.0 * resultado_bruto / NULLIF(ventas, 0), 2) AS margen_bruto_pct,
    ROUND(100.0 * resultado_neto  / NULLIF(ventas, 0), 2) AS margen_neto_pct,
    ROUND(100.0 * costo_productos_vendidos / NULLIF(ventas, 0), 2) AS costo_sobre_ventas_pct,
    ROUND(100.0 * gastos_operativos / NULLIF(ventas, 0), 2) AS gastos_sobre_ventas_pct
FROM calc;

CREATE VIEW vw_estado_patrimonial_detalle AS
SELECT
    tipo,
    CASE tipo
        WHEN 'activo_corriente'    THEN 'Activo corriente'
        WHEN 'activo_no_corriente' THEN 'Activo no corriente'
        WHEN 'pasivo'              THEN 'Pasivo'
        WHEN 'patrimonio_neto'     THEN 'Patrimonio neto'
    END AS grupo,
    rubro,
    importe
FROM estado_patrimonial_rubro
ORDER BY
    CASE tipo
        WHEN 'activo_corriente'    THEN 1
        WHEN 'activo_no_corriente' THEN 2
        WHEN 'pasivo'              THEN 3
        WHEN 'patrimonio_neto'     THEN 4
    END,
    orden;

CREATE VIEW vw_estado_patrimonial AS
WITH p AS (
    SELECT
        COALESCE(SUM(importe) FILTER (WHERE tipo = 'activo_corriente'),    0)::numeric(14,2) AS activo_corriente,
        COALESCE(SUM(importe) FILTER (WHERE tipo = 'activo_no_corriente'), 0)::numeric(14,2) AS activo_no_corriente,
        COALESCE(SUM(importe) FILTER (WHERE tipo = 'pasivo'),              0)::numeric(14,2) AS pasivo,
        COALESCE(SUM(importe) FILTER (WHERE tipo = 'patrimonio_neto'),     0)::numeric(14,2) AS patrimonio_neto
    FROM estado_patrimonial_rubro
),
tot AS (
    SELECT
        activo_corriente,
        activo_no_corriente,
        activo_corriente + activo_no_corriente AS activo_total,
        pasivo,
        patrimonio_neto,
        pasivo + patrimonio_neto AS pasivo_mas_patrimonio
    FROM p
)
SELECT
    activo_corriente,
    activo_no_corriente,
    activo_total,
    pasivo,
    patrimonio_neto,
    pasivo_mas_patrimonio,
    activo_total - pasivo_mas_patrimonio AS diferencia_ecuacion
FROM tot;

-- ---------------------------------------------------------------------------
-- Ventas y punto de equilibrio
-- ---------------------------------------------------------------------------

CREATE VIEW vw_ventas_por_canal AS
SELECT
    canal,
    COUNT(*)                          AS operaciones,
    SUM(unidades)                     AS unidades_informadas,
    SUM(total)                        AS total,
    ROUND(100.0 * SUM(total) / NULLIF(SUM(SUM(total)) OVER (), 0), 2) AS participacion_pct
FROM venta
GROUP BY canal
ORDER BY total DESC;

CREATE VIEW vw_reconciliacion_ventas AS
WITH v AS (
    SELECT
        COALESCE(SUM(total) FILTER (WHERE canal = 'acto'),             0)::numeric(14,2) AS ventas_actos,
        COALESCE(SUM(total) FILTER (WHERE canal = 'encargo_congelado'), 0)::numeric(14,2) AS ventas_encargos,
        COALESCE(SUM(total) FILTER (WHERE canal = 'mostrador'),         0)::numeric(14,2) AS ventas_mostrador,
        COALESCE(SUM(total) FILTER (WHERE canal = 'no_discriminado'),   0)::numeric(14,2) AS ventas_no_discriminadas,
        COALESCE(SUM(total), 0)::numeric(14,2) AS ventas_registradas
    FROM venta
),
i AS (
    SELECT monto AS ventas_informe
    FROM estado_resultado_concepto
    WHERE codigo = 'ventas'
)
SELECT
    v.ventas_actos,
    v.ventas_encargos,
    v.ventas_mostrador,
    v.ventas_no_discriminadas,
    v.ventas_registradas,
    i.ventas_informe,
    v.ventas_registradas - i.ventas_informe AS diferencia
FROM v CROSS JOIN i;

CREATE VIEW vw_punto_equilibrio AS
SELECT
    anio,
    mes,
    (CASE mes
        WHEN 1  THEN 'Enero'      WHEN 2  THEN 'Febrero'
        WHEN 3  THEN 'Marzo'      WHEN 4  THEN 'Abril'
        WHEN 5  THEN 'Mayo'       WHEN 6  THEN 'Junio'
        WHEN 7  THEN 'Julio'      WHEN 8  THEN 'Agosto'
        WHEN 9  THEN 'Septiembre' WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'  WHEN 12 THEN 'Diciembre'
     END) || ' ' || anio AS periodo,
    unidades_vendidas,
    unidades_equilibrio,
    unidades_vendidas - unidades_equilibrio AS resultado_calculado,
    resultado_reportado,
    resultado_reportado - (unidades_vendidas - unidades_equilibrio) AS diferencia,
    CASE
        WHEN resultado_reportado = unidades_vendidas - unidades_equilibrio THEN 'ok'
        ELSE 'revisar'
    END AS control
FROM punto_equilibrio_mensual
ORDER BY anio, mes;

-- ---------------------------------------------------------------------------
-- Capital y distribución
-- ---------------------------------------------------------------------------

CREATE VIEW vw_capital_social AS
WITH a AS (
    SELECT
        COALESCE(SUM(monto) FILTER (WHERE tipo = 'inicial'),    0)::numeric(14,2) AS capital_inicial,
        COALESCE(SUM(monto) FILTER (WHERE tipo = 'ampliacion'), 0)::numeric(14,2) AS ampliaciones,
        COALESCE(SUM(monto), 0)::numeric(14,2) AS capital_social_total
    FROM aporte_capital
),
i AS (
    SELECT importe AS capital_social_informe
    FROM estado_patrimonial_rubro
    WHERE tipo = 'patrimonio_neto' AND rubro = 'Capital Social'
)
SELECT
    a.capital_inicial,
    a.ampliaciones,
    a.capital_social_total,
    i.capital_social_informe,
    a.capital_social_total - i.capital_social_informe AS diferencia
FROM a CROSS JOIN i;

CREATE VIEW vw_aportes_por_socio AS
SELECT
    s.id,
    s.nombre || ' ' || s.apellido AS socio,
    s.participacion_pct,
    COALESCE(SUM(a.monto) FILTER (WHERE a.tipo = 'inicial'), 0) AS aporte_inicial,
    COALESCE(SUM(a.monto), 0) AS aporte_total
FROM socio s
LEFT JOIN aporte_capital a ON a.socio_id = s.id
GROUP BY s.id, s.nombre, s.apellido, s.participacion_pct
ORDER BY s.id;

CREATE VIEW vw_distribucion_ganancias AS
WITH r AS (
    SELECT resultado_neto FROM vw_estado_resultados
)
SELECT
    s.id,
    s.nombre || ' ' || s.apellido AS socio,
    dg.periodo,
    dg.monto,
    r.resultado_neto,
    SUM(dg.monto) OVER () AS total_distribuido,
    ROUND(100.0 * dg.monto / NULLIF(SUM(dg.monto) OVER (), 0), 2) AS pct_del_total_distribuido,
    ROUND(100.0 * SUM(dg.monto) OVER () / NULLIF(r.resultado_neto, 0), 2) AS pct_del_resultado
FROM socio s
JOIN distribucion_ganancia dg ON dg.socio_id = s.id
CROSS JOIN r
ORDER BY s.id;

-- ---------------------------------------------------------------------------
-- Objetivos, productos y proveedores
-- ---------------------------------------------------------------------------

CREATE VIEW vw_cumplimiento_objetivos AS
SELECT
    id,
    descripcion,
    metrica,
    meta_min,
    meta_max,
    unidad,
    resultado,
    estado,
    nota
FROM objetivo
ORDER BY id;

CREATE VIEW vw_margen_producto AS
SELECT
    pr.codigo,
    pr.nombre,
    pr.unidad_venta,
    pp.precio,
    pp.vigente_desde AS precio_desde,
    pc.costo_unitario,
    pc.vigente_desde AS costo_desde,
    CASE
        WHEN pp.precio IS NOT NULL AND pc.costo_unitario IS NOT NULL
        THEN ROUND(pp.precio - pc.costo_unitario, 2)
    END AS margen_absoluto,
    CASE
        WHEN pp.precio > 0 AND pc.costo_unitario IS NOT NULL
        THEN ROUND(100.0 * (pp.precio - pc.costo_unitario) / pp.precio, 2)
    END AS margen_pct
FROM producto pr
LEFT JOIN LATERAL (
    SELECT precio, vigente_desde
    FROM producto_precio
    WHERE producto_id = pr.id
    ORDER BY vigente_desde DESC
    LIMIT 1
) pp ON TRUE
LEFT JOIN LATERAL (
    SELECT costo_unitario, vigente_desde
    FROM producto_costo
    WHERE producto_id = pr.id
    ORDER BY vigente_desde DESC
    LIMIT 1
) pc ON TRUE
ORDER BY pr.id;

CREATE VIEW vw_proveedores_insumos AS
SELECT
    p.id,
    p.nombre,
    p.tipo,
    p.direccion,
    p.condiciones_pago,
    p.frecuencia_compra,
    p.notas,
    string_agg(i.nombre || ' (' || pi.unidad_compra || ')', ', ' ORDER BY i.nombre) AS insumos
FROM proveedor p
LEFT JOIN proveedor_insumo pi ON pi.proveedor_id = p.id
LEFT JOIN insumo i ON i.id = pi.insumo_id
GROUP BY p.id, p.nombre, p.tipo, p.direccion, p.condiciones_pago, p.frecuencia_compra, p.notas
ORDER BY p.tipo, p.id;

CREATE VIEW vw_costo_docena AS
SELECT
    j.id,
    j.fecha,
    j.tandas,
    SUM(lp.unidades) AS unidades_producidas,
    ROUND(SUM(lp.unidades) / 12.0, 2) AS docenas_producidas,
    j.costo_mano_obra,
    ROUND(j.costo_mano_obra / NULLIF(SUM(lp.unidades) / 12.0, 0), 2) AS mano_obra_por_docena,
    j.costo_insumos,
    CASE
        WHEN j.costo_insumos IS NOT NULL
        THEN ROUND((j.costo_mano_obra + j.costo_insumos) / NULLIF(SUM(lp.unidades) / 12.0, 0), 2)
    END AS costo_total_por_docena
FROM jornada_produccion j
LEFT JOIN lote_produccion lp ON lp.jornada_id = j.id
GROUP BY j.id, j.fecha, j.tandas, j.costo_mano_obra, j.costo_insumos
ORDER BY j.fecha;

-- ---------------------------------------------------------------------------
-- Encuestas
-- ---------------------------------------------------------------------------

CREATE VIEW vw_encuesta_resultados AS
SELECT
    e.id AS encuesta_id,
    e.nombre AS encuesta,
    p.codigo,
    p.texto AS pregunta,
    p.tipo,
    o.etiqueta AS opcion,
    r.cantidad,
    ROUND(100.0 * r.cantidad / e.respuestas, 2) AS porcentaje
FROM encuesta e
JOIN encuesta_pregunta p ON p.encuesta_id = e.id
JOIN encuesta_opcion o ON o.pregunta_id = p.id
JOIN encuesta_resultado r ON r.opcion_id = o.id
ORDER BY e.id, p.orden, o.orden;

CREATE VIEW vw_encuesta_indicadores AS
SELECT
    e.id AS encuesta_id,
    e.nombre AS encuesta,
    p.codigo,
    p.texto AS pregunta,
    i.nombre AS indicador,
    i.valor
FROM encuesta e
JOIN encuesta_pregunta p ON p.encuesta_id = e.id
JOIN encuesta_indicador i ON i.pregunta_id = p.id
ORDER BY e.id, p.orden, i.nombre;

-- ---------------------------------------------------------------------------
-- Control de integridad
-- ---------------------------------------------------------------------------

CREATE VIEW vw_verificacion_integridad AS
SELECT
    chequeo,
    esperado,
    obtenido,
    (ABS(obtenido - esperado) < 0.01) AS ok,
    nota
FROM (
    SELECT 'Capital inicial aportado'::text AS chequeo, 340935.00::numeric AS esperado,
           (SELECT COALESCE(SUM(monto), 0) FROM aporte_capital WHERE tipo = 'inicial') AS obtenido,
           '5 socios x $68.187'::text AS nota
    UNION ALL
    SELECT 'Capital social total', 1160938.00,
           (SELECT COALESCE(SUM(monto), 0) FROM aporte_capital),
           'Aportes iniciales + ampliación agregada'
    UNION ALL
    SELECT 'Activo corriente', 1842937.00,
           (SELECT COALESCE(SUM(importe), 0) FROM estado_patrimonial_rubro WHERE tipo = 'activo_corriente'),
           'Caja y Bancos + Otros Créditos + Bienes de Cambio'
    UNION ALL
    SELECT 'Activo no corriente', 61086.00,
           (SELECT COALESCE(SUM(importe), 0) FROM estado_patrimonial_rubro WHERE tipo = 'activo_no_corriente'),
           'Stand + balanzas'
    UNION ALL
    SELECT 'Activo total', 1904023.00,
           (SELECT COALESCE(SUM(importe), 0) FROM estado_patrimonial_rubro WHERE tipo LIKE 'activo%'),
           'Activo corriente + no corriente'
    UNION ALL
    SELECT 'Pasivo', 292530.00,
           (SELECT COALESCE(SUM(importe), 0) FROM estado_patrimonial_rubro WHERE tipo = 'pasivo'),
           'Remuneraciones pendientes de pago'
    UNION ALL
    SELECT 'Patrimonio neto', 1611493.00,
           (SELECT COALESCE(SUM(importe), 0) FROM estado_patrimonial_rubro WHERE tipo = 'patrimonio_neto'),
           'Capital social + resultado del ejercicio'
    UNION ALL
    SELECT 'Ecuación patrimonial (A - P - PN)', 0.00,
           (SELECT activo_total - pasivo_mas_patrimonio FROM vw_estado_patrimonial),
           'Debe dar cero'
    UNION ALL
    SELECT 'Resultado bruto', 772235.00,
           (SELECT resultado_bruto FROM vw_estado_resultados),
           'Ventas - costo de productos vendidos'
    UNION ALL
    SELECT 'Resultado neto', 450555.00,
           (SELECT resultado_neto FROM vw_estado_resultados),
           'Resultado bruto - sueldos - muestras'
    UNION ALL
    SELECT 'Ventas registradas', 1451937.00,
           (SELECT ventas_registradas FROM vw_reconciliacion_ventas),
           'Suma de ventas por canal'
    UNION ALL
    SELECT 'Distribución de ganancias', 450555.00,
           (SELECT COALESCE(SUM(monto), 0) FROM distribucion_ganancia),
           '5 socios x $90.111'
    UNION ALL
    SELECT 'Participación de los socios', 100.00,
           (SELECT COALESCE(SUM(participacion_pct), 0) FROM socio),
           'Debe sumar 100%'
) t;

CREATE VIEW vw_inconsistencias AS
SELECT
    'punto_equilibrio_mensual'::text AS fuente,
    format('Punto de equilibrio %s-%s', anio, lpad(mes::text, 2, '0')) AS hallazgo,
    (unidades_vendidas - unidades_equilibrio)::text AS esperado,
    resultado_reportado::text AS observado,
    (resultado_reportado - (unidades_vendidas - unidades_equilibrio))::numeric AS diferencia,
    'El informe publica el resultado reportado; el cálculo (vendidas - equilibrio) da otro valor.'::text AS nota
FROM punto_equilibrio_mensual
WHERE resultado_reportado <> unidades_vendidas - unidades_equilibrio

UNION ALL

SELECT
    'venta',
    'Ventas discriminadas por canal vs total del estado de resultados',
    (SELECT SUM(total)::text FROM venta WHERE canal IN ('acto', 'encargo_congelado')),
    (SELECT monto::text FROM estado_resultado_concepto WHERE codigo = 'ventas'),
    (SELECT monto FROM estado_resultado_concepto WHERE codigo = 'ventas')
        - (SELECT SUM(total) FROM venta WHERE canal IN ('acto', 'encargo_congelado')),
    'El informe no detalla $166.987 de ventas; se registran con el canal no_discriminado.'
UNION ALL
SELECT
    'aporte_capital',
    'Origen del capital social restante',
    '340.935 (aportes iniciales documentados)',
    '1.160.938 (capital social final)',
    820003,
    'El informe no explica el desglose de la ampliación de capital.'
;

COMMIT;
