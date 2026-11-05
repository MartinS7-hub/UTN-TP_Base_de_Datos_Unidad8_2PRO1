-- ============================================================================
-- Dip&Cheese - Base de datos del microemprendimiento
-- 05_verificacion.sql - Controles automáticos de integridad
--
-- Falla (RAISE EXCEPTION) si algún total no coincide con el informe.
-- Las discrepancias del documento fuente se listan aparte, sin abortar.
-- ============================================================================

SET search_path TO dipcheese, public;

\echo '== Controles de integridad =='
SELECT chequeo, esperado, obtenido, ok, nota
FROM vw_verificacion_integridad
ORDER BY ok, chequeo;

\echo '== Discrepancias / datos no documentados en el informe =='
SELECT fuente, hallazgo, esperado, observado, diferencia, nota
FROM vw_inconsistencias;

DO $$
DECLARE
    fallos integer;
BEGIN
    SELECT COUNT(*) INTO fallos
    FROM vw_verificacion_integridad
    WHERE NOT ok;

    IF fallos > 0 THEN
        RAISE EXCEPTION 'Verificación fallida: % control(es) no coinciden con el informe.', fallos;
    END IF;

    RAISE NOTICE 'Verificación OK: todos los totales coinciden con el informe.';
END $$;
