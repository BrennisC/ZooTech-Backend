/*
============================================================
ZOOTECH - SEED DATA
CATÁLOGOS / DATOS MAESTROS
SQL SERVER 2025
============================================================

Incluye únicamente:

- Catálogos de sexo
- Estados de vacuno
- Estados generales de registro
- Tipos de adquisición
- Tipos de utilización
- Razas
- Colores
- Estados de ordeño
- Estados de sequía
- Tipos de peso / triaje
- Estados de celo
- Características de celo
- Tipos de fecundación
- Resultados de fecundación
- Estados de fecundación del vacuno
- Estados de trazabilidad
- Tipos de responsable
- Información geográfica
- Configuración de celo

No incluye:

- Usuarios
- Responsables
- Granjas
- Vacunos
- Ordeños
- Triajes
- Celo
- Fecundaciones
- Auditoría
- Archivos
- Historiales

El script es idempotente:
si el código/nombre ya existe, no vuelve a insertarlo.
============================================================
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;


    /* ========================================================
       1. CAT_SEXO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_sexo
        WHERE code = 'HEMBRA'
    )
    BEGIN
        INSERT INTO cat_sexo
        (
            code,
            nombre
        )
        VALUES
        (
            'HEMBRA',
            'Hembra'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_sexo
        WHERE code = 'MACHO'
    )
    BEGIN
        INSERT INTO cat_sexo
        (
            code,
            nombre
        )
        VALUES
        (
            'MACHO',
            'Macho'
        );
    END;


    /* ========================================================
       2. CAT_ESTADO_VACUNO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_vacuno
        WHERE code = 'VIVO'
    )
    BEGIN
        INSERT INTO cat_estado_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'VIVO',
            'Vivo'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_vacuno
        WHERE code = 'MUERTO'
    )
    BEGIN
        INSERT INTO cat_estado_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'MUERTO',
            'Muerto'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_vacuno
        WHERE code = 'VENDIDO'
    )
    BEGIN
        INSERT INTO cat_estado_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'VENDIDO',
            'Vendido'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_vacuno
        WHERE code = 'TRASLADADO'
    )
    BEGIN
        INSERT INTO cat_estado_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'TRASLADADO',
            'Trasladado'
        );
    END;


    /* ========================================================
       3. CAT_ESTADO_REGISTRO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_registro
        WHERE code = 'ACTIVO'
    )
    BEGIN
        INSERT INTO cat_estado_registro
        (
            code,
            nombre
        )
        VALUES
        (
            'ACTIVO',
            'Activo'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_registro
        WHERE code = 'ELIMINADO_LOGICO'
    )
    BEGIN
        INSERT INTO cat_estado_registro
        (
            code,
            nombre
        )
        VALUES
        (
            'ELIMINADO_LOGICO',
            'Eliminado lógico'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_registro
        WHERE code = 'ANULADO'
    )
    BEGIN
        INSERT INTO cat_estado_registro
        (
            code,
            nombre
        )
        VALUES
        (
            'ANULADO',
            'Anulado'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_registro
        WHERE code = 'DESHABILITADO'
    )
    BEGIN
        INSERT INTO cat_estado_registro
        (
            code,
            nombre
        )
        VALUES
        (
            'DESHABILITADO',
            'Deshabilitado'
        );
    END;


    /* ========================================================
       4. CAT_TIPO_ADQUISICION
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_adquisicion
        WHERE code = 'COMPRA'
    )
    BEGIN
        INSERT INTO cat_tipo_adquisicion
        (
            code,
            nombre
        )
        VALUES
        (
            'COMPRA',
            'Compra'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_adquisicion
        WHERE code = 'NACIMIENTO_GRANJA'
    )
    BEGIN
        INSERT INTO cat_tipo_adquisicion
        (
            code,
            nombre
        )
        VALUES
        (
            'NACIMIENTO_GRANJA',
            'Nacimiento en granja'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_adquisicion
        WHERE code = 'DONACION'
    )
    BEGIN
        INSERT INTO cat_tipo_adquisicion
        (
            code,
            nombre
        )
        VALUES
        (
            'DONACION',
            'Donación'
        );
    END;


    /* ========================================================
       5. CAT_TIPO_UTILIZACION
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_utilizacion
        WHERE code = 'LECHE'
    )
    BEGIN
        INSERT INTO cat_tipo_utilizacion
        (
            code,
            nombre
        )
        VALUES
        (
            'LECHE',
            'Leche'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_utilizacion
        WHERE code = 'CARNE'
    )
    BEGIN
        INSERT INTO cat_tipo_utilizacion
        (
            code,
            nombre
        )
        VALUES
        (
            'CARNE',
            'Carne'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_utilizacion
        WHERE code = 'REPRODUCCION'
    )
    BEGIN
        INSERT INTO cat_tipo_utilizacion
        (
            code,
            nombre
        )
        VALUES
        (
            'REPRODUCCION',
            'Reproducción'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_utilizacion
        WHERE code = 'DOBLE_PROPOSITO'
    )
    BEGIN
        INSERT INTO cat_tipo_utilizacion
        (
            code,
            nombre
        )
        VALUES
        (
            'DOBLE_PROPOSITO',
            'Doble propósito'
        );
    END;


    /* ========================================================
       6. CAT_RAZA
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_raza
        WHERE code = 'HOLSTEIN'
    )
    BEGIN
        INSERT INTO cat_raza
        (
            code,
            nombre
        )
        VALUES
        (
            'HOLSTEIN',
            'Holstein'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_raza
        WHERE code = 'BROWN_SWISS'
    )
    BEGIN
        INSERT INTO cat_raza
        (
            code,
            nombre
        )
        VALUES
        (
            'BROWN_SWISS',
            'Brown Swiss'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_raza
        WHERE code = 'JERSEY'
    )
    BEGIN
        INSERT INTO cat_raza
        (
            code,
            nombre
        )
        VALUES
        (
            'JERSEY',
            'Jersey'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_raza
        WHERE code = 'SIMMENTAL'
    )
    BEGIN
        INSERT INTO cat_raza
        (
            code,
            nombre
        )
        VALUES
        (
            'SIMMENTAL',
            'Simmental'
        );
    END;


    /* ========================================================
        7. CAT_COLOR
        ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_color
        WHERE code = 'NEGRO'
    )
    BEGIN
        INSERT INTO dbo.cat_color
        (
            code,
            nombre
        )
        VALUES
        (
            'NEGRO',
            'Negro'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_color
        WHERE code = 'BLANCO'
    )
    BEGIN
        INSERT INTO dbo.cat_color
        (
            code,
            nombre
        )
        VALUES
        (
            'BLANCO',
            'Blanco'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_color
        WHERE code = 'MARRON'
    )
    BEGIN
        INSERT INTO dbo.cat_color
        (
            code,
            nombre
        )
        VALUES
        (
            'MARRON',
            'Marrón'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_color
        WHERE code = 'BLANCO_NEGRO'
    )
    BEGIN
        INSERT INTO dbo.cat_color
        (
            code,
            nombre
        )
        VALUES
        (
            'BLANCO_NEGRO',
            'Blanco y negro'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.cat_color
        WHERE code = 'CAFE'
    )
    BEGIN
        INSERT INTO dbo.cat_color
        (
            code,
            nombre
        )
        VALUES
        (
            'CAFE',
            'Café'
        );
    END;

    /* ========================================================
       8. CAT_ESTADO_ORDENIO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_ordenio
        WHERE code = 'ACTIVO'
    )
    BEGIN
        INSERT INTO cat_estado_ordenio
        (
            code,
            nombre
        )
        VALUES
        (
            'ACTIVO',
            'Activo'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_ordenio
        WHERE code = 'ELIMINADO_LOGICO'
    )
    BEGIN
        INSERT INTO cat_estado_ordenio
        (
            code,
            nombre
        )
        VALUES
        (
            'ELIMINADO_LOGICO',
            'Eliminado lógico'
        );
    END;


    /* ========================================================
       9. CAT_ESTADO_SEQUIA
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_sequia
        WHERE code = 'NO_SEQUIA'
    )
    BEGIN
        INSERT INTO cat_estado_sequia
        (
            code,
            nombre
        )
        VALUES
        (
            'NO_SEQUIA',
            'No sequía'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_sequia
        WHERE code = 'POR_ENTRAR'
    )
    BEGIN
        INSERT INTO cat_estado_sequia
        (
            code,
            nombre
        )
        VALUES
        (
            'POR_ENTRAR',
            'Por entrar'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_sequia
        WHERE code = 'EN_SEQUIA'
    )
    BEGIN
        INSERT INTO cat_estado_sequia
        (
            code,
            nombre
        )
        VALUES
        (
            'EN_SEQUIA',
            'En sequía'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_sequia
        WHERE code = 'FINALIZADA'
    )
    BEGIN
        INSERT INTO cat_estado_sequia
        (
            code,
            nombre
        )
        VALUES
        (
            'FINALIZADA',
            'Finalizada'
        );
    END;


    /* ========================================================
       10. CAT_TIPO_PESO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_peso
        WHERE code = 'RUTINARIO'
    )
    BEGIN
        INSERT INTO cat_tipo_peso
        (
            code,
            nombre
        )
        VALUES
        (
            'RUTINARIO',
            'Rutinario'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_peso
        WHERE code = 'CONTROL'
    )
    BEGIN
        INSERT INTO cat_tipo_peso
        (
            code,
            nombre
        )
        VALUES
        (
            'CONTROL',
            'Control'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_peso
        WHERE code = 'NACIMIENTO'
    )
    BEGIN
        INSERT INTO cat_tipo_peso
        (
            code,
            nombre
        )
        VALUES
        (
            'NACIMIENTO',
            'Nacimiento'
        );
    END;


    /* ========================================================
       11. CAT_ESTADO_CELO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_celo
        WHERE code = 'PROXIMO'
    )
    BEGIN
        INSERT INTO cat_estado_celo
        (
            code,
            nombre
        )
        VALUES
        (
            'PROXIMO',
            'Próximo'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_celo
        WHERE code = 'EN_CELO'
    )
    BEGIN
        INSERT INTO cat_estado_celo
        (
            code,
            nombre
        )
        VALUES
        (
            'EN_CELO',
            'En celo'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_celo
        WHERE code = 'PASO'
    )
    BEGIN
        INSERT INTO cat_estado_celo
        (
            code,
            nombre
        )
        VALUES
        (
            'PASO',
            'Pasó'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_celo
        WHERE code = 'SIN_DATOS'
    )
    BEGIN
        INSERT INTO cat_estado_celo
        (
            code,
            nombre
        )
        VALUES
        (
            'SIN_DATOS',
            'Sin datos'
        );
    END;


    /* ========================================================
       12. CAT_CARACTERISTICA_CELO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_caracteristica_celo
        WHERE nombre = 'Inquietud'
    )
    BEGIN
        INSERT INTO cat_caracteristica_celo
        (
            nombre
        )
        VALUES
        (
            'Inquietud'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_caracteristica_celo
        WHERE nombre = 'Mucosidad'
    )
    BEGIN
        INSERT INTO cat_caracteristica_celo
        (
            nombre
        )
        VALUES
        (
            'Mucosidad'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_caracteristica_celo
        WHERE nombre = 'Monta a otras vacas'
    )
    BEGIN
        INSERT INTO cat_caracteristica_celo
        (
            nombre
        )
        VALUES
        (
            'Monta a otras vacas'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_caracteristica_celo
        WHERE nombre = 'Baja producción'
    )
    BEGIN
        INSERT INTO cat_caracteristica_celo
        (
            nombre
        )
        VALUES
        (
            'Baja producción'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_caracteristica_celo
        WHERE nombre = 'Vocalización'
    )
    BEGIN
        INSERT INTO cat_caracteristica_celo
        (
            nombre
        )
        VALUES
        (
            'Vocalización'
        );
    END;


    /* ========================================================
       13. CAT_TIPO_FECUNDACION
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_fecundacion
        WHERE code = 'MONTA_NATURAL'
    )
    BEGIN
        INSERT INTO cat_tipo_fecundacion
        (
            code,
            nombre
        )
        VALUES
        (
            'MONTA_NATURAL',
            'Monta natural'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_fecundacion
        WHERE code = 'INSEMINACION_ARTIFICIAL'
    )
    BEGIN
        INSERT INTO cat_tipo_fecundacion
        (
            code,
            nombre
        )
        VALUES
        (
            'INSEMINACION_ARTIFICIAL',
            'Inseminación artificial'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_fecundacion
        WHERE code = 'TRANSFERENCIA_EMBRIONES'
    )
    BEGIN
        INSERT INTO cat_tipo_fecundacion
        (
            code,
            nombre
        )
        VALUES
        (
            'TRANSFERENCIA_EMBRIONES',
            'Transferencia de embriones'
        );
    END;


    /* ========================================================
       14. CAT_RESULTADO_FECUNDACION
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_resultado_fecundacion
        WHERE code = 'PENDIENTE'
    )
    BEGIN
        INSERT INTO cat_resultado_fecundacion
        (
            code,
            nombre
        )
        VALUES
        (
            'PENDIENTE',
            'Pendiente'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_resultado_fecundacion
        WHERE code = 'EXITOSA'
    )
    BEGIN
        INSERT INTO cat_resultado_fecundacion
        (
            code,
            nombre
        )
        VALUES
        (
            'EXITOSA',
            'Exitosa'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_resultado_fecundacion
        WHERE code = 'FALLIDA'
    )
    BEGIN
        INSERT INTO cat_resultado_fecundacion
        (
            code,
            nombre
        )
        VALUES
        (
            'FALLIDA',
            'Fallida'
        );
    END;


    /* ========================================================
       15. CAT_ESTADO_FECUNDACION_VACUNO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_fecundacion_vacuno
        WHERE code = 'NO_FECUNDADO'
    )
    BEGIN
        INSERT INTO cat_estado_fecundacion_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'NO_FECUNDADO',
            'No fecundado'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_fecundacion_vacuno
        WHERE code = 'EN_PROCESO'
    )
    BEGIN
        INSERT INTO cat_estado_fecundacion_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'EN_PROCESO',
            'En proceso'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_fecundacion_vacuno
        WHERE code = 'FECUNDADO'
    )
    BEGIN
        INSERT INTO cat_estado_fecundacion_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'FECUNDADO',
            'Fecundado'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_fecundacion_vacuno
        WHERE code = 'EN_GESTACION'
    )
    BEGIN
        INSERT INTO cat_estado_fecundacion_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'EN_GESTACION',
            'En gestación'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_fecundacion_vacuno
        WHERE code = 'SIN_ESTADO'
    )
    BEGIN
        INSERT INTO cat_estado_fecundacion_vacuno
        (
            code,
            nombre
        )
        VALUES
        (
            'SIN_ESTADO',
            'Sin estado'
        );
    END;


    /* ========================================================
       16. CAT_ESTADO_TRAZABILIDAD
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_trazabilidad
        WHERE code = 'VALIDA'
    )
    BEGIN
        INSERT INTO cat_estado_trazabilidad
        (
            code,
            nombre
        )
        VALUES
        (
            'VALIDA',
            'Válida'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_trazabilidad
        WHERE code = 'ANULADA'
    )
    BEGIN
        INSERT INTO cat_estado_trazabilidad
        (
            code,
            nombre
        )
        VALUES
        (
            'ANULADA',
            'Anulada'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_estado_trazabilidad
        WHERE code = 'PENDIENTE'
    )
    BEGIN
        INSERT INTO cat_estado_trazabilidad
        (
            code,
            nombre
        )
        VALUES
        (
            'PENDIENTE',
            'Pendiente'
        );
    END;


    /* ========================================================
       17. CAT_TIPO_RESPONSABLE
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_responsable
        WHERE code = 'VETERINARIO'
    )
    BEGIN
        INSERT INTO cat_tipo_responsable
        (
            code,
            nombre
        )
        VALUES
        (
            'VETERINARIO',
            'Veterinario'
        );
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM cat_tipo_responsable
        WHERE code = 'ENCARGADO'
    )
    BEGIN
        INSERT INTO cat_tipo_responsable
        (
            code,
            nombre
        )
        VALUES
        (
            'ENCARGADO',
            'Encargado'
        );
    END;


    /* ========================================================
       18. UBICACIÓN - DEPARTAMENTO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM geo_departamento
        WHERE codigo = '10'
    )
    BEGIN
        INSERT INTO geo_departamento
        (
            codigo,
            nombre
        )
        VALUES
        (
            N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE)',
            N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO)'
        );
    END;


    /* ========================================================
       19. UBICACIÓN - PROVINCIA
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM geo_provincia
        WHERE codigo = '1006'
    )
    BEGIN
        INSERT INTO geo_provincia
        (
            codigo,
            departamento_codigo,
            nombre
        )
        VALUES
        (
            N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE)',
            N'$(ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE)',
            N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA)'
        );
    END;


    /* ========================================================
       20. UBICACIÓN - DISTRITO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM geo_distrito
        WHERE codigo = '100601'
    )
    BEGIN
        INSERT INTO geo_distrito
        (
            codigo,
            provincia_codigo,
            nombre
        )
        VALUES
        (
            N'$(ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE)',
            N'$(ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE)',
            N'$(ZOOTECH_TENANT_ADDRESS_DISTRITO)'
        );
    END;


    /* ========================================================
       21. CONFIGURACIÓN DE CELO
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM celo_configuracion
        WHERE nombre = 'Configuración Seed'
    )
    BEGIN
        INSERT INTO celo_configuracion
        (
            nombre,
            dias_ciclo_estandar,
            dias_alerta_previa,
            dias_tolerancia_posterior,
            activo,
            created_by
        )
        VALUES
        (
            'Configuración Seed',
            21,
            3,
            2,
            1,
            NULL
        );
    END;


    /* ========================================================
       COMMIT
       ======================================================== */

    COMMIT TRANSACTION;

    PRINT '============================================================';
    PRINT 'CATÁLOGOS ZOOTECH INSERTADOS CORRECTAMENTE';
    PRINT '============================================================';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR DURANTE EL SEED DE CATÁLOGOS.';

    THROW;

