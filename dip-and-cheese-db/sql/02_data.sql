-- ============================================================================
-- Dip&Cheese - Base de datos del microemprendimiento
-- 02_data.sql - Datos tomados del informe final
--
-- Criterios:
--  * Se cargan solo cifras publicadas en el texto del informe.
--  * Cuando el informe no informa un dato (fechas exactas, detalle de compras,
--    precios finales, costos por producto), no se inventa: se deja constancia
--    en "nota" o la tabla queda vacía.
--  * Los importes están en pesos argentinos (ARS).
-- ============================================================================

BEGIN;
SET search_path TO dipcheese, public;
SET client_encoding TO 'UTF8';

-- ---------------------------------------------------------------------------
-- Socios y capital
-- ---------------------------------------------------------------------------

INSERT INTO socio (id, nombre, apellido, participacion_pct) VALUES
    (1, 'Benjamín', 'Cangialosi', 20.00),
    (2, 'Jeremías', 'García',     20.00),
    (3, 'Bruno',    'Moras',      20.00),
    (4, 'Sebastián','Sisterna',   20.00),
    (5, 'Ignacio',  'Ziemba',     20.00);

INSERT INTO aporte_capital (id, socio_id, fecha, monto, tipo, medio_pago, nota) VALUES
    (1, 1, DATE '2026-05-01',  68187.00, 'inicial', 'efectivo', 'Aporte inicial individual. Fecha estimada: el informe no la precisa.'),
    (2, 2, DATE '2026-05-01',  68187.00, 'inicial', 'efectivo', 'Aporte inicial individual. Fecha estimada: el informe no la precisa.'),
    (3, 3, DATE '2026-05-01',  68187.00, 'inicial', 'efectivo', 'Aporte inicial individual. Fecha estimada: el informe no la precisa.'),
    (4, 4, DATE '2026-05-01',  68187.00, 'inicial', 'efectivo', 'Aporte inicial individual. Fecha estimada: el informe no la precisa.'),
    (5, 5, DATE '2026-05-01',  68187.00, 'inicial', 'efectivo', 'Aporte inicial individual. Fecha estimada: el informe no la precisa.'),
    (6, NULL, DATE '2026-10-31', 820003.00, 'ampliacion', 'otro',
        'Diferencia entre el capital social final ($1.160.938) y los aportes iniciales ($340.935). El informe no detalla el desglose por socio ni la fecha.');

INSERT INTO rol (id, nombre, descripcion) VALUES
    (1, 'Dirección general',       'Coordinación general del emprendimiento.'),
    (2, 'Producción',              'Elaboración de chipá, nachos y dips.'),
    (3, 'Comercial y ventas',      'Ventas, pedidos y atención a clientes.'),
    (4, 'Administración y finanzas','Costos, cuentas y recursos financieros.'),
    (5, 'Recursos humanos',        'Organización del equipo, comunicación y clima laboral.'),
    (6, 'Marketing y diseño',      'Marca, redes, menús y materiales.');

INSERT INTO socio_rol (socio_id, rol_id, desde, hasta) VALUES
    (2, 5, DATE '2026-03-01', NULL);

COMMENT ON TABLE socio IS
    'Los 5 socios con 20% cada uno. El resto de las áreas del organigrama figura en los anexos del informe y no se transcribe.';

-- ---------------------------------------------------------------------------
-- Productos
-- ---------------------------------------------------------------------------

INSERT INTO categoria_producto (id, nombre) VALUES
    (1, 'Chipá'),
    (2, 'Nachos'),
    (3, 'Dips'),
    (4, 'Combos');

INSERT INTO producto (id, codigo, nombre, categoria_id, unidad_venta, es_congelado) VALUES
    (1, 'CHIPA-JQ',  'Chipá de jamón y queso',              1, 'porcion', false),
    (2, 'CHIPA-Q',   'Chipá de queso',                      1, 'porcion', false),
    (3, 'NACHOS',    'Nachos',                              2, 'bandeja', false),
    (4, 'DIP-GUAC',  'Dip de guacamole',                    3, 'unidad',  false),
    (5, 'DIP-CHED',  'Dip cheddar',                         3, 'unidad',  false),
    (6, 'DIP-CRIO',  'Dip de salsa criolla',                3, 'unidad',  false),
    (7, 'COMBO',     'Combo chipá + nachos con dos dips',   4, 'combo',   false),
    (8, 'CHIPA-CONG','Chipá congelado',                     1, 'docena',  true);

