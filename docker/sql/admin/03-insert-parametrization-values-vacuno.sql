/* ============================================================
   ZOOTECH - CATÁLOGO CENTRALIZADO DE PARÁMETROS
   MÓDULO: VACUNOS
   MOTOR: SQL SERVER 2025

   IMPORTANTE:
   - Este script NO crea relaciones con tenants.
   - Este script NO inserta tenant_features,
     setting_values ni tenant_business_rules.
   - Solo registra las DEFINICIONES/CATÁLOGOS centrales.
   ============================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

BEGIN TRY

    /* ========================================================
       1. SETTING GROUP
       ======================================================== */

    /*
       Grupo que contiene todas las configuraciones
       dinámicas relacionadas con el módulo de Vacunos.
    */

    IF NOT EXISTS (
        SELECT 1
        FROM setting_groups
        WHERE code = 'VACUNOS'
    )
    BEGIN
        INSERT INTO setting_groups
        (
            code,
            name,
            description,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            'VACUNOS',
            'Vacunos',
            'Configuraciones dinámicas del módulo de gestión de vacunos.',
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* ========================================================
       2. SETTING DEFINITIONS
       ======================================================== */

    DECLARE @SettingGroupId INT;

    SELECT @SettingGroupId = id
    FROM setting_groups
    WHERE code = 'VACUNOS';


    /*
       S01 - Ventana de filtrado por defecto
    */
    IF NOT EXISTS (
        SELECT 1
        FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_DEFAULT_FILTER_DAYS'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id,
            code,
            name,
            description,
            data_type,
            default_value,
            validation_schema,
            is_required,
            is_sensitive,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_DEFAULT_FILTER_DAYS',
            'Días de filtro por defecto',
            'Cantidad de días hacia atrás usados como ventana de filtro cuando no se especifican fechas.',
            'INT',
            N'30',
            N'{"minimum":1,"maximum":365}',
            0,
            0,
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* S02 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_ARBOL_MIN_NIVELES'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value, validation_schema,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_ARBOL_MIN_NIVELES',
            'Niveles mínimos del árbol genealógico',
            'Cantidad mínima de niveles permitidos al consultar el árbol genealógico.',
            'INT',
            N'1',
            N'{"minimum":1,"maximum":10}',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S03 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_ARBOL_MAX_NIVELES'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value, validation_schema,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_ARBOL_MAX_NIVELES',
            'Niveles máximos del árbol genealógico',
            'Cantidad máxima de niveles permitidos al consultar el árbol genealógico.',
            'INT',
            N'4',
            N'{"minimum":1,"maximum":20}',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S04 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_CODIGO_MAX_LENGTH'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value, validation_schema,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_CODIGO_MAX_LENGTH',
            'Longitud máxima del código',
            'Longitud máxima permitida para el campo Código del vacuno.',
            'INT',
            N'10',
            N'{"minimum":1,"maximum":50}',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S05 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_INPUT_MAX_LENGTH'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value, validation_schema,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_INPUT_MAX_LENGTH',
            'Longitud máxima de entradas de texto',
            'Longitud máxima para campos de texto general como nombre, color y granja.',
            'INT',
            N'15',
            N'{"minimum":1,"maximum":100}',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S06 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_OBSERVACIONES_MAX_LENGTH'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value, validation_schema,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_OBSERVACIONES_MAX_LENGTH',
            'Longitud máxima de observaciones',
            'Longitud máxima en caracteres del campo Observaciones.',
            'INT',
            N'150',
            N'{"minimum":1,"maximum":1000}',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S07 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_OBSERVACIONES_MAX_WORDS'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value, validation_schema,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_OBSERVACIONES_MAX_WORDS',
            'Máximo de palabras en observaciones',
            'Cantidad máxima de palabras permitidas en el campo Observaciones.',
            'INT',
            N'30',
            N'{"minimum":1,"maximum":500}',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S08 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_FOTO_FORMATOS_PERMITIDOS'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_FOTO_FORMATOS_PERMITIDOS',
            'Formatos de foto permitidos',
            'Formatos de imagen permitidos para la foto referencial del vacuno, almacenados como CSV.',
            'STRING',
            N'"png,jpg"',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S09 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_CODIGO_UPPERCASE_REQUIRED'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_CODIGO_UPPERCASE_REQUIRED',
            'Código en mayúsculas',
            'Indica si todos los códigos de vacunos deben almacenarse en mayúsculas.',
            'BOOLEAN',
            N'true',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S10 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_REPORTE_FORMATOS_DESCARGA'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_REPORTE_FORMATOS_DESCARGA',
            'Formatos de descarga de reportes',
            'Formatos disponibles para descargar reportes, almacenados como CSV de extensiones.',
            'STRING',
            N'"xlsx,pdf"',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S11 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_ELIMINACION_UNDO_SECONDS'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value, validation_schema,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_ELIMINACION_UNDO_SECONDS',
            'Tiempo para deshacer eliminación',
            'Segundos disponibles para deshacer una eliminación mediante soft-delete.',
            'INT',
            N'5',
            N'{"minimum":1,"maximum":30}',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* S12 */
    IF NOT EXISTS (
        SELECT 1 FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'VACUNOS_FECUNDACION_OBSERVACIONES_MAX_LENGTH'
    )
    BEGIN
        INSERT INTO setting_definitions
        (
            setting_group_id, code, name, description,
            data_type, default_value, validation_schema,
            is_required, is_sensitive, is_active,
            created_at, updated_at
        )
        VALUES
        (
            @SettingGroupId,
            'VACUNOS_FECUNDACION_OBSERVACIONES_MAX_LENGTH',
            'Longitud máxima de observaciones de fecundación',
            'Longitud máxima de las observaciones veterinarias en el registro de fecundación.',
            'INT',
            N'500',
            N'{"minimum":1,"maximum":2000}',
            0, 0, 1,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );
    END;


    /* ========================================================
       3. FEATURES
       ======================================================== */

    /* F01 */
    IF NOT EXISTS (
        SELECT 1 FROM features
        WHERE code = 'MODULE_VACUNOS'
    )
    BEGIN
        INSERT INTO features
        (
            code,
            name,
            description,
            category,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            'MODULE_VACUNOS',
            'Módulo de Vacunos',
            'Habilita o deshabilita el acceso completo al módulo de gestión de vacunos.',
            'Modules',
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* F02 */
    IF NOT EXISTS (
        SELECT 1 FROM features
        WHERE code = 'MODULE_VACUNOS_REPRODUCCION'
    )
    BEGIN
        INSERT INTO features
        (
            code,
            name,
            description,
            category,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            'MODULE_VACUNOS_REPRODUCCION',
            'Reproducción de Vacunos',
            'Habilita o deshabilita el submódulo de reproducción de vacunos.',
            'Modules',
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* F03 */
    IF NOT EXISTS (
        SELECT 1 FROM features
        WHERE code = 'MODULE_VACUNOS_REPORTES'
    )
    BEGIN
        INSERT INTO features
        (
            code,
            name,
            description,
            category,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            'MODULE_VACUNOS_REPORTES',
            'Reportes de Vacunos',
            'Habilita o deshabilita el submódulo de reportes y gráficos de vacunos.',
            'Modules',
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* ========================================================
       4. BUSINESS RULE DEFINITIONS
       ======================================================== */

    /* R01 */
    IF NOT EXISTS (
        SELECT 1 FROM rule_definitions
        WHERE code = 'VACUNOS_ELIMINACION_CONDICIONADA'
    )
    BEGIN
        INSERT INTO rule_definitions
        (
            code,
            name,
            module,
            description,
            condition_schema,
            action_schema,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            'VACUNOS_ELIMINACION_CONDICIONADA',
            'Eliminación condicionada de vacunos',
            'Vacunos',
            'Controla bajo qué condiciones se permite eliminar mediante soft-delete un registro de vacuno.',
            N'{"has_dependents":false,"OR":{"is_duplicate":true,"is_last_duplicate":true}}',
            N'{"action":"soft_delete","audit":true,"reason_required":true}',
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* R02 */
    IF NOT EXISTS (
        SELECT 1 FROM rule_definitions
        WHERE code = 'VACUNOS_FECUNDACION_TRAZABILIDAD'
    )
    BEGIN
        INSERT INTO rule_definitions
        (
            code,
            name,
            module,
            description,
            condition_schema,
            action_schema,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            'VACUNOS_FECUNDACION_TRAZABILIDAD',
            'Trazabilidad de fecundación',
            'Vacunos',
            'Al guardar una fecundación exitosa, actualiza automáticamente la trazabilidad del vacuno nacido.',
            N'{"resultado":"Exitosa"}',
            N'{"update_trazabilidad":true,"link_parents":true}',
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* R03 */
    IF NOT EXISTS (
        SELECT 1 FROM rule_definitions
        WHERE code = 'VACUNOS_FECUNDACION_PENDIENTE_UNICA'
    )
    BEGIN
        INSERT INTO rule_definitions
        (
            code,
            name,
            module,
            description,
            condition_schema,
            action_schema,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            'VACUNOS_FECUNDACION_PENDIENTE_UNICA',
            'Fecundación pendiente única',
            'Vacunos',
            'Una hembra solo puede tener una fecundación con estado Pendiente de confirmación a la vez.',
            N'{"receptor_sexo":"Hembra","estado_activo":"Pendiente de confirmación"}',
            N'{"block_new_registration":true}',
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* ========================================================
       5. CONFIRMACIÓN
       ======================================================== */

    COMMIT TRANSACTION;

    PRINT 'Catálogo de Vacunos insertado correctamente.';

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;


/* ============================================================
   CONSULTAS DE VERIFICACIÓN
   ============================================================ */

-- Settings
SELECT
    sg.code AS setting_group,
    sd.code,
    sd.data_type,
    sd.default_value,
    sd.validation_schema
FROM setting_groups sg
INNER JOIN setting_definitions sd
    ON sd.setting_group_id = sg.id
WHERE sg.code = 'VACUNOS'
ORDER BY sd.code;


-- Features
SELECT
    code,
    name,
    category,
    is_active
FROM features
WHERE code LIKE 'MODULE_VACUNOS%'
ORDER BY code;


-- Rules
SELECT
    code,
    name,
    module,
    condition_schema,
    action_schema,
    is_active
FROM rule_definitions
WHERE module = 'Vacunos'
ORDER BY code;