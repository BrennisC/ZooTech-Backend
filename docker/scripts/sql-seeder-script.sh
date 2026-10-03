#!/bin/bash
set -e

if [[ "${ZOOTECH_SEEDER_INIT_AUTOMATICALLY,,}" == "false" ]]; then
    echo "Omitiendo proceso de SEED automatico..."
    exit 0
fi

if [ -z "$ZOOTECH_DB_USER" ]; then
    echo "Error: La variable ZOOTECH_DB_USER no está definida o está vacía. Proceso cancelado, no se insertaron datos."
    exit 1
fi

if [ -z "$ZOOTECH_DB_SQLSERVER_CONTAINER_NAME" ]; then
    echo "La variable ZOOTECH_DB_SQLSERVER_CONTAINER_NAME no está definida o está vacía. Deteniendo."
    exit 1
fi

if [ -z "$ZOOTECH_TENANT_DB_NAME_1" ]; then
    echo "La variable ZOOTECH_TENANT_DB_NAME_1 no está definida o está vacía. Deteniendo."
    exit 0
fi

# Ingreso a carpeta /app
cd /app

echo "Iniciando el proceso de seeding..."

echo "Seed Base de Datos $ZOOTECH_TENANT_DB_NAME_1..."
dotnet ZooTech.DataSeeder.dll \
      --conn "Server=${ZOOTECH_DB_SQLSERVER_CONTAINER_NAME},1433;Database=${ZOOTECH_TENANT_DB_NAME_1};User Id=${ZOOTECH_DB_USER};Password=${ZOOTECH_DB_USER_PASSWORD};TrustServerCertificate=True;MultipleActiveResultSets=true;Pooling=True" \
      --usuarios "$ZOOTECH_TENANT_1_USUARIOS_NUMBER" \
      --granjas "$ZOOTECH_TENANT_1_GRANJAS_NUMBER" \
      --vacunos "$ZOOTECH_TENANT_1_VACUNOS_NUMBER" \
      --dias-ordenio "$ZOOTECH_TENANT_1_DIAS_ORDENIO_NUMBER" \
      --seed "$ZOOTECH_TENANT_1_SEED_NUMBER"


if [ -z "$ZOOTECH_TENANT_DB_NAME_2" ]; then
    echo "La variable ZOOTECH_TENANT_DB_NAME_2 no está definida o está vacía. Deteniendo."
    exit 0
fi

echo "Seed Base de Datos $ZOOTECH_TENANT_DB_NAME_2..."
dotnet ZooTech.DataSeeder.dll \
      --conn "Server=${ZOOTECH_DB_SQLSERVER_CONTAINER_NAME},1433;Database=${ZOOTECH_TENANT_DB_NAME_2};User Id=${ZOOTECH_DB_USER};Password=${ZOOTECH_DB_USER_PASSWORD};TrustServerCertificate=True;MultipleActiveResultSets=true;Pooling=True" \
      --usuarios "$ZOOTECH_TENANT_2_USUARIOS_NUMBER" \
      --granjas "$ZOOTECH_TENANT_2_GRANJAS_NUMBER" \
      --vacunos "$ZOOTECH_TENANT_2_VACUNOS_NUMBER" \
      --dias-ordenio "$ZOOTECH_TENANT_2_DIAS_ORDENIO_NUMBER" \
      --seed "$ZOOTECH_TENANT_2_SEED_NUMBER"


if [ -z "$ZOOTECH_TENANT_DB_NAME_3" ]; then
    echo "La variable ZOOTECH_TENANT_DB_NAME_3 no está definida o está vacía. Deteniendo."
    exit 0
fi

echo "Seed Base de Datos $ZOOTECH_TENANT_DB_NAME_3..."
dotnet ZooTech.DataSeeder.dll \
      --conn "Server=${ZOOTECH_DB_SQLSERVER_CONTAINER_NAME},1433;Database=${ZOOTECH_TENANT_DB_NAME_3};User Id=${ZOOTECH_DB_USER};Password=${ZOOTECH_DB_USER_PASSWORD};TrustServerCertificate=True;MultipleActiveResultSets=true;Pooling=True" \
      --usuarios "$ZOOTECH_TENANT_3_USUARIOS_NUMBER" \
      --granjas "$ZOOTECH_TENANT_3_GRANJAS_NUMBER" \
      --vacunos "$ZOOTECH_TENANT_3_VACUNOS_NUMBER" \
      --dias-ordenio "$ZOOTECH_TENANT_3_DIAS_ORDENIO_NUMBER" \
      --seed "$ZOOTECH_TENANT_3_SEED_NUMBER"