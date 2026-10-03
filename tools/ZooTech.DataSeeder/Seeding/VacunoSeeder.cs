using System.Data;
using Bogus;
using Microsoft.Data.SqlClient;
using ZooTechDataSeeder.Infrastructure;

namespace ZooTechDataSeeder.Seeding;

public sealed record VacunoInfo(long Id, string Sexo, DateTime FechaNacimiento, long GranjaId);

public static class VacunoSeeder
{
    private const string Hembra = "HEMBRA";
    private const string Macho = "MACHO";

    /// <summary>
    /// Genera "cantidad" vacunos en dos oleadas:
    ///   - Oleada 1 (~20%): fundadores, sin padre_id/madre_id, edad adulta (2 a 6 anios).
    ///   - Oleada 2 (~80%): crias, con padre_id/madre_id tomados de la oleada 1 respetando sexo,
    ///     y fecha_nacimiento posterior a la de la madre (gestacion + margen).
    ///
    /// Desde el esquema "3FN estricta" (ganaderia_3fn_cid_sqlserver2022.sql / create-tenants.sql),
    /// la tabla "vacuno" ya NO tiene precio_compra, tipo_utilizacion_code ni
    /// fecha_registro_utilizacion: esos datos viven en dos tablas nuevas que este seeder
    /// llena en el mismo recorrido, fila a fila junto con cada vacuno:
    ///   - vacuno_adquisicion (PK = vacuno_id, 1 fila por vacuno)
    ///   - vacuno_utilizacion_historial (1 fila inicial por vacuno)
    ///
    /// Devuelve la info de cada vacuno insertado para que otros seeders (ordenio, triaje, celo)
    /// puedan generar datos coherentes sin volver a leer la base.
    /// </summary>
    public static List<VacunoInfo> Seed(
        SqlConnection conn,
        int cantidad,
        List<long> granjaIds,
        List<long> usuarioIds,
        CatalogContext catalogos,
        Faker faker)
    {
        var startId = conn.GetCurrentMaxId("vacuno") + 1;
        var now = DateTime.UtcNow;

        var vacunoTable = BulkInsertExtensions.NewTable(
            ("codigo", typeof(string)),
            ("nombre", typeof(string)),
            ("fecha_nacimiento", typeof(DateTime)),
            ("tipo_adquisicion_code", typeof(string)),
            ("raza_code", typeof(string)),
            ("color_code", typeof(string)),
            ("sexo_code", typeof(string)),
            ("padre_id", typeof(long)),
            ("madre_id", typeof(long)),
            ("granja_id", typeof(long)),
            ("observaciones", typeof(string)),
            ("fecha_registro", typeof(DateTime)),
            ("created_by", typeof(long)),
            ("created_at", typeof(DateTime)),
            ("updated_at", typeof(DateTime))
        );
        vacunoTable.Columns["padre_id"]!.AllowDBNull = true;
        vacunoTable.Columns["madre_id"]!.AllowDBNull = true;
        vacunoTable.Columns["observaciones"]!.AllowDBNull = true;

        // vacuno_adquisicion: PK = vacuno_id (no es IDENTITY), así que no necesita reserva de ids.
        var adquisicionTable = BulkInsertExtensions.NewTable(
            ("vacuno_id", typeof(long)),
            ("tipo_adquisicion_code", typeof(string)),
            ("precio_compra", typeof(decimal)),
            ("fecha_adquisicion", typeof(DateTime)),
            ("proveedor", typeof(string)),
            ("created_at", typeof(DateTime))
        );
        adquisicionTable.Columns["precio_compra"]!.AllowDBNull = true;
        adquisicionTable.Columns["proveedor"]!.AllowDBNull = true;

        // vacuno_utilizacion_historial SI tiene "id" IDENTITY, pero como nadie mas referencia
        // esos ids en este seeder, lo dejamos fuera del DataTable (igual que en "usuario",
        // "granja" y "vacuno") y que el motor lo autogenere.
        var utilizacionTable = BulkInsertExtensions.NewTable(
            ("vacuno_id", typeof(long)),
            ("tipo_utilizacion_code", typeof(string)),
            ("created_at", typeof(DateTime))
        );

        var founders = (int)Math.Round(cantidad * 0.2);
        var offspring = cantidad - founders;
        var result = new List<VacunoInfo>(cantidad);

        long nextId = startId;

        // --- Oleada 1: fundadores (adultos, sin padres registrados) ---
        var founderRecords = new List<VacunoInfo>(founders);

        for (var i = 0; i < founders; i++)
        {
            var id = nextId++;
            var sexo = faker.Random.Bool() ? Macho : Hembra;
            var fechaNacimiento = faker.Date.Between(now.AddYears(-6), now.AddYears(-2));
            var granjaId = faker.PickRandom(granjaIds);

            AddVacunoRow(vacunoTable, adquisicionTable, utilizacionTable, id, sexo, fechaNacimiento,
                granjaId, padreId: null, madreId: null, catalogos, usuarioIds, faker, now);

            var info = new VacunoInfo(id, sexo, fechaNacimiento, granjaId);
            founderRecords.Add(info);
            result.Add(info);
        }

        var machosFundadores = founderRecords.Where(f => f.Sexo == Macho).Select(f => f.Id).ToList();
        var hembrasFundadoras = founderRecords.Where(f => f.Sexo == Hembra).ToList();

        // Fallback por si el azar no genero al menos un macho/hembra fundador.
        if (machosFundadores.Count == 0) machosFundadores.Add(founderRecords[0].Id);
        if (hembrasFundadoras.Count == 0) hembrasFundadoras.Add(founderRecords[^1]);

        // --- Oleada 2: crias, con padre/madre validos y fecha posterior a la madre ---
        for (var i = 0; i < offspring; i++)
        {
            var id = nextId++;
            var madre = faker.PickRandom(hembrasFundadoras);
            var padreId = faker.PickRandom(machosFundadores);
            var sexo = faker.Random.Bool() ? Macho : Hembra;

            var fechaNacimiento = madre.FechaNacimiento.AddDays(faker.Random.Int(300, 1800));
            if (fechaNacimiento > now) fechaNacimiento = now.AddDays(-faker.Random.Int(1, 200));

            var granjaId = madre.GranjaId; // nace en el mismo fundo que la madre

            AddVacunoRow(vacunoTable, adquisicionTable, utilizacionTable, id, sexo, fechaNacimiento,
                granjaId, padreId, madre.Id, catalogos, usuarioIds, faker, now,
                tipoAdquisicionForzado: "NACIMIENTO");

            result.Add(new VacunoInfo(id, sexo, fechaNacimiento, granjaId));
        }

        conn.BulkInsert("vacuno", vacunoTable);
        conn.BulkInsert("vacuno_adquisicion", adquisicionTable);
        conn.BulkInsert("vacuno_utilizacion_historial", utilizacionTable);
        return result;
    }

