/*
============================================================
ZOOTECH - SEED DATA
CATALOGOS / DATOS MAESTROS DE LA BASE DE DATOS DE TENANT
SQL SERVER 2025
============================================================

Version corregida y validada contra el esquema del bacpac
"Database Backup - Tenant - ZooTech" (52 tablas) y contra los
datos de catalogo contenidos en ese mismo respaldo.

Incluye unicamente:
 - Catalogos de vacuno, produccion, sanidad/triaje, reproduccion
   y responsables
 - Catalogos tecnicos: modulos, tipos de archivo, formatos de reporte
 - Ubicacion geografica del tenant (variables de entorno)
 - Configuracion de celo

No incluye: usuarios, responsables, granjas, vacunos, ordenios, triajes,
celo, fecundaciones, auditoria, archivos ni historiales.
Tampoco inserta cat_tipo_reporte ni parametro_sistema (en el respaldo
estan vacias).

Idempotente: cada fila se inserta solo si su clave (code / codigo /
extension / nombre) todavia no existe.

Variables de scripting de sqlcmd requeridas (ubicacion del tenant):
   ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE   (2 caracteres)
   ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO
   ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE      (4 caracteres)
   ZOOTECH_TENANT_ADDRESS_PROVINCIA
   ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE       (6 caracteres)
   ZOOTECH_TENANT_ADDRESS_DISTRITO

Guardar el archivo en UTF-8 (sin BOM). Si en Linux los acentos se
ven mal, ejecutar sqlcmd con -f 65001.
============================================================
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;

    /* ========================================================
       0. VALIDACION DE VARIABLES DE UBICACION
       (si sqlcmd no pudo sustituir una variable, el texto
        queda como "$(...)" y rompe codigos varchar(2/4/6))
       ======================================================== */

    IF  LEFT(N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE)', 2) = N'$' + N'('
     OR LEFT(N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO)', 2)      = N'$' + N'('
     OR LEFT(N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE)', 2)    = N'$' + N'('
     OR LEFT(N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA)', 2)         = N'$' + N'('
     OR LEFT(N'$(ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE)', 2)     = N'$' + N'('
     OR LEFT(N'$(ZOOTECH_TENANT_ADDRESS_DISTRITO)', 2)          = N'$' + N'('
        THROW 50001, 'Variables ZOOTECH_TENANT_ADDRESS_* no definidas.', 1;

    IF  LEN(N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE)') <> 2
     OR LEN(N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE)')    <> 4
     OR LEN(N'$(ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE)')     <> 6
        THROW 50002, 'Codigos de ubicacion invalidos: se esperan 2, 4 y 6 caracteres (departamento, provincia, distrito).', 1;

    IF  LEFT(N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE)', 2) <> N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE)'
     OR LEFT(N'$(ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE)', 4)  <> N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE)'
        THROW 50003, 'Los codigos de provincia y distrito no son coherentes con el codigo de departamento/provincia.', 1;


    /* ========================================================
       1. CAT_SEXO
       ======================================================== */

    INSERT INTO dbo.cat_sexo (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'HEMBRA', N'Hembra', N'Animal femenino'),
        (N'MACHO', N'Macho', N'Animal masculino'),
        (N'ND', N'No Definido', N'Sexo no determinado')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_sexo t WHERE t.code = v.code);

    /* ========================================================
       2. CAT_ESTADO_VACUNO
       ======================================================== */

    INSERT INTO dbo.cat_estado_vacuno (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'CUARENTENA', N'Cuarentena', N'Animal en período de cuarentena'),
        (N'ENFERMO', N'Enfermo', N'Animal con enfermedad diagnosticada'),
        (N'MUERTO', N'Muerto', N'Animal fallecido o dado de baja por muerte'),
        (N'SANO', N'Sano', N'Animal en buen estado de salud')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_estado_vacuno t WHERE t.code = v.code);

    /* ========================================================
       3. CAT_ESTADO_REGISTRO
       ======================================================== */

    INSERT INTO dbo.cat_estado_registro (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'ACTIVO', N'Activo', N'Registro activo en el sistema'),
        (N'ELIMINADO', N'Eliminado', N'Registro eliminado lógicamente'),
        (N'INACTIVO', N'Inactivo', N'Registro inactivo')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_estado_registro t WHERE t.code = v.code);

    /* ========================================================
       4. CAT_TIPO_ADQUISICION
       ======================================================== */

    INSERT INTO dbo.cat_tipo_adquisicion (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'COMPRA', N'Compra', N'Adquirido por compra directa'),
        (N'DONACION', N'Donación', N'Recibido por donación'),
        (N'NACIMIENTO', N'Nacimiento', N'Nacido en la granja')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_adquisicion t WHERE t.code = v.code);

    /* ========================================================
       5. CAT_TIPO_UTILIZACION
       ======================================================== */

    INSERT INTO dbo.cat_tipo_utilizacion (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'CARNE', N'Producción de Carne', N'Vacuno para producción cárnica'),
        (N'LECHE', N'Producción de Leche', N'Vacuno para producción lechera'),
        (N'REPRODUCCION', N'Reproducción', N'Vacuno para reproducción')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_utilizacion t WHERE t.code = v.code);

    /* ========================================================
       6. CAT_RAZA
       ======================================================== */

    INSERT INTO dbo.cat_raza (code, nombre)
    SELECT v.code, v.nombre
    FROM (VALUES
        (N'BROWN_SWISS', N'Brown Swiss'),
        (N'HOLSTEIN', N'Holstein'),
        (N'JERSEY', N'Jersey')
    ) AS v (code, nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_raza t WHERE t.code = v.code);

    /* ========================================================
       7. CAT_COLOR
       ======================================================== */

    INSERT INTO dbo.cat_color (code, nombre)
    SELECT v.code, v.nombre
    FROM (VALUES
        (N'BEIGE', N'Beige'),
        (N'MARRON', N'Marrón'),
        (N'NEGRO_BLANCO', N'Negro y Blanco')
    ) AS v (code, nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_color t WHERE t.code = v.code);

    /* ========================================================
       8. CAT_ESTADO_ORDENIO
       ======================================================== */

    INSERT INTO dbo.cat_estado_ordenio (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'ACTIVO', N'Activo', N'Ordeño registrado correctamente'),
        (N'ANULADO', N'Anulado', N'Ordeño anulado por error'),
        (N'PENDIENTE', N'Pendiente', N'Ordeño pendiente de verificación')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_estado_ordenio t WHERE t.code = v.code);

    /* ========================================================
       9. CAT_ESTADO_SEQUIA
       ======================================================== */

    INSERT INTO dbo.cat_estado_sequia (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'EN_SEQUIA', N'En Sequía', N'Vacuno en período de sequía'),
        (N'FINALIZADO', N'Finalizado', N'Período de sequía finalizado'),
        (N'SUSPENDIDO', N'Suspendido', N'Sequía suspendida por tratamiento')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_estado_sequia t WHERE t.code = v.code);

    /* ========================================================
       10. CAT_TIPO_PESO (TRIAJE)
       ======================================================== */

    INSERT INTO dbo.cat_tipo_peso (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'CONTROL', N'Peso de Control', N'Peso de control periódico'),
        (N'FINAL', N'Peso Final', N'Peso al momento de salida'),
        (N'INICIAL', N'Peso Inicial', N'Peso al momento de ingreso')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_peso t WHERE t.code = v.code);

    /* ========================================================
       11. CAT_ESTADO_CELO
       ======================================================== */

    INSERT INTO dbo.cat_estado_celo (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'CONFIRMADO', N'Confirmado', N'Celo confirmado por veterinario'),
        (N'DETECTADO', N'Detectado', N'Celo detectado y registrado'),
        (N'DUDOSO', N'Dudoso', N'Celo con señales dudosas')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_estado_celo t WHERE t.code = v.code);

    /* ========================================================
       12. CAT_CARACTERISTICA_CELO
       ======================================================== */

    INSERT INTO dbo.cat_caracteristica_celo (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'INQUIETA', N'Inquieta', N'Animal muestra inquietud'),
        (N'MONTA', N'Acepta monta', N'La vaca acepta ser montada'),
        (N'VULVA_INFLAMADA', N'Vulva inflamada', N'Signos físicos visibles')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_caracteristica_celo t WHERE t.code = v.code);

    /* ========================================================
       13. CAT_TIPO_FECUNDACION
       ======================================================== */

    INSERT INTO dbo.cat_tipo_fecundacion (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'INSEMINACION_ARTIFICIAL', N'Inseminación Artificial', N'Fecundación por inseminación artificial'),
        (N'MONTA_NATURAL', N'Monta Natural', N'Fecundación por monta natural'),
        (N'TRANSFERENCIA_EMBRION', N'Transferencia de Embrión', N'Fecundación por transferencia embrionaria')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_fecundacion t WHERE t.code = v.code);

    /* ========================================================
       14. CAT_RESULTADO_FECUNDACION
       ======================================================== */

    INSERT INTO dbo.cat_resultado_fecundacion (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'EXITOSO', N'Exitoso', N'Fecundación resultó exitosa'),
        (N'FALLIDO', N'Fallido', N'Fecundación no tuvo éxito'),
        (N'PENDIENTE', N'Pendiente', N'Resultado pendiente de confirmación')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_resultado_fecundacion t WHERE t.code = v.code);

    /* ========================================================
       15. CAT_ESTADO_FECUNDACION_VACUNO
       ======================================================== */

    INSERT INTO dbo.cat_estado_fecundacion_vacuno (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'EN_ESPERA', N'En Espera', N'Esperando resultado de fecundación'),
        (N'GESTANTE', N'Gestante', N'Vacuno en período de gestación'),
        (N'VACIA', N'Vacía', N'Vacuno sin gestación activa')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_estado_fecundacion_vacuno t WHERE t.code = v.code);

    /* ========================================================
       16. CAT_ESTADO_TRAZABILIDAD
       ======================================================== */

    INSERT INTO dbo.cat_estado_trazabilidad (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'DUDOSA', N'Dudosa', N'Trazabilidad con dudas'),
        (N'INVALIDA', N'Inválida', N'Trazabilidad inválida'),
        (N'VALIDA', N'Válida', N'Trazabilidad válida y confirmada')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_estado_trazabilidad t WHERE t.code = v.code);

    /* ========================================================
       17. CAT_TIPO_RESPONSABLE
       ======================================================== */

    INSERT INTO dbo.cat_tipo_responsable (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'ENCARGADO', N'Encargado', N'Encargado de granja'),
        (N'TECNICO', N'Técnico', N'Técnico agropecuario'),
        (N'VETERINARIO', N'Veterinario', N'Médico veterinario')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_responsable t WHERE t.code = v.code);

    /* ========================================================
       18. CAT_MODULO
       ======================================================== */

    INSERT INTO dbo.cat_modulo (code, nombre, descripcion)
    SELECT v.code, v.nombre, v.descripcion
    FROM (VALUES
        (N'LECHE', N'Producción de Leche', N'Control de ordeño y producción'),
        (N'REPRODUCCION', N'Reproducción', N'Control reproductivo y fecundación'),
        (N'VACUNO', N'Gestión de Vacunos', N'Módulo principal de vacunos')
    ) AS v (code, nombre, descripcion)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_modulo t WHERE t.code = v.code);

    /* ========================================================
       19. CAT_TIPO_ARCHIVO
       ======================================================== */

    INSERT INTO dbo.cat_tipo_archivo (extension, mime_type)
    SELECT v.extension, v.mime_type
    FROM (VALUES
        (N'.jpg', N'image/jpeg'),
        (N'.pdf', N'application/pdf'),
        (N'.xlsx', N'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    ) AS v (extension, mime_type)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_archivo t WHERE t.extension = v.extension);

    /* ========================================================
       20. CAT_FORMATO_REPORTE
       ======================================================== */

    INSERT INTO dbo.cat_formato_reporte (code, nombre)
    SELECT v.code, v.nombre
    FROM (VALUES
        (N'CSV', N'CSV'),
        (N'EXCEL', N'Excel'),
        (N'PDF', N'PDF')
    ) AS v (code, nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.cat_formato_reporte t WHERE t.code = v.code);

    /* ========================================================
       21. UBICACION - DEPARTAMENTO
       ======================================================== */

    INSERT INTO dbo.geo_departamento (codigo, nombre)
    SELECT v.codigo, v.nombre
    FROM (VALUES
        (N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE)', N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO)')
    ) AS v (codigo, nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.geo_departamento t WHERE t.codigo = v.codigo);

    /* ========================================================
       22. UBICACION - PROVINCIA
       ======================================================== */

    INSERT INTO dbo.geo_provincia (codigo, departamento_codigo, nombre)
    SELECT v.codigo, v.departamento_codigo, v.nombre
    FROM (VALUES
        (N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE)', N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE)', N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA)')
    ) AS v (codigo, departamento_codigo, nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.geo_provincia t WHERE t.codigo = v.codigo);

    /* ========================================================
       23. UBICACION - DISTRITO
       ======================================================== */

    INSERT INTO dbo.geo_distrito (codigo, provincia_codigo, nombre)
    SELECT v.codigo, v.provincia_codigo, v.nombre
    FROM (VALUES
        (N'$(ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE)', N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE)', N'$(ZOOTECH_TENANT_ADDRESS_DISTRITO)')
    ) AS v (codigo, provincia_codigo, nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.geo_distrito t WHERE t.codigo = v.codigo);

    /* ========================================================
       24. CONFIGURACION DE CELO
       (created_by queda NULL: no se siembran usuarios)
       ======================================================== */

    INSERT INTO dbo.celo_configuracion
        (nombre, dias_ciclo_estandar, dias_alerta_previa, dias_tolerancia_posterior, activo, created_by)
    SELECT v.nombre, v.dias_ciclo_estandar, v.dias_alerta_previa, v.dias_tolerancia_posterior, 1, NULL
    FROM (VALUES
        (N'Configuración Estándar Bovina', 21, 3, 2)
    ) AS v (nombre, dias_ciclo_estandar, dias_alerta_previa, dias_tolerancia_posterior)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.celo_configuracion t WHERE t.nombre = v.nombre);

    /* ========================================================
       COMMIT
       ======================================================== */

    COMMIT TRANSACTION;

    PRINT '============================================================';
    PRINT 'CATALOGOS ZOOTECH INSERTADOS CORRECTAMENTE';
    PRINT '============================================================';

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR DURANTE EL SEED DE CATALOGOS.';

    THROW;

