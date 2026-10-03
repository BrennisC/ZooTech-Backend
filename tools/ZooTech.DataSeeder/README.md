# ZooTech Data Seeder

Generador de datos masivos de prueba para una base de datos **tenant** de ZooTech,
sobre el esquema 3FN estricta (`ganaderia_3fn_cid_sqlserver2022.sql` /
`create-tenants.sql`, ambos estructuralmente equivalentes). Piensa en él como un
*job* que corres una vez por cada base de datos de organización (una por tenant,
según `tenant_database_connections`).

Antes de correr el seeder contra una base de un tenant, esa base ya debe tener:
1. El DDL del esquema (`create-tenants.sql` / `ganaderia_3fn_cid_sqlserver2022.sql`).
2. Los catálogos y la ubicación geográfica (`insert-common-info-in-tenants.sql`, con
   las variables `$(ZOOTECH_TENANT_ADDRESS_*)` resueltas por `sqlcmd`).

El seeder solo agrega datos transaccionales (`usuario`, `granja`, `vacuno` y lo que
depende de ellos) — nunca catálogos.

## Estrategia (resumen)

1. **Bogus** (`Faker`) genera los datos "de mentira" (nombres, fechas, pesos, litros, etc.),
   con una semilla fija (`--seed`) para que la carga sea reproducible.
2. **SqlBulkCopy** (`Microsoft.Data.SqlClient`) hace la inserción real. Es órdenes de
   magnitud más rápido que un `INSERT` por fila — miles de filas por segundo en vez
   de por minuto.
3. **Orden de siembra** respeta las FKs del modelo:
   `usuario` → `granja` → `vacuno` (fundadores sin padres, luego crías con
   `padre_id`/`madre_id` válidos), y junto con cada vacuno — en el mismo recorrido —
   su fila 1:1 en `vacuno_adquisicion` y su fila inicial en
   `vacuno_utilizacion_historial` (en el esquema 3FN esos datos ya NO están en la
   tabla `vacuno`). Después siguen `ordenio` / `triaje`, que dependen de `vacuno`.
4. **Resolución de IDs sin round-trips**: como el seeder corre en modo exclusivo
   (nadie más escribe a la vez), antes de cada bulk insert se lee el `MAX(id)` actual
   y se asignan en memoria los ids siguientes de forma contigua, en el mismo orden en
   que se insertan las filas. Así los `padre_id`, `madre_id`, `vacuno_id`, etc. ya se
   conocen sin tener que volver a consultar la base. Ver el comentario en
   `Infrastructure/BulkInsertExtensions.cs` para el detalle y la condición que lo
   garantiza.
5. **Catálogos**: el seeder nunca inventa `code`s de catálogo — los lee de las tablas
   `cat_*` que ya pobló `insert-common-info-in-tenants.sql` (`cat_raza`, `cat_color`,
   `cat_tipo_adquisicion`, `cat_tipo_utilizacion`, `cat_tipo_peso`). Si por algún
   motivo `geo_departamento/provincia/distrito` está vacío, se crea automáticamente
   un registro mínimo para poder continuar (normalmente ya viene poblado por ese
   mismo script, vía las variables `$(ZOOTECH_TENANT_ADDRESS_*)`).
6. **Checks de fecha**: el esquema 3FN agregó `CHECK (fecha_hora <= sysdatetime())`
   en `ordenio` y `triaje`, y `CHECK (fecha_adquisicion <= getdate())` en
   `vacuno_adquisicion`. El seeder genera siempre fechas pasadas y recorta (clamp)
   cualquier caso límite que pudiera caer en el futuro por redondeo de horas.

## Qué genera hoy