    private static void AddVacunoRow(
        DataTable vacunoTable, DataTable adquisicionTable, DataTable utilizacionTable,
        long id, string sexo, DateTime fechaNacimiento, long granjaId,
        long? padreId, long? madreId, CatalogContext catalogos, List<long> usuarioIds,
        Faker faker, DateTime now, string? tipoAdquisicionForzado = null)
    {
        // "NACIMIENTO" (antes "NACIMIENTO_GRANJA") es el code vigente en cat_tipo_adquisicion
        // desde insert-common-info-in-tenants.sql; si por algun motivo no existe en el catalogo
        // cargado, caemos a uno aleatorio en vez de romper el insert.
        var tipoAdquisicion = tipoAdquisicionForzado is not null && catalogos.TipoAdquisicionCodes.Contains(tipoAdquisicionForzado)
            ? tipoAdquisicionForzado
            : faker.PickRandom(catalogos.TipoAdquisicionCodes);

        // ck_vacuno_adquisicion_fecha / vacuno.fecha_registro: no pueden ser futuras.
        var fechaAdquisicion = fechaNacimiento.AddDays(faker.Random.Int(0, 60));
        if (fechaAdquisicion > now) fechaAdquisicion = now;

        var vRow = vacunoTable.NewRow();
        vRow["codigo"] = $"VAC{id:D8}".Clamp(15);
        vRow["nombre"] = faker.Commerce.ProductAdjective().Clamp(100);
        vRow["fecha_nacimiento"] = fechaNacimiento.Date;
        vRow["tipo_adquisicion_code"] = tipoAdquisicion;
        vRow["raza_code"] = faker.PickRandom(catalogos.RazaCodes);
        vRow["color_code"] = faker.PickRandom(catalogos.ColorCodes);
        vRow["sexo_code"] = sexo;
        vRow["padre_id"] = (object?)padreId ?? DBNull.Value;
        vRow["madre_id"] = (object?)madreId ?? DBNull.Value;
        vRow["granja_id"] = granjaId;
        vRow["observaciones"] = faker.Random.Bool(0.3f) ? faker.Lorem.Sentence().Clamp(150) : (object)DBNull.Value;
        vRow["fecha_registro"] = fechaAdquisicion.Date;
        vRow["created_by"] = faker.PickRandom(usuarioIds);
        vRow["created_at"] = now;
        vRow["updated_at"] = now;
        vacunoTable.Rows.Add(vRow);

        // ck_vacuno_adquisicion_precio: NULL o > 0 (ya no se usa 0 como "sin precio").
        var aRow = adquisicionTable.NewRow();
        aRow["vacuno_id"] = id;
        aRow["tipo_adquisicion_code"] = tipoAdquisicion;
        aRow["precio_compra"] = tipoAdquisicion == "COMPRA"
            ? (object)Math.Round(faker.Random.Decimal(800, 4500), 2)
            : DBNull.Value;
        aRow["fecha_adquisicion"] = fechaAdquisicion.Date;
        aRow["proveedor"] = tipoAdquisicion == "COMPRA"
            ? (object)faker.Company.CompanyName().Clamp(150)
            : DBNull.Value;
        aRow["created_at"] = now;
        adquisicionTable.Rows.Add(aRow);

        utilizacionTable.Rows.Add(id, faker.PickRandom(catalogos.TipoUtilizacionCodes), now);
    }
}
