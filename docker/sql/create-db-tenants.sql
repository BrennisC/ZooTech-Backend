/* ============================================================
   4. CREAR BASE DE DATOS TENANTS 1
   ============================================================ */

USE [master];
GO

IF DB_ID(N'$(ZOOTECH_TENANT_DB_NAME_1)') IS NULL
BEGIN
    CREATE DATABASE [$(ZOOTECH_TENANT_DB_NAME_1)];
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

ALTER ROLE [db_owner]
ADD MEMBER [$(ZOOTECH_DB_USER)];
GO

/* ============================================================
   5. CREAR BASE DE DATOS TENANT 2
   ============================================================ */

USE [master];
GO

IF DB_ID(N'$(ZOOTECH_TENANT_DB_NAME_2)') IS NULL
BEGIN
    CREATE DATABASE [$(ZOOTECH_TENANT_DB_NAME_2)];
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

ALTER ROLE [db_owner]
ADD MEMBER [$(ZOOTECH_DB_USER)];
GO

/* ============================================================
   6. CREAR BASE DE DATOS TENANT 3
   ============================================================ */


USE [master];
GO

IF DB_ID(N'$(ZOOTECH_TENANT_DB_NAME_3)') IS NULL
BEGIN
    CREATE DATABASE [$(ZOOTECH_TENANT_DB_NAME_3)];
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

ALTER ROLE [db_owner]
ADD MEMBER [$(ZOOTECH_DB_USER)];
GO