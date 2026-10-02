/* ============================================================
   CATÁLOGO DE SETTINGS - MÓDULO CELO
   SQL SERVER 2025

   IMPORTANTE:
   - No relaciona los settings con tenants.
   - No inserta registros en setting_values.
   - Solo crea el grupo y las definiciones centrales.
   ============================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    /* ========================================================
       1. SETTING GROUP
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM setting_groups
        WHERE code = 'CELO'
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
            'CELO',
            'Celo',
            'Configuraciones dinámicas utilizadas para determinar el ciclo estral y el estado reproductivo de las vacas.',
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* ========================================================
       2. OBTENER ID DEL GRUPO
       ======================================================== */

    DECLARE @SettingGroupId INT;

    SELECT @SettingGroupId = id
    FROM setting_groups
    WHERE code = 'CELO';


    /* ========================================================
       3. DuracionCicloDias
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'DURACION_CICLO_DIAS'
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
            'DURACION_CICLO_DIAS',
            'Duración del ciclo estral',
            'Duración estándar del ciclo estral, expresada en días entre un celo y el siguiente.',
            'INT',
            N'21',
            N'{"minimum":1,"maximum":365}',
            0,
            0,
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* ========================================================
       4. DiasEnCelo
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'DIAS_EN_CELO'
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
            'DIAS_EN_CELO',
            'Días en celo',
            'Cantidad de días posteriores al último celo registrado durante los cuales la vaca se considera En celo.',
            'INT',
            N'2',
            N'{"minimum":1,"maximum":30}',
            0,
            0,
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* ========================================================
       5. DiasProximo
       ======================================================== */

    IF NOT EXISTS
    (
        SELECT 1
        FROM setting_definitions
        WHERE setting_group_id = @SettingGroupId
          AND code = 'DIAS_PROXIMO'
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
            'DIAS_PROXIMO',
            'Días para próximo celo',
            'Ventana de días antes del próximo celo esperado durante la cual la vaca se considera Próxima.',
            'INT',
            N'3',
            N'{"minimum":1,"maximum":30}',
            0,
            0,
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END;


    /* ========================================================
       6. CONFIRMAR TRANSACCIÓN
       ======================================================== */

    COMMIT TRANSACTION;

    PRINT 'Settings del módulo CELO insertados correctamente.';

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;


/* ============================================================
   VERIFICACIÓN
   ============================================================ */

SELECT
    sg.code AS setting_group,
    sd.code,
    sd.name,
    sd.data_type,
    sd.default_value,
    sd.validation_schema
FROM setting_groups sg
INNER JOIN setting_definitions sd
    ON sd.setting_group_id = sg.id
WHERE sg.code = 'CELO'
ORDER BY sd.id;