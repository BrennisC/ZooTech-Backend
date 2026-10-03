#!/bin/bash
set -e

echo "Esperando SQL Server..."

until /opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -Q "SELECT 1" > /dev/null 2>&1
do
    sleep 3
done

echo "SQL Server disponible."

# ============================================================
# Creacion de Usuarios y Base de Datos (Admin) 
# en SQL Server 
# ============================================================

if [ -z "$MULTITENANT_ADMIN_DATABASE_NAME" ]; then
    echo "Error: La variable MULTITENANT_ADMIN_DATABASE_NAME no está definida o está vacía. Proceso cancelado, no se insertaron datos."
    exit 1
fi

if [ -z "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" ]; then
    echo "Error: La variable ZOOTECH_DB_SQLSERVER_CONTAINER_NAME no está definida o está vacía. Proceso cancelado, no se insertaron datos."
    exit 1
fi

echo "Creando usuario de BD y BD admin en SQL SERVER..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -i /scripts/create-userdb-and-db-admin.sql

# ============================================================
# Creacion de Bases de Datos (Tenants) 
# en SQL Server 
# ============================================================

if [[ "${ZOOTECH_SQL_TENANTS_INIT_EXECUTE,,}" == "true" ]]; then
    echo "Creando BD para los tenants en SQL SERVER..."
    /opt/mssql-tools/bin/sqlcmd \
        -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
        -U sa \
        -P "$MSSQL_SA_PASSWORD" \
        -C \
        -i /scripts/create-db-tenants.sql
fi

# ============================================================
# Creacion de Base de Datos Admin Principal
# ============================================================

echo "Creando $MULTITENANT_ADMIN_DATABASE_NAME..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -d $MULTITENANT_ADMIN_DATABASE_NAME \
    -i /scripts/admin/01-create-admin.sql

# ============================================================
# Insertando Informacion de Tenant Admin 
# ============================================================

echo "Insertando datos de admin en $MULTITENANT_ADMIN_DATABASE_NAME..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -d $MULTITENANT_ADMIN_DATABASE_NAME \
    -i /scripts/admin/02-insert-admin-tenant-info.sql

# ============================================================
# Insertando settings, features y rules para los Tenants en
# Admin DB
# ============================================================

echo "Insertando valores de parametrizacion en $MULTITENANT_ADMIN_DATABASE_NAME..."

echo "Modulo Produccion-Leche"
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -d $MULTITENANT_ADMIN_DATABASE_NAME \
    -i /scripts/admin/03-insert-parametrizartion-values-produccion-leche.sql

echo "Modulo Sanidad"
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -d $MULTITENANT_ADMIN_DATABASE_NAME \
    -i /scripts/admin/03-insert-parametrizartion-values-sanidad.sql

echo "Modulo Vacuno"
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -d $MULTITENANT_ADMIN_DATABASE_NAME \
    -i /scripts/admin/03-insert-parametrization-values-vacuno.sql

echo "Modulo Celo"
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -d $MULTITENANT_ADMIN_DATABASE_NAME \
    -i /scripts/admin/03-insert-parametrization-values-celo.sql

# ============================================================
# Insertando informacion de tenants (clientes) en Admin DB
# ============================================================

if [[ "${ZOOTECH_SQL_TENANTS_INIT_EXECUTE,,}" == "true" ]]; then
    echo "Insertando informacion de tenants..."
    /opt/mssql-tools/bin/sqlcmd \
        -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
        -U sa \
        -P "$MSSQL_SA_PASSWORD" \
        -C \
        -d $MULTITENANT_ADMIN_DATABASE_NAME \
        -i /scripts/admin/04-insert-tenants-info.sql
fi

# ============================================================
# Insertando informacion de usuario administrador
# inicial
# ============================================================

echo "Insertando usuario admin de prueba..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -d $MULTITENANT_ADMIN_DATABASE_NAME \
    -i /scripts/admin/05-insert-test-admin-user.sql

# ============================================================
# Creacion de Esquema de DB para cada Tenant (cliente)
# ============================================================

if [[ "${ZOOTECH_SQL_TENANTS_INIT_EXECUTE,,}" == "false" ]]; then
    echo "Omitiendo creacion de esquemas en DBs Tenants..."
    exit 0
fi


if [ -z "$ZOOTECH_TENANT_DB_NAME_1" ]; then
    echo "La variable ZOOTECH_TENANT_DB_NAME_1 no está definida o está vacía. Deteniendo."
    exit 0
fi

if [ -z "$ZOOTECH_DB_USER" ]; then
    echo "La variable ZOOTECH_DB_USER no está definida o está vacía. Deteniendo."
    exit 0
fi

export ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO="$ZOOTECH_TENANT_1_ADDRESS_DEPARTAMENTO"
export ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE="$ZOOTECH_TENANT_1_ADDRESS_DEPARTAMENTO_CODE"
export ZOOTECH_TENANT_ADDRESS_PROVINCIA="$ZOOTECH_TENANT_1_ADDRESS_PROVINCIA"
export ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE="$ZOOTECH_TENANT_1_ADDRESS_PROVINCIA_CODE"
export ZOOTECH_TENANT_ADDRESS_DISTRITO="$ZOOTECH_TENANT_1_ADDRESS_DISTRITO"
export ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE="$ZOOTECH_TENANT_1_ADDRESS_DISTRITO_CODE"

echo "Creando Esquema para $ZOOTECH_TENANT_DB_NAME_1..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U "$ZOOTECH_DB_USER" \
    -P "$ZOOTECH_DB_USER_PASSWORD" \
    -C \
    -d $ZOOTECH_TENANT_DB_NAME_1 \
    -i /scripts/tenants/create-tenants.sql
echo "Insertando datos de cat_ y geo_ para $ZOOTECH_TENANT_DB_NAME_1..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U "$ZOOTECH_DB_USER" \
    -P "$ZOOTECH_DB_USER_PASSWORD" \
    -C \
    -d $ZOOTECH_TENANT_DB_NAME_1 \
    -i /scripts/tenants/insert-common-info-in-tenants.sql


if [ -z "$ZOOTECH_TENANT_DB_NAME_2" ]; then
    echo "Error: La variable ZOOTECH_TENANT_DB_NAME_2 no está definida o está vacía. Deteniendo."
    exit 0
fi

export ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO="$ZOOTECH_TENANT_2_ADDRESS_DEPARTAMENTO"
export ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE="$ZOOTECH_TENANT_2_ADDRESS_DEPARTAMENTO_CODE"
export ZOOTECH_TENANT_ADDRESS_PROVINCIA="$ZOOTECH_TENANT_2_ADDRESS_PROVINCIA"
export ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE="$ZOOTECH_TENANT_2_ADDRESS_PROVINCIA_CODE"
export ZOOTECH_TENANT_ADDRESS_DISTRITO="$ZOOTECH_TENANT_2_ADDRESS_DISTRITO"
export ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE="$ZOOTECH_TENANT_2_ADDRESS_DISTRITO_CODE"

echo "Creando Esquema para $ZOOTECH_TENANT_DB_NAME_2..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U "$ZOOTECH_DB_USER" \
    -P "$ZOOTECH_DB_USER_PASSWORD" \
    -C \
    -d $ZOOTECH_TENANT_DB_NAME_2 \
    -i /scripts/tenants/create-tenants.sql
echo "Insertando datos de cat_ y geo_ para $ZOOTECH_TENANT_DB_NAME_2..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U "$ZOOTECH_DB_USER" \
    -P "$ZOOTECH_DB_USER_PASSWORD" \
    -C \
    -d $ZOOTECH_TENANT_DB_NAME_2 \
    -i /scripts/tenants/insert-common-info-in-tenants.sql

if [ -z "$ZOOTECH_TENANT_DB_NAME_3" ]; then
    echo "Error: La variable ZOOTECH_TENANT_DB_NAME_3 no está definida o está vacía. Deteniendo."
    exit 0
fi

export ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO="$ZOOTECH_TENANT_3_ADDRESS_DEPARTAMENTO"
export ZOOTECH_TENANT_ADDRESS_DEPARTAMENTO_CODE="$ZOOTECH_TENANT_3_ADDRESS_DEPARTAMENTO_CODE"
export ZOOTECH_TENANT_ADDRESS_PROVINCIA="$ZOOTECH_TENANT_3_ADDRESS_PROVINCIA"
export ZOOTECH_TENANT_ADDRESS_PROVINCIA_CODE="$ZOOTECH_TENANT_3_ADDRESS_PROVINCIA_CODE"
export ZOOTECH_TENANT_ADDRESS_DISTRITO="$ZOOTECH_TENANT_3_ADDRESS_DISTRITO"
export ZOOTECH_TENANT_ADDRESS_DISTRITO_CODE="$ZOOTECH_TENANT_3_ADDRESS_DISTRITO_CODE"

echo "Creando Esquema para $ZOOTECH_TENANT_DB_NAME_3..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U "$ZOOTECH_DB_USER" \
    -P "$ZOOTECH_DB_USER_PASSWORD" \
    -C \
    -d $ZOOTECH_TENANT_DB_NAME_3 \
    -i /scripts/tenants/create-tenants.sql
echo "Insertando datos de cat_ y geo_ para $ZOOTECH_TENANT_DB_NAME_3..."
/opt/mssql-tools/bin/sqlcmd \
    -S "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" \
    -U "$ZOOTECH_DB_USER" \
    -P "$ZOOTECH_DB_USER_PASSWORD" \
    -C \
    -d $ZOOTECH_TENANT_DB_NAME_3 \
    -i /scripts/tenants/insert-common-info-in-tenants.sql

echo "Inicialización SQL completada."