INSERT INTO producto_precio (id, producto_id, vigente_desde, vigente_hasta, precio, nota) VALUES
    (1, 2, DATE '2026-05-01', NULL, 4500.00,
        'Precio de referencia de la encuesta de preferencia: 58% pagaría $4.500 por una porción de 5 o 6 chipás (promedio $4.188).'),
    (2, 3, DATE '2026-05-01', NULL, 3000.00,
        'Precio de referencia de la encuesta de preferencia: 58% pagaría $3.000 por una bandeja de nachos con dos salsas (promedio $3.138).');

-- ---------------------------------------------------------------------------
-- Insumos y proveedores
-- ---------------------------------------------------------------------------

INSERT INTO insumo (id, nombre, unidad_medida, perecedero) VALUES
    (1,  'Fécula de mandioca',        'kg',      false),
    (2,  'Huevos',                    'unidad',  true),
    (3,  'Queso muzzarella',          'kg',      true),
    (4,  'Queso parmesano',           'kg',      true),
    (5,  'Queso sardo estacionado',   'kg',      true),
    (6,  'Manteca',                   'kg',      true),
    (7,  'Aceite',                    'litro',   false),
    (8,  'Leche',                     'litro',   true),
    (9,  'Sal',                       'kg',      false),
    (10, 'Pimienta',                  'kg',      false),
    (11, 'Polvo de hornear',          'kg',      false),
    (12, 'Verduras',                  'kg',      true),
    (13, 'Queso cheddar',             'kg',      true),
    (14, 'Nachos',                    'bolsa 750 g', false),
    (15, 'Descartables',              'unidad',  false);

INSERT INTO proveedor (id, nombre, tipo, direccion, condiciones_pago, frecuencia_compra, notas) VALUES
    (1, 'Suazo S.R.L.', 'principal', 'Mercado Cooperativo de Guaymallén',
        'Contado o transferencia', 'A demanda, cuando se produce para los actos',
        'Queso sardo y parmesano por kg; muzzarella por horma.'),
    (2, 'Proveedor 2 (fécula de mandioca)', 'principal', 'Mercado Cooperativo de Guaymallén',
        'Contado o transferencia', 'A demanda, menos frecuente que el queso',
        'El informe no consigna la razón social.'),
    (3, 'Nachos Chamaco S.R.L.', 'principal', 'Dorrego (entrega en su casa)',
        'Contado o transferencia', 'A demanda, menos frecuente que el queso',
        'Bolsa de 750 g. Descuento de $1.300 por bolsa comprando 3 o más.'),
    (4, 'La Picada', 'alternativo', NULL, NULL, NULL,
        'Plan B para insumos de producción.'),
    (5, 'Átomo', 'alternativo', NULL, NULL, NULL,
        'Plan B para nachos.');

INSERT INTO proveedor_insumo (id, proveedor_id, insumo_id, unidad_compra, precio_unitario, minimo_compra, descuento_unitario) VALUES
    (1, 1, 3,  'horma',      NULL, NULL, NULL),
    (2, 1, 4,  'kg',         NULL, NULL, NULL),
    (3, 1, 5,  'kg',         NULL, NULL, NULL),
    (4, 2, 1,  'kg',         NULL, NULL, NULL),
    (5, 3, 14, 'bolsa 750 g', NULL, 3,    1300.00);

-- ---------------------------------------------------------------------------
-- Producción
-- ---------------------------------------------------------------------------

INSERT INTO costo_fijo (id, nombre, monto, base, nota) VALUES
    (1, 'Mano de obra', 58506.00, 'jornada',
        'Único costo fijo informado. El informe no aclara si el monto corresponde a una jornada o al período; se interpreta por jornada.');

INSERT INTO jornada_produccion (id, fecha, tandas, costo_mano_obra, costo_insumos, nota) VALUES
    (1, DATE '2026-05-20', 10, 58506.00, NULL,
        'Jornada tipo previa al acto del 22/05. Fecha estimada. Costo de insumos no informado.');

INSERT INTO lote_produccion (id, jornada_id, producto_id, tandas, unidades_por_tanda) VALUES
    (1, 1, 2, 10, 36);

-- ---------------------------------------------------------------------------
-- Ventas
-- ---------------------------------------------------------------------------