| Tabla     | Volumen aproximado                                             |
|-----------|------------------------------------------------------------------|
| usuario                      | `--usuarios` (default 20)                                        |
| granja                       | `--granjas` (default 8)                                           |
| vacuno                       | `--vacunos` (default 5000): ~20% fundadores, ~80% crías con padres |
| vacuno_adquisicion           | 1 fila por vacuno (misma oleada que `vacuno`); `precio_compra`/`proveedor` solo si `tipo_adquisicion_code = 'COMPRA'` |
| vacuno_utilizacion_historial | 1 fila inicial por vacuno (misma oleada que `vacuno`)             |
| ordenio                      | por cada vaca hembra adulta, ~1 registro/día durante `--dias-ordenio` (default 180), con ~15% de huecos realistas |
| triaje                       | por cada vacuno, 1 control de peso cada ~30 días desde su nacimiento (o el último año) |

Con los valores por defecto (5000 vacunos, 180 días de ordeño) esto ya genera
cientos de miles de filas en `ordenio` + `triaje` sin tocar código.

### Cómo seguir agregando tablas

El patrón es siempre el mismo (ver cualquier archivo en `Seeding/`):

1. `var startId = conn.GetCurrentMaxId("tabla") + 1;`
2. Armar un `DataTable` con `BulkInsertExtensions.NewTable(...)`.
3. Llenarlo iterando sobre la lista de `vacunos` (o lo que corresponda).
4. `conn.BulkInsert("tabla", table);`

Tablas naturales para extender con el mismo patrón: `celo_registro` (+ 
`celo_registro_caracteristica`, `celo_estado_vacuno`), `fecundacion` (+
`fecundacion_cria`), `incidente_vacuno`, `periodo_sequia`,
`vacuno_estado_historial`.

## Uso local

```bash
dotnet restore
dotnet run -- \
  --conn "Server=localhost,1433;Database=ZooTech_AltoHuallaga_Db;User Id=sa;Password=TuPasswordFuerte1;TrustServerCertificate=True" \
  --usuarios 15 --granjas 6 --vacunos 8000 --dias-ordenio 365 --seed 42
```

## Uso contra el SQL Server del docker-compose

Si tu `docker-compose.yml` expone el contenedor de SQL Server (por ejemplo el
`sql-init`/`sqlserver` que ya usa tu backend) en el puerto host `1433`, corres el
seeder **desde tu máquina** (no necesita estar dentro de Docker) apuntando a
`localhost,1433` con las credenciales que definiste en las variables de entorno del
contenedor.

Si prefieres correrlo como un servicio "one-off" dentro de la misma red de Docker
(por ejemplo para que un compañero no necesite el SDK de .NET instalado), agrega un
servicio con perfil aparte para no levantarlo con `docker compose up`:

```yaml
services:
  zootech-data-seeder:
    build:
      context: ./ZooTechDataSeeder
      dockerfile: Dockerfile
    profiles: ["seed"]     # no se levanta con "up" normal
    networks:
      - zootech-network
    depends_on:
      - sql-init
    entrypoint: >
      dotnet ZooTechDataSeeder.dll
      --conn "Server=sql-init,1433;Database=ZooTech_AltoHuallaga_Db;User Id=sa;Password=${SA_PASSWORD};TrustServerCertificate=True"
      --vacunos 8000
```

Y lo ejecutas puntualmente con:

```bash
docker compose --profile seed run --rm zootech-data-seeder
```

### Dockerfile sugerido (multi-stage, igual filosofía que tu frontend)

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "ZooTechDataSeeder.dll"]
```

## Corriendo el seeder para las 4 organizaciones nuevas

Cada organización tiene su propia base (`database_name` en
`tenant_database_connections`). Por cada una, en orden: `create-tenants.sql` (DDL),
`insert-common-info-in-tenants.sql` (catálogos + ubicación, con las variables
`$(ZOOTECH_TENANT_ADDRESS_*)` del tenant correspondiente) y por último el seeder:

```bash
for db in ZooTech_CentroSoporte_Db ZooTech_AltoHuallaga_Db ZooTech_Monzon_Db ZooTech_RioVerde_Db; do
  dotnet run -- --conn "Server=localhost,1433;Database=$db;User Id=sa;Password=TuPasswordFuerte1;TrustServerCertificate=True" \
    --vacunos 5000 --dias-ordenio 180 --seed 42
done
```
