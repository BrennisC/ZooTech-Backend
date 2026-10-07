SET XACT_ABORT ON;

BEGIN TRY

BEGIN TRANSACTION;

------------------------------------------------------------
-- TENANTS
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
    created_at,
    updated_at,
    deleted_at
)
SELECT
    V.Code,
    V.Subdomain,
    V.DisplayName,
    V.LegalName,
    V.Email,
    V.Phone,
    V.Timezone,
    V.Status,
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME(),
    NULL
FROM
(
VALUES

('GANADERA_ALTO_HUALLAGA',N'zootech-app-altohuallaga',N'Ganadera Alto Huallaga',N'Ganadera Alto Huallaga S.A.C.',N'contacto@altohuallaga.com',N'+51 962 200 200',N'America/Lima',N'ACTIVE'),
('AGROPECUARIA_MONZON',N'zootech-app-agromonzon',N'Agropecuaria Monzón',N'Agropecuaria Monzón S.R.L.',N'contacto@agromonzon.com',N'+51 962 300 300',N'America/Lima',N'ACTIVE'),
('FUNDO_RIO_VERDE',N'zootech-app-rioverde',N'Fundo Río Verde',N'Fundo Río Verde S.A.C.',N'contacto@fundorioverde.com',N'+51 962 400 400',N'America/Lima',N'TRIAL')

) V (Code, Subdomain, DisplayName, LegalName, Email, Phone, Timezone, Status)
WHERE NOT EXISTS
(
    SELECT 1
    FROM tenants t
    WHERE t.code = V.Code
);

------------------------------------------------------------
-- ADDRESSES
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
    created_at,
    updated_at,
    deleted_at
)
SELECT
    t.id,
    V.Country,
    V.State,
    V.Province,
    V.City,
    V.AddressLine1,
    V.AddressLine2,
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME(),
    NULL
FROM tenants t
JOIN
(
VALUES

('GANADERA_ALTO_HUALLAGA',N'Perú',N'Húanuco',N'Leoncio Prado',N'Tingo María',N'Carretera Fernando Belaúnde Terry km 5',NULL),
('AGROPECUARIA_MONZON',N'Perú',N'Húanuco',N'Huamalíes',N'Monzón',N'Plaza de Armas s/n',NULL),
('FUNDO_RIO_VERDE',N'Perú',N'Húanuco',N'Pachitea',N'Panao',N'Camino a Chaglla km 3',NULL)

) V (Code, Country, State, Province, City, AddressLine1, AddressLine2)
    ON t.code = V.Code
WHERE NOT EXISTS
(
    SELECT 1
    FROM addresses a
    WHERE a.tenant_id = t.id
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
    created_at,
    updated_at,
    deleted_at
)
SELECT
    t.id,
    V.PrimaryColor,
    V.SecondaryColor,
    V.AccentColor,
    V.LogoUrl,
    V.FaviconUrl,
    V.LoginBackgroundUrl,
    NULL,
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME(),
    NULL
FROM tenants t
JOIN
(
VALUES

('GANADERA_ALTO_HUALLAGA',N'#2e7d32',N'#1b5e20',N'#e8f5e9',N'https://cdn.zootech.com/tenants/altohuallaga/logo.png',N'https://cdn.zootech.com/tenants/altohuallaga/favicon.ico',N'https://cdn.zootech.com/tenants/altohuallaga/login-bg.jpg'),
('AGROPECUARIA_MONZON',N'#8d6e63',N'#5d4037',N'#efebe9',N'https://cdn.zootech.com/tenants/monzon/logo.png',N'https://cdn.zootech.com/tenants/monzon/favicon.ico',N'https://cdn.zootech.com/tenants/monzon/login-bg.jpg'),
('FUNDO_RIO_VERDE',N'#00838f',N'#006064',N'#e0f7fa',N'https://cdn.zootech.com/tenants/rioverde/logo.png',N'https://cdn.zootech.com/tenants/rioverde/favicon.ico',N'https://cdn.zootech.com/tenants/rioverde/login-bg.jpg')

) V (Code, PrimaryColor, SecondaryColor, AccentColor, LogoUrl, FaviconUrl, LoginBackgroundUrl)
    ON t.code = V.Code
WHERE NOT EXISTS
(
    SELECT 1
    FROM tenant_branding b
    WHERE b.tenant_id = t.id
);

