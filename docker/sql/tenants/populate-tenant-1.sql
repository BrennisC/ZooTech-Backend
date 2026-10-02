/* ============================================================
   ZOOTECH - SEED DATA
   SQL SERVER 2025

   OBJETIVO
   ------------------------------------------------------------
   Generar datos de prueba realistas y relacionados para:

   - Vacunos
   - Fotos
   - Estados e historial
   - Incidentes
   - Ordeños
   - Producción estándar
   - Sequía
   - Triajes
   - Celo
   - Características de celo
   - Fecundaciones
   - Trazabilidad de crías
   - Usuarios / responsables
   - Catálogos y ubicación

   VOLUMEN PRINCIPAL
   ------------------------------------------------------------
   1,000 vacunos

   Los módulos dependientes generan cantidades variables
   en función de esos vacunos.

   RANGO TEMPORAL
   ------------------------------------------------------------
   Desde hace 6 meses hasta hoy.

   IMPORTANTE
   ------------------------------------------------------------
   - El script NO elimina información existente.
   - Usa transacción.
   - Evita duplicar los datos del seed mediante un prefijo
     identificable.
   - Respeta las relaciones FK.
   - No establece valores artificiales sobre columnas que
     tienen DEFAULT cuando no es necesario.
   ============================================================
   ESTA PENSADO PARA EJECUTARSE UNA VEZ SOBRE UNA UNICA BASE DE DATOS
   DE LO CONTRARIO PODRIA GENERAR DUPLICADOS ENTRE BASES DE DATOS
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;


    /* ========================================================
       0. FECHAS BASE
       ======================================================== */

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @Desde DATE = DATEADD(MONTH, -6, @Hoy);

    DECLARE @Ahora DATETIME2 = SYSUTCDATETIME();


    /* ========================================================
       1. USUARIOS
       ========================================================

       Necesarios para:
       - created_by
       - updated_by
       - encargado_usuario_id
       - responsable
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM usuario
        WHERE codigo = 'SEEDUSR001'
    )
    BEGIN
        INSERT INTO usuario
        (
            codigo,
            nombre_usuario,
            nombre_completo,
            correo,
            activo
        )
        VALUES
        ('SEEDUSR001', 'seed.admin', 'Usuario Seed Administrador', 'seed.admin@zootech.local', 1),
        ('SEEDUSR002', 'seed.veterinario', 'Usuario Seed Veterinario', 'seed.veterinario@zootech.local', 1),
        ('SEEDUSR003', 'seed.encargado', 'Usuario Seed Encargado', 'seed.encargado@zootech.local', 1);
    END;


    /* ========================================================
       2. CATÁLOGOS BÁSICOS
       ======================================================== */

    /* SEXOS */

    IF NOT EXISTS (SELECT 1 FROM cat_sexo WHERE code = 'HEMBRA')
        INSERT INTO cat_sexo(code, nombre)
        VALUES ('HEMBRA', 'Hembra');

    IF NOT EXISTS (SELECT 1 FROM cat_sexo WHERE code = 'MACHO')
        INSERT INTO cat_sexo(code, nombre)
        VALUES ('MACHO', 'Macho');


    /* ESTADOS DE VACUNO */

    IF NOT EXISTS (SELECT 1 FROM cat_estado_vacuno WHERE code = 'VIVO')
        INSERT INTO cat_estado_vacuno(code, nombre)
        VALUES ('VIVO', 'Vivo');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_vacuno WHERE code = 'MUERTO')
        INSERT INTO cat_estado_vacuno(code, nombre)
        VALUES ('MUERTO', 'Muerto');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_vacuno WHERE code = 'VENDIDO')
        INSERT INTO cat_estado_vacuno(code, nombre)
        VALUES ('VENDIDO', 'Vendido');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_vacuno WHERE code = 'TRASLADADO')
        INSERT INTO cat_estado_vacuno(code, nombre)
        VALUES ('TRASLADADO', 'Trasladado');


    /* ESTADO GENERAL DE REGISTRO */

    IF NOT EXISTS (SELECT 1 FROM cat_estado_registro WHERE code = 'ACTIVO')
        INSERT INTO cat_estado_registro(code, nombre)
        VALUES ('ACTIVO', 'Activo');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_registro WHERE code = 'ELIMINADO_LOGICO')
        INSERT INTO cat_estado_registro(code, nombre)
        VALUES ('ELIMINADO_LOGICO', 'Eliminado lógico');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_registro WHERE code = 'ANULADO')
        INSERT INTO cat_estado_registro(code, nombre)
        VALUES ('ANULADO', 'Anulado');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_registro WHERE code = 'DESHABILITADO')
        INSERT INTO cat_estado_registro(code, nombre)
        VALUES ('DESHABILITADO', 'Deshabilitado');


    /* TIPOS DE ADQUISICIÓN */

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_adquisicion WHERE code = 'COMPRA')
        INSERT INTO cat_tipo_adquisicion(code, nombre)
        VALUES ('COMPRA', 'Compra');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_adquisicion WHERE code = 'NACIMIENTO_GRANJA')
        INSERT INTO cat_tipo_adquisicion(code, nombre)
        VALUES ('NACIMIENTO_GRANJA', 'Nacimiento en granja');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_adquisicion WHERE code = 'DONACION')
        INSERT INTO cat_tipo_adquisicion(code, nombre)
        VALUES ('DONACION', 'Donación');


    /* UTILIZACIÓN */

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_utilizacion WHERE code = 'LECHE')
        INSERT INTO cat_tipo_utilizacion(code, nombre)
        VALUES ('LECHE', 'Leche');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_utilizacion WHERE code = 'CARNE')
        INSERT INTO cat_tipo_utilizacion(code, nombre)
        VALUES ('CARNE', 'Carne');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_utilizacion WHERE code = 'REPRODUCCION')
        INSERT INTO cat_tipo_utilizacion(code, nombre)
        VALUES ('REPRODUCCION', 'Reproducción');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_utilizacion WHERE code = 'DOBLE_PROPOSITO')
        INSERT INTO cat_tipo_utilizacion(code, nombre)
        VALUES ('DOBLE_PROPOSITO', 'Doble propósito');


    /* RAZAS */

    IF NOT EXISTS (SELECT 1 FROM cat_raza WHERE code = 'HOLSTEIN')
        INSERT INTO cat_raza(code, nombre)
        VALUES ('HOLSTEIN', 'Holstein');

    IF NOT EXISTS (SELECT 1 FROM cat_raza WHERE code = 'BROWN_SWISS')
        INSERT INTO cat_raza(code, nombre)
        VALUES ('BROWN_SWISS', 'Brown Swiss');

    IF NOT EXISTS (SELECT 1 FROM cat_raza WHERE code = 'JERSEY')
        INSERT INTO cat_raza(code, nombre)
        VALUES ('JERSEY', 'Jersey');

    IF NOT EXISTS (SELECT 1 FROM cat_raza WHERE code = 'SIMMENTAL')
        INSERT INTO cat_raza(code, nombre)
        VALUES ('SIMMENTAL', 'Simmental');


    /* COLORES */

    IF NOT EXISTS (SELECT 1 FROM cat_color WHERE nombre = 'Negro')
        INSERT INTO cat_color(nombre) VALUES ('Negro');

    IF NOT EXISTS (SELECT 1 FROM cat_color WHERE nombre = 'Blanco')
        INSERT INTO cat_color(nombre) VALUES ('Blanco');

    IF NOT EXISTS (SELECT 1 FROM cat_color WHERE nombre = 'Marrón')
        INSERT INTO cat_color(nombre) VALUES ('Marrón');

    IF NOT EXISTS (SELECT 1 FROM cat_color WHERE nombre = 'Blanco y negro')
        INSERT INTO cat_color(nombre) VALUES ('Blanco y negro');

    IF NOT EXISTS (SELECT 1 FROM cat_color WHERE nombre = 'Café')
        INSERT INTO cat_color(nombre) VALUES ('Café');


    /* ========================================================
       3. CATÁLOGOS DE PRODUCCIÓN
       ======================================================== */

    IF NOT EXISTS (SELECT 1 FROM cat_estado_ordenio WHERE code = 'ACTIVO')
        INSERT INTO cat_estado_ordenio(code, nombre)
        VALUES ('ACTIVO', 'Activo');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_ordenio WHERE code = 'ELIMINADO_LOGICO')
        INSERT INTO cat_estado_ordenio(code, nombre)
        VALUES ('ELIMINADO_LOGICO', 'Eliminado lógico');


    IF NOT EXISTS (SELECT 1 FROM cat_estado_sequia WHERE code = 'NO_SEQUIA')
        INSERT INTO cat_estado_sequia(code, nombre)
        VALUES ('NO_SEQUIA', 'No sequía');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_sequia WHERE code = 'POR_ENTRAR')
        INSERT INTO cat_estado_sequia(code, nombre)
        VALUES ('POR_ENTRAR', 'Por entrar');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_sequia WHERE code = 'EN_SEQUIA')
        INSERT INTO cat_estado_sequia(code, nombre)
        VALUES ('EN_SEQUIA', 'En sequía');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_sequia WHERE code = 'FINALIZADA')
        INSERT INTO cat_estado_sequia(code, nombre)
        VALUES ('FINALIZADA', 'Finalizada');


    /* ========================================================
       4. CATÁLOGOS DE TRIAJE
       ======================================================== */

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_peso WHERE code = 'RUTINARIO')
        INSERT INTO cat_tipo_peso(code, nombre)
        VALUES ('RUTINARIO', 'Rutinario');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_peso WHERE code = 'CONTROL')
        INSERT INTO cat_tipo_peso(code, nombre)
        VALUES ('CONTROL', 'Control');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_peso WHERE code = 'NACIMIENTO')
        INSERT INTO cat_tipo_peso(code, nombre)
        VALUES ('NACIMIENTO', 'Nacimiento');


    /* ========================================================
       5. CATÁLOGOS DE CELO
       ======================================================== */

    IF NOT EXISTS (SELECT 1 FROM cat_estado_celo WHERE code = 'PROXIMO')
        INSERT INTO cat_estado_celo(code, nombre)
        VALUES ('PROXIMO', 'Próximo');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_celo WHERE code = 'EN_CELO')
        INSERT INTO cat_estado_celo(code, nombre)
        VALUES ('EN_CELO', 'En celo');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_celo WHERE code = 'PASO')
        INSERT INTO cat_estado_celo(code, nombre)
        VALUES ('PASO', 'Pasó');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_celo WHERE code = 'SIN_DATOS')
        INSERT INTO cat_estado_celo(code, nombre)
        VALUES ('SIN_DATOS', 'Sin datos');


    IF NOT EXISTS (SELECT 1 FROM cat_caracteristica_celo WHERE nombre = 'Inquietud')
        INSERT INTO cat_caracteristica_celo(nombre)
        VALUES ('Inquietud');

    IF NOT EXISTS (SELECT 1 FROM cat_caracteristica_celo WHERE nombre = 'Mucosidad')
        INSERT INTO cat_caracteristica_celo(nombre)
        VALUES ('Mucosidad');

    IF NOT EXISTS (SELECT 1 FROM cat_caracteristica_celo WHERE nombre = 'Monta a otras vacas')
        INSERT INTO cat_caracteristica_celo(nombre)
        VALUES ('Monta a otras vacas');

    IF NOT EXISTS (SELECT 1 FROM cat_caracteristica_celo WHERE nombre = 'Baja producción')
        INSERT INTO cat_caracteristica_celo(nombre)
        VALUES ('Baja producción');

    IF NOT EXISTS (SELECT 1 FROM cat_caracteristica_celo WHERE nombre = 'Vocalización')
        INSERT INTO cat_caracteristica_celo(nombre)
        VALUES ('Vocalización');


    /* ========================================================
       6. CATÁLOGOS DE FECUNDACIÓN
       ======================================================== */

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_fecundacion WHERE code = 'MONTA_NATURAL')
        INSERT INTO cat_tipo_fecundacion(code, nombre)
        VALUES ('MONTA_NATURAL', 'Monta natural');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_fecundacion WHERE code = 'INSEMINACION_ARTIFICIAL')
        INSERT INTO cat_tipo_fecundacion(code, nombre)
        VALUES ('INSEMINACION_ARTIFICIAL', 'Inseminación artificial');

    IF NOT EXISTS (SELECT 1 FROM cat_tipo_fecundacion WHERE code = 'TRANSFERENCIA_EMBRIONES')
        INSERT INTO cat_tipo_fecundacion(code, nombre)
        VALUES ('TRANSFERENCIA_EMBRIONES', 'Transferencia de embriones');


    IF NOT EXISTS (SELECT 1 FROM cat_resultado_fecundacion WHERE code = 'PENDIENTE')
        INSERT INTO cat_resultado_fecundacion(code, nombre)
        VALUES ('PENDIENTE', 'Pendiente');

    IF NOT EXISTS (SELECT 1 FROM cat_resultado_fecundacion WHERE code = 'EXITOSA')
        INSERT INTO cat_resultado_fecundacion(code, nombre)
        VALUES ('EXITOSA', 'Exitosa');

    IF NOT EXISTS (SELECT 1 FROM cat_resultado_fecundacion WHERE code = 'FALLIDA')
        INSERT INTO cat_resultado_fecundacion(code, nombre)
        VALUES ('FALLIDA', 'Fallida');


    IF NOT EXISTS (SELECT 1 FROM cat_estado_fecundacion_vacuno WHERE code = 'NO_FECUNDADO')
        INSERT INTO cat_estado_fecundacion_vacuno(code, nombre)
        VALUES ('NO_FECUNDADO', 'No fecundado');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_fecundacion_vacuno WHERE code = 'EN_PROCESO')
        INSERT INTO cat_estado_fecundacion_vacuno(code, nombre)
        VALUES ('EN_PROCESO', 'En proceso');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_fecundacion_vacuno WHERE code = 'FECUNDADO')
        INSERT INTO cat_estado_fecundacion_vacuno(code, nombre)
        VALUES ('FECUNDADO', 'Fecundado');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_fecundacion_vacuno WHERE code = 'EN_GESTACION')
        INSERT INTO cat_estado_fecundacion_vacuno(code, nombre)
        VALUES ('EN_GESTACION', 'En gestación');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_fecundacion_vacuno WHERE code = 'SIN_ESTADO')
        INSERT INTO cat_estado_fecundacion_vacuno(code, nombre)
        VALUES ('SIN_ESTADO', 'Sin estado');


    IF NOT EXISTS (SELECT 1 FROM cat_estado_trazabilidad WHERE code = 'VALIDA')
        INSERT INTO cat_estado_trazabilidad(code, nombre)
        VALUES ('VALIDA', 'Válida');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_trazabilidad WHERE code = 'ANULADA')
        INSERT INTO cat_estado_trazabilidad(code, nombre)
        VALUES ('ANULADA', 'Anulada');

    IF NOT EXISTS (SELECT 1 FROM cat_estado_trazabilidad WHERE code = 'PENDIENTE')
        INSERT INTO cat_estado_trazabilidad(code, nombre)
        VALUES ('PENDIENTE', 'Pendiente');


    /* ========================================================
       7. RESPONSABLES
       ======================================================== */

    DECLARE @UsuarioVeterinario BIGINT;
    DECLARE @UsuarioEncargado BIGINT;
    DECLARE @UsuarioAdmin BIGINT;

    SELECT @UsuarioVeterinario = id
    FROM usuario
    WHERE codigo = 'SEEDUSR002';

    SELECT @UsuarioEncargado = id
    FROM usuario
    WHERE codigo = 'SEEDUSR003';

    SELECT @UsuarioAdmin = id
    FROM usuario
    WHERE codigo = 'SEEDUSR001';


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
        ('VETERINARIO', 'Veterinario'),
        ('ENCARGADO', 'Encargado');
    END;


    IF NOT EXISTS
    (
        SELECT 1
        FROM responsable
        WHERE documento = 'SEED-VET-001'
    )
    BEGIN
        INSERT INTO responsable
        (
            usuario_id,
            tipo_responsable_code,
            nombre_completo,
            documento,
            telefono,
            activo
        )
        VALUES
        (
            @UsuarioVeterinario,
            'VETERINARIO',
            'Veterinario Seed',
            'SEED-VET-001',
            '999111222',
            1
        );
    END;


    DECLARE @ResponsableId BIGINT;

    SELECT TOP 1 @ResponsableId = id
    FROM responsable
    WHERE documento = 'SEED-VET-001';


    /* ========================================================
       8. UBICACIÓN
       ======================================================== */

    /*
       Se utilizan códigos ficticios pero estructuralmente válidos
       para las relaciones geográficas.
    */

    IF NOT EXISTS
    (
        SELECT 1 FROM geo_departamento WHERE codigo = '10'
    )
    BEGIN
        INSERT INTO geo_departamento(codigo, nombre)
        VALUES ('10', 'Huánuco');
    END;


    IF NOT EXISTS
    (
        SELECT 1 FROM geo_provincia WHERE codigo = '1006'
    )
    BEGIN
        INSERT INTO geo_provincia
        (
            codigo,
            departamento_codigo,
            nombre
        )
        VALUES
        ('1006', '10', 'Leoncio Prado');
    END;


    IF NOT EXISTS
    (
        SELECT 1 FROM geo_distrito WHERE codigo = '100601'
    )
    BEGIN
        INSERT INTO geo_distrito
        (
            codigo,
            provincia_codigo,
            nombre
        )
        VALUES
        ('100601', '1006', 'Rupa Rupa');
    END;


    /* ========================================================
       9. GRANJAS
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM granja
        WHERE nombre = 'Granja Norte'
    )
    BEGIN
        INSERT INTO granja
        (
            nombre,
            distrito_codigo,
            activo
        )
        VALUES
        ('Granja Norte', '100601', 1),
        ('Granja Centro', '100601', 1),
        ('Granja Sur', '100601', 1);
    END;


    /* ========================================================
       10. TABLA TEMPORAL DE GRANJAS
       ======================================================== */

    CREATE TABLE #Granjas
    (
        rn INT PRIMARY KEY,
        id BIGINT
    );

    INSERT INTO #Granjas
    (
        rn,
        id
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY id),
        id
    FROM granja
    WHERE nombre IN
    (
        'Granja Norte',
        'Granja Centro',
        'Granja Sur'
    );


    /* ========================================================
       11. GENERAR 1,000 NÚMEROS
       ======================================================== */

    CREATE TABLE #Numeros
    (
        n INT PRIMARY KEY
    );

    INSERT INTO #Numeros(n)
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b;


    /* ========================================================
       12. INSERTAR 1,000 VACUNOS
       ======================================================== */

    /*
       Distribución:
       - ~70% hembras
       - ~30% machos
       - Varias razas
       - Varias utilizaciones
       - Fechas de nacimiento históricas
       - Todos inicialmente VIVOS
    */

    INSERT INTO vacuno
    (
        codigo,
        nombre,
        fecha_nacimiento,
        tipo_adquisicion_code,
        precio_compra,
        raza_code,
        color_id,
        sexo_code,
        padre_id,
        madre_id,
        granja_id,
        tipo_utilizacion_code,
        fecha_registro_utilizacion,
        observaciones,
        fecha_registro,
        created_by,
        updated_by
    )
    SELECT
        CONCAT('SEED-V-', RIGHT(CONCAT('0000', n.n), 4)),
        CONCAT('Vacuno ', n.n),

        DATEADD
        (
            DAY,
            -(
                365
                + ABS(CHECKSUM(NEWID())) % 1825
            ),
            @Hoy
        ),

        CASE
            WHEN n.n % 5 = 0 THEN 'COMPRA'
            WHEN n.n % 5 = 1 THEN 'DONACION'
            ELSE 'NACIMIENTO_GRANJA'
        END,

        CASE
            WHEN n.n % 5 = 0
                THEN CAST(ROUND(500 + ABS(CHECKSUM(NEWID())) % 4500, 2) AS DECIMAL(12,2))
            ELSE CAST(0 AS DECIMAL(12,2))
        END,

        CASE
            WHEN n.n % 4 = 0 THEN 'HOLSTEIN'
            WHEN n.n % 4 = 1 THEN 'BROWN_SWISS'
            WHEN n.n % 4 = 2 THEN 'JERSEY'
            ELSE 'SIMMENTAL'
        END,

        (
            SELECT TOP 1 id
            FROM cat_color
            ORDER BY
                ABS(CHECKSUM(NEWID()))
        ),

        CASE
            WHEN n.n % 10 < 7 THEN 'HEMBRA'
            ELSE 'MACHO'
        END,

        NULL,
        NULL,

        (
            SELECT id
            FROM #Granjas
            WHERE rn =
            (
                ((n.n - 1) % 3) + 1
            )
        ),

        CASE
            WHEN n.n % 10 < 5 THEN 'LECHE'
            WHEN n.n % 10 < 7 THEN 'DOBLE_PROPOSITO'
            WHEN n.n % 10 < 9 THEN 'REPRODUCCION'
            ELSE 'CARNE'
        END,

        DATEADD
        (
            DAY,
            -ABS(CHECKSUM(NEWID())) % 180,
            @Hoy
        ),

        CASE
            WHEN n.n % 7 = 0
                THEN 'Registro generado para pruebas del sistema.'
            ELSE NULL
        END,

        DATEADD
        (
            DAY,
            -ABS(CHECKSUM(NEWID())) % 180,
            @Hoy
        ),

        @UsuarioAdmin,
        @UsuarioAdmin

    FROM #Numeros n
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM vacuno v
        WHERE v.codigo =
            CONCAT('SEED-V-', RIGHT(CONCAT('0000', n.n), 4))
    );


    /* ========================================================
       13. RELACIONES GENEALÓGICAS
       ======================================================== */

    /*
       Se asignan padres/madres únicamente después de insertar
       todos los vacunos.

       Padre:
       - MACHO

       Madre:
       - HEMBRA

       Nunca se asigna el propio vacuno.
    */

    ;WITH Vacunos AS
    (
        SELECT
            id,
            ROW_NUMBER() OVER (ORDER BY id) AS rn,
            sexo_code
        FROM vacuno
        WHERE codigo LIKE 'SEED-V-%'
    ),
    Padres AS
    (
        SELECT
            id,
            ROW_NUMBER() OVER (ORDER BY id) AS rn
        FROM Vacunos
        WHERE sexo_code = 'MACHO'
    ),
    Madres AS
    (
        SELECT
            id,
            ROW_NUMBER() OVER (ORDER BY id) AS rn
        FROM Vacunos
        WHERE sexo_code = 'HEMBRA'
    )
    UPDATE v
    SET
        padre_id =
        CASE
            WHEN v.sexo_code = 'MACHO'
                THEN NULL
            ELSE
            (
                SELECT TOP 1 p.id
                FROM Padres p
                WHERE p.id <> v.id
                ORDER BY
                    ABS(CHECKSUM(CONCAT(v.id, p.id)))
            )
        END,

        madre_id =
        CASE
            WHEN v.rn % 10 < 2
                THEN NULL
            ELSE
            (
                SELECT TOP 1 m.id
                FROM Madres m
                WHERE m.id <> v.id
                ORDER BY
                    ABS(CHECKSUM(CONCAT(v.id, m.id)))
            )
        END

    FROM Vacunos v;


    /* ========================================================
       14. ESTADO HISTÓRICO DE VACUNOS
       ======================================================== */

    INSERT INTO vacuno_estado_historial
    (
        vacuno_id,
        estado_code,
        fecha_estado,
        motivo,
        vigente,
        created_by
    )
    SELECT
        v.id,
        'VIVO',
        DATEADD
        (
            DAY,
            -ABS(CHECKSUM(NEWID())) % 180,
            @Hoy
        ),
        'Estado inicial generado para pruebas.',
        1,
        @UsuarioAdmin
    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%'
      AND NOT EXISTS
      (
          SELECT 1
          FROM vacuno_estado_historial h
          WHERE h.vacuno_id = v.id
            AND h.vigente = 1
      );


    /* ========================================================
       15. FOTOS
       ======================================================== */

    /*
       Para no depender de archivos físicos reales, se crean
       referencias lógicas en archivo.

       Esto permite probar la relación vacuno -> foto.
    */

    INSERT INTO archivo
    (
        modulo_code,
        nombre_original,
        nombre_almacenado,
        ruta_archivo,
        extension,
        mime_type,
        tamano_bytes,
        hash_sha256,
        creado_por
    )
    SELECT
        'VACUNOS',
        CONCAT(v.codigo, '.jpg'),
        CONCAT(v.codigo, '-foto.jpg'),
        CONCAT('/seed/vacunos/', v.codigo, '-foto.jpg'),
        'jpg',
        'image/jpeg',
        125000,
        CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', v.codigo), 2),
        @UsuarioAdmin
    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%'
      AND NOT EXISTS
      (
          SELECT 1
          FROM archivo a
          WHERE a.nombre_almacenado =
              CONCAT(v.codigo, '-foto.jpg')
      );


    INSERT INTO vacuno_foto
    (
        vacuno_id,
        archivo_id,
        es_principal,
        uploaded_by
    )
    SELECT
        v.id,
        a.id,
        1,
        @UsuarioAdmin
    FROM vacuno v
    INNER JOIN archivo a
        ON a.nombre_almacenado =
            CONCAT(v.codigo, '-foto.jpg')
    WHERE v.codigo LIKE 'SEED-V-%'
      AND NOT EXISTS
      (
          SELECT 1
          FROM vacuno_foto vf
          WHERE vf.vacuno_id = v.id
            AND vf.es_principal = 1
      );


    /* ========================================================
       16. INCIDENTES
       ======================================================== */

    INSERT INTO incidente_vacuno
    (
        vacuno_id,
        fecha_incidente,
        descripcion,
        estado_registro_code,
        created_by
    )
    SELECT
        v.id,
        DATEADD
        (
            DAY,
            -ABS(CHECKSUM(NEWID())) % 180,
            @Hoy
        ),
        'Incidente generado para pruebas.',
        'ACTIVO',
        @UsuarioVeterinario
    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%'
      AND v.id % 5 = 0;


    /* ========================================================
       17. PRODUCCIÓN ESTÁNDAR
       ======================================================== */

    INSERT INTO produccion_leche_estandar
    (
        vacuno_id,
        fecha_inicio,
        fecha_fin,
        litros_esperados_dia,
        descripcion,
        activo,
        created_by
    )
    SELECT
        v.id,
        @Desde,
        NULL,
        CAST
        (
            8 + (ABS(CHECKSUM(NEWID())) % 13)
            AS DECIMAL(8,3)
        ),
        'Estándar generado para pruebas.',
        1,
        @UsuarioAdmin
    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%'
      AND v.sexo_code = 'HEMBRA'
      AND v.tipo_utilizacion_code IN
      (
          'LECHE',
          'DOBLE_PROPOSITO'
      );


    /* ========================================================
       18. ORDEÑOS
       ======================================================== */

    /*
       Aproximadamente 3 registros por vaca lechera.
    */

    INSERT INTO ordenio
    (
        codigo,
        fecha_hora,
        vacuno_id,
        encargado_usuario_id,
        litros,
        observaciones,
        estado_ordenio_code,
        created_by,
        updated_by
    )
    SELECT
        CONCAT
        (
            'ORD-SEED-',
            RIGHT(CONCAT('000000', v.id), 6),
            '-',
            d.n
        ),

        DATEADD
        (
            HOUR,
            CASE
                WHEN d.n = 1 THEN 6
                ELSE 17
            END,
            CAST
            (
                DATEADD
                (
                    DAY,
                    -(
                        ((v.id + d.n * 17) % 180)
                    ),
                    @Hoy
                )
                AS DATETIME2
            )
        ),

        v.id,
        @UsuarioEncargado,

        CAST
        (
            4 +
            (
                ABS
                (
                    CHECKSUM
                    (
                        CONCAT(v.id, d.n)
                    )
                ) % 13
            ) / 2.0
            AS DECIMAL(8,3)
        ),

        NULL,
        'ACTIVO',
        @UsuarioEncargado,
        @UsuarioEncargado

    FROM vacuno v
    CROSS JOIN
    (
        VALUES (1), (2), (3)
    ) d(n)

    WHERE v.codigo LIKE 'SEED-V-%'
      AND v.sexo_code = 'HEMBRA'
      AND v.tipo_utilizacion_code IN
      (
          'LECHE',
          'DOBLE_PROPOSITO'
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM ordenio o
          WHERE o.codigo =
              CONCAT
              (
                  'ORD-SEED-',
                  RIGHT(CONCAT('000000', v.id), 6),
                  '-',
                  d.n
              )
      );


    /* ========================================================
       19. PERIODOS DE SEQUÍA
       ======================================================== */

    INSERT INTO periodo_sequia
    (
        vacuno_id,
        fecha_inicio,
        fecha_fin_estimada,
        fecha_fin_real,
        estado_sequia_code,
        motivo,
        observaciones,
        created_by
    )
    SELECT
        v.id,

        DATEADD
        (
            DAY,
            -30,
            @Hoy
        ),

        DATEADD
        (
            DAY,
            60,
            @Hoy
        ),

        NULL,

        'EN_SEQUIA',

        'Periodo generado para pruebas.',

        NULL,

        @UsuarioAdmin

    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%'
      AND v.sexo_code = 'HEMBRA'
      AND v.id % 10 = 0;


    /* ========================================================
       20. TRIAJES
       ======================================================== */

    INSERT INTO triaje
    (
        codigo,
        fecha_hora,
        vacuno_id,
        tipo_peso_code,
        peso_kg,
        observaciones,
        estado_registro_code,
        encargado_usuario_id,
        created_by,
        updated_by
    )
    SELECT
        CONCAT
        (
            'TRI-SEED-',
            RIGHT(CONCAT('000000', v.id), 6)
        ),

        DATEADD
        (
            DAY,
            -ABS(CHECKSUM(NEWID())) % 180,
            @Hoy
        ),

        v.id,

        CASE
            WHEN v.id % 3 = 0 THEN 'RUTINARIO'
            WHEN v.id % 3 = 1 THEN 'CONTROL'
            ELSE 'NACIMIENTO'
        END,

        CAST
        (
            250 +
            (
                ABS(CHECKSUM(NEWID())) % 450
            )
            AS DECIMAL(8,2)
        ),

        NULL,

        'ACTIVO',

        @UsuarioVeterinario,
        @UsuarioVeterinario,
        @UsuarioVeterinario

    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%'
      AND NOT EXISTS
      (
          SELECT 1
          FROM triaje t
          WHERE t.codigo =
              CONCAT
              (
                  'TRI-SEED-',
                  RIGHT(CONCAT('000000', v.id), 6)
              )
      );


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
            @UsuarioAdmin
        );
    END;


    /* ========================================================
       22. REGISTROS DE CELO
       ======================================================== */

    /*
       Dos registros por aproximadamente la mitad de las hembras.
    */

    INSERT INTO celo_registro
    (
        codigo,
        fecha_hora,
        vacuno_id,
        encargado_usuario_id,
        observaciones,
        estado_registro_code,
        created_by,
        updated_by
    )
    SELECT
        CONCAT
        (
            'CEL-SEED-',
            RIGHT(CONCAT('000000', v.id), 6)
        ),

        DATEADD
        (
            DAY,
            -ABS(CHECKSUM(NEWID())) % 120,
            @Hoy
        ),

        v.id,
        @UsuarioEncargado,
        NULL,
        'ACTIVO',
        @UsuarioEncargado,
        @UsuarioEncargado

    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%'
      AND v.sexo_code = 'HEMBRA'
      AND v.id % 2 = 0
      AND NOT EXISTS
      (
          SELECT 1
          FROM celo_registro c
          WHERE c.codigo =
              CONCAT
              (
                  'CEL-SEED-',
                  RIGHT(CONCAT('000000', v.id), 6)
              )
      );


    /* ========================================================
       23. CARACTERÍSTICAS DE CELO
       ======================================================== */

    INSERT INTO celo_registro_caracteristica
    (
        celo_registro_id,
        caracteristica_id
    )
    SELECT
        c.id,
        cc.id
    FROM celo_registro c
    CROSS APPLY
    (
        SELECT TOP 1
            id
        FROM cat_caracteristica_celo
        ORDER BY
            ABS
            (
                CHECKSUM
                (
                    CONCAT(c.id, id)
                )
            )
    ) cc
    WHERE c.codigo LIKE 'CEL-SEED-%'
      AND NOT EXISTS
      (
          SELECT 1
          FROM celo_registro_caracteristica crc
          WHERE crc.celo_registro_id = c.id
      );


    /* ========================================================
       24. CARACTERÍSTICAS LIBRES
       ======================================================== */

    INSERT INTO celo_registro_caracteristica_libre
    (
        celo_registro_id,
        descripcion
    )
    SELECT
        c.id,
        'Comportamiento observado durante la inspección.'
    FROM celo_registro c
    WHERE c.codigo LIKE 'CEL-SEED-%'
      AND c.id % 5 = 0
      AND NOT EXISTS
      (
          SELECT 1
          FROM celo_registro_caracteristica_libre x
          WHERE x.celo_registro_id = c.id
      );


    /* ========================================================
       25. ESTADO DE CELO POR VACUNO
       ======================================================== */

    INSERT INTO celo_estado_vacuno
    (
        vacuno_id,
        estado_celo_code,
        fecha_ultimo_celo,
        fecha_proximo_celo_estimada,
        dias_restantes,
        veces_celo,
        crias
    )
    SELECT
        v.id,

        CASE
            WHEN v.id % 4 = 0 THEN 'EN_CELO'
            WHEN v.id % 4 = 1 THEN 'PROXIMO'
            WHEN v.id % 4 = 2 THEN 'PASO'
            ELSE 'SIN_DATOS'
        END,

        CASE
            WHEN c.ultimo_celo IS NOT NULL
                THEN c.ultimo_celo
            ELSE NULL
        END,

        CASE
            WHEN c.ultimo_celo IS NOT NULL
                THEN DATEADD(DAY, 21, c.ultimo_celo)
            ELSE NULL
        END,

        CASE
            WHEN c.ultimo_celo IS NOT NULL
                THEN DATEDIFF
                (
                    DAY,
                    @Hoy,
                    DATEADD(DAY, 21, c.ultimo_celo)
                )
            ELSE NULL
        END,

        CASE
            WHEN c.ultimo_celo IS NULL THEN 0
            ELSE 1
        END,

        0

    FROM vacuno v

    OUTER APPLY
    (
        SELECT MAX(CAST(fecha_hora AS DATE)) AS ultimo_celo
        FROM celo_registro cr
        WHERE cr.vacuno_id = v.id
          AND cr.deleted_at IS NULL
    ) c

    WHERE v.codigo LIKE 'SEED-V-%'
      AND v.sexo_code = 'HEMBRA'
      AND NOT EXISTS
      (
          SELECT 1
          FROM celo_estado_vacuno cev
          WHERE cev.vacuno_id = v.id
      );


    /* ========================================================
       26. REPRODUCTORES EXTERNOS
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM reproductor_externo
        WHERE codigo_externo = 'SEED-EXT-001'
    )
    BEGIN
        INSERT INTO reproductor_externo
        (
            nombre,
            codigo_externo,
            sexo_code,
            descripcion,
            activo,
            created_by
        )
        VALUES
        (
            'Toro externo Seed',
            'SEED-EXT-001',
            'MACHO',
            'Reproductor externo generado para pruebas.',
            1,
            @UsuarioVeterinario
        );
    END;


    /* ========================================================
       27. FECUNDACIONES
       ======================================================== */

    /*
       Se crean fecundaciones para hembras.

       Se evita crear más de una pendiente por vacuno.
    */

    INSERT INTO fecundacion
    (
        codigo,
        tipo_fecundacion_code,
        vacuno_receptor_id,
        donante_vacuno_id,
        donante_externo_id,
        celo_registro_id,
        fecha_procedimiento,
        responsable_id,
        resultado_code,
        codigo_semen,
        codigo_embrion,
        observaciones_veterinarias,
        created_by,
        updated_by
    )
    SELECT TOP (500)
        CONCAT
        (
            'FEC-SEED-',
            RIGHT(CONCAT('000000', v.id), 6)
        ),

        CASE
            WHEN v.id % 3 = 0 THEN 'MONTA_NATURAL'
            WHEN v.id % 3 = 1 THEN 'INSEMINACION_ARTIFICIAL'
            ELSE 'TRANSFERENCIA_EMBRIONES'
        END,

        v.id,

        CASE
            WHEN v.id % 3 = 0
                THEN
                (
                    SELECT TOP 1 id
                    FROM vacuno p
                    WHERE p.sexo_code = 'MACHO'
                      AND p.id <> v.id
                    ORDER BY
                        ABS(CHECKSUM(CONCAT(v.id, p.id)))
                )
            ELSE NULL
        END,

        CASE
            WHEN v.id % 3 <> 0
                THEN
                (
                    SELECT TOP 1 id
                    FROM reproductor_externo
                    WHERE codigo_externo = 'SEED-EXT-001'
                )
            ELSE NULL
        END,

        (
            SELECT TOP 1 c.id
            FROM celo_registro c
            WHERE c.vacuno_id = v.id
              AND c.deleted_at IS NULL
            ORDER BY c.fecha_hora DESC
        ),

        DATEADD
        (
            DAY,
            -ABS(CHECKSUM(NEWID())) % 150,
            @Hoy
        ),

        @ResponsableId,

        CASE
            WHEN v.id % 5 = 0 THEN 'PENDIENTE'
            WHEN v.id % 5 = 1 THEN 'FALLIDA'
            ELSE 'EXITOSA'
        END,

        CASE
            WHEN v.id % 3 = 1
                THEN CONCAT('SEM-', v.id)
            ELSE NULL
        END,

        CASE
            WHEN v.id % 3 = 2
                THEN CONCAT('EMB-', v.id)
            ELSE NULL
        END,

        NULL,
        @UsuarioVeterinario,
        @UsuarioVeterinario

    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%'
      AND v.sexo_code = 'HEMBRA'
      AND NOT EXISTS
      (
          SELECT 1
          FROM fecundacion f
          WHERE f.codigo =
              CONCAT
              (
                  'FEC-SEED-',
                  RIGHT(CONCAT('000000', v.id), 6)
              )
      )
    ORDER BY
        v.id;


    /* ========================================================
       28. CRÍAS / TRAZABILIDAD
       ======================================================== */

    /*
       Para fecundaciones exitosas se relacionan vacunos
       existentes como crías.

       Solo se utilizan vacunos que no sean el receptor.
    */

    INSERT INTO fecundacion_cria
    (
        fecundacion_id,
        vacuno_hijo_id,
        estado_trazabilidad_code,
        fecha_vinculacion,
        observaciones,
        created_by,
        updated_by
    )
    SELECT
        f.id,

        (
            SELECT TOP 1 h.id
            FROM vacuno h
            WHERE h.codigo LIKE 'SEED-V-%'
              AND h.id <> f.vacuno_receptor_id
              AND h.id % 7 =
                  f.id % 7
            ORDER BY
                ABS(CHECKSUM(CONCAT(f.id, h.id)))
        ),

        'VALIDA',

        CAST(f.fecha_procedimiento AS DATE),

        'Relación de trazabilidad generada para pruebas.',

        @UsuarioVeterinario,
        @UsuarioVeterinario

    FROM fecundacion f
    WHERE f.codigo LIKE 'FEC-SEED-%'
      AND f.resultado_code = 'EXITOSA'
      AND NOT EXISTS
      (
          SELECT 1
          FROM fecundacion_cria fc
          WHERE fc.fecundacion_id = f.id
      );


    /* ========================================================
       29. HISTORIAL DE ESTADO DE FECUNDACIÓN
       ======================================================== */

    INSERT INTO vacuno_estado_fecundacion_historial
    (
        vacuno_id,
        estado_fecundacion_code,
        fecundacion_id,
        fecha_actualizacion,
        observaciones,
        vigente,
        created_by
    )
    SELECT
        f.vacuno_receptor_id,

        CASE
            WHEN f.resultado_code = 'EXITOSA'
                THEN 'EN_GESTACION'
            WHEN f.resultado_code = 'PENDIENTE'
                THEN 'EN_PROCESO'
            ELSE 'NO_FECUNDADO'
        END,

        f.id,

        f.fecha_procedimiento,

        'Estado generado para pruebas.',

        1,

        @UsuarioVeterinario

    FROM fecundacion f
    WHERE f.codigo LIKE 'FEC-SEED-%'
      AND NOT EXISTS
      (
          SELECT 1
          FROM vacuno_estado_fecundacion_historial h
          WHERE h.fecundacion_id = f.id
      );


    /* ========================================================
       30. ACTUALIZAR CONTADORES DE CELO
       ======================================================== */

    UPDATE cev
    SET
        veces_celo =
        (
            SELECT COUNT(*)
            FROM celo_registro cr
            WHERE cr.vacuno_id = cev.vacuno_id
              AND cr.deleted_at IS NULL
        ),

        crias =
        (
            SELECT COUNT(*)
            FROM fecundacion_cria fc
            INNER JOIN fecundacion f
                ON f.id = fc.fecundacion_id
            WHERE f.vacuno_receptor_id = cev.vacuno_id
              AND fc.estado_trazabilidad_code = 'VALIDA'
        ),

        calculated_at = SYSUTCDATETIME()

    FROM celo_estado_vacuno cev
    WHERE EXISTS
    (
        SELECT 1
        FROM vacuno v
        WHERE v.id = cev.vacuno_id
          AND v.codigo LIKE 'SEED-V-%'
    );


    /* ========================================================
       31. AUDITORÍA
       ======================================================== */

    INSERT INTO bitacora_auditoria
    (
        modulo_code,
        entidad,
        entidad_id,
        accion,
        datos_anteriores,
        datos_nuevos,
        motivo,
        usuario_id,
        created_at
    )
    SELECT
        'VACUNOS',
        'vacuno',
        v.id,
        'INSERT',
        NULL,
        (
            SELECT
                v.codigo,
                v.nombre,
                v.sexo_code,
                v.raza_code,
                v.granja_id
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ),
        'Registro generado por seed de pruebas.',
        @UsuarioAdmin,
        SYSUTCDATETIME()
    FROM vacuno v
    WHERE v.codigo LIKE 'SEED-V-%';


    /* ========================================================
       32. COMMIT
       ======================================================== */

    COMMIT TRANSACTION;

    PRINT '============================================================';
    PRINT 'SEED ZOOTECH COMPLETADO CORRECTAMENTE';
    PRINT '============================================================';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR DURANTE EL SEED.';
    THROW;

