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

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = N'$(ZOOTECH_DB_USER)'
)
BEGIN
    CREATE LOGIN [$(ZOOTECH_DB_USER)]
    WITH PASSWORD = '$(ZOOTECH_DB_USER_PASSWORD)',
         CHECK_POLICY = ON;
END;
GO


/* ============================================================
   2. PERMITIR CREAR BASES DE DATOS
   ============================================================ */

ALTER SERVER ROLE [dbcreator]
ADD MEMBER [$(ZOOTECH_DB_USER)];
GO


/* ============================================================
   3. CREAR BASE DE DATOS ADMIN
   ============================================================ */

IF DB_ID(N'$(MULTITENANT_ADMIN_DATABASE_NAME)') IS NULL
BEGIN
    CREATE DATABASE [$(MULTITENANT_ADMIN_DATABASE_NAME)];
END;
GO


/* Crear usuario dentro de Admin */

USE [$(MULTITENANT_ADMIN_DATABASE_NAME)];
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

ALTER ROLE [db_owner]
ADD MEMBER [$(ZOOTECH_DB_USER)];
GO