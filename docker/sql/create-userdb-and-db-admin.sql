/*
    docker/sql/create-users-and-dbs.sql

    Crea:
      - Login SQL Server: $(DB_USER)
      - Base de datos: Admin
      - Base de datos: Tenants

    El mismo usuario tendrá:
      - db_owner sobre Admin
      - db_owner sobre Tenants
      - dbcreator a nivel de servidor
        -> puede crear nuevas bases de datos.

    Las credenciales se pasan desde sqlcmd mediante -v.
*/


/* ============================================================
   1. CREAR LOGIN A NIVEL DE SERVIDOR
   ============================================================ */

USE [master];
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.server_principals
    WHERE name = N'$(ZOOTECH_DB_USER)'
)
BEGIN

    PRINT 'Creando login $(ZOOTECH_DB_USER)...';

    CREATE LOGIN [$(ZOOTECH_DB_USER)]
    WITH PASSWORD = '$(ZOOTECH_DB_USER_PASSWORD)',
         CHECK_POLICY = ON;

END
ELSE
BEGIN

    PRINT 'El login $(ZOOTECH_DB_USER) ya existe. No se crea nuevamente.';

END;
GO


/* ============================================================
   2. PERMITIR CREAR BASES DE DATOS
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.server_role_members rm
    INNER JOIN sys.server_principals role_principal
        ON rm.role_principal_id = role_principal.principal_id
    INNER JOIN sys.server_principals member_principal
        ON rm.member_principal_id = member_principal.principal_id
    WHERE role_principal.name = N'dbcreator'
      AND member_principal.name = N'$(ZOOTECH_DB_USER)'
)
BEGIN

    PRINT 'Agregando $(ZOOTECH_DB_USER) al rol dbcreator...';

    ALTER SERVER ROLE [dbcreator]
    ADD MEMBER [$(ZOOTECH_DB_USER)];

END
ELSE
BEGIN

    PRINT '$(ZOOTECH_DB_USER) ya pertenece a dbcreator.';

END;
GO


/* ============================================================
   3. CREAR BASE DE DATOS ADMIN
   ============================================================ */

IF DB_ID(N'$(MULTITENANT_ADMIN_DATABASE_NAME)') IS NULL
BEGIN

    PRINT 'Creando base de datos $(MULTITENANT_ADMIN_DATABASE_NAME)...';

    CREATE DATABASE [$(MULTITENANT_ADMIN_DATABASE_NAME)];

END
ELSE
BEGIN

    PRINT 'La base $(MULTITENANT_ADMIN_DATABASE_NAME) ya existe.';

END;
GO


/* Crear usuario dentro de Admin */

USE [$(MULTITENANT_ADMIN_DATABASE_NAME)];
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'$(ZOOTECH_DB_USER)'
)
BEGIN

    PRINT 'Creando usuario $(ZOOTECH_DB_USER) en Admin...';

    CREATE USER [$(ZOOTECH_DB_USER)]
    FOR LOGIN [$(ZOOTECH_DB_USER)];

END
ELSE
BEGIN

    PRINT 'El usuario $(ZOOTECH_DB_USER) ya existe en Admin.';

END;
GO

/*
    db_owner permite:

    - Crear tablas
    - Crear índices
    - Crear vistas
    - Crear procedimientos
    - Crear funciones
    - Crear/modificar/eliminar objetos
    - Leer y escribir datos
    - Ejecutar operaciones administrativas dentro de la BD
*/

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

    PRINT 'Agregando $(ZOOTECH_DB_USER) a db_owner en Admin...';

    ALTER ROLE [db_owner]
    ADD MEMBER [$(ZOOTECH_DB_USER)];

END
ELSE
BEGIN

    PRINT '$(ZOOTECH_DB_USER) ya pertenece a db_owner en Admin.';

END;
GO