INSERT INTO evento (id, nombre, fecha, tipo, lugar) VALUES
    (1, 'Acto del 22 de mayo',   DATE '2026-05-22', 'acto', 'Centro Educativo Dios Padre'),
    (2, 'Acto del 19 de junio',  DATE '2026-06-19', 'acto', 'Centro Educativo Dios Padre'),
    (3, 'Acto del 24 de agosto', DATE '2026-08-24', 'acto', 'Centro Educativo Dios Padre'),
    (4, 'Acto del 9 de octubre', DATE '2026-10-09', 'acto', 'Centro Educativo Dios Padre');

INSERT INTO venta (id, fecha, canal, evento_id, medio_pago, total, unidades, nota) VALUES
    (1, DATE '2026-05-22', 'acto',             1, 'indistinto', 248600.00, NULL, 'Recaudación del acto. El informe no discrimina medios de pago por acto.'),
    (2, DATE '2026-06-19', 'acto',             2, 'indistinto',  68200.00, NULL, 'Recaudación del acto.'),
    (3, DATE '2026-08-24', 'acto',             3, 'indistinto', 125000.00, NULL, 'Recaudación del acto.'),
    (4, DATE '2026-10-09', 'acto',             4, 'indistinto', 159200.00, NULL, 'Recaudación del acto.'),
    (5, DATE '2026-10-31', 'encargo_congelado', NULL, 'indistinto', 683950.00, NULL,
        '52 encargos de chipá congelado fuera del colegio. Fecha de cierre estimada.'),
    (6, DATE '2026-10-31', 'no_discriminado',   NULL, 'indistinto', 166987.00, NULL,
        'Diferencia de conciliación: ventas del informe ($1.451.937) - actos ($601.000) - encargos ($683.950). El informe no detalla estas ventas.');

-- ---------------------------------------------------------------------------
-- Punto de equilibrio
-- ---------------------------------------------------------------------------

INSERT INTO punto_equilibrio_mensual (id, anio, mes, unidades_vendidas, unidades_equilibrio, resultado_reportado) VALUES
    (1, 2026, 5,  551, 161, 396),
    (2, 2026, 6,  473, 188, 285),
    (3, 2026, 8,  180, 205, -25),
    (4, 2026, 9,  318, 136, 182),
    (5, 2026, 10, 600, 149, 451);

-- ---------------------------------------------------------------------------
-- Estados contables
-- ---------------------------------------------------------------------------

INSERT INTO estado_resultado_concepto (id, codigo, concepto, tipo, monto, orden, nota) VALUES
    (1, 'ventas',                   'Ventas totales',                        'ingreso', 1451937.00, 10, NULL),
    (2, 'costo_productos_vendidos', 'Costo de los productos vendidos',       'costo',    679702.00, 20, 'Derivado: ventas ($1.451.937) - resultado bruto ($772.235).'),
    (3, 'sueldos_jornales',         'Sueldos y jornales',                    'gasto',    292530.00, 30, NULL),
    (4, 'muestras_degustaciones',   'Muestras y degustaciones',              'gasto',     29150.00, 40, NULL);

INSERT INTO estado_patrimonial_rubro (id, tipo, rubro, importe, orden) VALUES
    (1, 'activo_corriente',     'Caja y Bancos',                       934217.00, 10),
    (2, 'activo_corriente',     'Otros Créditos',                      850003.00, 20),
    (3, 'activo_corriente',     'Bienes de Cambio',                     58717.00, 30),
    (4, 'activo_no_corriente',  'Stand',                                43086.00, 10),
    (5, 'activo_no_corriente',  'Balanzas de alimentos',                18000.00, 20),
    (6, 'pasivo',               'Remuneraciones pendientes de pago',   292530.00, 10),
    (7, 'patrimonio_neto',      'Capital Social',                     1160938.00, 10),
    (8, 'patrimonio_neto',      'Resultado del ejercicio',             450555.00, 20);

-- ---------------------------------------------------------------------------
-- Objetivos, billeteras y distribución
-- ---------------------------------------------------------------------------