END CATCH;
GO


/* ============================================================
   RESUMEN
   ============================================================ */


SELECT 'cat_sexo' AS tabla, COUNT(*) AS cantidad FROM dbo.cat_sexo
UNION ALL

SELECT 'cat_estado_vacuno', COUNT(*) FROM dbo.cat_estado_vacuno
UNION ALL

SELECT 'cat_estado_registro', COUNT(*) FROM dbo.cat_estado_registro
UNION ALL

SELECT 'cat_tipo_adquisicion', COUNT(*) FROM dbo.cat_tipo_adquisicion
UNION ALL

SELECT 'cat_tipo_utilizacion', COUNT(*) FROM dbo.cat_tipo_utilizacion
UNION ALL

SELECT 'cat_raza', COUNT(*) FROM dbo.cat_raza
UNION ALL

SELECT 'cat_color', COUNT(*) FROM dbo.cat_color
UNION ALL

SELECT 'cat_estado_ordenio', COUNT(*) FROM dbo.cat_estado_ordenio
UNION ALL

SELECT 'cat_estado_sequia', COUNT(*) FROM dbo.cat_estado_sequia
UNION ALL

SELECT 'cat_tipo_peso', COUNT(*) FROM dbo.cat_tipo_peso
UNION ALL

SELECT 'cat_estado_celo', COUNT(*) FROM dbo.cat_estado_celo
UNION ALL

