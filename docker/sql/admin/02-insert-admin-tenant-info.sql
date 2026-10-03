SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

    ------------------------------------------------------------
    -- TENANT
    ------------------------------------------------------------
    INSERT INTO tenants
    (
        code,
        subdomain,
        display_name,
        legal_name,
        email,
        phone,
        timezone,
        status,
        metadata,
        created_at
    )
    VALUES
    (
        N'$(ZOOTECH_ADMIN_TENANT_CODE)',
        N'$(MULTITENANT_ADMIN_SUB_DOMAIN)',
        N'$(ZOOTECH_ADMIN_TENANT_DISPLAY_NAME)',
        N'$(ZOOTECH_ADMIN_TENANT_LEGAL_NAME)',
        N'$(ZOOTECH_ADMIN_TENANT_EMAIL)',
        '+51 999 888 777',
        N'$(ZOOTECH_ADMIN_TENANT_TIMEZONE)',
        N'$(ZOOTECH_ADMIN_TENANT_STATUS)',
        NULL,
        SYSDATETIMEOFFSET()
    );

    DECLARE @TenantId INT = SCOPE_IDENTITY();

    ------------------------------------------------------------
    -- ADDRESS
    ------------------------------------------------------------
    INSERT INTO addresses
    (
        tenant_id,
        country,
        state,
        province,
        city,
        address_line_1,
        address_line_2,
        metadata,
        created_at
    )
    VALUES
    (
        @TenantId,
        'Perú',
        'Huánuco',
        'Leoncio Prado',
        'Tingo María',
        'Jr. Raymondi 350',
        NULL,
        NULL,
        SYSDATETIMEOFFSET()
    );

    ------------------------------------------------------------
    -- TENANT BRANDING
    ------------------------------------------------------------
    INSERT INTO tenant_branding
    (
        tenant_id,
        primary_color,
        secondary_color,
        accent_color,
        logo_url,
        favicon_url,
        login_background_url,
        custom_css,
        metadata,
        created_at
    )
    VALUES
    (
        @TenantId,
        '#37474f',
        '#263238',
        '#eceff1',
        'https://cdn.zootech.com/tenants/soporte/logo.png',
        'https://cdn.zootech.com/tenants/soporte/favicon.ico',
        'https://cdn.zootech.com/tenants/soporte/login-bg.jpg',
        NULL,
        NULL,
        SYSDATETIMEOFFSET()
    );
------------------------------------------------------------
-- TENANT DATABASE CONNECTION
------------------------------------------------------------
INSERT INTO tenant_database_connections
(
    tenant_id,
    database_name,
    server_name,
    provider,
    connection_string_encrypted,
    is_active,
    metadata,
    created_at
)
VALUES
(
    @TenantId,
    N'$(MULTITENANT_ADMIN_DATABASE_NAME)',
    N'$(ZOOTECH_DB_SQLSERVER_CONTAINER_NAME)',
    'SQLSERVER',
    NULL,
    1,
    NULL,
    SYSDATETIMEOFFSET()
);
    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;