INSERT INTO objetivo (id, descripcion, metrica, meta_min, meta_max, unidad, resultado, estado, nota) VALUES
    (1, 'Generar entre $600.000 y $900.000 de ingresos', 'ingresos', 600000.00, 900000.00, 'ARS', 1451937.00,
        'cumplido', 'Superó el máximo previsto.'),
    (2, 'Vender más de 10 docenas de chipás por acto o jornada', 'docenas_por_acto', 10.00, NULL, 'docenas', NULL,
        'sin_medicion', 'El informe no publica las docenas vendidas por acto.'),
    (3, 'Alcanzar más de 20 docenas de chipás por mes', 'docenas_por_mes', 20.00, NULL, 'docenas', NULL,
        'sin_medicion', 'El informe no publica las docenas vendidas por mes.'),
    (4, 'Recuperar la inversión inicial de los socios', 'inversion_recuperada', 340935.00, NULL, 'ARS', 450555.00,
        'cumplido', 'La ganancia neta supera el capital inicial aportado.'),
    (5, 'Obtener ganancias una vez recuperada la inversión', 'resultado_neto', 0.00, NULL, 'ARS', 450555.00,
        'cumplido', NULL);

INSERT INTO billetera_virtual (id, nombre, rendimiento_mensual_pct) VALUES
    (1, 'Mercado Pago', 1.46),
    (2, 'Naranja',      1.58);

INSERT INTO rendimiento_financiero (id, billetera_id, periodo, monto, nota) VALUES
    (1, NULL, 'mayo-octubre 2026', 7000.00,
        'Aproximado. El informe no discrimina cuánto corresponde a cada billetera.');

INSERT INTO distribucion_ganancia (id, socio_id, periodo, monto) VALUES
    (1, 1, 'mayo-octubre 2026', 90111.00),
    (2, 2, 'mayo-octubre 2026', 90111.00),
    (3, 3, 'mayo-octubre 2026', 90111.00),
    (4, 4, 'mayo-octubre 2026', 90111.00),
    (5, 5, 'mayo-octubre 2026', 90111.00);

-- ---------------------------------------------------------------------------
-- Encuesta de preferencia (40 respuestas, 27/04/2026 a 06/05/2026)
-- ---------------------------------------------------------------------------

INSERT INTO encuesta (id, nombre, tipo, fecha_desde, fecha_hasta, respuestas) VALUES
    (1, 'Encuesta de preferencia', 'preferencia', DATE '2026-04-27', DATE '2026-05-06', 40),
    (2, 'Encuesta de satisfacción', 'satisfaccion', DATE '2026-10-15', DATE '2026-10-31', 19);

INSERT INTO encuesta_pregunta (id, encuesta_id, codigo, texto, tipo, orden) VALUES
    (1,  1, 'aceptacion',        'Aceptación de la idea (escala 1 a 10)',              'escala',   10),
    (2,  1, 'producto_preferido','Producto preferido',                                  'unica',    20),
    (3,  1, 'forma_consumo',     'Forma de consumo preferida',                          'multiple', 30),
    (4,  1, 'salsas',            'Salsas más pedidas',                                  'multiple', 40),
    (5,  1, 'salsa_aparte',      'Prefiere la salsa en recipiente aparte',              'unica',    50),
    (6,  1, 'precio_porcion',    'Precio dispuesto a pagar por una porción de 5 o 6 chipás', 'unica', 60),
    (7,  1, 'precio_bandeja',    'Precio dispuesto a pagar por una bandeja de nachos con dos salsas', 'unica', 70),
    (8,  1, 'momento_compra',    'Momento de compra',                                   'multiple', 80),
    (9,  1, 'medio_pago',        'Medio de pago preferido',                             'unica',    90),
    (10, 1, 'nuevos_productos',  'Interés en nuevos productos',                         'multiple', 100),
    (11, 1, 'motivo_eleccion',   'Motivo para elegirnos',                               'multiple', 110),
    (12, 2, 'sabor',             'Sabor del chipá',                                     'unica',    10),
    (13, 2, 'dips',              'Calificación de los dips',                            'unica',    20),
    (14, 2, 'variedad',          'Suficiencia de variedades',                          'unica',    30),
    (15, 2, 'pedido',            'Facilidad para hacer el pedido',                     'unica',    40),
    (16, 2, 'calidad_precio',    'Relación calidad-precio',                            'unica',    50),
    (17, 2, 'recompra',          '¿Nos volvería a comprar?',                            'unica',    60);