END CATCH;


/* ============================================================
   RESUMEN
   ============================================================ */

SELECT 'cat_sexo' AS tabla, COUNT(*) AS cantidad
FROM cat_sexo

UNION ALL

SELECT 'cat_estado_vacuno', COUNT(*)
FROM cat_estado_vacuno

UNION ALL

SELECT 'cat_estado_registro', COUNT(*)
FROM cat_estado_registro

UNION ALL

SELECT 'cat_tipo_adquisicion', COUNT(*)
FROM cat_tipo_adquisicion

UNION ALL

SELECT 'cat_tipo_utilizacion', COUNT(*)
FROM cat_tipo_utilizacion

UNION ALL

SELECT 'cat_raza', COUNT(*)
FROM cat_raza

UNION ALL

SELECT 'cat_color', COUNT(*)
FROM cat_color

UNION ALL

SELECT 'cat_estado_ordenio', COUNT(*)
FROM cat_estado_ordenio

UNION ALL

SELECT 'cat_estado_sequia', COUNT(*)
FROM cat_estado_sequia

UNION ALL

SELECT 'cat_tipo_peso', COUNT(*)
FROM cat_tipo_peso

UNION ALL

SELECT 'cat_estado_celo', COUNT(*)
FROM cat_estado_celo

UNION ALL

SELECT 'cat_caracteristica_celo', COUNT(*)
FROM cat_caracteristica_celo

UNION ALL

SELECT 'cat_tipo_fecundacion', COUNT(*)
FROM cat_tipo_fecundacion

UNION ALL

SELECT 'cat_resultado_fecundacion', COUNT(*)
FROM cat_resultado_fecundacion

UNION ALL

SELECT 'cat_estado_fecundacion_vacuno', COUNT(*)
FROM cat_estado_fecundacion_vacuno

UNION ALL

SELECT 'cat_estado_trazabilidad', COUNT(*)
FROM cat_estado_trazabilidad

UNION ALL

SELECT 'cat_tipo_responsable', COUNT(*)
FROM cat_tipo_responsable

UNION ALL

SELECT 'geo_departamento', COUNT(*)
FROM geo_departamento

UNION ALL

SELECT 'geo_provincia', COUNT(*)
FROM geo_provincia

UNION ALL

SELECT 'geo_distrito', COUNT(*)
FROM geo_distrito

UNION ALL

SELECT 'celo_configuracion', COUNT(*)
FROM celo_configuracion

ORDER BY tabla;