------------------------------------------------------------
-- TENANT DATABASE CONNECTIONS
-- NOTA: connection_string_encrypted es un valor PLACEHOLDER.
-- Reemplazar por la cadena de conexion real cifrada antes de usar en produccion.
-- Cada organizacion tiene su PROPIA base de datos (una por tenant), creada
-- ejecutando "Script - Create - Tenant DB.sql" con el nombre de base indicado
-- aqui, y luego poblada con datos masivos usando el ZooTechDataSeeder.
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
    created_at,
    updated_at,
    deleted_at
)
SELECT
    t.id,
    V.DatabaseName,
    V.ServerName,
    V.Provider,
    V.ConnectionStringEncrypted,
    1,
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME(),
    NULL
FROM tenants t
JOIN
(
VALUES

('GANADERA_ALTO_HUALLAGA',N'$(ZOOTECH_TENANT_DB_NAME_1)',N'$(ZOOTECH_DB_SQLSERVER_CONTAINER_NAME)',N'SQLSERVER',N''),
('AGROPECUARIA_MONZON',N'$(ZOOTECH_TENANT_DB_NAME_2)',N'$(ZOOTECH_DB_SQLSERVER_CONTAINER_NAME)',N'SQLSERVER',N''),
('FUNDO_RIO_VERDE',N'$(ZOOTECH_TENANT_DB_NAME_2)',N'$(ZOOTECH_DB_SQLSERVER_CONTAINER_NAME)',N'SQLSERVER',N'')

) V (Code, DatabaseName, ServerName, Provider, ConnectionStringEncrypted)
    ON t.code = V.Code
WHERE NOT EXISTS
(
    SELECT 1
    FROM tenant_database_connections c
    WHERE c.tenant_id = t.id
);

------------------------------------------------------------
-- TENANT FEATURES
-- Asocia las 4 organizaciones nuevas con TODAS las features activas actualmente
-- definidas en la plataforma (tabla features).
------------------------------------------------------------

INSERT INTO tenant_features
(
    tenant_id,
    feature_id,
    is_enabled,
    enabled_at,
    expires_at,
    updated_at,
    metadata
)
SELECT
    t.id,
    f.id,
    1,
    SYSUTCDATETIME(),
    NULL,
    SYSUTCDATETIME(),
    NULL
FROM tenants t
CROSS JOIN features f
WHERE t.code IN ('GANADERA_ALTO_HUALLAGA','AGROPECUARIA_MONZON','FUNDO_RIO_VERDE')
  AND f.is_active = 1
  AND f.deleted_at IS NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM tenant_features tf
      WHERE tf.tenant_id = t.id
        AND tf.feature_id = f.id
  );

------------------------------------------------------------
-- SETTING VALUES
-- Asocia las 4 organizaciones nuevas con TODOS los setting_definitions activos
-- actualmente definidos (VACUNOS, SANIDAD, PRODUCCION_LECHE), usando el
-- default_value de cada definicion como valor inicial a nivel TENANT.
------------------------------------------------------------

INSERT INTO setting_values
(
    tenant_id,
    setting_definition_id,
    actor_type,
    actor_id,
    value,
    is_active,
    metadata,
    created_at,
    updated_at,
    deleted_at
)
SELECT
    t.id,
    sd.id,
    'TENANT',
    NULL,
    sd.default_value,
    1,
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME(),
    NULL
FROM tenants t
CROSS JOIN setting_definitions sd
WHERE t.code IN ('GANADERA_ALTO_HUALLAGA','AGROPECUARIA_MONZON','FUNDO_RIO_VERDE')
  AND sd.is_active = 1
  AND sd.deleted_at IS NULL
  AND sd.default_value IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM setting_values sv
      WHERE sv.tenant_id = t.id
        AND sv.setting_definition_id = sd.id
        AND sv.actor_type = 'TENANT'
        AND sv.actor_id IS NULL
  );

------------------------------------------------------------
-- TENANT BUSINESS RULES
-- Asocia las 4 organizaciones nuevas con TODAS las reglas de negocio activas
-- actualmente definidas en rule_definitions.
------------------------------------------------------------

INSERT INTO tenant_business_rules
(
    tenant_id,
    rule_definition_id,
    is_active,
    priority,
    rule_version,
    execution_mode,
    custom_condition,
    custom_action,
    metadata,
    created_at,
    updated_at,
    deleted_at
)
SELECT
    t.id,
    rd.id,
    1,
    0,
    1,
    'SYNC',
    NULL,
    NULL,
    NULL,
    SYSUTCDATETIME(),
    SYSUTCDATETIME(),
    NULL
FROM tenants t
CROSS JOIN rule_definitions rd
WHERE t.code IN ('GANADERA_ALTO_HUALLAGA','AGROPECUARIA_MONZON','FUNDO_RIO_VERDE')
  AND rd.is_active = 1
  AND rd.deleted_at IS NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM tenant_business_rules tbr
      WHERE tbr.tenant_id = t.id
        AND tbr.rule_definition_id = rd.id
  );

COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;