INSERT INTO encuesta_opcion (id, pregunta_id, etiqueta, orden) VALUES
    -- Preferencia
    (1,  1,  'Puntaje 10',                                          10),
    (2,  2,  'Chipá',                                               10),
    (3,  2,  'Combo de chipá y nachos',                             20),
    (4,  2,  'Nachos con dips',                                     30),
    (5,  3,  'Recién salido del horno',                             10),
    (6,  3,  'Crocante por fuera y suave por dentro',               20),
    (7,  4,  'Guacamole',                                           10),
    (8,  4,  'Cheddar',                                             20),
    (9,  4,  'Salsa criolla',                                       30),
    (10, 5,  'Prefiere la salsa en recipiente aparte',              10),
    (11, 6,  '$4.500',                                              10),
    (12, 6,  '$3.500',                                              20),
    (13, 7,  '$3.000',                                              10),
    (14, 8,  'Recreo del mediodía',                                 10),
    (15, 8,  'Viernes',                                             20),
    (16, 9,  'Indistinto',                                          10),
    (17, 9,  'Transferencia',                                       20),
    (18, 9,  'Efectivo',                                            30),
    (19, 10, 'Chipá relleno',                                       10),
    (20, 10, 'Compra por encargo fuera del colegio',                20),
    (21, 10, 'Pack para compartir',                                 30),
    (22, 11, 'Es casero',                                           10),
    (23, 11, 'Es algo diferente',                                   20),
    -- Satisfacción
    (24, 12, 'Delicioso',                                           10),
    (25, 12, 'Rico',                                                20),
    (26, 12, 'Decente',                                             30),
    (27, 12, 'Sin respuesta',                                       40),
    (28, 13, 'Ricos',                                               10),
    (29, 14, 'Dos variedades son suficientes',                      10),
    (30, 14, 'Debería tener más variedades',                        20),
    (31, 15, 'Fácil',                                               10),
    (32, 16, 'Adecuada',                                            10),
    (33, 16, 'Barato',                                              20),
    (34, 17, 'Sí',                                                  10),
    (35, 17, 'No',                                                  20),
    (36, 17, 'Sin respuesta',                                       30);

INSERT INTO encuesta_resultado (id, opcion_id, cantidad) VALUES
    (1,  1,  28),
    (2,  2,  23),
    (3,  3,  15),
    (4,  4,   2),
    (5,  5,  27),
    (6,  6,  22),
    (7,  7,  29),
    (8,  8,  20),
    (9,  9,  12),
    (10, 10, 36),
    (11, 11, 23),
    (12, 12, 14),
    (13, 13, 23),
    (14, 14, 23),
    (15, 15, 29),
    (16, 16, 22),
    (17, 17, 17),
    (18, 18,  1),
    (19, 19, 31),
    (20, 20, 32),
    (21, 21, 33),
    (22, 22, 22),
    (23, 23, 17),
    (24, 24, 16),
    (25, 25,  1),
    (26, 26,  1),
    (27, 27,  1),
    (28, 28, 19),
    (29, 29, 18),
    (30, 30,  1),
    (31, 31, 19),
    (32, 32, 17),
    (33, 33,  2),
    (34, 34, 17),
    (35, 35,  1),
    (36, 36,  1);

INSERT INTO encuesta_indicador (id, pregunta_id, nombre, valor) VALUES
    (1, 1, 'Promedio (escala 1-10)', 9.40),
    (2, 6, 'Precio promedio',        4188.00),
    (3, 7, 'Precio promedio',        3138.00);

-- ---------------------------------------------------------------------------
-- Ajuste de secuencias de identidad (los datos usan ids explícitos)
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    t      text;
    seq    text;
    maxid  bigint;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'socio', 'aporte_capital', 'rol', 'categoria_producto', 'producto',
        'producto_precio', 'producto_costo', 'insumo', 'proveedor',
        'proveedor_insumo', 'compra', 'detalle_compra', 'costo_fijo',
        'jornada_produccion', 'lote_produccion', 'evento', 'venta',
        'detalle_venta', 'punto_equilibrio_mensual', 'estado_resultado_concepto',
        'estado_patrimonial_rubro', 'objetivo', 'billetera_virtual',
        'rendimiento_financiero', 'distribucion_ganancia', 'encuesta',
        'encuesta_pregunta', 'encuesta_opcion', 'encuesta_resultado',
        'encuesta_indicador'
    ]
    LOOP
        seq := pg_get_serial_sequence('dipcheese.' || t, 'id');
        IF seq IS NOT NULL THEN
            EXECUTE format('SELECT MAX(id) FROM dipcheese.%I', t) INTO maxid;
            IF maxid IS NULL THEN
                PERFORM setval(seq, 1, false);
            ELSE
                PERFORM setval(seq, maxid, true);
            END IF;
        END IF;
    END LOOP;
END $$;

COMMIT;
