/* ============================================================
   4. CREAR BASE DE DATOS TENANTS 1
   ============================================================ */

USE [master];
GO

IF DB_ID(N'$(ZOOTECH_TENANT_DB_NAME_1)') IS NULL
BEGIN

    PRINT 'Creando $(ZOOTECH_TENANT_DB_NAME_1)...';

    CREATE DATABASE [$(ZOOTECH_TENANT_DB_NAME_1)];

END
ELSE
BEGIN

    PRINT '$(ZOOTECH_TENANT_DB_NAME_1) ya existe.';

END;
GO


/* Crear usuario dentro de Tenant 1 */

USE [$(ZOOTECH_TENANT_DB_NAME_1)];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'$(ZOOTECH_DB_USER)'
)
BEGIN
    CREATE USER [$(ZOOTECH_DB_USER)]
    FOR LOGIN [$(ZOOTECH_DB_USER)];
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_role_members rm
    INNER JOIN sys.database_principals role_principal
        ON rm.role_principal_id = role_principal.principal_id
    INNER JOIN sys.database_principals member_principal
        ON rm.member_principal_id = member_principal.principal_id
    WHERE role_principal.name = N'db_owner'
      AND member_principal.name = N'$(ZOOTECH_DB_USER)'
)
BEGIN

    ALTER ROLE [db_owner]
    ADD MEMBER [$(ZOOTECH_DB_USER)];

END;
GO

/* ============================================================
   5. CREAR BASE DE DATOS TENANT 2
   ============================================================ */

USE [master];
GO

IF DB_ID(N'$(ZOOTECH_TENANT_DB_NAME_2)') IS NULL
BEGIN

    PRINT 'Creando $(ZOOTECH_TENANT_DB_NAME_2)...';

    CREATE DATABASE [$(ZOOTECH_TENANT_DB_NAME_2)];

END
ELSE
BEGIN

    PRINT '$(ZOOTECH_TENANT_DB_NAME_2) ya existe.';

END;
GO

/* Crear usuario dentro de Tenant 2 */

USE [$(ZOOTECH_TENANT_DB_NAME_2)];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'$(ZOOTECH_DB_USER)'
)
BEGIN
    CREATE USER [$(ZOOTECH_DB_USER)]
    FOR LOGIN [$(ZOOTECH_DB_USER)];
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_role_members rm
    INNER JOIN sys.database_principals role_principal
        ON rm.role_principal_id = role_principal.principal_id
    INNER JOIN sys.database_principals member_principal
        ON rm.member_principal_id = member_principal.principal_id
    WHERE role_principal.name = N'db_owner'
      AND member_principal.name = N'$(ZOOTECH_DB_USER)'
)
BEGIN

    ALTER ROLE [db_owner]
    ADD MEMBER [$(ZOOTECH_DB_USER)];

END;
GO

/* ============================================================
   6. CREAR BASE DE DATOS TENANT 3
   ============================================================ */


USE [master];
GO

IF DB_ID(N'$(ZOOTECH_TENANT_DB_NAME_3)') IS NULL
BEGIN

    PRINT 'Creando $(ZOOTECH_TENANT_DB_NAME_3)...';

    CREATE DATABASE [$(ZOOTECH_TENANT_DB_NAME_3)];

END
ELSE
BEGIN

    PRINT '$(ZOOTECH_TENANT_DB_NAME_3) ya existe.';

END;
GO

/* Crear usuario dentro de Tenant 3 */

USE [$(ZOOTECH_TENANT_DB_NAME_3)];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'$(ZOOTECH_DB_USER)'
)
BEGIN
    CREATE USER [$(ZOOTECH_DB_USER)]
    FOR LOGIN [$(ZOOTECH_DB_USER)];
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_role_members rm
    INNER JOIN sys.database_principals role_principal
        ON rm.role_principal_id = role_principal.principal_id
    INNER JOIN sys.database_principals member_principal
        ON rm.member_principal_id = member_principal.principal_id
    WHERE role_principal.name = N'db_owner'
      AND member_principal.name = N'$(ZOOTECH_DB_USER)'
)
BEGIN

    ALTER ROLE [db_owner]
    ADD MEMBER [$(ZOOTECH_DB_USER)];

END;
GO