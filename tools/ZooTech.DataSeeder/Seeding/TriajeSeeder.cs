using Bogus;
using Microsoft.Data.SqlClient;
using ZooTechDataSeeder.Infrastructure;

namespace ZooTechDataSeeder.Seeding;

public static class TriajeSeeder
{
    /// <summary>
    /// Genera controles de peso periodicos (cada ~30 dias) para todos los vacunos vivos,
    /// desde su nacimiento (o el inicio de la ventana de historia) hasta hoy.
    /// </summary>
    public static void Seed(SqlConnection conn, List<VacunoInfo> vacunos, List<long> usuarioIds,
        CatalogContext catalogos, Faker faker)
    {
        var startId = conn.GetCurrentMaxId("triaje") + 1;
        var now = DateTime.UtcNow;
        long nextId = startId;

        var table = BulkInsertExtensions.NewTable(
            ("codigo", typeof(string)),
            ("fecha_hora", typeof(DateTime)),
            ("vacuno_id", typeof(long)),
            ("tipo_peso_code", typeof(string)),
            ("peso_kg", typeof(decimal)),
            ("encargado_usuario_id", typeof(long)),
            ("created_at", typeof(DateTime)),
            ("updated_at", typeof(DateTime))
        );

        foreach (var vaca in vacunos)
        {
            var inicio = vaca.FechaNacimiento < now.AddYears(-1) ? now.AddYears(-1) : vaca.FechaNacimiento;
            var pesoBase = faker.Random.Decimal(35, 60); // peso aproximado de nacimiento/inicio

            for (var fecha = inicio; fecha < now; fecha = fecha.AddDays(30))
            {
                var id = nextId++;
                // Incremento de peso simulado a lo largo del tiempo (crecimiento acumulado).
                pesoBase += faker.Random.Decimal(3, 15);

                // ck_triaje_fecha (nuevo en el esquema 3FN): fecha_hora <= sysdatetime().
                var fechaHora = fecha.AddHours(faker.Random.Int(7, 16));
                if (fechaHora > now) fechaHora = now.AddMinutes(-5);

                table.Rows.Add(
                    $"TRJ{id:D8}".Clamp(15),
                    fechaHora,
                    vaca.Id,
                    faker.PickRandom(catalogos.TipoPesoCodes),
                    Math.Round(pesoBase, 2),
                    faker.PickRandom(usuarioIds),
                    now,
                    now
                );
            }
        }

        conn.BulkInsert("triaje", table);
    }
}