END CATCH;


/* ============================================================
   33. RESUMEN DE DATOS GENERADOS
   ============================================================ */

SELECT
    'vacuno' AS tabla,
    COUNT(*) AS cantidad
FROM vacuno
WHERE codigo LIKE 'SEED-V-%'

UNION ALL

SELECT
    'vacuno_foto',
    COUNT(*)
FROM vacuno_foto vf
INNER JOIN vacuno v
    ON v.id = vf.vacuno_id
WHERE v.codigo LIKE 'SEED-V-%'

UNION ALL

SELECT
    'ordenio',
    COUNT(*)
FROM ordenio
WHERE codigo LIKE 'ORD-SEED-%'

UNION ALL

SELECT
    'triaje',
    COUNT(*)
FROM triaje
WHERE codigo LIKE 'TRI-SEED-%'

UNION ALL

SELECT
    'celo_registro',
    COUNT(*)
FROM celo_registro
WHERE codigo LIKE 'CEL-SEED-%'

UNION ALL

SELECT
    'fecundacion',
    COUNT(*)
FROM fecundacion
WHERE codigo LIKE 'FEC-SEED-%'

UNION ALL

SELECT
    'fecundacion_cria',
    COUNT(*)
FROM fecundacion_cria fc
INNER JOIN fecundacion f
    ON f.id = fc.fecundacion_id
WHERE f.codigo LIKE 'FEC-SEED-%'

UNION ALL

SELECT
    'incidente_vacuno',
    COUNT(*)
FROM incidente_vacuno iv
INNER JOIN vacuno v
    ON v.id = iv.vacuno_id
WHERE v.codigo LIKE 'SEED-V-%'

UNION ALL

SELECT
    'vacuno_estado_historial',
    COUNT(*)
FROM vacuno_estado_historial h
INNER JOIN vacuno v
    ON v.id = h.vacuno_id
WHERE v.codigo LIKE 'SEED-V-%'

UNION ALL

SELECT
    'vacuno_estado_fecundacion_historial',
    COUNT(*)
FROM vacuno_estado_fecundacion_historial h
INNER JOIN vacuno v
    ON v.id = h.vacuno_id
WHERE v.codigo LIKE 'SEED-V-%'

ORDER BY tabla;