SELECT 'cat_caracteristica_celo', COUNT(*) FROM dbo.cat_caracteristica_celo
UNION ALL

SELECT 'cat_tipo_fecundacion', COUNT(*) FROM dbo.cat_tipo_fecundacion
UNION ALL

SELECT 'cat_resultado_fecundacion', COUNT(*) FROM dbo.cat_resultado_fecundacion
UNION ALL

SELECT 'cat_estado_fecundacion_vacuno', COUNT(*) FROM dbo.cat_estado_fecundacion_vacuno
UNION ALL

SELECT 'cat_estado_trazabilidad', COUNT(*) FROM dbo.cat_estado_trazabilidad
UNION ALL

SELECT 'cat_tipo_responsable', COUNT(*) FROM dbo.cat_tipo_responsable
UNION ALL

SELECT 'cat_modulo', COUNT(*) FROM dbo.cat_modulo
UNION ALL

SELECT 'cat_tipo_archivo', COUNT(*) FROM dbo.cat_tipo_archivo
UNION ALL

SELECT 'cat_formato_reporte', COUNT(*) FROM dbo.cat_formato_reporte
UNION ALL

SELECT 'geo_departamento', COUNT(*) FROM dbo.geo_departamento
UNION ALL

SELECT 'geo_provincia', COUNT(*) FROM dbo.geo_provincia
UNION ALL

SELECT 'geo_distrito', COUNT(*) FROM dbo.geo_distrito
UNION ALL

SELECT 'celo_configuracion', COUNT(*) FROM dbo.celo_configuracion

ORDER BY tabla;